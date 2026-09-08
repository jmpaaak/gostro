#!/usr/bin/env python3
"""Regression tests for STATUS compaction."""

from pathlib import Path
import os
import tempfile
import time
import unittest

from scripts.compact_status import compact_status


class CompactStatusTest(unittest.TestCase):
    def test_heading_based_newest_first_log_keeps_complete_latest_section(self):
        latest = "## 2026-09-09 — latest\n\n- latest fact\n- Next slice: next\n"
        older = "".join(
            f"\n## 2026-09-{day:02d} — older {day}\n\n- " + ("old " * 80) + "\n"
            for day in range(8, 0, -1)
        )
        with tempfile.TemporaryDirectory() as directory:
            status = Path(directory) / "STATUS.md"
            status.write_text("# STATUS\n" + latest + older, encoding="utf-8")
            old = time.time() - 60
            os.utime(status, (old, old))

            result = compact_status(status, keep_chars=500)

            self.assertEqual("compacted", result["action"])
            kept = status.read_text(encoding="utf-8")
            history = status.with_name("STATUS_HISTORY.md").read_text(encoding="utf-8")
            self.assertIn(latest.strip(), kept)
            self.assertNotIn("older 1", kept)
            self.assertIn("older 1", history)


if __name__ == "__main__":
    unittest.main()