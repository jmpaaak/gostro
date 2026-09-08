#!/usr/bin/env python3
"""Tests for the INBOX module-assignment policy."""

from __future__ import annotations

import sys
from pathlib import Path
import unittest

sys.path.insert(0, str(Path(__file__).parent))

from module_policy import parse_pending_items, pending_module_issues  # noqa: E402


INBOX = """# Feedback Inbox

## 처리 대기

(7) **Feature with an owner**
  - 담당: `game/feature.lua`
  - detail

(8) **Feature missing an owner**
  - build it in the scene

### Phase D

## 처리 완료
"""


class ModulePolicyTests(unittest.TestCase):
    def test_parses_top_level_items_without_treating_details_as_items(self) -> None:
        items = parse_pending_items(INBOX)

        self.assertEqual(
            [item.title for item in items],
            ["(7) **Feature with an owner**", "(8) **Feature missing an owner**"],
        )
        self.assertEqual(items[0].modules, ("game/feature.lua",))

    def test_reports_only_items_without_an_explicit_module_path(self) -> None:
        issues = pending_module_issues(INBOX)

        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0].title, "(8) **Feature missing an owner**")

    def test_accepts_an_empty_pending_section(self) -> None:
        text = "# Feedback Inbox\n\n## 처리 대기\n\n## 처리 완료\n"

        self.assertEqual(parse_pending_items(text), [])
        self.assertEqual(pending_module_issues(text), [])


if __name__ == "__main__":
    unittest.main()
