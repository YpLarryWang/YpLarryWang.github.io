#import "../index.typ": template, tufted

#let post-tags = ("MechanisticInterpretability", "Steering", "AGOP", "TrainingDynamics", "RepresentationLearning")

// Archival stamps. `post-published` stays `none` until the article is actually
// pushed live — there is no publication date before publication, and inventing
// one would corrupt the very record it is meant to provide.
// `post-updated` tracks changes to the prose only: stylesheet and layout work
// must never move it, or readers see a fresh edit date for unchanged text.
// Stamps are recorded in UTC: it is the archival standard (ISO 8601 / RFC 3339,
// and what Zenodo, DOI registries and timestamping services all use), and it
// reveals nothing about where the author sits. The instant below is the same
// moment as 2026-08-24 18:51 local time, expressed in UTC.
#let post-author = "Yupei Wang"
// Set at go-live, 2026-08-25. Until this moment it was `none`, and the byline,
// `citation_*` tags and BibTeX url/date were all correctly absent because the
// post genuinely had no publication date or stable URL.
#let post-published = datetime(year: 2026, month: 8, day: 25, hour: 11, minute: 54, second: 0)
// Moved 2026-08-25 for the Pythia/OLMo reference additions — the first real
// prose change since this field was introduced. A dozen intervening styling
// rounds correctly left it alone.
#let post-updated = datetime(year: 2026, month: 8, day: 25, hour: 9, minute: 1, second: 0)
#let tz-offset = "+00:00"
#let tz-label = "UTC"

#show: template.with(
  title: "How Do Function Vectors Come into Being and Where Do They Live?",
  description: "Tracing function vectors across 19 pre-training checkpoints of Pythia-410M and Pythia-1B: when causal steering emerges, and how task representations relate to the geometry of loss gradients.",
  // The post's date drives the listing order, `<meta name="date">` and the RSS
  // pubDate. Set to the real publication day so every machine-readable field
  // agrees with `post-published` below; 2026-08-24 was the drafting date and
  // would have left meta/pubDate contradicting article:published_time.
  date: datetime(year: 2026, month: 8, day: 25),
  lang: "en",
  tags: post-tags,
  published: post-published,
)

