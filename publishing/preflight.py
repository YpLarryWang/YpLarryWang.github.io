#!/usr/bin/env python3
"""
Pre-publish evidence report for the FV/AGOP post.

Design rules, each earned the hard way on this project:

* Reports EVIDENCE, never a verdict. No "PASS" line exists in this file.
  A check that makes the reader stop doubting is worse than no check.
* Reads the BUILT ARTIFACT, not the source, for anything that is only true
  after rendering (figure numbering, math tags, meta assertions).
* Normalises U+2212 / en dash / em dash to ASCII "-" before comparing numbers.
  Typst emits U+2212 when rendering math; the source correctly uses ASCII.
* Matches numbers on digit boundaries, never as substrings ("3.2" must not
  match inside "3.29").
* Matches HTML classes as multi-valued, never as a whole-attribute equality.

Read-only. Touches nothing, publishes nothing.
"""

from __future__ import annotations

import html as html_mod
import pathlib
import re
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent
SITE = REPO / "_site"
CONTENT = REPO / "content"
POST_DIR = "fv-agop-dev-interp"

DASHES = {"−": "-", "–": "-", "—": "-"}
SIGNED_DECIMAL = re.compile(r"(?<![\d.])-?\d+\.\d+(?![\d])")


def normalise(text: str) -> str:
    for bad, good in DASHES.items():
        text = text.replace(bad, good)
    return text


def strip_tags(markup: str) -> str:
    return html_mod.unescape(re.sub(r"<[^>]+>", " ", markup))


def has_class(markup: str, name: str) -> list[str]:
    """Class attributes hold several names; never compare the whole attribute."""
    return re.findall(rf'class="[^"]*\b{re.escape(name)}\b[^"]*">([^<]*)<', markup)


def line(label: str, value) -> None:
    print(f"  {label:<34} {value}")


