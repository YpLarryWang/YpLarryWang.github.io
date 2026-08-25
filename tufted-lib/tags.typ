/// Blog tag helpers. Tags may be written with or without a leading `#`.

#let normalize-tag(tag) = str(tag).trim().trim("#")

#let tag-slug(tag) = {
  lower(normalize-tag(tag)).replace(regex("[^a-z0-9]+"), "-").trim("-")
}

#let tag-href(tag) = "/Blog/#tag-" + tag-slug(tag)

#let tag-label(tag) = "#" + normalize-tag(tag)

#let tag-list(tags, class: "blog-tags", filter: false) = {
  let cleaned = tags.map(normalize-tag).filter(t => t != "")
  if cleaned.len() == 0 {
    none
  } else {
    html.div(
      class: class,
      {
        for (i, tag) in cleaned.enumerate() {
          let slug = tag-slug(tag)
          html.elem(
            "a",
            attrs: if filter {
              (
                class: "blog-tag blog-tag-filter",
                href: tag-href(tag),
                "data-tag": slug,
              )
            } else {
              (
                class: "blog-tag",
                href: tag-href(tag),
              )
            },
            tag-label(tag),
          )
          if i < cleaned.len() - 1 {
            [ ]
          }
        }
      },
    )
  }
}
