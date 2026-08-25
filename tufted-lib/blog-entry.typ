#import "tags.typ": tag-list, tag-slug

/// Renders a blog index entry with a date column, linked title, and optional tags.
///
/// The `date` argument may be either a `datetime` value or preformatted
/// content. The `path` argument may include or omit a trailing slash.
/// `tags` is an array of strings, with or without a leading `#`.
#let blog-entry(date: auto, path: str, title: str, tags: (), filter: false) = {
  let href = if path.ends-with("/") {
    path
  } else {
    path + "/"
  }

  let date_display = if type(date) == datetime {
    date.display()
  } else {
    date
  }

  let slugs = tags.map(tag-slug).filter(s => s != "")

  html.elem(
    "div",
    attrs: (
      class: "blog-entry",
      "data-tags": slugs.join(" "),
    ),
    {
      html.div(
        class: "blog-entry-date",
        date_display,
      )
      html.div(
        class: "blog-entry-content",
        {
          html.a(href: href, title)
          tag-list(tags, filter: filter)
        },
      )
    },
  )
}
