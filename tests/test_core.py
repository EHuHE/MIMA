from __future__ import annotations

import copy
import json
import subprocess
import tempfile
import unittest
from pathlib import Path

from mima_verify.core import (
    VerificationError,
    analyze_spec,
    load_json_object,
    verify_candidate,
)
from mima_verify.ghdl import _find_simulation_support
from mima_verify.recipe import replay_candidate
from mima_verify.release_audit import audit_paths, audit_tracked_tree
from mima_verify.search import search_equivalent_net_cse
from mima_verify.vhdl import render_vhdl


ROOT = Path(__file__).resolve().parents[1]
RETAINED = (
    "s100_apl_94432cbb162fe56d",
    "s100_apl_29fd2ff6b6c1dffd",
    "s100_y1x4_3f8b9fd2cfc1e3ff",
    "s100_cse27_3f9b3b31517bfce2",
)


class CandidateTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.valid_dir = ROOT / "candidates/s100_apl_29fd2ff6b6c1dffd"
        cls.valid = load_json_object(cls.valid_dir / "theory.json", "test theory")

    def test_all_retained_candidates_are_bound_and_valid(self) -> None:
        for candidate_id in RETAINED:
            with self.subTest(candidate_id=candidate_id):
                directory = ROOT / "candidates" / candidate_id
                report = verify_candidate(
                    directory / "theory.json",
                    metadata_path=directory / "metadata.json",
                    vhdl_path=directory / "SB.vhd",
                )
                self.assertEqual(report["status"], "PASS")
                self.assertEqual(report["truth_table_checked"], 64)
                self.assertEqual(report["D_theory_ps"], 197.952)

    def test_vhdl_renderer_is_byte_exact(self) -> None:
        for candidate_id in RETAINED:
            with self.subTest(candidate_id=candidate_id):
                directory = ROOT / "candidates" / candidate_id
                spec = load_json_object(directory / "theory.json", "test theory")
                self.assertEqual(render_vhdl(spec), (directory / "SB.vhd").read_bytes())

    def test_replays_are_byte_exact(self) -> None:
        pairs = (
            ("s100_apl_94432cbb162fe56d", "s100_apl_29fd2ff6b6c1dffd"),
            ("s100_y1x4_3f8b9fd2cfc1e3ff", "s100_cse27_3f9b3b31517bfce2"),
        )
        for parent, child in pairs:
            with self.subTest(child=child):
                report, theory, vhdl = replay_candidate(
                    ROOT / "candidates" / parent,
                    ROOT / "candidates" / child,
                )
                self.assertEqual(report["status"], "PASS")
                self.assertEqual(theory, (ROOT / "candidates" / child / "theory.json").read_bytes())
                self.assertEqual(vhdl, (ROOT / "candidates" / child / "SB.vhd").read_bytes())

    def test_illegal_gate_is_rejected(self) -> None:
        invalid = copy.deepcopy(self.valid)
        invalid["gates"][0]["type"] = "MAGIC"
        with self.assertRaisesRegex(VerificationError, "illegal gate type"):
            analyze_spec(invalid)

    def test_cycle_is_rejected(self) -> None:
        invalid = copy.deepcopy(self.valid)
        invalid["gates"][0]["in"] = [invalid["gates"][0]["out"]]
        with self.assertRaisesRegex(VerificationError, "cycle"):
            analyze_spec(invalid)

    def test_multiple_driver_is_rejected(self) -> None:
        invalid = copy.deepcopy(self.valid)
        duplicate = copy.deepcopy(invalid["gates"][0])
        duplicate["id"] = "duplicate_driver"
        invalid["gates"].append(duplicate)
        with self.assertRaisesRegex(VerificationError, "multiple drivers"):
            analyze_spec(invalid)

    def test_wrong_truth_table_is_rejected(self) -> None:
        invalid = copy.deepcopy(self.valid)
        invalid["outputs"]["y0"] = "x0"
        with self.assertRaisesRegex(VerificationError, "truth-table mismatch"):
            analyze_spec(invalid)

    def test_wrong_claimed_delay_is_rejected(self) -> None:
        invalid = copy.deepcopy(self.valid)
        invalid["claimed_d_theory_ps"] = 1
        with self.assertRaisesRegex(VerificationError, "claimed delay"):
            analyze_spec(invalid)

    def test_theory_symlink_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            link = Path(directory) / "theory.json"
            link.symlink_to(self.valid_dir / "theory.json")
            with self.assertRaisesRegex(VerificationError, "symbolic link"):
                verify_candidate(link)

    def test_vhdl_support_is_found_from_candidate(self) -> None:
        support, testbench = _find_simulation_support(self.valid_dir / "SB.vhd")
        self.assertEqual(support, ROOT / "hdl/sim/stdcells.vhd")
        self.assertEqual(testbench, ROOT / "hdl/sim/tb_sb.vhd")

    def test_cse_search_is_deterministic_and_does_not_invent_sta(self) -> None:
        first = search_equivalent_net_cse(self.valid, limit=5)
        second = search_equivalent_net_cse(self.valid, limit=5)
        self.assertEqual(first, second)
        self.assertTrue(first)
        self.assertTrue(all(row["D_sta_ns"] == "NOT_RUN" for row in first))


class ReleaseAuditTests(unittest.TestCase):
    def test_sensitive_path_is_reported_without_value(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            path = root / "sample.txt"
            path.write_text("local=" + "/" + "home/example/project\n", encoding="utf-8")
            report = audit_paths(root, ["sample.txt"])
            codes = {item["code"] for item in report["violations"]}
            self.assertIn("unix-home-path", codes)
            self.assertNotIn("local=", json.dumps(report))

    def test_symlink_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            target = root / "target.txt"
            target.write_text("safe", encoding="utf-8")
            (root / "link.txt").symlink_to(target)
            report = audit_paths(root, ["link.txt"])
            codes = {item["code"] for item in report["violations"]}
            self.assertIn("symbolic-link", codes)

    def test_symlinked_parent_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            actual = root / "actual"
            actual.mkdir()
            (actual / "sample.txt").write_text("safe", encoding="utf-8")
            (root / "linked").symlink_to(actual, target_is_directory=True)
            report = audit_paths(root, ["linked/sample.txt"])
            codes = {item["code"] for item in report["violations"]}
            self.assertIn("symbolic-link-parent", codes)

    def test_unstaged_tracked_change_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            subprocess.run(["git", "init", "-q"], cwd=root, check=True)
            path = root / "sample.txt"
            path.write_text("staged\n", encoding="utf-8")
            subprocess.run(["git", "add", "sample.txt"], cwd=root, check=True)
            path.write_text("unstaged\n", encoding="utf-8")
            report = audit_tracked_tree(root)
            codes = {item["code"] for item in report["violations"]}
            self.assertIn("unstaged-tracked-changes", codes)


if __name__ == "__main__":
    unittest.main()
