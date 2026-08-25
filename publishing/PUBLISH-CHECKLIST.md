# Go-live checklist — FV/AGOP post

Working document owned by Yuxi. Nothing here may be executed without the
owner's explicit approval. Last updated 2026-08-25.

Site repo: `/Users/yupeiwang/Documents/YpLarryWang.github.io`
Preview: `uv run build.py preview --no-open` → http://127.0.0.1:8000

---

## 0. Blocking decisions (owner)

| # | Item | Where | Current value |
|---|---|---|---|
| 1 | Post date + slug | `content/Blog/<slug>/`, `posts.typ`, `date:` | placeholder `2026-08-24-function-vectors` |
| 2 | ~~Site SEO description~~ | `config.typ` | **DONE** — `Yupei Wang's personal site and blog.` |
| 3 | ~~Author name~~ | `config.typ` | **DONE** — `Yupei Wang` in all four places |
| 4 | ~~Sample posts~~ | `content/Blog/_2024-*`, `_2025-*` | **DONE** — underscore-prefixed, excluded from build, URLs 404 |
| 5 | OpenTimestamps authorized; Zenodo pending go-live | — | nothing installed or submitted yet |
| 6 | ~~Visitor-local time~~ | byline | **DONE** — UTC, fixed |
| 7 | ~~Content licence~~ | `LICENSE-CONTENT` | **DONE** — CC BY 4.0 for `content/`, MIT retained for code |

## 1. Fields that MUST be filled in the same batch as the push

Every row below currently asserts something the byline denies
(`Not yet published`), or carries the placeholder slug, or carries a build
date. Filling only some of them ships a self-contradictory record — that is
the specific failure to avoid.

Values below were **read out of `_site/` on 2026-08-25**, not inferred from the
generator. Three of them (`canonical`, sitemap `loc`/`lastmod`, feed `link`)
were missing from the first draft of this list.

| Assertion | Where | Current value |
|---|---|---|
| `post-published` | post `index.typ` | `none` → real push moment, UTC |
| `<meta name="date">` | article page | `2026-08-24` (placeholder) |
| `<meta property="og:url">` | article page | placeholder slug |
| `<link rel="canonical">` | article page | placeholder slug |
| `<meta property="og:type">` | article page | `article` (correct, no change) |
| `<meta property="article:published_time">` | article page | absent — add at publish |
| sitemap `<loc>` | `sitemap.xml` | placeholder slug |
| sitemap `<lastmod>` | `sitemap.xml` | `2026-08-25` = **build date, not publication date** |
| feed `<link>` | `feed.xml` | placeholder slug |
| feed `<pubDate>` | `feed.xml` | `Mon, 24 Aug 2026 00:00:00 +0000` |
| BibTeX `url` + `urldate` | `#tufted.citation(...)` | absent |
| `citation_*` | article page | absent by design until `published` is set — **implemented and dry-run verified** |
| feed `<guid isPermaLink="true">` | `feed.xml` | placeholder slug — **see warning below** |
| Blog listing `href` | `_site/Blog/index.html` | placeholder slug (relative link) |
| `<meta name="author">` | article page | `Yupei Wang` ✓ |
| `<meta property="article:author">` | article page | `Yupei Wang` ✓ — **second author field, easy to miss** |
| BibTeX `author` | citation block | `Yupei Wang` ✓ — all three now agree |

**`<guid>` is a permanent identifier, so the slug must be final before the
first push.** If the slug changes after publication, every subscriber's feed
reader treats the post as a brand-new item and re-notifies, while the old entry
may linger. This is the strongest single reason not to publish on a placeholder
slug.

**The set is closed** (verified in `_site/` on 2026-08-25, not assumed):
JSON-LD blocks 0, microdata `itemprop`/`itemtype` 0, `robots.txt` does not
mention the post. Only four files reference the slug at all — the article page
(2), the Blog listing (1), `feed.xml` (2), `sitemap.xml` (1). Nothing else
speaks for this article.

## 1b. After editing, READ THE ARTIFACT — do not trust the generator

`canonical` and the sitemap will *probably* follow the slug automatically,
because the slug is the directory name. **"Probably automatic" is exactly the
assumption that has failed repeatedly**: assuming no `#figure` meant no figure
numbering, and assuming hashing the prose locked the content. Both times the
mechanism sounded right and the artifact said otherwise.

So after every publish-time edit, print these straight out of `_site/` and
compare them against the byline:

