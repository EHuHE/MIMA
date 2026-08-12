"""Deterministic replay of the two retained candidate recipe families."""

from __future__ import annotations

from pathlib import Path
from typing import Any, Mapping

from .core import (
    VerificationError,
    analyze_spec,
    canonical_json_bytes,
    clone_spec,
    graph_sha256,
    load_json_object,
    recipe_sha256,
    sha256_bytes,
    sha256_file,
    truth_signatures,
)
from .vhdl import render_vhdl


def _gate_by_output(spec: Mapping[str, Any], output: str) -> Mapping[str, Any]:
    matches = [gate for gate in spec["gates"] if gate["out"] == output]
    if len(matches) != 1:
        raise VerificationError(f"expected one gate driving {output}, found {len(matches)}")
    return matches[0]


def _apply_ablation(spec: dict[str, Any], parameters: Mapping[str, Any]) -> None:
    output = parameters.get("output")
    old_gate = parameters.get("old_gate")
    new_gate = parameters.get("new_gate")
    pruned = parameters.get("pruned_outputs")
    if (
        not isinstance(output, str)
        or not isinstance(old_gate, Mapping)
        or not isinstance(new_gate, Mapping)
        or not isinstance(pruned, list)
        or any(not isinstance(net, str) for net in pruned)
    ):
        raise VerificationError("invalid ablation recipe parameters")
    gate = _gate_by_output(spec, output)
    if gate.get("type") != old_gate.get("type") or gate.get("in") != old_gate.get("inputs"):
        raise VerificationError("ablation old_gate does not match parent")
    gate["type"] = new_gate.get("type")
    gate["in"] = new_gate.get("inputs")
    existing = {item["out"] for item in spec["gates"]}
    if any(net not in existing for net in pruned):
        raise VerificationError("ablation pruned output is absent from parent")
    spec["gates"] = [gate for gate in spec["gates"] if gate["out"] not in pruned]
    referenced = {net for item in spec["gates"] for net in item["in"]} | set(
        spec["outputs"].values()
    )
    dangling = sorted(set(pruned) & referenced)
    if dangling:
        raise VerificationError(f"pruned outputs remain referenced: {dangling}")


def _apply_cse(spec: dict[str, Any], operations: Any) -> None:
    if not isinstance(operations, list) or not operations:
        raise VerificationError("CSE recipe operations must be a non-empty list")
    for operation in operations:
        if not isinstance(operation, Mapping):
            raise VerificationError("CSE operation must be an object")
        removed = operation.get("removed")
        survivor = operation.get("survivor")
        if not isinstance(removed, str) or not isinstance(survivor, str):
            raise VerificationError("CSE operation requires removed and survivor nets")
        signatures = truth_signatures(spec)
        if removed not in signatures or survivor not in signatures:
            raise VerificationError("CSE operation references an unknown net")
        if signatures[removed] != signatures[survivor]:
            raise VerificationError(f"CSE nets are not truth-equivalent: {removed}, {survivor}")
        _gate_by_output(spec, removed)
        for gate in spec["gates"]:
            gate["in"] = [survivor if net == removed else net for net in gate["in"]]
        spec["outputs"] = {
            name: survivor if net == removed else net for name, net in spec["outputs"].items()
        }
        spec["gates"] = [gate for gate in spec["gates"] if gate["out"] != removed]


def replay_candidate(parent_dir: Path, child_dir: Path) -> tuple[dict[str, Any], bytes, bytes]:
    """Replay a child from its direct parent and verify every stable content hash."""

    if parent_dir.is_symlink() or child_dir.is_symlink():
        raise VerificationError("candidate directories must not be symbolic links")
    parent_dir = parent_dir.resolve()
    child_dir = child_dir.resolve()
    parent_spec = load_json_object(parent_dir / "theory.json", "parent theory")
    parent_metadata = load_json_object(parent_dir / "metadata.json", "parent metadata")
    load_json_object(child_dir / "theory.json", "child theory")
    child_metadata = load_json_object(child_dir / "metadata.json", "child metadata")
    recipe = child_metadata.get("recipe")
    if not isinstance(recipe, Mapping):
        raise VerificationError("child metadata recipe is missing")
    if recipe_sha256(recipe) != child_metadata.get("recipe_sha256"):
        raise VerificationError("child recipe hash mismatch")
    if recipe.get("parent_candidate_id") != parent_metadata.get("candidate_id"):
        raise VerificationError("recipe parent candidate id mismatch")
    parent_graph = graph_sha256(parent_spec)
    if parent_graph != parent_metadata.get("graph_sha256") or parent_graph != recipe.get(
        "parent_graph_sha256"
    ):
        raise VerificationError("recipe parent graph hash mismatch")

    generated = clone_spec(parent_spec)
    family = recipe.get("family")
    if family == "componentwise_parent_944_resub20_single_ablation":
        parameters = recipe.get("parameters")
        if not isinstance(parameters, Mapping):
            raise VerificationError("ablation recipe parameters are missing")
        _apply_ablation(generated, parameters)
        suffix = str(child_metadata["candidate_id"]).rsplit("_", 1)[-1]
        generated["name"] = (
            f"apn_sbox_diag_cw20_single_{parameters.get('replacement_index')}_{suffix}"
        )
    elif family is None and "operations" in recipe:
        _apply_cse(generated, recipe.get("operations"))
        generated["name"] = f"apn_sbox_{child_metadata['candidate_id']}"
    else:
        raise VerificationError(f"unsupported recipe family: {family}")

    analysis = analyze_spec(generated, check_claim=False)
    generated["claimed_d_theory_ps"] = analysis["D_theory_ps"]
    theory_bytes = canonical_json_bytes(generated)
    vhdl_bytes = render_vhdl(generated)
    checks = {
        "graph_sha256": graph_sha256(generated),
        "theory_json_sha256": sha256_bytes(theory_bytes),
        "sb_vhd_sha256": sha256_bytes(vhdl_bytes),
    }
    for field, value in checks.items():
        if child_metadata.get(field) != value:
            raise VerificationError(f"replayed {field} mismatch")
    if theory_bytes != (child_dir / "theory.json").read_bytes():
        raise VerificationError("replayed theory bytes differ from tracked child")
    if vhdl_bytes != (child_dir / "SB.vhd").read_bytes():
        raise VerificationError("replayed VHDL bytes differ from tracked child")

    return (
        {
            "candidate_id": child_metadata["candidate_id"],
            "parent_candidate_id": parent_metadata["candidate_id"],
            "recipe_family": family or "cross_output_cse",
            "status": "PASS",
            "validation": {
                "function_64": "PASS",
                "graph_hash": "PASS",
                "parent_binding": "PASS",
                "recipe_hash": "PASS",
                "theory_bytes": "PASS",
                "vhdl_bytes": "PASS",
            },
            **checks,
            "parent_theory_json_sha256": sha256_file(parent_dir / "theory.json"),
        },
        theory_bytes,
        vhdl_bytes,
    )
