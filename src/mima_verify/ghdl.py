"""Optional exhaustive VHDL simulation using a caller-provided GHDL binary."""

from __future__ import annotations

import shutil
import subprocess
import tempfile
from pathlib import Path

from .core import VerificationError, sha256_file


def _run(command: list[str], timeout_seconds: int) -> None:
    try:
        result = subprocess.run(
            command,
            check=False,
            stdout=subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            timeout=timeout_seconds,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise VerificationError(f"GHDL invocation failed: {command[0]}") from exc
    if result.returncode != 0:
        tail = "\n".join(result.stdout.splitlines()[-20:])
        raise VerificationError(f"GHDL returned {result.returncode}:\n{tail}")


def _find_simulation_support(candidate_vhdl: Path) -> tuple[Path, Path]:
    search_starts = (candidate_vhdl.parent, Path.cwd(), Path(__file__).resolve().parent)
    visited: set[Path] = set()
    for start in search_starts:
        for root in (start, *start.parents):
            root = root.resolve()
            if root in visited:
                continue
            visited.add(root)
            support = root / "hdl/sim/stdcells.vhd"
            testbench = root / "hdl/sim/tb_sb.vhd"
            if all(path.is_file() and not path.is_symlink() for path in (support, testbench)):
                return support, testbench
    raise VerificationError("VHDL simulation support files are unavailable")


def simulate_vhdl(
    candidate_vhdl: Path,
    *,
    ghdl_binary: str | None = None,
    timeout_seconds: int = 120,
) -> dict[str, object]:
    if candidate_vhdl.is_symlink():
        raise VerificationError("candidate VHDL must not be a symbolic link")
    candidate_vhdl = candidate_vhdl.resolve()
    if not candidate_vhdl.is_file():
        raise VerificationError("candidate VHDL must be a regular file")
    executable = ghdl_binary or shutil.which("ghdl")
    if not executable:
        return {
            "reason": "GHDL executable is unavailable",
            "status": "NOT_RUN",
            "validation": {"function_64_vhdl": "NOT_RUN"},
        }
    executable_path = Path(executable).resolve()
    if not executable_path.is_file():
        raise VerificationError("GHDL executable is not a regular file")
    support, testbench = _find_simulation_support(candidate_vhdl)

    with tempfile.TemporaryDirectory(prefix="mima-ghdl-") as directory:
        work = Path(directory)
        common = [str(executable_path), "--std=08", f"--workdir={work}"]
        for source in (support, candidate_vhdl, testbench):
            _run([common[0], "-a", *common[1:], str(source)], timeout_seconds)
        _run([common[0], "-e", *common[1:], "tb_sb"], timeout_seconds)
        _run(
            [common[0], "-r", *common[1:], "tb_sb", "--assert-level=error"],
            timeout_seconds,
        )
    version = subprocess.run(
        [str(executable_path), "--version"],
        check=False,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        timeout=10,
    ).stdout.splitlines()[0]
    return {
        "candidate_vhdl_sha256": sha256_file(candidate_vhdl),
        "ghdl": {"path": str(executable_path), "version": version},
        "status": "PASS",
        "vectors_checked": 64,
        "validation": {"function_64_vhdl": "PASS"},
    }
