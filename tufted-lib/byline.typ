/// Author line and archival timestamps shown directly under a post title.
///
/// Two timestamps are kept deliberately separate:
///
/// - `published` is the moment the post first became publicly visible. It can
///   only be written once that has actually happened, so it stays `none` while
///   a post is still local. Rendering a placeholder here would defeat the
///   whole point of an archival record.
/// - `updated` tracks changes to the *prose* only. Layout and stylesheet work
///   must not move it, otherwise a reader sees a fresh edit date for an
///   article whose text has not changed.
///
/// `proof` is optional and holds a link to external evidence for the
/// published stamp (a commit, a signature, a timestamping receipt).

#let two(n) = if n < 10 { "0" + str(n) } else { str(n) }

/// ISO 8601 with offset, for the machine-readable `datetime` attribute.
#let iso-stamp(dt, offset) = {
  str(dt.year()) + "-" + two(dt.month()) + "-" + two(dt.day()) + "T" + two(dt.hour()) + ":" + two(
    dt.minute(),
  ) + ":00" + offset
}

/// Human-readable form, to the minute as requested.
#let human-stamp(dt) = {
  str(dt.year()) + "-" + two(dt.month()) + "-" + two(dt.day()) + " " + two(dt.hour()) + ":" + two(
    dt.minute(),
  )
}

#let stamp(label, dt, offset, label-class: "byline-label") = {
  html.elem(
    "span",
    attrs: (class: "byline-item"),
    {
      html.elem("span", attrs: (class: label-class), label)
      " "
      html.elem(
        "time",
        attrs: (datetime: iso-stamp(dt, offset)),
        human-stamp(dt),
      )
    },
  )
}

#let byline(
  author: none,
  published: none,
  updated: none,
  offset: "+00:00",
  offset-label: "UTC",
  proof: none,
  proof-label: "verify",
) = {
  html.elem(
    "p",
    attrs: (class: "post-byline"),
    {
      if author != none {
        html.elem("span", attrs: (class: "byline-author"), author)
      }

      if published != none {
        stamp("Published", published, offset)
        if proof != none {
          " "
          html.elem(
            "a",
            attrs: (class: "byline-proof", href: proof, rel: "nofollow"),
            proof-label,
          )
        }
      } else {
        // Honest placeholder: the post is not public yet, so there is no date.
        html.elem(
          "span",
          attrs: (class: "byline-item byline-pending"),
          "Not yet published",
        )
      }

      // An "Updated" stamp earlier than "Published" is nonsense to a reader:
      // edits made before publication are drafting, not updates. Show it only
      // once the prose has genuinely changed after the post went live.
      let updated-after-publication = (
        updated != none
          and (published == none or updated > published)
      )
      if updated-after-publication {
        stamp("Updated", updated, offset)
      }

      if published != none or updated != none {
        html.elem("span", attrs: (class: "byline-tz"), offset-label)
      }
    },
  )
}
