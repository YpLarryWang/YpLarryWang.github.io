/// "Cite this post" block: a BibTeX entry readers can copy in one click.
///
/// The copy button comes from `assets/code-blocks.js`, which attaches to every
/// `pre > code`, so nothing extra is needed here.
///
/// `url` and `published` stay `none` until the post is actually live: an
/// unpublished post has no stable URL and no publication date, and a citation
/// carrying a guessed one would be wrong in exactly the way citations must
/// never be wrong.

#let bibtex-entry(
  key: none,
  author: none,
  title: none,
  year: none,
  month: none,
  url: none,
  urldate: none,
  note: none,
) = {
  let lines = ("@misc{" + key + ",",)
  if author != none { lines.push("  author       = {" + author + "},") }
  if title != none { lines.push("  title        = {" + title + "},") }
  if year != none { lines.push("  year         = {" + year + "},") }
  if month != none { lines.push("  month        = {" + month + "},") }
  if url != none { lines.push("  howpublished = {\\url{" + url + "}},") }
  if urldate != none { lines.push("  urldate      = {" + urldate + "},") }
  if note != none { lines.push("  note         = {" + note + "},") }
  lines.push("}")
  lines.join("\n")
}

#let citation(
  heading-text: "Cite this post",
  key: none,
  author: none,
  title: none,
  year: none,
  month: none,
  url: none,
  urldate: none,
  note: none,
  pending-note: none,
) = {
  html.elem(
    "section",
    attrs: (class: "post-citation"),
    {
      html.elem("h3", heading-text)

      if pending-note != none {
        html.elem(
          "p",
          attrs: (class: "citation-pending"),
          pending-note,
        )
      }

      html.elem(
        "pre",
        html.elem(
          "code",
          attrs: (class: "language-bibtex"),
          bibtex-entry(
            key: key,
            author: author,
            title: title,
            year: year,
            month: month,
            url: url,
            urldate: urldate,
            note: note,
          ),
        ),
      )
    },
  )
}
