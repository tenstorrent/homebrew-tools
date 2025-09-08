#!/usr/bin/env python3
"""
Bump Formula/tracy.rb stable url + sha256 for a tenstorrent/tracy tag or commit.

Run from the homebrew-tools repo root:
  ./scripts/bump_tracy_formula.py v0.10.7-tt.1
  ./scripts/bump_tracy_formula.py --commit FULL_SHA

Updates the first `url` and `sha256` in Formula/tracy.rb (stable tarball pin).
"""

from __future__ import annotations

import argparse
import hashlib
import re
import sys
import urllib.error
import urllib.request
from typing import Optional


SLUG_DEFAULT = "tenstorrent/tracy"
FORMULA_DEFAULT = "Formula/tracy.rb"


def archive_url(slug: str, *, tag: Optional[str] = None, commit: Optional[str] = None) -> str:
    if commit:
        return f"https://github.com/{slug}/archive/{commit.strip()}.tar.gz"
    if not tag:
        raise ValueError("tag or commit required")
    t = tag.strip()
    if not t.startswith("v"):
        t = "v" + t
    return f"https://github.com/{slug}/archive/refs/tags/{t}.tar.gz"


def sha256_url(url: str) -> str:
    req = urllib.request.Request(url, headers={"User-Agent": "homebrew-tools-tracy-bump"})
    with urllib.request.urlopen(req, timeout=180) as resp:
        return hashlib.sha256(resp.read()).hexdigest()


def bump_formula(path: str, url: str, digest: str) -> None:
    text = open(path, encoding="utf-8").read()

    new_text, n_url = re.subn(
        r'^(\s*)url\s+"[^"]*"',
        lambda m: f'{m.group(1)}url "{url}"',
        text,
        count=1,
        flags=re.MULTILINE,
    )
    if n_url != 1:
        print("error: expected exactly one url line (inside stable block)", file=sys.stderr)
        sys.exit(1)

    new_text, n_sha = re.subn(
        r'^(\s*)sha256\s+"[^"]*"',
        lambda m: f'{m.group(1)}sha256 "{digest}"',
        new_text,
        count=1,
        flags=re.MULTILINE,
    )
    if n_sha != 1:
        print("error: expected exactly one sha256 line", file=sys.stderr)
        sys.exit(1)

    open(path, "w", encoding="utf-8").write(new_text)
    print(f"Updated {path}")
    print(f"  url {url}")
    print(f"  sha256 {digest}")


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("ref", nargs="?", help="Git tag (e.g. v0.10.7-tt.1)")
    ap.add_argument("--commit", metavar="SHA", help="Full commit SHA (archive tarball)")
    ap.add_argument("--slug", default=SLUG_DEFAULT)
    ap.add_argument("--formula", default=FORMULA_DEFAULT)
    args = ap.parse_args()

    if args.commit:
        url = archive_url(args.slug, commit=args.commit)
    else:
        if not args.ref:
            ap.error("tag required unless --commit is set")
        tag = args.ref.strip()
        if not tag.startswith("v"):
            tag = "v" + tag
        url = archive_url(args.slug, tag=tag)

    try:
        digest = sha256_url(url)
    except urllib.error.HTTPError as e:
        print(f"error: HTTP {e.code} fetching {url}", file=sys.stderr)
        sys.exit(1)

    bump_formula(args.formula, url, digest)


if __name__ == "__main__":
    main()
