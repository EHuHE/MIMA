"""Console entry points for verification, replay, simulation and release audit."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Sequence

from .core import VerificationError, verify_candidate
from .ghdl import simulate_vhdl
from .recipe import replay_candidate
from .release_audit import audit_tracked_tree
from .search import search_file


def _print(value: Any) -> None:
    print(json.dumps(value, ensure_ascii=False, indent=2, sort_keys=True))


def _fail(exc: Exception) -> int:
    _print({"error": str(exc), "status": "FAIL"})
    return 2


def verify_main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="mima-verify",
        description="Exhaustively verify a fixed 6-bit MIMA theory candidate.",
    )
    parser.add_argument("theory_json", type=Path)
    parser.add_argument("--metadata", type=Path)
    parser.add_argument("--vhdl", type=Path)
    args = parser.parse_args(argv)
    candidate_dir = args.theory_json.absolute().parent
    metadata = args.metadata
    vhdl = args.vhdl
    if metadata is None and (candidate_dir / "metadata.json").is_file():
        metadata = candidate_dir / "metadata.json"
    if vhdl is None and (candidate_dir / "SB.vhd").is_file():
        vhdl = candidate_dir / "SB.vhd"
    try:
        _print(
            verify_candidate(
                args.theory_json,
                metadata_path=metadata,
                vhdl_path=vhdl,
            )
        )
    except (OSError, VerificationError) as exc:
        return _fail(exc)
    return 0


def replay_main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="mima-replay-recipe",
        description="Replay a retained child candidate from its direct parent.",
    )
    parser.add_argument("parent_dir", type=Path)
    parser.add_argument("child_dir", type=Path)
    parser.add_argument("--output-dir", type=Path)
    args = parser.parse_args(argv)
    try:
        report, theory_bytes, vhdl_bytes = replay_candidate(args.parent_dir, args.child_dir)
        if args.output_dir is not None:
            output_dir = args.output_dir.resolve()
            if output_dir.exists() or output_dir.is_symlink():
                raise VerificationError("output directory must not already exist")
            output_dir.mkdir(parents=True)
            (output_dir / "theory.json").write_bytes(theory_bytes)
            (output_dir / "SB.vhd").write_bytes(vhdl_bytes)
            report["output_dir"] = str(output_dir)
        _print(report)
    except (OSError, VerificationError) as exc:
        return _fail(exc)
    return 0


def audit_main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="mima-release-audit",
        description="Audit the exact Git index before publication.",
    )
    parser.add_argument("--root", type=Path, default=Path.cwd())
    args = parser.parse_args(argv)
    try:
        report = audit_tracked_tree(args.root)
        _print(report)
    except (OSError, VerificationError) as exc:
        return _fail(exc)
    return 0 if report["status"] == "PASS" else 2


def simulate_main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="mima-simulate",
        description="Exhaustively simulate candidate SB.vhd with GHDL.",
    )
    parser.add_argument("candidate_vhdl", type=Path)
    parser.add_argument("--ghdl")
    parser.add_argument("--timeout-s", type=int, default=120)
    args = parser.parse_args(argv)
    try:
        report = simulate_vhdl(
            args.candidate_vhdl,
            ghdl_binary=args.ghdl,
            timeout_seconds=args.timeout_s,
        )
        _print(report)
    except (OSError, VerificationError) as exc:
        return _fail(exc)
    return 0 if report["status"] in {"PASS", "NOT_RUN"} else 2


def search_main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        prog="mima-search-cse",
        description="Enumerate deterministic truth-equivalent single-net CSE moves.",
    )
    parser.add_argument("theory_json", type=Path)
    parser.add_argument("--limit", type=int, default=20)
    args = parser.parse_args(argv)
    try:
        _print(search_file(args.theory_json, limit=args.limit))
    except (OSError, VerificationError) as exc:
        return _fail(exc)
    return 0


def main(argv: Sequence[str] | None = None) -> int:
    parser = argparse.ArgumentParser(prog="python -m mima_verify")
    parser.add_argument("command", choices=("verify", "replay", "audit", "simulate", "search"))
    args, remaining = parser.parse_known_args(argv)
    return {
        "verify": verify_main,
        "replay": replay_main,
        "audit": audit_main,
        "simulate": simulate_main,
        "search": search_main,
    }[args.command](remaining)


if __name__ == "__main__":
    raise SystemExit(main())
