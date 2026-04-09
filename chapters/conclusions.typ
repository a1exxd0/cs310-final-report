= Conclusions and Future Work <ch:conclusions>

This report has presented an end-to-end implementation and empirical evaluation of the
mixture-of-superpositions-based classical verification protocol for quantum parity learning
introduced by Caro et al. @Caro_2023. To our knowledgement, this is the first systematic measurement
of the protocol's concrete behaviour, complementing its existing asymptotic guarantees.

== Summary of Contributions <sec:conclusions-summary>

The mixture-of-superpositions implementation described in @ch:implementation separates state-level
quantum machinery (the `mos` package and its sampler) from protocol level interactive verification
work (the `ql` package realising the verifier-prover pair $(V, P)$). Two sampling backends are
provided:
+ A faithful circuit-based preparation of $|psi_f chevron.r$ directly from Hadamard and MCX gates,
+ A lower-overhead `Statevector` construction of which we show in @lemma:original to be equivalent
  in the noiseless case.

This dual path is what makes both the gate noise experiment from @sec:robustness-gate-noise and the
completeness sweep in @sec:completeness-scaling up to $n = 16$ feasible on the same codebase.

For experimentation, we explore four axes: completeness (@sec:completeness), soundness
(@sec:soundness), robustness (@sec:robustness), and sensitivity (@sec:sensitivity). The overarching
empirical picture is that the protocol in @thm:protocol is exactly as correct and exactly as brittle
as theory says it should be.

However, we explore a small exception to this in @sec:robustness-gate-noise, where Caro et al.
@Caro_2023 do not provide any theoretical bounds on the effects of gate noise on the protocol - the
observed cliff at $n = 6$ remains an open empirical question rather than a direct violation of any
known bound.

== Future Work <sec:conclusions-future-work>

We group future direction by the limitation each addresses, in roughly decreasing order of impact on
the conclusions this report can presently support.

=== Validation at analytic sample budgets

Recall @sec:limitations. Every experiment in @ch:experiments hard-codes its shot and sample counts
orders of magnitude below the @Caro_2023[Thm. 12] Hoeffding bound. Re-running at least the soundness
experiments at the full analytic budget (feasible if left running for multiple days on DCS clusters)
would upgrade the present empirical agreement from a "good-enough"-state to an exact model of the
paper.

=== A formal treatment of per-gate depolarising noise

Whilst Ma, Su, and Deng @Ma_2024 partially admit a solution to circuit noise, neither bound in their
paper covers depolarizing noise inside the QFS circuit. A natural theoretical extension is to show
that under gate noise, our empirically-observed uniform noise floor is tight, or identify a distinct
scaling. It is worth acknowledging what Ma et al. @Ma_2024 do provide a more general algorithm which
relaxes independence assumptions slightly but limit the probability of a given bit flip to some
parameter $eta$.

=== Execution on real quantum hardware

All measurements in this report come from classical simulation. Running any $n lt.eq 8$ subset of
our experiments on publicly accessible backends (IBM Quantum) would stress-test the protocol under a
noise profile that is neither i.i.d. label-flip, nor symmetric per-gate depolarising. Instead, we
are able to observe hardware characteristics such as cross-talk, decay, or biased readout.
Interestingly, the gate-noise cliff of @sec:robustness-gate-noise gives us a concrete success
criterion: any backend whose effective per-gate error sits below the $10^(-3)$ region of
@fig:robustness_2 should admit honest acceptance at $n = 6$.
