== Alignment with known theory and bounds <sec:tight-bounds>

Across all 7 experiments in @ch:experiments, every cell whose target distribution lies inside the
formal preconditions of Caro et al. @Caro_2023[Lemma 1] reproduces the relevant analytic prediction
to within sampling noise. The strongest such quantitative agreement comes from the label-flip noise
sweep of @sec:robustness-label-flip. @Caro_2023[Lemma 6] predicts the conditional QFS mass of $s^*$
is attenuated by exactly $(1 - 2 eta)^2$ under independent flips of rate $eta$. At every
$eta lt 0.42$ this satisfies, with deviation rising monotnically with $eta$ as expected from
sampling variance on a vanishing signal. In the _empty list_ input case, it transitions sharpy at
$approx 0.447$, the root at which the acceptance margin $(1 - 2 eta)^2 - epsilon^2/8$ becomes
negative.

The remaining alignments are qualitatively cleaner, but quantitatively weaker.
@thm:approx_sampling's $1/2$ post-selection weight in the scaling experiment
@sec:completeness-scaling lies in $[0.496, 0.502]$; honest acceptance is 100% in the same sweep.

The @Caro_2023[Corollary 5] list-extraction prediction is exercised most cleanly by the
bent-function experiment in @sec:sensitivity-bent, at the crossover $n approx 5.47$ where
$|hat(g)(s)| = 2^(-n/2)$ falls below $theta.alt$ and the recovered list size collapses to one or two
spurious entries at $n=6$. This exactly straddles the predicted boundary. @sec:sensitivity-theta
produces a similar result via a heatmap in the dual direction: Acceptance is preserved up to
$theta.alt = 0.2$, the precise point at which the small-coefficient promise of
@Caro_2023[Definition. 11, 13] fail.

For adverarial tries in soundness-testing, we saw no bad accepts except for accidental inclusions in
the _random list_ strategy matching theory to within sampling noise.
