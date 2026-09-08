#!/usr/bin/env python3
"""Enforce explicit module ownership for pending INBOX work."""

from __future__ import annotations

from dataclasses import dataclass
import re

_ITEM_PATTERNS = (
    re.compile(r"^\([^\n)]{1,12}\)\s+"),
    re.compile(r"^\d+\.\s+"),
    re.compile(r"^-\s+"),
)
_MODULE_PATH = re.compile(r"`([^`\s]+/[^`\s]+\.[A-Za-z0-9]+)`")


@dataclass(frozen=True)
class PendingItem:
    """One top-level pending item and its explicitly assigned modules."""

    title: str
    modules: tuple[str, ...]


def _pending_section(text: str) -> str:
    _header, marker, rest = text.partition("## 처리 대기")
    if not marker or "## 처리 완료" not in rest:
        raise ValueError("INBOX must contain pending and completed sections")
    return rest.split("## 처리 완료", 1)[0]


def _is_item_title(line: str) -> bool:
    return not line[:1].isspace() and any(pattern.match(line) for pattern in _ITEM_PATTERNS)


def parse_pending_items(text: str) -> list[PendingItem]:
    """Parse top-level pending items, excluding indented acceptance bullets."""
    blocks: list[tuple[str, list[str]]] = []
    for line in _pending_section(text).splitlines():
        if _is_item_title(line):
            blocks.append((line.strip(), []))
        elif blocks:
            blocks[-1][1].append(line)

    items: list[PendingItem] = []
    for title, details in blocks:
        modules: list[str] = []
        for line in details:
            stripped = line.strip()
            if stripped.startswith("- 담당:"):
                modules.extend(_MODULE_PATH.findall(stripped))
        items.append(PendingItem(title, tuple(modules)))
    return items


def pending_module_issues(text: str) -> list[PendingItem]:
    """Return pending items that have no module path in their owner line."""
    return [item for item in parse_pending_items(text) if not item.modules]