```
meta date · og:url · canonical · og:type · article:published_time
meta author · article:author · BibTeX author
sitemap loc + lastmod · feed link + guid + pubDate
Blog listing href · BibTeX url/urldate
```

Takes seconds; it is the only step that would have caught the two misses above.
**Valla has offered to run this audit independently before push — take it.**

## 2. Pre-push verification

- [ ] **`uv run build.py build --force`** — never an incremental build. An
      incremental build only adds and updates; it does **not** remove artifacts
      whose source was deleted, so anything "already deleted" can still ship.
- [ ] **What actually reaches the public site is the COMMIT, not the local
      build.** `_site/` is gitignored and CI rebuilds it from the checked-out
      repo (`build.py build -f`), so the local build output never uploads.
      **The only gate is what is committed** — `git status` before pushing.
      Anything sitting in `content/` will be copied into the site by CI whether
      or not a page links to it.
- [ ] Still check both layers locally, for a different reason: the local
      `_site/` is what you *inspect*, so if it is stale you are verifying
      something other than what will deploy. Source deleted but artifact kept →
      the preview lies to you. Artifact gone but source kept → the preview looks
      clean while the file still lands in the repo (this is what happened with
      the owner's private images).
- [ ] `.gitignore` does not stop the asset copier: a gitignored file inside
      `content/` is still copied into the build (`.DS_Store` did this). It only
      stops it reaching the site because it never gets committed.
- [ ] Content: article `index.typ` SHA matches Valla's approved snapshot; ask
      Valla to diff the increment and re-verify numbers
- [ ] Surfaces agree: listing, `feed.xml`, `sitemap.xml` all derive from
      `posts.typ` — counts must match intent
- [ ] Layout sweep 700 / 1025 / 1360 / 1827 / 2200 px: no horizontal overflow,
      no clipped equations, hero in margin column above 760px
- [ ] Math: 311 `role="math"` elements, all with `aria-label`
- [ ] Figures: 9 numbered; decorative images unnumbered
- [ ] No `[TODO]` string anywhere in `_site`. One `config.typ` value feeds
      **three** outlets — verified by scanning the whole build, not assumed:
      `<meta name="description">` and `<meta property="og:description">` on the
      home page, **and the RSS `<channel><description>`**, which is what feed
      readers show as the subscription's blurb. Fixing `config.typ` fixes all
      three, but all three must be re-checked.
- [ ] Asset links carry `?v=<hash>` (cache busting)

## 2b. Ordering constraint — prose edits before stamping

**DONE 2026-08-25** — Pythia/OLMo citations synced; `index.typ` is
`db060d7554794223ae15bfa3e80c148140aa4e4304ec1cfb92b8d1b17ee7edef` and the prose
is frozen. `post-updated` moved `01:51` → `09:01 UTC`, its first real move.
Decimals went 114 → 115 (the OLMo DOI). Order that was followed, and applies to
any future prose change:

```
add references → prose final → OpenTimestamps → push
```

Stamping first means the proof is voided by the reference edit and has to be
redone. The manifest covers the prose, so any prose change invalidates it.

**This will also be the first legitimate bump of `post-updated`.** That field
tracks prose only and has deliberately not moved through a dozen styling
rounds; a reference addition is a real content change, so it moves with it.

## 3. Timestamping (only if authorized)

Order matters — display format is file content, so it must be frozen first.

1. Freeze all display decisions (timezone, captions, tags). Changing any of
   them afterwards voids the proof.
2. Valla regenerates the content manifest (covers `index.typ`, 16 figure
   assets, 11 data CSVs, tri-ortho files) → single hash.
3. `ots stamp` that manifest. **The `.ots` file is the evidence** — commit it
   to the repo, never treat it as a temp file.
4. Schedule a reminder for the async `ots upgrade` a few hours later; without
   it the proof stays incomplete and unverifiable.
5. Zenodo DOI only *after* go-live (it uploads content = a publication act),
   then backfill `doi` into the BibTeX and re-verify with Valla.
6. Wayback capture on the day of publication.

## 4. Push and rollback

- [ ] Branch, never commit straight to `main` without approval
- [ ] Owner's own uncommitted local edits (`_CV/`, `_Docs/`, portrait images)
      must not be swept into the commit — check `git status` first
- [ ] Record the deployed commit SHA here for rollback
- [ ] GitHub Actions (`deploy.yml`) builds with Typst/uv → Pages
- [ ] After deploy: verify the live URL renders, then Wayback capture

Rollback: revert to the previously deployed SHA and re-run the workflow.
Record both SHAs before pushing.