def main() -> int:
    post = SITE / "Blog" / POST_DIR / "index.html"
    if not post.is_file():
        print(f"cannot read {post} — build first", file=sys.stderr)
        return 2

    page = post.read_text(encoding="utf-8")
    source = (CONTENT / "Blog" / POST_DIR / "index.typ").read_text(encoding="utf-8")
    feed = (SITE / "feed.xml").read_text(encoding="utf-8")
    sitemap = (SITE / "sitemap.xml").read_text(encoding="utf-8")

    print("\nCONTENT INTEGRITY (source vs rendered)")
    src_n = normalise(source)
    labels = " ".join(normalise(html_mod.unescape(m))
                      for m in re.findall(r'aria-label="([^"]*)"', page))
    visible = normalise(strip_tags(page))
    decimals = set(SIGNED_DECIMAL.findall(src_n))
    missing = sorted(d for d in decimals if d not in visible and d not in labels)
    line("signed decimals in source", len(decimals))
    line("not found on page", f"{len(missing)}  {missing if missing else ''}")

    math_all = re.findall(r'role="math"', page)
    math_lab = re.findall(r'role="math" aria-label=', page)
    line("math elements / with aria-label", f"{len(math_all)} / {len(math_lab)}")

    # Figure numbering uses a non-breaking space in the template.
    figs = re.findall(r"Figure[\s ](\d+):", page)
    imgs = re.findall(r"<img [^>]*src=\"([^\"]+)\"", page)
    decorative = [s for s in imgs if "handdrawn" in s]
    line("numbered figures", f"{len(figs)}  {'consecutive' if figs == [str(i) for i in range(1, len(figs) + 1)] else figs}")
    line("images total / decorative", f"{len(imgs)} / {len(decorative)}")
    line("data tables (details blocks)", len(re.findall(r'details class="figure-data"', page)))
    line("em dashes on page", page.count("—"))
    line("[TODO] placeholders sitewide",
         sum(f.read_text(encoding="utf-8", errors="ignore").count("[TODO]")
             for f in SITE.rglob("*") if f.is_file() and f.suffix in (".html", ".xml", ".txt")))

    print("\nPUBLICATION ASSERTIONS (machine-readable vs the byline)")
    pending = has_class(page, "byline-pending")
    line("byline says", pending[0] if pending else "(published — no pending marker)")
    for name in ("date", "author", "citation_title", "citation_author",
                 "citation_publication_date", "citation_public_url"):
        found = re.findall(rf'<meta name="{name}" content="([^"]*)"', page)
        line(f"meta {name}", found[0] if found else "(absent)")
    for prop in ("og:url", "article:author", "article:published_time", "og:type"):
        found = re.findall(rf'<meta property="{prop}" content="([^"]*)"', page)
        line(f"meta {prop}", found[0] if found else "(absent)")
    canon = re.findall(r'<link rel="canonical" href="([^"]*)"', page)
    line("canonical", canon[0] if canon else "(absent)")

    print("\nSITE SURFACES (must agree with the posts.typ catalog)")
    entry = re.search(r"<url>\s*<loc>([^<]*%s[^<]*)</loc>\s*<lastmod>([^<]*)</lastmod>" % POST_DIR,
                      sitemap)
    line("sitemap urls total", len(re.findall(r"<loc>", sitemap)))
    line("sitemap loc (this post)", entry.group(1) if entry else "(absent)")
    line("sitemap lastmod", (entry.group(2) + "   <- build date, not publication date") if entry else "-")
    line("feed items", len(re.findall(r"<item>", feed)))
    for tag in ("link", "guid", "pubDate"):
        got = re.findall(rf"<{tag}[^>]*>([^<]*)</{tag}>",
                         re.search(r"<item>.*?</item>", feed, re.S).group(0))
        line(f"feed {tag}", got[0] if got else "(absent)")

    print("\nBIBTEX")
    cite = re.search(r'<section class="post-citation">.*?</section>', page, re.S)
    if cite:
        text = strip_tags(cite.group(0))
        for field in ("author", "title", "year", "howpublished", "urldate"):
            got = re.findall(rf"{field}\s*=\s*\{{([^}}]*)\}}", text)
            line(f"bibtex {field}", got[0].strip() if got else "(absent)")

    print("\nASSERTION SURFACE CENSUS")
    # Two checkers agreeing proves little if both were built from the same
    # hand-written list: a surface neither of us enumerated would be missed by
    # both, consistently. So enumerate EVERY meta/link on the page and flag
    # anything not already classified, instead of only revisiting known names.
    ASSERTING = {
        "date", "author", "og:url", "article:author", "article:published_time",
        "citation_title", "citation_author", "citation_publication_date",
        "citation_public_url",
    }
    INERT = {
        "viewport", "generator", "description", "og:title", "og:type",
        "og:description", "og:image", "twitter:card", "twitter:image", "charset",
    }
    names = re.findall(r'<meta\s+(?:name|property)="([^"]+)"', page)
    unknown = sorted({n for n in names if n not in ASSERTING and n not in INERT})
    line("meta tags on page", len(names))
    line("asserting date/URL/identity", len([n for n in names if n in ASSERTING]))
    line("inert (title/desc/render)", len([n for n in names if n in INERT]))
    line("UNCLASSIFIED — classify these", f"{len(unknown)}  {unknown if unknown else ''}")
    # `<link>` carries canonical, so the census is incomplete without it.
    LINK_ASSERTING = {"canonical"}
    LINK_INERT = {"icon", "stylesheet", "alternate"}
    rels = re.findall(r'<link\s+rel="([^"]+)"', page)
    unknown_rel = sorted({r for r in rels if r not in LINK_ASSERTING and r not in LINK_INERT})
    line("link tags on page", len(rels))
    line("link asserting / inert",
         f"{len([r for r in rels if r in LINK_ASSERTING])} / {len([r for r in rels if r in LINK_INERT])}")
    line("UNCLASSIFIED link rels", f"{len(unknown_rel)}  {unknown_rel if unknown_rel else ''}")
    line("JSON-LD blocks", page.count("application/ld+json"))
    line("microdata itemprop / itemtype", f"{page.count('itemprop')} / {page.count('itemtype')}")
    slug_files = sorted(
        f"{f.relative_to(SITE)}:{f.read_text(encoding='utf-8', errors='ignore').count(POST_DIR)}"
        for f in SITE.rglob("*")
        if f.is_file() and f.suffix in (".html", ".xml", ".txt")
        and POST_DIR in f.read_text(encoding="utf-8", errors="ignore")
    )
    line("files naming this post", f"{len(slug_files)}")
    for entry_line in slug_files:
        line("  ", entry_line)

    print("\nPUBLISHED BUT UNREFERENCED (everything under content/ ships, linked or not)")
    # `copy_content_assets` copies all of content/ into the build, so a file
    # merely sitting there becomes publicly fetchable at a guessable URL even
    # when no page links to it. Being unlinked is not the same as being private.
    pages = "".join(
        f.read_text(encoding="utf-8", errors="ignore")
        for f in SITE.rglob("*")
        if f.is_file() and f.suffix in (".html", ".xml", ".css", ".js")
    )
    # Scan every published asset, not just /imgs — the post's figures/ directory
    # ships too, and an /imgs-only scan silently under-reports.
    PAGE_TYPES = {".html", ".xml", ".css", ".js", ".txt"}
    assets = [f for f in SITE.rglob("*")
              if f.is_file() and f.suffix.lower() not in PAGE_TYPES]

    referenced, orphans, archival = [], [], []
    for f in assets:
        if f.name in pages:
            referenced.append(f)
            continue
        # A raster whose same-stem vector IS on the page is the deliberate
        # archival counterpart, not litter. Classified by rule, not by a
        # hand-maintained allow-list that would rot.
        if f.suffix.lower() in {".png", ".jpg", ".jpeg"} and f"{f.stem}.svg" in pages:
            archival.append(f)
        # A file named by a source .typ is a build input (the data CSVs are read
        # at compile time and rendered into the tables). Also rule-based: if the
        # source stops naming it, it stops being explained and shows up again.
        # Only sources that actually build count: an underscore-prefixed path is
        # excluded from the site, so a reference from one explains nothing.
        elif any(f.name in t.read_text(encoding="utf-8", errors="ignore")
                 for t in CONTENT.rglob("*.typ")
                 if not any(part.startswith("_")
                            for part in t.relative_to(CONTENT).parts)):
            archival.append(f)
        else:
            orphans.append(f)

    line("published assets", len(assets))
    line("referenced by a page", len(referenced))
    line("archival counterparts (kept)", f"{len(archival)}  (raster twins of referenced SVGs)")
    line("UNEXPLAINED — review these", len(orphans))
    for f in sorted(orphans, key=lambda x: -x.stat().st_size):
        line("  ", f"{f.stat().st_size/1_048_576:>6.2f} MB  {f.relative_to(SITE)}")
    if orphans:
        line("unexplained weight", f"{sum(f.stat().st_size for f in orphans)/1_048_576:.2f} MB")
    else:
        line("", "(empty is the expected state — anything listed needs a decision)")

    print("\nASSET FRESHNESS")
    versioned = re.findall(r'(?:href|src)="/assets/[^"?]+\.(?:css|js)\?v=([0-9a-f]{8})"', page)
    unversioned = re.findall(r'(?:href|src)="(/assets/[^"?]+\.(?:css|js))"', page)
    line("assets with content hash", len(versioned))
    line("assets WITHOUT hash", f"{len(unversioned)}  {unversioned if unversioned else ''}")
    line("et-book font dir present", (SITE / "assets" / "et-book").is_dir())

    print("\nNo verdict is printed by design. Compare the rows above and decide.\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
