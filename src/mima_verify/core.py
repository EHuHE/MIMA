"""Strict, dependency-free verification of MIMA theory candidates."""

from __future__ import annotations

import copy
import hashlib
import json
import re
from collections import deque
from decimal import Decimal
from pathlib import Path
from typing import Any, Mapping, Sequence


class VerificationError(ValueError):
    """Raised when a candidate cannot satisfy the verification contract."""


GATE_DELAY_PS: dict[str, Decimal] = {
    "INV": Decimal("22.048"),
    "BUF": Decimal("33.557"),
    "NAND2": Decimal("27.886"),
    "NOR2": Decimal("40.650"),
    "AND2": Decimal("40.171"),
    "OR2": Decimal("56.414"),
    "XOR2": Decimal("73.019"),
    "XNOR2": Decimal("57.604"),
    "NAND3": Decimal("34.767"),
    "OAI21": Decimal("32.651"),
    "AOI21": Decimal("51.619"),
    "NOR3": Decimal("61.543"),
    "AND3": Decimal("51.869"),
    "OR3": Decimal("85.840"),
    "MUX2": Decimal("75.175"),
    "OAI22": Decimal("54.596"),
    "AOI22": Decimal("57.255"),
    "NAND4": Decimal("44.487"),
    "NOR4": Decimal("91.313"),
    "AND4": Decimal("65.492"),
    "OR4": Decimal("118.592"),
}

GATE_ARITY: dict[str, int] = {
    "INV": 1,
    "BUF": 1,
    "NAND2": 2,
    "NOR2": 2,
    "AND2": 2,
    "OR2": 2,
    "XOR2": 2,
    "XNOR2": 2,
    "NAND3": 3,
    "OAI21": 3,
    "AOI21": 3,
    "NOR3": 3,
    "AND3": 3,
    "OR3": 3,
    "MUX2": 3,
    "OAI22": 4,
    "AOI22": 4,
    "NAND4": 4,
    "NOR4": 4,
    "AND4": 4,
    "OR4": 4,
}

TARGET_SBOX: tuple[int, ...] = (
    0x00,
    0x36,
    0x30,
    0x0D,
    0x0F,
    0x12,
    0x35,
    0x23,
    0x19,
    0x3F,
    0x2D,
    0x34,
    0x03,
    0x14,
    0x29,
    0x21,
    0x3B,
    0x24,
    0x02,
    0x22,
    0x0A,
    0x08,
    0x39,
    0x25,
    0x3C,
    0x13,
    0x2A,
    0x0E,
    0x32,
    0x1A,
    0x3A,
    0x18,
    0x27,
    0x1B,
    0x15,
    0x11,
    0x10,
    0x1D,
    0x01,
    0x3E,
    0x2F,
    0x28,
    0x33,
    0x38,
    0x07,
    0x2B,
    0x2C,
    0x26,
    0x1F,
    0x0B,
    0x04,
    0x1C,
    0x3D,
    0x2E,
    0x05,
    0x31,
    0x09,
    0x06,
    0x17,
    0x20,
    0x1E,
    0x0C,
    0x37,
    0x16,
)

IDENTIFIER_RE = re.compile(r"[A-Za-z][A-Za-z0-9_]*\Z")
CLAIM_TOLERANCE_PS = Decimal("0.000001")


def canonical_json_bytes(value: Any) -> bytes:
    """Return the canonical JSON encoding used by the candidate metadata."""

    return (
        json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":")) + "\n"
    ).encode("utf-8")


def sha256_bytes(value: bytes) -> str:
    return hashlib.sha256(value).hexdigest()


def sha256_file(path: Path) -> str:
    if not path.is_file() or path.is_symlink():
        raise VerificationError(f"required regular file is unavailable: {path}")
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def load_json_object(path: Path, label: str) -> dict[str, Any]:
    if not path.is_file() or path.is_symlink():
        raise VerificationError(f"{label} must be a regular file: {path}")
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise VerificationError(f"invalid JSON in {label}: {path}") from exc
    if not isinstance(value, dict):
        raise VerificationError(f"{label} must contain a JSON object")
    return value


