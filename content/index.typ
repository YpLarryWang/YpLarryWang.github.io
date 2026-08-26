#import "../config.typ": template, tufted
#show: template

// Deliberately uncaptioned: the picture sets the tone of the page and is not
// making a claim, so it carries no visible text. `alt` is still required — it
// is read by screen readers, not displayed, so it is not a caption.
#tufted.margin-note({
  image(
    // Neutral filename on purpose: the picture gets retouched from time to
    // time, and a name that describes one particular rendering goes stale
    // silently the next time it is replaced.
    "imgs/stone-guardian-handdrawn.webp",
    alt: "Hand-drawn ivory-toned illustration of a stone guardian figure.",
  )
})

= Yupei Wang

I am a student.