// Exact series behind each figure, loaded verbatim from the data files.
#let data-table(file) = {
  let rows = csv(file)
  table(
    columns: rows.first().len(),
    table.header(..rows.first().map(h => [#h])),
    ..rows.slice(1).flatten().map(c => [#c]),
  )
}

#let data-details(..blocks) = html.elem(
  "details",
  attrs: (class: "figure-data"),
  {
    html.elem("summary", "Data behind this figure")
    for block in blocks.pos() {
      block
    }
  },
)

= How Do Function Vectors Come into Being and Where Do They Live?

// Decorative opening image. Deliberately not a `#figure`, so it stays out of
// the Figure 1-9 numbering that carries the experimental evidence.
// A block-level container, not `margin-note`: Typst wraps the caption in a
// `<p>`, and a `<p>` inside the `<span class="marginnote">` is invalid HTML,
// so the browser closes the span early and the caption falls into the body
// text. The CSS floats this into the same margin column instead.
#html.elem(
  "div",
  attrs: (class: "post-hero"),
  {
    image(
      "../../imgs/pavilion-bridge-handdrawn-ivory.webp",
      alt: "Hand-drawn ivory-toned illustration of a pavilion beside a bridge.",
    )
    html.elem(
      "span",
      attrs: (class: "hero-caption"),
      "Shantang Street, Suzhou. Photographed 7 July 2025.",
    )
  },
)

#tufted.byline(
  author: post-author,
  published: post-published,
  updated: post-updated,
  offset: tz-offset,
  offset-label: tz-label,
)

#tufted.tag-list(post-tags, class: "blog-tags article-tags")

This blog post documents an exploration undertaken from November 2025 to February 2026. The framework explored here has since been expanded to concept learning in an upcoming preprint. The author warmly thanks Alex Warstadt, Mikhail Belkin, Kyle Mahowald, Neil Mallinar, and Sasha Boguraev for their generous time and valuable feedback throughout this exploration.

== 1. Introduction

Function vectors (#link("https://openreview.net/forum?id=AwyxtyMwaG")[Todd et al., 2024]) are compact, linear directions in activation space extracted from attention head outputs that causally induce specific task behaviors (such as `antonym` generation, `country-capital` retrieval, or translation) when added to the residual stream at inference time.

While the causal efficacy of function vectors in fully trained checkpoints is well established, fundamental questions remain regarding their developmental geometry during pre-training:

1. *How does the function vector evolve across pre-training?* When does causal steering emerge, does discrete decision-flipping develop simultaneously with continuous logit push, and is there an abrupt transition during training?
2. *How does the model's optimization geometry shape this development?* How does the function vector relate to the principal directions of loss gradients as the model learns?

The initial intuition behind this investigation was straightforward: *during pre-training, do task representations align with the loss landscape as gradients “carve out” functionality; and once the capability is consolidated, does the representation decouple from immediate loss gradients?*

Our empirical results reveal a more nuanced picture. By tracing Function Vectors across *19 pre-training checkpoints* (from Step 1 to Step 143,000, spanning five orders of magnitude on a logarithmic schedule) in *Pythia-410M* (evaluated on the `antonym` task) and *Pythia-1B* (evaluated across four core in-context learning tasks: `antonym`, `country-capital`, `english-french`, and `present-past`), and probing optimization geometry using the *Average Gradient Outer Product (AGOP)* (#link("https://doi.org/10.1126/science.adi5639")[Radhakrishnan et al., 2024]) alongside validation on a converged *OLMo-1B* model, we map the geometric lifecycle of task representations:

- In *Pythia-410M*, alignment with task gradient eigenspaces surges sharply around Step 1000 (within the first \~0.7% of training) before settling back to near-chance baseline at convergence.
- In *Pythia-1B*, alignment across four tasks exhibits a multi-peak dynamic: starting near chance, surging to an early peak at Step 1000–2000, experiencing a temporary dip during the middle training stage, and rebounding in late pre-training to settle consistently above chance baseline.

=== Key Takeaways

- *Synchronized Transition within the First \~0.7% of Training:* Function vector efficacy does not emerge gradually. Within the first \~0.7% of pre-training, the model undergoes an abrupt transition: the logit of the target token surges multiple-fold and cleanly diverges from isotropic random baselines, the optimal intervention site migrates from output layers to intermediate layers, and gradient alignment reaches an initial transient peak.
- *Two-Stage Maturation (Logit Push vs. Decision Flipping):* Continuous logit steering ($Delta "logit"$) separates from random control within the first \~0.7% of pre-training across all tasks. However, discrete argmax next-token classification flipping ($Delta "top-1"$) matures significantly later and is model- and task-dependent. Crucially, elevating the target token's logit score does not guarantee flipping the final classification: tasks like `present-past` and `english-french` achieve massive logit gains while exhibiting very weak top-1 separation from random control.
- *Subspace Energy Reorganization:* During the early synchronized transition, the component residing in the task-irrelevant control subspace temporarily surges while the remaining orthogonal portion drops, before both settle back toward baseline. Throughout pre-training, the component parallel to task gradients accounts for only \~9–14% of total energy on Pythia-410M ($k=128$), yet drives the majority of late-stage discrete classification flips, showing that alignment with gradient directions is far more consequential for accuracy than the total energy allocated to that component.
- *Low-Rank Concentration:* The function vector aligns predominantly with the leading few principal gradient directions, rapidly decaying to chance baseline across higher subspace dimensions.
- *Metric-Specific Subspace Alignment:* While the majority (73%–79%) of the vector's energy resides in directions orthogonal to task gradients (driving continuous logit scale on Pythia-410M and OLMo-1B), the component parallel to task gradients is the primary driver of discrete classification flips. In late pre-training, isolating and normalizing the gradient-parallel component ($bold(v)_parallel$) *outperforms the intact Function Vector* in discrete argmax accuracy ($Delta "top-1"$) at optimal intervention layers on Pythia-410M and converged OLMo-1B (on Pythia-1B, this advantage is task-dependent, holding on `country-capital`, `present-past`, and late-stage `antonym`, but not `english-french`). On continuous logit steering ($Delta "logit"$), however, the intact Function Vector remains superior on Pythia-410M and OLMo-1B across Steps 1000 to 143,000.

== 2. Setup & Framework

=== 2.1 Models, Tasks, and Extraction

- *Primary Trajectory Models:*
  - `EleutherAI/pythia-410m` (#link("https://proceedings.mlr.press/v202/biderman23a.html")[Biderman et al., 2023]; $L=24$ layers, $d_"model"=1024$), evaluated across 19 checkpoints on `antonym`: $"Step" in {1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1000, 2000, 4000, 8000, 16000, 32000, 64000, 120000, 143000}$.
  - `EleutherAI/pythia-1b` (#link("https://proceedings.mlr.press/v202/biderman23a.html")[Biderman et al., 2023]; $L=16$ layers, $d_"model"=2048$), evaluated across the identical 19 checkpoints across four tasks (`antonym`, `country-capital`, `english-french`, `present-past`).
- *Cross-Model Validation:* `allenai/OLMo-1B-0724-hf` (#link("https://doi.org/10.18653/v1/2024.acl-long.841")[Groeneveld et al., 2024]; $L=16$ layers evaluated, $d_"model"=2048$) at its final converged checkpoint (`step1454000-tokens3048B`).
- *Task Protocols:* 10-shot in-context learning ($N_"shots"=10$). Extraction set: 128 prompts; Evaluation set: 200 held-out prompt pairs; Random seed: 42. In each evaluation prompt, 10 demonstration pairs are formatted sequentially followed by an incomplete query prompt (e.g., in `antonym`):

  ```text
  Q: flawed
  A: perfect

  Q: orthodox
  A: unorthodox

  ... (8 more demonstration pairs)

  Q: unrelated
  A:
  ```

  The model's greedy completion is evaluated against the target token (` related`, noting the leading space).
- *Function Vector:* Constructed following the causal indirect effect protocol (Todd et al., 2024), summing the outputs of top attention heads (default: top 5 heads) at the final token position.

=== 2.2 Gradient Sensitivity and AGOP

To capture the model's loss landscape geometry, we compute the *Average Gradient Outer Product (AGOP)* matrix with respect to the attention module output $bold(h)^((ell))$ at the final token position under next-token cross-entropy loss as an empirical average over $N=128$ demonstration prompts:

$ bold(G) &= 1/N sum_(i=1)^N nabla_(bold(h)^((ell))) cal(L)(bold(x)_i) dot (nabla_(bold(h)^((ell))) cal(L)(bold(x)_i))^top \
  &in RR^(d_"model" times d_"model") $

Here, $cal(L)$ is the scalar cross-entropy loss on the target token. We use the leading orthonormal eigenvectors ${bold(u)_i}_(i=1)^(d_"model")$ of $bold(G)$ (sorted by descending eigenvalue $lambda_1 >= lambda_2 >= dots$) as the principal gradient subspace basis for projection and alignment measurements.

We construct two distinct AGOP matrices per layer:

1. *Task AGOP ($bold(G)_"task"$):* Computed over clean task ICL prompts, spanning the task-specific gradient subspace $cal(S)_"task" = "span"{bold(u)_1^"task", dots, bold(u)_k^"task"}$.
2. *Control-data AGOP ($bold(G)_"control"$):* Computed over length-matched uniform random token prompts with identical sequence lengths but arbitrary vocabulary tokens, defining a task-irrelevant baseline subspace $cal(S)_"control" = "span"{bold(u)_1^"control", dots, bold(u)_k^"control"}$.

Both AGOP and FV extraction use only the 128-prompt extraction set; the 200 evaluation prompt pairs remain strictly held-out.

=== 2.3 Tri-Orthogonal Subspace Decomposition

To isolate where causal function resides relative to optimization gradients, we decompose the full Function Vector $bold(v)_"full"$ into three components via sequential projection. The construction strictly guarantees that $bold(v)_"struct"$ is orthogonal to the remainder and that $bold(v)_parallel$ is orthogonal to $bold(v)_perp$:#footnote[Sequential projection strictly guarantees that $bold(v)_"struct" perp (bold(v)_parallel + bold(v)_perp)$ and $bold(v)_parallel perp bold(v)_perp$. However, this construction does not generally guarantee that all three components are pairwise mutually orthogonal, because the Task and Control AGOP eigenspaces ($cal(S)_"task"$ and $cal(S)_"control"$) can overlap. On Pythia-1B, the normalized subspace overlap $norm(bold(U)_"task"^top bold(U)_"control")_F^2 / k$ ranges between $0.017$ and $0.129$, which is small in absolute terms but above the random-subspace expectation of $k/d approx 0.00977$ ($k=20, d=2048$). On Pythia-410M, we did not track subspace overlap across training.]

$ bold(v)_"full" = bold(v)_"struct" + bold(v)_parallel + bold(v)_perp $

#figure(
  image("figures/tri-ortho-decomposition.svg", alt: "The full function vector is decomposed by sequential projection into a control-aligned structural component, a task-parallel component, and a task-orthogonal remainder."),
  caption: [Tri-orthogonal subspace decomposition framework. The full Function Vector $bold(v)_"full"$ is projected sequentially onto Control-data AGOP ($cal(S)_"control"$) to obtain $bold(v)_"struct"$, then the structural remainder is projected onto Task AGOP ($cal(S)_"task"$) to obtain $bold(v)_parallel$, leaving the task-orthogonal remainder $bold(v)_perp$.],
)

1. *Structural Component ($bold(v)_"struct"$):* We first project the raw Function Vector $bold(v)_"full"$ onto the top-$k$ eigenspace of Control-data AGOP $cal(S)_"control"$, yielding $bold(v)_"struct" = bold(P)_"control" bold(v)_"full"$. This isolates the portion of the vector aligned with the length-matched random-token control baseline.
2. *Parallel Task Component ($bold(v)_parallel$):* We then take the structural remainder $(bold(v)_"full" - bold(v)_"struct")$ and project it directly onto the top-$k$ eigenspace of the original Task AGOP $cal(S)_"task"$, yielding $bold(v)_parallel = bold(P)_"task" (bold(v)_"full" - bold(v)_"struct")$. Empirically, the task and control eigenspaces are nearly orthogonal in activation space, though this is an empirical property rather than an architectural constraint.
3. *Task-Orthogonal Remainder ($bold(v)_perp$):* The remaining residual vector $bold(v)_perp = bold(v)_"full" - bold(v)_"struct" - bold(v)_parallel$. By construction, $bold(v)_perp$ is strictly orthogonal to the top Task AGOP subspace $cal(S)_"task"$, and is approximately orthogonal to $cal(S)_"control"$ to the extent that task and control eigenspaces are empirically near-orthogonal in activation space.

To test causal behavior without magnitude confounds, each component $bold(v)_"comp" in {bold(v)_"full", bold(v)_parallel, bold(v)_perp, bold(v)_"struct"}$ is normalized to unit norm and scaled by $gamma dot bar(r)_ell$, where $bar(r)_ell = 1/M sum_(j=1)^M norm(bold(h)^((ell))(bold(x)_j))$ is the layer-average activation norm evaluated at the final token position across evaluation prompts, before injection into the residual stream:

$ bold(h)^((ell)) arrow.l bold(h)^((ell)) + gamma dot bar(r)_ell dot bold(v)_"comp"/norm(bold(v)_"comp") $

where $gamma$ is the steering intensity (default $gamma=1.0$).

== 3. Pre-Training Trajectory

Tracking the Function Vector across 19 pre-training checkpoints reveals that task capabilities do not accumulate linearly. Instead, the model undergoes a sharp, multi-metric transition at *Step 1000* (the first \~0.7% of pre-training).

=== 3.1 Causal Metrics and `antonym` Trajectory on Pythia-410M

When the extracted Function Vector is injected at layer $ell$ with intensity $gamma=1.0$, we evaluate two complementary causal metrics across 200 held-out evaluation pairs:

- *$Delta "logit"$ (Continuous Steering Force):* The change in the unnormalized logit score of the correct target token ($y^*$). This measures whether the vector exerts directional push toward the target.
- *$Delta "top-1 accuracy"$ (Discrete Decision Flipping):* The change in greedy argmax accuracy. This measures whether the steering force is strong and calibrated enough to flip final token classification from incorrect to correct.

#figure(
  image("figures/causal_efficacy.svg", alt: "On Pythia-410M antonym, the function vector's logit effect jumps at Step 1000, while discrete top-1 decision flipping matures much later."),
  caption: [Pythia-410M, `antonym`, γ=1.0. Solid = median across the 24 layers (band = 25th–75th percentile); dashed = the single strongest layer. The two panels use different y-scales.],
)

#data-details(
  [*$Delta "logit"$ (target logit)*],
  data-table("data/fig2_logit.csv"),
  [*$Delta "top-1"$ (accuracy)*],
  data-table("data/fig2_top1.csv"),
)

Examining the trajectory in Pythia-410M on `antonym` reveals several key observations:

1. *The Step 1000 Transition:* Read the onset against the random control, not against zero. Up to Step 512 the function vector does no more than an isotropic random vector of the same length (where the random control peak is $+0.909$ vs $+0.690$ for the function vector), so the minor lift before Step 1000 is not specific to the function vector. Across all 24 layers, the cross-layer median $Delta "logit"$ leaps from $+0.473$ at Step 512 to $+2.740$ at Step 1000. Concurrently, the optimal injection site shifts from the final output layer (Layer 23) to intermediate processing layers (Layer 10). Looking at the single strongest layer per checkpoint, the peak effect leaps by $7.15 times$ (from $+0.690$ at Layer 23 at Step 512 to $+4.940$ at Layer 10 at Step 1000). Note that $+4.940$ is the peak at Step 1000; the global trajectory peak across all checkpoints reaches $+6.195$ at Layer 9 at Step 32,000.
2. *Delayed Decision-Flipping Maturation:* While directional logit force emerges at Step 1000, discrete next-token classification flipping develops much later. At Step 1000, $Delta "top-1"$ at Layer 10 is only $0.010$ (2 out of 200 evaluation prompt pairs). From Steps 1000 to 8000, the gap over random control remains small and non-monotonic (0.020 to 0.030, returning to 0.000 at Step 2000). The first checkpoint where the gap reaches $0.100$ and remains sustained above that level is *Step 16,000* ($Delta "top-1" = 0.110$ peak at Layer 9 vs $0.010$ for random control), eventually reaching a peak of $0.410$ at Step 120,000.

=== 3.2 Multi-Task Replication on Pythia-1B

Does this early transition generalize beyond the `antonym` task? Evaluating Pythia-1B across 19 checkpoints on four distinct tasks demonstrates that this two-stage causal maturation is a general property of pre-training dynamics.

#figure(
  image("figures/crosstask_causal_efficacy.svg", alt: "Across four Pythia-1B tasks, logit effects separate from random control at Step 1000, while top-1 separation emerges later and depends on the task."),
  caption: [Pythia-1B, four tasks, γ=1.0, k=20. Each line is the strongest layer at that checkpoint; solid = function vector, thin dashed = a random vector of the same length in the same task.],
)

#data-details(
  [*$Delta "logit"$ (target logit)*],
  data-table("data/fig3_logit.csv"),
  [*$Delta "top-1"$ (accuracy)*],
  data-table("data/fig3_top1.csv"),
)

- *Onset Relative to Random Control (Step 1000):* Up to Step 512, the function vector and random control coincide in every task. At Step 1000, the task-specific logit effect cleanly separates from the random control across all four tasks, with $Delta "logit"$ surging to 2.0–3.2 (7–15$times$ the control level).
- *Task-Dependent Top-1 Maturation:* Discrete next-token decision-flipping ($Delta "top-1"$) remains at zero through Step 512. Here, separation is defined as the first checkpoint where the function vector's $Delta "top-1"$ exceeds that of a same-length random vector. This separation emerges between Steps 2000 and 4000 in three tasks (`antonym`, `country-capital`, and `present-past`), whereas in `english-french` a sustained gap above a single test flip does not establish until Step 32,000.
- *Logit Push Does Not Imply Decision Flipping:* While the Function Vector reliably elevates the target token's logit score, this directional push does not necessarily alter the greedy argmax prediction. While `country-capital` ($Delta "top-1" = 0.205$ at Step 143k) and `antonym` ($0.185$) achieve substantial greedy argmax accuracy gains, `english-french` ($0.070$) and especially `present-past` ($0.060$) exhibit very weak top-1 separation from random control (whose final baseline is $0.050$), despite `present-past` achieving the largest logit effect of all four tasks ($Delta "logit" = 8.06$).

== 4. Optimization Geometry

How does the Function Vector align with the model's loss landscape during training? We project the extracted FV onto the top-$k$ eigenspaces of Task AGOP ($cal(S)_"task"$) and Control-data AGOP ($cal(S)_"control"$).

=== 4.1 Pythia-410M Alignment Trajectory

On Pythia-410M ($k=128$), we track the alignment of the Function Vector with AGOP eigenspaces across training steps compared against both an empirical isotropic random-vector null control and the analytic chance baseline $sqrt(k/d) = sqrt(128/1024) approx 0.354$ (representing the root-mean-square alignment for an isotropic random vector; see Appendix for proof sketch).

#figure(
  image("figures/agop_alignment.svg", alt: "On Pythia-410M, function vector alignment with the task AGOP subspace departs from baseline only around Steps 1000–2000 and returns to chance by convergence."),
  caption: [Pythia-410M, `antonym`, k=128. Line = median across the 24 layers; band = 25th–75th percentile. Solid = the function vector, dashed = an isotropic random vector of the same length. Blue and orange measure alignment with the task AGOP subspace, green and amber with the control AGOP subspace. The chance level $0.354$ is $sqrt(k/d) = sqrt(128/1024)$, the root-mean-square alignment a randomly drawn direction achieves with any 128-dimensional subspace of a 1024-dimensional space.],
)

