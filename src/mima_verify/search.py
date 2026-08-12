"""Small, deterministic CSE search used to demonstrate the project method."""

from __future__ import annotations

import copy
from collections import defaultdict
from pathlib import Path
from typing import Any, Mapping

from .core import VerificationError, analyze_spec, load_json_object, truth_signatures


def _replace_net(spec: Mapping[str, Any], removed: str, survivor: str) -> dict[str, Any]:
    candidate = copy.deepcopy(spec)
    candidate["gates"] = [gate for gate in candidate["gates"] if gate["out"] != removed]
    for gate in candidate["gates"]:
        gate["in"] = [survivor if net == removed else net for net in gate["in"]]
    candidate["outputs"] = {
        name: survivor if net == removed else net for name, net in candidate["outputs"].items()
    }
    return candidate


def search_equivalent_net_cse(spec: Mapping[str, Any], *, limit: int = 20) -> list[dict[str, Any]]:
    """Enumerate safe one-net CSE substitutions and rank without STA guesses."""

    if limit <= 0:
        raise VerificationError("limit must be positive")
    baseline = analyze_spec(spec)
    signatures = truth_signatures(spec)
    groups: dict[int, list[str]] = defaultdict(list)
    for gate in spec["gates"]:
        groups[signatures[gate["out"]]].append(gate["out"])

    results: list[dict[str, Any]] = []
    for nets in groups.values():
        if len(nets) < 2:
            continue
        for removed in nets:
            for survivor in nets:
                if removed == survivor:
                    continue
                candidate = _replace_net(spec, removed, survivor)
                try:
                    report = analyze_spec(candidate, check_claim=False)
                except VerificationError:
                    continue
                results.append(
                    {
                        "D_sta_ns": "NOT_RUN",
                        "D_theory_ps": report["D_theory_ps"],
                        "baseline_D_theory_ps": baseline["D_theory_ps"],
                        "gate_count": report["gate_count"],
                        "graph_sha256": report["graph_sha256"],
                        "operation": {"removed": removed, "survivor": survivor},
                        "status": "STATIC_SCREEN_PASS_STA_NOT_RUN",
                    }
                )
    results.sort(
        key=lambda item: (
            item["D_theory_ps"],
            item["gate_count"],
            item["operation"]["removed"],
            item["operation"]["survivor"],
        )
    )
    return results[:limit]


def search_file(path: Path, *, limit: int = 20) -> dict[str, Any]:
    spec = load_json_object(path.resolve(), "search parent theory")
    baseline = analyze_spec(spec)
    results = search_equivalent_net_cse(spec, limit=limit)
    return {
        "algorithm": "equivalent-net-single-cse",
        "baseline": {
            "D_theory_ps": baseline["D_theory_ps"],
            "gate_count": baseline["gate_count"],
            "graph_sha256": baseline["graph_sha256"],
        },
        "candidate_count_returned": len(results),
        "candidates": results,
        "scope": "single safe truth-equivalent net substitution",
        "status": "PASS",
    }
