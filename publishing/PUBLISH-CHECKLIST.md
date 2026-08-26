# Publishing checklist

**STATUS 2026-08-25: the FV/AGOP post is PUBLISHED.**
<https://ypwang.one/Blog/fv-agop-dev-interp/> — published 2026-08-25 11:54 UTC.

| Item | State |
|---|---|
| Live | article, `/Blog/`, `/Blog/tags/`, `/` all 200; template CV/Docs/3 samples 404 (11/11 verified against a pre-push baseline) |
| Prose | frozen, `index.typ` = `5939d6d9c507fb32fe71fe72d57a4447c084faf67f5e37581a57100147c4720a` |
| Assertions | all publication fields agree with the byline; verified on the live page, not just locally |
| Timestamps | two OTS proofs committed — `1b27ca8e…` (pre-publication) and `451e15be…` (published version); **both awaiting Bitcoin confirmation → `ots upgrade` still to run** |
| Archive | Wayback 20260825121928 (article) / 20260825122121 (home); 9 figures + 8 collapsed data tables confirmed present in the snapshot |
| Deploy | Pages `build_type: workflow` — **must stay that way**, see Deploy configuration below |
| Outstanding | `ots upgrade` after confirmation; Zenodo DOI once the owner picks a licence |

**Sections 0–3 below are the original pre-publication checklist, kept as the
record of what was decided and verified before go-live. The standing rules at
the end are what applies to future posts.**

---
## 0. Blocking decisions (owner)

| # | Item | Where | Current value |
|---|---|---|---|
| 1 | Post date + slug | `content/Blog/<slug>/`, `posts.typ`, `date:` | placeholder `fv-agop-dev-interp` |
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

---

## Standing rules (locked 2026-08-25)

Earned during the first real publish. Each exists because it was violated or
nearly violated that day.

1. **Verify the live site after every deploy — the built artifact is not
   evidence of what is served.** Check both directions: key pages return 200
   *with the right content*, and paths that should be gone return 404. On the
   first publish the artifact was correct all along (CI compiled 4 pages), but
   GitHub Pages was set to `build_type: legacy` and served a Jekyll render of
   the repo root for 14 minutes instead. Every check we had inspected the local
   `_site/`; **"local artifact = live content" was assumed and never tested
   until it failed.**
2. **What is pushed must byte-equal what was verified.** Evidence files,
   documentation and content go in separate commits. The natural urge to
   "commit related things together" is exactly what breaks an audit trail.
3. **`Updated` tracks prose only, and only after publication.** Styling changes
   never move it. An `Updated` earlier than `Published` is nonsense; edits made
   before a post exists publicly are drafting.
4. **Decorative images never enter Figure numbering** and stay out of the
   evidence manifest.
5. **Timestamp proofs (`.ots`) are evidence, not documentation.** Never
   regenerate a stamped manifest; a lost proof cannot be rebuilt, and
   re-stamping only ever proves a later time.
6. **When something disappears, ask what appeared.** The incident report for
   the 14-minute outage listed the pages that 404'd but missed that raw repo
   source had become publicly fetchable — the more consequential half.

## Deploy configuration

GitHub Pages must stay on `build_type: workflow`. Under `legacy` both the
Actions workflow and the built-in Jekyll builder run on every push, roughly one
second apart, and **whichever finishes last wins** — a race that silently
publishes the wrong thing.

## Comparing builds: exclude volatile fields, and list them explicitly

**The build is not deterministic.** Two builds of identical input differ,
because `feed.xml` rewrites `<lastBuildDate>` with the current time on every
run. Any check that diffs build output before and after a change must exclude
such fields first, or it reports a difference every single time — and an alarm
that always fires is worse than no alarm, because it trains people to skim past
real differences too.

**The exclusion list must be written down here, never applied silently.**
Otherwise, when a new volatile field appears, nobody can tell why comparisons
suddenly started reporting differences again.

Known volatile fields:

- `feed.xml` → `<lastBuildDate>`

Two further conditions, both learned by getting them wrong:

- **Fingerprints only compare if produced by the identical command from the
  identical working directory.** `shasum` output lines contain the file path, so
  `find _site -type f` and `cd _site && find . -type f` yield different
  aggregates for byte-identical trees. Recompute both sides; never compare
  against a recorded number of unknown provenance.
- **Compare the Git trees, not the working directory.** Export each side with
  `git archive` and build in a clean directory. What CI checks out is the tree,
  and the working directory can contain untracked files that mask a difference
  either way.

This is why the timestamp proofs anchor `content/` sources rather than build
output. The original reason was "output is determined by input" — a deduction.
The measured reason is stronger: **the output is not stable, so it is unfit to
anchor.** Had `_site/` been stamped, the proof would fail verification after
every rebuild, and the cause (one RSS timestamp) would be the last thing anyone
suspected.

## Provenance of the template demo material

The Tufted template shipped 26 demo files — a sample CV, template
documentation, and three example posts. They were never part of this site's
content. On 2026-08-26 they were removed from Git tracking and added to
`.gitignore`; they remain on the author's local disk as reference, and are
deliberately excluded from the remote tree and therefore from the Zenodo
archive (which snapshots the tree at release, not history).

**Searching history for these paths requires care.** All 26 existed in the
initial commit `d136d14`, but under *un-prefixed* names — `content/CV/`,
`content/Docs/`, `content/Blog/2025-…`. The underscore prefixes were introduced
in `eef5ab7`, the publish commit. A search for `content/_CV/` finds nothing
before `eef5ab7` and would suggest, wrongly, that the files were added late.

They contain no identifying information for this site's author: 0 files mention
their name or email, and the only email-shaped strings are
`example@example.com` and `noreply@edwardtufte.com`.

## The unit of checking decides the blind spot