#data-details(data-table("data/fig4_alignment.csv"))

The measured random control confirms the chance baseline empirically, sitting 2–4% above the analytic line. In the function vector trajectory:

- Alignment with Task AGOP rises above the random control strictly at Steps 1000 and 2000 (reaching $0.479$ and $0.455$, corresponding to gaps of $+0.112$ and $+0.092$ over the measured random control).
- From Step 4000 onward, the gap narrows to $+0.014$ (comparable to early baseline fluctuations), and by Step 143,000 it settles at $0.364$ (a gap of $+0.005$ over the measured random control of $0.359$). Thus, by the end of training, the function vector is no more aligned with task loss gradients than a random direction.
- Notably, *during the middle training stage (Steps 1000–32,000), the Function Vector aligns more strongly with the Control-data AGOP than with the Task AGOP* (e.g., at Step 1000: $0.515$ vs $0.479$, a gap of $+0.037$; at Step 32,000: $0.409$ vs $0.353$, a gap of $+0.056$). The isotropic random vector shows only a small preference for the control subspace ($+0.005$ to $+0.019$), demonstrating that this preference is not purely an artifact of the control subspace itself. The precise mechanism behind this elevated control alignment remains an open question. At convergence, alignment with both subspaces returns to chance level ($0.358$ for Control-data AGOP and $0.364$ for Task AGOP).

