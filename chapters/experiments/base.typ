= Experiments and Results <ch:experiments>

This chapter reports 7 experiments that evaluate the mixture-of-superpositions verification protocol
of Caro et al. @Caro_2023. Each experiment tests a specific theorem, lemma, or corollary of the
paper on a dedicated target class. All experiments were ran on the University of Warwick's DCS batch
compute system, specifically on the `tiger` node, with experiments supporting distributed trials and
Protobuf-based result aggregation and processing.

The four experimental areas are: completeness on honest provers (@sec:completeness), soundness on
dishonest provers (@sec:soundness), robustness to noise and distributional assumptions
(@sec:robustness), and parameter sensitivity and practical limitations (@sec:sensitivity). Three
structural caveats apply throughout: firstly, every experiment hard-codes sample budgets at values
that are orders of magnitude less than the analytic Hoeffding requirement of Caro et al.
@Caro_2023[Thm. 12], so the experiment maps boundaries and mechanisms rather than asymptotic
complexity. This is an explicit limitation of simulating the computations on classical machinery.
Next, some experiments deliberately operate _off-promise_ in order to probe failure cases where
formal preconditions are violated. Third, soundness in Caro et al. @Caro_2023[Definition 7] is
universally quantified. The cheating strategies in this chapter constitute an empirical spot-check
as opposed to a proof of the universal statement.

Unless otherwise stated, let $epsilon = 0.3, delta = 0.1, theta.alt = epsilon = 0.3$, and
$a^2 = b^2 = 1$.

#include "completeness.typ"
#include "soundness.typ"
#include "robustness.typ"
#include "sensitivity.typ"
#include "summary.typ"