Every blind spot found during the first publish had the same mechanism. None
was caused by checking carelessly; each was caused by the *unit* the check was
framed around, which put the contradiction structurally outside it:

| Unit of checking | What became invisible |
|---|---|
| the page | disagreement *between* pages — the blog list said `2026-08-24` while the article, feed, and every meta tag said `2026-08-25` |
| the local build | the difference between local output and what is actually served — Pages was set to `legacy` and served a Jekyll render for 14 minutes |
| the changed files | unchanged files that would nonetheless be archived — the template demo material |
| the file's content | an error in the *record about* the file — a wrong hash written into notes |

**Checking harder never closes a gap of this kind.** If the contradiction lies
between two units, no amount of care applied inside either one can reach it.
The only move that works is to re-ask the question with a different unit:
compare fact against fact rather than page against itself; compare served
bytes rather than built bytes; compare the whole archived tree rather than the
diff; compare the record against the thing it describes.

`preflight.py`'s `cross_surface_report()` implements the first of these: it
gathers every surface that states a given fact — publication date, author,
canonical URL — and prints them together, so a disagreement between files
cannot hide inside a file that is internally consistent.

Two rules that section follows, both load-bearing:

- **A value that cannot be found prints `MISSING`, never nothing.** A checker
  that silently drops a surface is worse than one that never covered it, because
  it still looks like it is working.
- **Fields that legitimately differ are excluded and labelled, not compared.**
  `sitemap <lastmod>` comes from file mtime and equals the build date by design;
  comparing it would raise a disagreement on every run.

## Two checks that share a foundation are one check run twice

A generator and its own verifier share a parser and a set of assumptions about
the format. If the generator misreads something, the verifier misreads it the
same way and reports agreement. That is not redundancy: the probability of
error has not moved, only confidence in it.

So "double-checked" is only meaningful when the second check rests on a
*different* foundation — recomputed a different way, by a different party, or
from a different artifact. Before stamping the third proof, all 31 manifest
entries were re-hashed independently rather than accepting the generator's own
verify pass.

## What can and cannot be verified locally

`ots verify` requires a Bitcoin node to compare against the chain. There is none
on this machine, so it cannot complete here, and **"the proof verifies" must
never be claimed from this environment.**

What *can* be established locally is whether a proof has a Bitcoin attestation
embedded:

```
ots info <file>.ots | grep -ci 'bitcoin block'
```

The two statements sound similar and differ completely in force: one means the
hash was compared against a block on the chain, the other only means the file
contains such a record. Say the second, and say it in those words.

## When a new timestamp proof is needed

**Ask one question: is the changed file inside the manifest's scope?**

```
content/Blog/<post>/index.typ   in scope   -> re-stamp
figures, data tables, diagram   in scope   -> re-stamp
.zenodo.json                    out        -> no proof needed
CSS / JS / README / tooling     out        -> no proof needed
```

The manifest anchors 31 files and says so in its own header; the repository
holds 85. It has never been a snapshot of the tree, and its `NOT covered` line
is part of the claim rather than an omission.

**Do not use "the tree changed" as the trigger.** That reasoning sounds
cautious and quietly creates unbounded work: a CSS tweak, a typo fix, or a line
of README would each demand a fresh proof, and the tree changes again the moment
the proof is committed. It is the same infinite regress as trying to make an
archive contain its own DOI, entering through a different door.

**A scoped manifest's entire value is that out-of-scope changes leave it
accurate.** Reasoning that erases that distinction erases the value.

Keeping the stamped tree close to the released tree is still good practice —
edit release metadata first, then stamp — but that is hygiene, not correctness.

## Upgrade a proof before archiving it — never archive a fresh stamp

**A freshly stamped `.ots` contains zero Bitcoin attestations, by definition.**
`ots stamp` returns a calendar commitment; the Bitcoin attestation only exists
once the calendar's transaction is mined, an hour or two later. So "stamp, then
immediately archive" does not risk producing an incomplete proof — it produces
one every single time, without exception. The ordering itself is the defect.

This happened to the v1.0.0 archive. Verified by downloading the published zip
from Zenodo and inspecting it, not by reading the record page:

```
proof 1 (pre-publication)  3600 B  3 attestations  -> verifiable offline
proof 2 (published)        1632 B  1 attestation   -> verifiable offline
proof 3 (final)            1050 B  0 attestations  -> needs a calendar server
```

Scope of the damage, stated precisely: the archive is **internally
self-verifying for content** — its manifest matches the archived files 31/31
with no network access. Only the *time* anchor of the third proof is degraded,
from "guaranteed by Bitcoin" to "guaranteed by a volunteer-run server staying
alive". Proof 2 still anchors the published article offline, so the claim "this
existed before 2026-08-25" survives regardless.

**Rule:** a stamp is not finished when `ots stamp` succeeds. It is finished when
`ots upgrade` has attached a Bitcoin attestation. Only then may it enter a
permanent archive.

## Match the deploy run by commit SHA, never by "the latest one"

```
gh run list --limit 10 --json databaseId,headSha \
  -q '.[] | select(.headSha=="'"$(git rev-parse HEAD)"'") | .databaseId'
```

Taking the most recent run races the push: the new workflow may not be listed
yet, so the query returns the *previous* run, waits for it, and reports a
success that belongs to someone else's commit. That happened here — a deploy was
reported complete while the live page still lacked the change.

What makes this class hard is that it is usually right. The latest run and my
run are the same object except during the few seconds after a push, so the
error never reproduces on demand and looks like a fluke. Selecting by SHA moves
it from *usually correct* to *correct by construction*.

Same remedy as the stamp-then-upgrade ordering: do not rely on being careful at
the moment it matters; remove the possibility of the wrong answer.