=== 4.2 Multi-Task Alignment on Pythia-1B

On Pythia-1B ($k=20$), we evaluate AGOP alignment across all four tasks against the analytic chance baseline $sqrt(k/d) = sqrt(20/2048) approx 0.099$.

#figure(
  image("figures/crosstask_agop_alignment.svg", alt: "On Pythia-1B, AGOP alignment across four tasks peaks at Steps 1000–2000, dips mid-training, and rebounds to settle above chance."),
  caption: [Pythia-1B, four tasks, k=20. Line = median across the 16 layers; band = 25th–75th percentile. The chance level 0.099 is √(k/d)=√(20/2048).],
)

#data-details(data-table("data/fig5_alignment.csv"))

All four tasks scatter around chance until Step 512; early excursions (such as `country-capital` at Step 128 reaching $1.3 times$ chance) are transient and not sustained. From Step 512, all four tasks rise to a peak at Steps 1000–2000 at $1.7$–$2.3 times$ chance (`english-french` peaking at Step 2000 at $2.27 times$ chance; `antonym`, `country-capital`, and `present-past` peaking at Step 1000 at $1.67$–$2.10 times$ chance). The trajectories then experience dips that vary by task (troughing at Step 8000 for `antonym` and `english-french`, Step 16,000 for `country-capital`, and a shallow dip at Step 64,000 for `present-past`), before recovering in late training to settle consistently above chance baseline at convergence ($1.5$–$1.9 times$ chance, ranging from $0.144$ to $0.192$).

