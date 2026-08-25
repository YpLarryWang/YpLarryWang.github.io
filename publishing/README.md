# Publishing

- **`PUBLISH-CHECKLIST.md`** — what must be decided, filled and verified before
  the site goes live. Read it before any publish action.
- **`preflight.py`** — read-only evidence report. Run `python3 publishing/preflight.py`
  after every change, not only before publishing. It prints counts and values;
  it deliberately never prints a verdict.

Neither file is evidence. If timestamp proofs (`.ots`) are added later they are
evidence itself — losing one cannot be undone, unlike these documents, which can
always be rewritten.