def graph_sha256(spec: Mapping[str, Any]) -> str:
    return sha256_bytes(canonical_json_bytes({"gates": spec["gates"], "outputs": spec["outputs"]}))


def recipe_sha256(recipe: Mapping[str, Any]) -> str:
    return sha256_bytes(canonical_json_bytes(recipe))


def _require_int(value: Any, expected: int, label: str) -> None:
    if type(value) is not int or value != expected:
        raise VerificationError(f"{label} must equal {expected}")


def validate_structure(
    spec: Mapping[str, Any],
) -> tuple[list[str], dict[str, Mapping[str, Any]], dict[str, str]]:
    """Validate schema, net ownership, legal gates and acyclicity."""

    _require_int(spec.get("n_inputs"), 6, "n_inputs")
    _require_int(spec.get("n_outputs"), 6, "n_outputs")
    target = spec.get("target")
    if not isinstance(target, Mapping) or target.get("mode") != "fixed_s0_6bit":
        raise VerificationError("target.mode must be fixed_s0_6bit")
    gates = spec.get("gates")
    outputs = spec.get("outputs")
    if not isinstance(gates, list) or not gates:
        raise VerificationError("gates must be a non-empty list")
    if not isinstance(outputs, Mapping):
        raise VerificationError("outputs must be an object")

    primary_inputs = {f"x{index}" for index in range(6)}
    expected_outputs = {f"y{index}" for index in range(6)}
    if set(outputs) != expected_outputs:
        raise VerificationError("outputs must contain exactly y0 through y5")

    gate_by_id: dict[str, Mapping[str, Any]] = {}
    driver: dict[str, str] = {}
    gate_order: dict[str, int] = {}
    for index, value in enumerate(gates):
        if not isinstance(value, Mapping):
            raise VerificationError(f"gate {index} must be an object")
        gate = value
        gate_id = gate.get("id")
        gate_type = gate.get("type")
        gate_out = gate.get("out")
        gate_inputs = gate.get("in")
        if not isinstance(gate_id, str) or IDENTIFIER_RE.fullmatch(gate_id) is None:
            raise VerificationError(f"gate {index} has an invalid id")
        if gate_id in gate_by_id:
            raise VerificationError(f"duplicate gate id: {gate_id}")
        if gate_type not in GATE_ARITY:
            raise VerificationError(f"illegal gate type on {gate_id}: {gate_type}")
        if not isinstance(gate_out, str) or IDENTIFIER_RE.fullmatch(gate_out) is None:
            raise VerificationError(f"gate {gate_id} has an invalid output net")
        if gate_out in primary_inputs:
            raise VerificationError(f"gate {gate_id} drives primary input {gate_out}")
        if gate_out in driver:
            raise VerificationError(
                f"multiple drivers on {gate_out}: {driver[gate_out]} and {gate_id}"
            )
        if (
            not isinstance(gate_inputs, list)
            or len(gate_inputs) != GATE_ARITY[gate_type]
            or any(
                not isinstance(net, str) or IDENTIFIER_RE.fullmatch(net) is None
                for net in gate_inputs
            )
        ):
            raise VerificationError(f"gate {gate_id} requires {GATE_ARITY[gate_type]} valid inputs")
        gate_by_id[gate_id] = gate
        gate_order[gate_id] = index
        driver[gate_out] = gate_id

    for output_name, net in outputs.items():
        if not isinstance(net, str) or net not in driver | {key: key for key in primary_inputs}:
            raise VerificationError(f"output {output_name} references undefined net {net}")

    successors: dict[str, list[str]] = {gate_id: [] for gate_id in gate_by_id}
    indegree: dict[str, int] = {gate_id: 0 for gate_id in gate_by_id}
    for gate_id, gate in gate_by_id.items():
        for net in gate["in"]:
            if net in driver:
                predecessor = driver[net]
                successors[predecessor].append(gate_id)
                indegree[gate_id] += 1
            elif net not in primary_inputs:
                raise VerificationError(f"gate {gate_id} uses undefined net {net}")

    ready = deque(gate_id for gate_id in gate_by_id if indegree[gate_id] == 0)
    topo: list[str] = []
    while ready:
        gate_id = ready.popleft()
        topo.append(gate_id)
        for successor in sorted(successors[gate_id], key=gate_order.__getitem__):
            indegree[successor] -= 1
            if indegree[successor] == 0:
                ready.append(successor)
    if len(topo) != len(gates):
        raise VerificationError("combinational cycle detected")
    return topo, gate_by_id, driver