The two models used different subspace truncation sizes ($k=128$ for Pythia-410M, $k=20$ for Pythia-1B), so only the qualitative shapes and each model's own endpoint relative to its baseline are comparable, not the raw peak heights. Unlike the 410M evaluations, these 1B runs did not record an empirical random-vector control, so the baseline shown is the analytic chance line.

=== 4.3 Divergent Alignment Dynamics

Across the two model scales, the alignment between Function Vectors and task gradient eigenspaces shows distinct developmental trajectories:

- *Pythia-410M* exhibits a single-peak dynamic: alignment makes a single narrow departure from baseline strictly at Steps 1000–2000 before returning to near-chance levels for the remainder of training.
- *Pythia-1B* exhibits a multi-peak dynamic: alignment rises to an early peak at Steps 1000–2000, dips during intermediate steps, and rebounds in late pre-training to settle stably above chance.

== 5. Subspace Energy

To understand how the Function Vector distributes across the decomposed subspaces, we examine energy allocation across pre-training. For each component $bold(v)_"comp"$, its energy fraction is defined as its normalized squared norm, $"Energy"(bold(v)_"comp") = norm(bold(v)_"comp")^2 / norm(bold(v)_"full")^2$, such that the three components strictly sum to $1.0$. For a single projection, this equals the squared cosine alignment with the subspace. Fixing $k=128$ on Pythia-410M ($d_"model"=1024$), the chance expected energy fraction for an isotropic random vector projected onto the $k$-dimensional control subspace is exactly $k/d = 0.125$. For the task-parallel component $bold(v)_parallel$, the expected energy fraction is $(k - c)/d <= k/d = 0.125$, where $c = "Tr"(bold(P)_"control" bold(P)_"task") >= 0$ measures subspace overlap. For the task-orthogonal remainder ($bold(v)_perp$), the expected energy fraction is $(d - 2k + c)/d >= (d - 2k)/d = 0.750$, achieving the lower bound of $0.750$ when the two subspaces are strictly orthogonal ($c = 0$).

#figure(
  image("figures/energy_decomposition.svg", alt: "Away from Step 1000 the three components sit near random baselines; at Step 1000 the control-aligned structural component surges while the task-orthogonal remainder drops."),
  caption: [Energy decomposition across three subspaces during pre-training for Pythia-410M (evaluated on the `antonym` task). Shaded bands represent the interquartile range across network layers within a single checkpoint. Dashed reference lines denote random-vector baselines: $k/d "reference" = 0.125$ represents the exact expectation for $bold(v)_"struct"$ and an upper reference for $bold(v)_parallel$, while $"orthogonal-subspace lower bound" = 0.75$ marks the theoretical lower bound for $bold(v)_perp$.],
)

#data-details(data-table("data/fig6_energy.csv"))

- *Expected Energy Allocation in $bold(v)_perp$:* Away from Step 1000, all three components sit near their expected random baselines. Across early and final checkpoints, the task-orthogonal remainder $bold(v)_perp$ accounts for 73%–79% of total energy (at Step 143k, the cross-layer median reaches 76.5%, with Layer 10 at 73.3%). This sits near the random-vector expectation of $(d-2k)/d = 0.750$.
- *The Step 1000 Structural Reorganization:* The primary departure occurs at *Step 1000*: the network-wide cross-layer median energy of $bold(v)_"struct"$ rises to 26.6% (about $2.1 times$ chance expectation) while $bold(v)_perp$ drops to 62.0%. At Layer 10, $bold(v)_"struct"$ reaches 47.4% while $bold(v)_perp$ falls to 39.4%. Throughout pre-training, the task-parallel component $bold(v)_parallel$ maintains a steady energy share of \~9–12% (cross-layer median 11.9% at Step 1000, 10.8% at Step 143k).

