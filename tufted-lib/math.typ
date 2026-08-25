/// Recovers a plain-text rendering of a math expression.
///
/// Typst exports equations as SVG glyph outlines, so without this the numbers
/// and symbols inside an equation are invisible to screen readers and cannot
/// be searched or copied. The result is attached as `aria-label`.
#let math-to-text(c) = {
  if c == none {
    return ""
  }
  if type(c) == str {
    return c
  }
  if type(c) != content {
    return str(c)
  }

  let f = c.func()

  // Covers both `text` and `symbol`: in math, operators such as `=` and Greek
  // letters arrive as `symbol`, which also carries a `text` field.
  if c.has("text") {
    let t = c.text
    // A few elements carry content rather than a plain string here.
    return if type(t) == str { t } else { math-to-text(t) }
  }
  if repr(f) == "space" or f == h or f == linebreak or f == parbreak {
    return " "
  }
  if c.has("children") {
    return c.children.map(math-to-text).sum(default: "")
  }
  // `bold(v)`, `cal(L)` and friends wrap their argument in a `styled` element.
  if c.has("child") {
    return math-to-text(c.child)
  }
  if f == math.frac {
    return "(" + math-to-text(c.num) + ")/(" + math-to-text(c.denom) + ")"
  }
  if f == math.attach {
    let out = math-to-text(c.base)
    if c.has("t") and c.t != none {
      out = out + "^(" + math-to-text(c.t) + ")"
    }
    if c.has("b") and c.b != none {
      out = out + "_(" + math-to-text(c.b) + ")"
    }
    return out
  }
  if f == math.root {
    let idx = if c.has("index") and c.index != none { math-to-text(c.index) } else { "" }
    return "root" + idx + "(" + math-to-text(c.radicand) + ")"
  }
  if f == math.lr {
    return math-to-text(c.body)
  }
  if c.has("body") {
    return math-to-text(c.body)
  }
  // Spacing elements carry no text but do separate tokens.
  if f == h or f == parbreak or f == linebreak {
    return " "
  }
  return ""
}

/// Collapses runs of whitespace so the label reads as one clean line.
/// Note that joining an empty array yields `none` in Typst, so the empty case
/// is handled explicitly.
#let tidy-label(s) = {
  let parts = s.split().filter(part => part != "")
  if parts.len() == 0 { "" } else { parts.join(" ") }
}

/// Builds the element attributes, omitting `aria-label` when nothing could be
/// extracted. An empty label is worse than none: it would hide the element
/// from assistive technology instead of describing it.
#let math-attrs(body) = {
  let label = tidy-label(math-to-text(body))
  if label == "" { (role: "math") } else { (role: "math", "aria-label": label) }
}

#let template-math(content) = {
  set math.equation(numbering: "(1)")

  show math.equation.where(block: false): it => {
    if target() == "html" {
      html.elem(
        "span",
        attrs: math-attrs(it.body),
        html.frame(it),
      )
    } else {
      it
    }
  }

  show math.equation.where(block: true): it => {
    if target() == "html" {
      html.elem(
        "figure",
        attrs: math-attrs(it.body),
        html.frame(it),
      )
    } else {
      it
    }
  }

  content
}