def evaluate_gate(gate_type: str, inputs: Sequence[int]) -> int:
    if gate_type == "INV":
        return 1 - inputs[0]
    if gate_type == "BUF":
        return inputs[0]
    if gate_type.startswith("NAND"):
        return 1 - int(all(inputs))
    if gate_type.startswith("NOR"):
        return 1 - int(any(inputs))
    if gate_type.startswith("AND"):
        return int(all(inputs))
    if gate_type.startswith("OR"):
        return int(any(inputs))
    if gate_type == "XOR2":
        return inputs[0] ^ inputs[1]
    if gate_type == "XNOR2":
        return 1 - (inputs[0] ^ inputs[1])
    if gate_type == "AOI21":
        return 1 - ((inputs[0] & inputs[1]) | inputs[2])
    if gate_type == "OAI21":
        return 1 - ((inputs[0] | inputs[1]) & inputs[2])
    if gate_type == "AOI22":
        return 1 - ((inputs[0] & inputs[1]) | (inputs[2] & inputs[3]))
    if gate_type == "OAI22":
        return 1 - ((inputs[0] | inputs[1]) & (inputs[2] | inputs[3]))
    if gate_type == "MUX2":
        return inputs[0] if inputs[2] == 0 else inputs[1]
    raise VerificationError(f"unsupported gate semantics: {gate_type}")


def evaluate_vector(
    spec: Mapping[str, Any],
    topo: Sequence[str],
    gate_by_id: Mapping[str, Mapping[str, Any]],
    input_value: int,
) -> dict[str, int]:
    environment = {f"x{index}": (input_value >> index) & 1 for index in range(6)}
    for gate_id in topo:
        gate = gate_by_id[gate_id]
        environment[gate["out"]] = evaluate_gate(
            gate["type"], [environment[net] for net in gate["in"]]
        )
    return environment


def truth_signatures(spec: Mapping[str, Any]) -> dict[str, int]:
    """Return a 64-bit truth signature for every primary and internal net."""

    topo, gate_by_id, _driver = validate_structure(spec)
    signatures: dict[str, int] = {}
    for input_value in range(64):
        environment = evaluate_vector(spec, topo, gate_by_id, input_value)
        for net, bit in environment.items():
            signatures[net] = signatures.get(net, 0) | (bit << input_value)
    return signatures


def analyze_spec(spec: Mapping[str, Any], *, check_claim: bool = True) -> dict[str, Any]:
    """Run all structural, exhaustive functional and delay checks."""

    topo, gate_by_id, _driver = validate_structure(spec)
    outputs = spec["outputs"]
    observed: list[int] = []
    for input_value in range(64):
        environment = evaluate_vector(spec, topo, gate_by_id, input_value)
        result = sum(environment[outputs[f"y{index}"]] << index for index in range(6))
        observed.append(result)
        expected = TARGET_SBOX[input_value]
        if result != expected:
            raise VerificationError(
                f"truth-table mismatch at 0x{input_value:02x}: "
                f"expected 0x{expected:02x}, got 0x{result:02x}"
            )

    arrival = {f"x{index}": Decimal(0) for index in range(6)}
    predecessor: dict[str, str | None] = {f"x{index}": None for index in range(6)}
    for gate_id in topo:
        gate = gate_by_id[gate_id]
        input_times = [arrival[net] for net in gate["in"]]
        maximum = max(input_times)
        maximum_index = input_times.index(maximum)
        arrival[gate["out"]] = maximum + GATE_DELAY_PS[gate["type"]]
        predecessor[gate["out"]] = gate["in"][maximum_index]

    output_delays = {f"y{index}": arrival[outputs[f"y{index}"]] for index in range(6)}
    critical_output = max(output_delays, key=output_delays.__getitem__)
    theory_delay = output_delays[critical_output]
    path: list[str] = []
    net: str | None = outputs[critical_output]
    while net is not None:
        path.append(net)
        net = predecessor[net]
    path.reverse()

    if check_claim:
        claimed_value = spec.get("claimed_d_theory_ps")
        try:
            claimed = Decimal(str(claimed_value))
        except Exception as exc:
            raise VerificationError("claimed_d_theory_ps must be numeric") from exc
        if not claimed.is_finite() or abs(claimed - theory_delay) > CLAIM_TOLERANCE_PS:
            raise VerificationError(
                f"claimed delay {claimed_value} differs from computed {theory_delay} ps"
            )

    return {
        "D_theory_ps": float(theory_delay),
        "critical_output": critical_output,
        "critical_path_nets": path,
        "critical_source_input": path[0],
        "gate_count": len(spec["gates"]),
        "graph_sha256": graph_sha256(spec),
        "output_delays_ps": {name: float(delay) for name, delay in sorted(output_delays.items())},
        "truth_table_checked": len(observed),
    }