== 6. Low-Rank Concentration

How deeply does the Function Vector align with the Task AGOP eigenspace? By sweeping the truncation rank $k in {1, 2, 4, 8, 16, 32, 64, 128}$ on Pythia-410M ($d_"model"=1024$) at the final checkpoint (Step 143,000), we measure the *Enrichment Ratio*, defined as the energy fraction of $bold(v)_parallel$ in the top-$k$ Task AGOP subspace divided by the random chance baseline $k / d_"model"$:

$ "Enrichment"(k, ell) = ("Energy fraction of " bold(v)_parallel " in top-" k " subspace")/(k/d_"model") $

#figure(
  image("figures/k_sweep_enrichment.svg", alt: "Function vector alignment is concentrated in the leading 1 to 4 task AGOP eigenvectors and decays to chance by k=128."),
  caption: [Pythia-410M, `antonym`, final checkpoint (step 143000). Band = 25th–75th percentile across layers.],
)

#data-details(data-table("data/fig7_ksweep.csv"))

The Function Vector is concentrated along the *leading 1 to 4 eigenvectors of the Task AGOP matrix*:

- At $k=1$, the cross-layer median reaches $approx 3.4 times$ chance, while Layer 10 reaches $12.6 times$ (and deeper layers such as Layer 12 reach $27.9 times$, Layer 13 reaches $24.5 times$, and Layer 11 reaches $16.4 times$). Layer 10 is highlighted as the primary causal intervention site, not the maximum enrichment layer.
- By $k=128$, the enrichment ratio falls below $1.0$ ($0.87 times$ median, $0.92 times$ at Layer 10). This shows that the task-specific alignment is concentrated in the top few gradient directions, while higher-dimensional subspaces capture energy at or below chance expectation.

== 7. Component Causal Efficacy

When we isolate $bold(v)_"struct"$, $bold(v)_parallel$, and $bold(v)_perp$, scale each to unit layer norm, and inject them individually at inference, how do their causal effects compare to the intact Function Vector?

#figure(
  image("figures/component_causal_effect.svg", alt: "The isolated task-parallel component beats the intact function vector in late-training top-1 flipping, while the intact vector keeps the largest logit push."),
  caption: [Pythia-410M, `antonym`, k=128, γ=1.0. Solid with markers = the strongest layer at that checkpoint; faint dotted in the same colour = the median layer for the same component.],
)

#data-details(
  [*$Delta "logit"$ (target logit)*],
  data-table("data/fig8_logit.csv"),
  [*$Delta "top-1"$ (accuracy)*],
  data-table("data/fig8_top1.csv"),
)

