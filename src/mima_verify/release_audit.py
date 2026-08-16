"""Fail-closed audit for the exact files intended for Git publication."""

from __future__ import annotations

import hashlib
import re
import subprocess
from pathlib import Path, PurePosixPath
from typing import Sequence

from .core import VerificationError


MAX_FILE_BYTES = 10 * 1024 * 1024
PROBLEM_PDF_PATH = "problem/2026密码数学挑战赛-赛题二.pdf"
APPROVED_BINARY_SHA256 = {
    PROBLEM_PDF_PATH: "6612c1c028a62052336218a74f3ad173807ce4ed300b2e4a65ed06dc75b7c099",
}
FORBIDDEN_TOP_LEVEL = {
    ".agents",
    ".aris",
    ".codex",
    ".ruff_cache",
    "agents",
    "experiments",
    "output",
    "problem",
    "projects",
    "runtime",
    "tmp",
    "汇报",
}
FORBIDDEN_PARTS = {
    "__pycache__",
    ".mypy_cache",
    ".pytest_cache",
    ".venv",
    "node_modules",
}
FORBIDDEN_SUFFIXES = {
    ".7z",
    ".doc",
    ".docx",
    ".gz",
    ".lib",
    ".pdf",
    ".pem",
    ".pfx",
    ".ppt",
    ".pptx",
    ".pyc",
    ".rar",
    ".tar",
    ".tgz",
    ".zip",
    ".zst",
}
REQUIRED_PATHS = {
    ".github/workflows/ci.yml",
    ".gitattributes",
    ".gitignore",
    "LICENSE",
    "README.md",
    "SECURITY.md",
    "THIRD_PARTY.md",
    "pyproject.toml",
    PROBLEM_PDF_PATH,
    "candidates/s100_apl_29fd2ff6b6c1dffd/SB.vhd",
    "candidates/s100_apl_29fd2ff6b6c1dffd/theory.json",
    "candidates/s100_cse27_3f9b3b31517bfce2/SB.vhd",
    "candidates/s100_cse27_3f9b3b31517bfce2/theory.json",
}


def _sensitive_patterns() -> tuple[tuple[str, re.Pattern[str]], ...]:
    unix_home = "/" + "home/"
    media_home = "/" + "media/"
    users_home = "/" + "Users/"
    private_marker = "BEGIN " + "PRIVATE KEY"
    return (
        ("private-key", re.compile(re.escape(private_marker))),
        ("unix-home-path", re.compile(re.escape(unix_home))),
        ("media-path", re.compile(re.escape(media_home))),
        ("macos-home-path", re.compile(re.escape(users_home))),
        ("windows-user-path", re.compile(r"[A-Za-z]:\\Users\\")),
        ("credential-url", re.compile(r"https?://[^/@\s:]+:[^/@\s]+@")),
        ("email", re.compile(r"\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b")),
        (
            "github-token",
            re.compile(r"\b(?:gh[pousr]_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,})\b"),
        ),
        ("aws-access-key", re.compile(r"\bAKIA[0-9A-Z]{16}\b")),
        ("openai-token", re.compile(r"\bsk-[A-Za-z0-9_-]{20,}\b")),
        ("competition-id", re.compile(r"(?<!\d)\d{10}\+2(?!\d)")),
    )


def tracked_paths(root: Path) -> list[str]:
    try:
        result = subprocess.run(
            ["git", "ls-files", "-z"],
            cwd=root,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
    except (OSError, subprocess.CalledProcessError) as exc:
        raise VerificationError("cannot enumerate the Git index") from exc
    try:
        return sorted(path.decode("utf-8") for path in result.stdout.split(b"\0") if path)
    except UnicodeDecodeError as exc:
        raise VerificationError("Git index contains a non-UTF-8 path") from exc


def audit_paths(root: Path, paths: Sequence[str]) -> dict[str, object]:
    root = root.resolve()
    violations: list[dict[str, str]] = []
    normalized_paths = sorted(dict.fromkeys(paths))
    path_set = set(normalized_paths)
    for required in sorted(REQUIRED_PATHS - path_set):
        violations.append({"code": "required-path-missing", "path": required})

    patterns = _sensitive_patterns()
    for relative_text in normalized_paths:
        relative = PurePosixPath(relative_text)
        approved_binary_hash = APPROVED_BINARY_SHA256.get(relative_text)
        if relative.is_absolute() or ".." in relative.parts or not relative.parts:
            violations.append({"code": "unsafe-index-path", "path": relative_text})
            continue
        if relative.parts[0] in FORBIDDEN_TOP_LEVEL and approved_binary_hash is None:
            violations.append({"code": "forbidden-top-level", "path": relative_text})
        if any(part in FORBIDDEN_PARTS for part in relative.parts):
            violations.append({"code": "generated-or-vendored-path", "path": relative_text})
        if relative.suffix.lower() in FORBIDDEN_SUFFIXES and approved_binary_hash is None:
            violations.append(
                {"code": "forbidden-binary-or-third-party-file", "path": relative_text}
            )

        path = root.joinpath(*relative.parts)
        if path.is_symlink():
            violations.append({"code": "symbolic-link", "path": relative_text})
            continue
        try:
            resolved_path = path.resolve(strict=True)
        except (OSError, RuntimeError):
            violations.append({"code": "missing-regular-file", "path": relative_text})
            continue
        try:
            resolved_path.relative_to(root)
        except ValueError:
            violations.append({"code": "path-escape", "path": relative_text})
            continue
        if resolved_path != path:
            violations.append({"code": "symbolic-link-parent", "path": relative_text})
            continue
        if not resolved_path.is_file():
            violations.append({"code": "missing-regular-file", "path": relative_text})
            continue
        size = resolved_path.stat().st_size
        if size > MAX_FILE_BYTES:
            violations.append({"code": "file-over-10-mib", "path": relative_text})
            continue
        payload = resolved_path.read_bytes()
        if approved_binary_hash is not None:
            if hashlib.sha256(payload).hexdigest() != approved_binary_hash:
                violations.append(
                    {"code": "approved-binary-hash-mismatch", "path": relative_text}
                )
            continue
        if b"\0" in payload:
            violations.append({"code": "unexpected-binary-content", "path": relative_text})
            continue
        try:
            text = payload.decode("utf-8")
        except UnicodeDecodeError:
            violations.append({"code": "non-utf8-text", "path": relative_text})
            continue
        for code, pattern in patterns:
            if pattern.search(text):
                violations.append({"code": code, "path": relative_text})

    return {
        "file_count": len(normalized_paths),
        "max_file_bytes": MAX_FILE_BYTES,
        "status": "PASS" if not violations else "FAIL",
        "violations": violations,
    }


def audit_tracked_tree(root: Path) -> dict[str, object]:
    root = root.resolve()
    try:
        worktree_check = subprocess.run(
            ["git", "diff", "--quiet", "--"],
            cwd=root,
            check=False,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
        )
    except OSError as exc:
        raise VerificationError("cannot compare the Git index to the worktree") from exc
    if worktree_check.returncode not in {0, 1}:
        raise VerificationError("cannot compare the Git index to the worktree")

    report = audit_paths(root, tracked_paths(root))
    if worktree_check.returncode == 1:
        report["violations"].append({"code": "unstaged-tracked-changes", "path": "<git-index>"})
        report["status"] = "FAIL"
    return report
