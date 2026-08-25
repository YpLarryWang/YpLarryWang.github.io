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