Every component is injected at the same length (rescaled to $gamma$ times the layer's mean activation norm), testing directional efficacy rather than magnitude:

- For continuous logit steering ($Delta "logit"$), the cross-layer median reaches roughly half the single best layer (e.g., full FV at Step 32,000 has median $3.29$ vs peak $6.20$), indicating broadly distributed directional lift across layers.
- For discrete argmax classification ($Delta "top-1"$), the cross-layer median is essentially zero across all components, while the single strongest layer reaches $0.410$ (for the intact Function Vector at Layer 9 at Step 120,000) and $0.320$ (for isolated $bold(v)_parallel$ at Layer 9 at Step 32,000, where the cross-layer median is $0.000$). This shows that decision-flipping is concentrated in specific intermediate intervention layers.

=== 7.1 Metric Divergence on Pythia-410M and OLMo-1B

Decomposing the Function Vector reveals a divergence between continuous logit steering and discrete classification success:

- *Discrete Classification Success ($Delta "top-1"$):* At the single best-performing intervention layer, isolated $bold(v)_parallel$ *outperforms the intact Function Vector in 4 out of the final 5 pre-training checkpoints* on Pythia-410M. At Step 32,000, peak $bold(v)_parallel$ (Layer 9) achieves $Delta "top-1" = 0.320$, exceeding peak full FV ($Delta "top-1" = 0.200$ at Layer 9). At convergence (Step 143k), $bold(v)_parallel$ remains superior ($0.310$ at Layer 12 vs $0.290$ at Layer 9 for full FV). On converged OLMo-1B (`step1454000-tokens3048B`), peak $bold(v)_parallel$ (Layer 6) achieves $Delta "top-1" = 0.360$ compared to $0.125$ for peak full FV at Layer 5 (a *$2.88 times$ improvement*).
- *Continuous Steering Force ($Delta "logit"$):* On Pythia-410M, across all 9 checkpoints from Step 1000 to 143,000 (following initial causal emergence), isolated $bold(v)_parallel$ *never exceeds the intact Function Vector* in continuous logit steering (0 out of 9 checkpoints). The full Function Vector consistently produces the largest raw logit shift on Pythia-410M and OLMo-1B because the orthogonal component $bold(v)_perp$ also contributes continuous logit magnitude.
- *Component Roles in Early vs. Late Training:* At Step 1000 on Pythia-410M, $bold(v)_"struct"$ accounts for the majority of the initial classification effect ($0.040$ vs $0.010$ for $bold(v)_parallel$ and $0.000$ for $bold(v)_perp$, representing 80% of total top-1 flips). However, in late pre-training (Step 143k), $bold(v)_parallel$ accounts for the largest share of classification success (about 55% of the summed component effect, $0.310$ vs $0.050$ for $bold(v)_"struct"$ and $0.200$ for $bold(v)_perp$).

=== 7.2 Cross-Task Component Advantage on Pythia-1B

To test whether isolating $bold(v)_parallel$ improves discrete accuracy across multiple tasks, we evaluate the difference in $Delta "top-1"$ between the isolated task-parallel component $bold(v)_parallel$ and the intact Function Vector across 19 checkpoints in Pythia-1B ($k=20$).

#figure(
  image("figures/crosstask_component_advantage.svg", alt: "The isolated component's top-1 advantage over the intact vector is task-dependent on Pythia-1B: stable for country-capital and present-past, late-emerging for antonym, and absent for english-french."),
  caption: [Pythia-1B, four tasks, γ=1.0, k=20. Each line is the difference between two Δtop-1 accuracies measured at each checkpoint's strongest layer: the isolated task-parallel component minus the intact function vector. Above the zero line the isolated component flips more decisions; below it the intact vector does. Both are injected at the same length.],
)

#data-details(data-table("data/fig9_advantage.csv"))

The component advantage in Pythia-1B shows substantial task-dependent heterogeneity:

- In `country-capital` and `present-past`, the isolated component establishes a stable late advantage (at Step 143,000, difference is $+0.085$ and $+0.015$).
- In `antonym`, the isolated component is below zero at Steps 16,000 ($-0.055$) and 32,000 ($-0.010$), before turning positive from Step 64,000 onward (reaching $+0.070$ at Step 143,000).
- In `english-french`, the isolated component never establishes an advantage over the intact vector, ending at $-0.025$ at Step 143,000.

Furthermore, on continuous logit steering ($Delta "logit"$), Pythia-1B exhibits dynamics distinct from Pythia-410M: on Pythia-1B, $bold(v)_parallel$ frequently exceeds the intact Function Vector in raw logit lift (e.g., at Step 64,000 across all four tasks). The claim that the intact Function Vector consistently produces larger logit shifts is specific to Pythia-410M and OLMo-1B (both evaluated on `antonym`).

=== 7.3 Margin Selectivity and Classification Mechanics

Why does $bold(v)_parallel$ flip more discrete decisions despite producing a smaller raw target logit increase on Pythia-410M? An inspection of prediction margins ($"margin" = "target logit" - "top competing logit"$) reveals how the three components navigate the trade-off between push magnitude and selectivity:

- At Step 32,000 (Layer 9), $bold(v)_parallel$ achieves the highest margin gain ($Delta "margin" = 4.60$, $Delta "top-1" = 0.320$) by combining strong target push ($Delta "logit" = 5.79$) with moderate competitor lift ($+1.19$). In contrast, $bold(v)_"struct"$ produces matching target push ($Delta "logit" = 5.84$) but elevates competing logits heavily ($+3.49$, $Delta "margin" = 2.34$, $Delta "top-1" = 0.030$). Meanwhile, $bold(v)_perp$ is the most selective (elevating competitors by only $+0.34$, $Delta "margin" / Delta "logit" = 0.89$) but achieves a smaller raw margin ($Delta "margin" = 2.73$) and flips very few decisions ($Delta "top-1" = 0.010$, 2 of 200).
- At Step 143,000 (Layer 10), $bold(v)_parallel$ produces the largest margin gain ($Delta "margin" = 2.88$, shifting competing logits by $-0.16$, $Delta "top-1" = 0.230$), while $bold(v)_"struct"$ and $bold(v)_perp$ elevate competing logits by $+1.91$ ($Delta "margin" = 0.40$, $Delta "top-1" = 0.010$) and $+1.13$ ($Delta "margin" = 1.68$, $Delta "top-1" = 0.050$), respectively.

This pattern is corroborated in probability space by target-versus-rest log-odds ($Delta "odds"_"all" = Delta log p(y^*)/(1 - p(y^*))$): at Step 32,000 (Layer 9), $bold(v)_parallel$ achieves $Delta "odds"_"all" = +4.86$ compared to $+3.45$ for $bold(v)_"struct"$ and $+3.28$ for $bold(v)_perp$.

These measurements show that discrete classification flipping requires both sufficient target push and selectivity against competitor elevation: $bold(v)_"struct"$ pushes strongly but non-selectively, $bold(v)_perp$ is selective but weak in raw margin at Step 32,000, and only $bold(v)_parallel$ satisfies both criteria at both checkpoints examined (note: $"top competing logit"$ tracks the maximum logit among non-target tokens, and the identity of this maximizing token may change before and after intervention).

== 8. Limitations

We explicitly state the empirical boundaries of this study:

1. *Model and Checkpoint Scope:* Full developmental trajectories across 19 pre-training checkpoints are analyzed on Pythia-410M and Pythia-1B. Validation on OLMo-1B is restricted to its single converged checkpoint (`step1454000-tokens3048B`), as intermediate pre-training checkpoints were not available. On Pythia-410M, the control-aligned component $bold(v)_"struct"$ plays a non-trivial causal role in the middle training stage that it does not retain at convergence; because OLMo-1B provides only a converged checkpoint, this mid-training trajectory has not yet been tested there.
2. *Layer Variance vs. Statistical Error:* Shaded bands in our figures represent the interquartile range (25th–75th percentile) across network layers within a single checkpoint run, illustrating how intervention efficacy varies across injection layers. They do not represent sampling variance across evaluation prompts or cross-seed training variance. The study plots no statistical error bars.
3. *Subspace Hyperparameters:* The multi-task component advantage evaluation on Pythia-1B was conducted with a single random seed and fixed subspace rank $k=20$.

== 9. Conclusion

By observing Function Vector causal efficacy throughout pre-training and decomposing vectors against empirical loss gradient eigenspaces (AGOP), we map the developmental geometry of linear task representations:

- *Phase Transition at Step 1000 (\~0.7% of Pre-Training):* In both Pythia-410M and Pythia-1B, task-directed continuous steering ($Delta "logit"$) cleanly separates from isotropic random baselines, coinciding with a shift in optimal injection sites to intermediate layers and an initial peak in gradient subspace alignment.
- *Staggered Emergence of Logit Steering vs. Decision Flipping:* Discrete classification flipping ($Delta "top-1"$) develops substantially later (Steps 2000–4000 in Pythia-1B, Step 16,000 in Pythia-410M). Strong logit push does not guarantee argmax decision flips, as shown by weak top-1 separation on `english-french` and `present-past`.
- *Divergent Alignment Dynamics:* Pythia-410M exhibits a single-peak dynamic (a narrow departure strictly at Steps 1000–2000 before returning to chance baseline), while Pythia-1B displays a multi-peak trajectory that rebounds in late pre-training to settle stably above chance.
- *Low-Rank Concentration:* Gradient alignment is concentrated along the leading $k <= 4$ eigenvectors of the Task AGOP matrix (reaching $12.6 times$ enrichment at $k=1$ in Layer 10 of Pythia-410M), decaying to chance expectation across higher dimensions.
- *Metric-Specific Subspace Specialization:* Separating the task-parallel component ($bold(v)_parallel$) from the control subspace ($bold(v)_"struct"$) and task-orthogonal nullspace ($bold(v)_perp$) yields vectors that outperform intact Function Vectors in discrete classification success ($Delta "top-1"$) at optimal intervention layers in late pre-training across Pythia-410M, converged OLMo-1B, and select Pythia-1B tasks, while intact Function Vectors maintain higher continuous logit push on Pythia-410M and OLMo-1B.

== Appendix: Expected Energy Fraction Proof Sketches

The theoretical baselines for subspace energy and alignment derive from projection properties of isotropic random vectors:

1. *Energy Fraction in a $k$-Dimensional Subspace ($EE = k/d$):* For a standard Gaussian random vector $bold(v) tilde.op cal(N)(bold(0), bold(I)_d)$, the total energy $norm(bold(v))^2 tilde.op chi^2(d)$. Projecting $bold(v)$ onto an arbitrary $k$-dimensional subspace yields projected energy $X = norm(bold(P)_k bold(v))^2 tilde.op chi^2(k)$, while the orthogonal component $Y = norm(bold(v) - bold(P)_k bold(v))^2 tilde.op chi^2(d-k)$. Since $X$ and $Y$ are independent, the energy fraction $R = X / (X + Y)$ follows a Beta distribution $"Beta"(k/2, (d-k)/2)$. Its expected value is:

   $ EE[R] = (k/2)/(k/2 + (d-k)/2) = k/d $

   The root-mean-square cosine alignment is $sqrt(EE[R]) = sqrt(k/d)$.

2. *Task-Parallel Component ($bold(v)_parallel = bold(P)_"task" (bold(I) - bold(P)_"control") bold(v)$):*

   $ EE[norm(bold(v)_parallel)^2] &= ("Tr"((bold(I) - bold(P)_"control") bold(P)_"task" (bold(I) - bold(P)_"control")))/d \
     &= ("Tr"(bold(P)_"task" - bold(P)_"control" bold(P)_"task"))/d \
     &= (k - c)/d <= k/d $

   where $c = "Tr"(bold(P)_"control" bold(P)_"task") >= 0$ is the subspace overlap. Thus $k/d$ serves as an upper bound, with equality achieved if and only if the subspaces are strictly orthogonal ($c = 0$).

3. *Task-Orthogonal Remainder ($bold(v)_perp = (bold(I) - bold(P)_"task") (bold(I) - bold(P)_"control") bold(v)$):*

   $ EE[norm(bold(v)_perp)^2] &= 1 - EE[norm(bold(v)_"struct")^2] - EE[norm(bold(v)_parallel)^2] \
     &= 1 - k/d - (k - c)/d \
     &= (d - 2k + c)/d >= (d - 2k)/d $

   Thus $(d - 2k)/d$ serves as an exact lower bound, achieved if and only if the task and control subspaces are strictly orthogonal ($c = 0$).

== References

- Todd, E., Li, M., Sen Sharma, A., Mueller, A., Wallace, B. C., & Bau, D. (2024). Function Vectors in Large Language Models. _The Twelfth International Conference on Learning Representations (ICLR 2024)_. #link("https://openreview.net/forum?id=AwyxtyMwaG")
- Radhakrishnan, A., Beaglehole, D., Pandit, P., & Belkin, M. (2024). Mechanism for feature learning in neural networks and backpropagation-free machine learning models. _Science_, 383(6690), 1461–1467. #link("https://doi.org/10.1126/science.adi5639")
- Biderman, S., Schoelkopf, H., Anthony, Q. G., Bradley, H., O'Brien, K., Hallahan, E., Khan, M. A., Purohit, S., Prashanth, U. S., Raff, E., Skowron, A., Sutawika, L., & Van Der Wal, O. (2023). Pythia: A Suite for Analyzing Large Language Models Across Training and Scaling. _Proceedings of the 40th International Conference on Machine Learning_, PMLR 202, 2397–2430. #link("https://proceedings.mlr.press/v202/biderman23a.html")
- Groeneveld, D., Beltagy, I., Walsh, E., Bhagia, A., Kinney, R., Tafjord, O., Jha, A., Ivison, H., Magnusson, I., Wang, Y., Arora, S., Atkinson, D., Authur, R., Chandu, K., Cohan, A., Dumas, J., Elazar, Y., Gu, Y., Hessel, J., … Hajishirzi, H. (2024). OLMo: Accelerating the Science of Language Models. _Proceedings of the 62nd Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers)_, 15789–15809. #link("https://doi.org/10.18653/v1/2024.acl-long.841")

#tufted.citation(
  key: "wang2026functionvectors",
  author: post-author,
  title: "How Do Function Vectors Come into Being and Where Do They Live?",
  year: "2026",
  month: "aug",
  url: "https://ypwang.one/Blog/fv-agop-dev-interp/",
  urldate: "2026-08-25",
  note: "Blog post",
)