def verify_candidate(
    theory_path: Path,
    *,
    metadata_path: Path | None = None,
    vhdl_path: Path | None = None,
) -> dict[str, Any]:
    """Verify one candidate and bind the report to its recorded hashes."""

    if theory_path.is_symlink():
        raise VerificationError("theory candidate must not be a symbolic link")
    theory_path = theory_path.resolve()
    spec = load_json_object(theory_path, "theory candidate")
    analysis = analyze_spec(spec)
    theory_digest = sha256_file(theory_path)
    report: dict[str, Any] = {
        **analysis,
        "candidate_id": None,
        "status": "PASS",
        "theory_json_sha256": theory_digest,
        "validation": {
            "allowed_gate_types": "PASS",
            "dag": "PASS",
            "function_64": "PASS",
            "pure_combinational": "PASS",
            "single_driver": "PASS",
            "structure": "PASS",
            "theory": "PASS",
        },
    }

    metadata: dict[str, Any] | None = None
    if metadata_path is not None:
        if metadata_path.is_symlink():
            raise VerificationError("candidate metadata must not be a symbolic link")
        metadata_path = metadata_path.resolve()
        metadata = load_json_object(metadata_path, "candidate metadata")
        candidate_id = metadata.get("candidate_id")
        if not isinstance(candidate_id, str) or not candidate_id:
            raise VerificationError("metadata candidate_id is missing")
        expected = {
            "graph_sha256": analysis["graph_sha256"],
            "theory_json_sha256": theory_digest,
        }
        for field, actual in expected.items():
            if metadata.get(field) != actual:
                raise VerificationError(
                    f"metadata {field} mismatch: {metadata.get(field)} != {actual}"
                )
        recipe = metadata.get("recipe")
        if isinstance(recipe, Mapping):
            digest = recipe_sha256(recipe)
            if metadata.get("recipe_sha256") != digest:
                raise VerificationError("metadata recipe_sha256 mismatch")
        if "pure_combinational" in metadata and metadata.get("pure_combinational") is not True:
            raise VerificationError("metadata contradicts pure_combinational verification")
        report["candidate_id"] = candidate_id
        report["metadata_sha256"] = sha256_file(metadata_path)
        report["validation"]["metadata_hashes"] = "PASS"

    if vhdl_path is not None:
        from .vhdl import render_vhdl

        if vhdl_path.is_symlink():
            raise VerificationError("candidate VHDL must not be a symbolic link")
        vhdl_path = vhdl_path.resolve()
        rendered = render_vhdl(spec)
        actual = vhdl_path.read_bytes()
        if actual != rendered:
            raise VerificationError("tracked VHDL is not the deterministic theory rendering")
        vhdl_digest = sha256_bytes(actual)
        if metadata is not None and metadata.get("sb_vhd_sha256") != vhdl_digest:
            raise VerificationError("metadata sb_vhd_sha256 mismatch")
        report["sb_vhd_sha256"] = vhdl_digest
        report["validation"]["theory_vhdl_roundtrip"] = "PASS"

    return report


def clone_spec(spec: Mapping[str, Any]) -> dict[str, Any]:
    """Make a type-narrowed deep copy for deterministic recipe transforms."""

    value = copy.deepcopy(spec)
    if not isinstance(value, dict):
        raise VerificationError("theory candidate must be an object")
    return value
