/// Single catalog for the blog index and the tag directory.
/// Add a new post here and on its `index.typ` `template.with(tags: (...))`.
/// Sample posts (Normal Distribution, Monkeys vs Apes, Iterators vs Generators)
/// are delisted per owner decision; their source folders stay in place as
/// format references. To relist one, add its entry back here.
#let posts = (
  (
    date: datetime(year: 2026, month: 8, day: 24),
    path: "fv-agop-dev-interp/",
    title: "How Do Function Vectors Come into Being and Where Do They Live?",
    tags: ("MechanisticInterpretability", "Steering", "AGOP", "TrainingDynamics", "RepresentationLearning"),
  ),
)
