# Timestamps — DO NOT DELETE

These files are **evidence**, not documentation. A lost `.ots` cannot be
regenerated: it is the only path linking the manifest hash to a Bitcoin block.

| File | Role |
|---|---|
| `content-manifest-2026-08-25.txt` | Pins the SHA-256 of all 31 constituent files |
| `content-manifest-2026-08-25.txt.ots` | The timestamp proof for that manifest |

**Both are required.** The `.ots` proves *a* hash existed at a time; the
manifest says *which content* that hash stands for. Either alone proves nothing
useful.

Manifest SHA-256:
`1b27ca8e7a9ab59c636e6667d63d9222d35af0fc5be5c633e7a9e3d28221bdbd`

## Status

Stamped 2026-08-25. **Pending Bitcoin confirmation at time of writing** — run
`ots upgrade content-manifest-2026-08-25.txt.ots` once confirmed (a few hours),
which embeds the block path and removes the dependency on calendar servers
retaining data. A reminder is scheduled for this; it is the step most likely to
be skipped.

## Verify

```
ots verify content-manifest-2026-08-25.txt.ots     # proof -> Bitcoin block time
shasum -a 256 content-manifest-2026-08-25.txt      # must equal the SHA above
```

Then re-hash each `source_path` listed in the manifest and compare, to confirm
the live content is the content that was stamped.

## What this does and does not prove

Proves: this exact content existed **no later than** the block time.
Does not prove: when it was created, or that it was not public earlier.

## Why there will be two proofs

Publishing necessarily edits the article: the real publication time,
`citation_*` metadata and possibly `og:url` are written at go-live. That
changes `index.typ`, so the manifest hash changes too. This is caused by the
act of publishing, not by an undisclosed edit.

Two proofs therefore exist, each answering a different question:

| Proof | Proves |
|---|---|
| `content-manifest-2026-08-25` (this one) | the content existed **before publication** — a claim that cannot be reconstructed once the post is public |
| the post-publication stamp (later) | the version that is **actually public** |

### The difference must be checkable, not merely asserted

Written **before** the second proof exists, so it is a prediction rather than
an after-the-fact explanation. Comparing the two manifests line by line:

- **exactly one line should differ — `index.typ`**
- the other **30 lines must be byte-identical**: prose, formulas, numbers,
  figures, data tables and diagrams are untouched by publishing

```
diff <(sort content-manifest-2026-08-25.txt) <(sort content-manifest-<later>.txt)
```

**If any of those 30 lines has moved, that is not a normal difference — it
means content changed and must be investigated before trusting either proof.**
Valla will run this comparison and treat any other change as a blocker.

### Prediction revised 2026-08-25, before the slug rename

The prediction above said exactly one line would differ. **That is no longer
right, and the reason is recorded here rather than quietly corrected later.**

After it was written, the owner chose a new slug (`fv-agop-dev-interp`, no date).
The manifest pins both `site_path` and `source_path`, so renaming the directory
changes **all 31 lines** — every path moves, even though no content does.

The check therefore shifts from lines to **hashes**, which is the stronger form:

- compare the `sha256` column only, ignoring the path columns
- **30 of 31 hashes must be byte-identical** — prose, formulas, numbers,
  figures, data tables, diagrams
- **only `index.typ` may differ**, and only because publishing writes the
  publication time and `citation_*` metadata into it

```
cut -d'|' -f4 manifest_a | sort > /tmp/a
cut -d'|' -f4 manifest_b | sort > /tmp/b
diff /tmp/a /tmp/b        # expect exactly one differing hash
```

A rename moves content; it does not alter it. If any hash beyond `index.typ`
has moved, content changed and that is a blocker.
