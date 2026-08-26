#import "../index.typ": template, tufted
#import "posts.typ": posts
#show: template.with(
  title: "Blog",
  description: "Some blog examples",
  js-scripts: ("/assets/blog-filter.js", "/assets/random-image.js"),
)

= Blog

// Reserved slot for a random margin image, the same shape as the one on the
// home page. Every image listed here is a candidate; random-image.js shows one
// of them per page load. Add or replace images by editing this block only.
#{
  html.elem(
    "div",
    attrs: (class: "random-image post-hero"),
    {
      html.elem(
        "div",
        attrs: (class: "random-item"),
        {
          image(
            "../imgs/pier-handdrawn-ivory.webp",
            alt: "Hand-drawn ivory-toned illustration of a pier.",
          )
          html.elem(
            "span",
            attrs: (class: "hero-caption"),
            "Ellen Browning Scripps Memorial Pier, La Jolla.",
          )
        },
      )
    },
  )
}

#{
  let labels = posts
    .map(post => post.tags)
    .flatten()
    .map(tufted.normalize-tag)
    .filter(tag => tag != "")
    .dedup()
    .sorted()

  html.p(
    class: "blog-tag-picker",
    {
      html.elem(
        "a",
        attrs: (
          class: "blog-show-all",
          href: "/Blog/",
        ),
        [All],
      )
      for (i, tag) in labels.enumerate() {
        html.elem(
          "a",
          attrs: (
            class: "blog-tag blog-tag-filter",
            href: tufted.tag-href(tag),
            "data-tag": tufted.tag-slug(tag),
          ),
          tufted.tag-label(tag),
        )
        if i < labels.len() - 1 {
          [ ]
        }
      }
    },
  )

  let years = posts.map(post => post.date.year()).dedup().sorted(key: y => -y)
  for year in years {
    html.elem(
      "h3",
      attrs: (class: "blog-year"),
      str(year),
    )
    for post in posts.filter(post => post.date.year() == year) {
      tufted.blog-entry(
        date: post.date,
        path: post.path,
        title: post.title,
        tags: post.tags,
        filter: true,
      )
    }
  }
}
