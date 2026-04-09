= Introduction <ch:intro>

== Motivation <sec:motivation>

The delegation of learning tasks to untrusted third parties is useful only when the delegating party
is able to verify that the task has been performed correctly. A computationally weak client that
entrusts a learning problem to a data-rich or compute-rich server must possess some mechanism,
necessarily based on its own limited resources, for distinguishing a correct hypothesis from an
incorrect one. Goldwasser, Rothblum, Shafer, and Yehudayoff @Goldwasser_2021 formalize this
framework, and establish that verification is straightforward in the realisable PAC setting, but
substantially more difficult in the agnostic setting, where the optimal achievable error is unknown
to both parties in advance.

The problem is more acute when the server is quantum. Quantum learners with access to superposition
example states can achieve sample complexities unmatched by known classical procedures
@Bshouty_1995, but for the foreseeable future, such states will be preparable only by specialised
devices accessed remotely. A classical client wishing to benefit from this advantage must therefore
be able to certify the quality of the returned hypothesis using only classical samples and a short
interaction.

Caro, Hinsche, Ioannou, Nietner, and Sweke @Caro_2023 provide the first protocol meeting this
requirement for a non-trivial task. They introduce the Mixture-of-Superpositions (MoS) quantum
example and use it to construct a one-round interactive protocol in which a classical verifier
delegates distributional 1-agnostic parity learning to an untrusted quantum prover.

However, the theoretical guarantees are asymptotic, constants are large and the soundness bound is
universal and uninformative on specific individual cheating strategies. This report provides both a
first-ever implementation of the MoS state as well as a characterisation of the preceding statement.

== Research Questions <sec:questions>

This report seeks to address the following questions:
+ Can the MoS construction and @Caro_2023[Thm. 12] protocol be implemented in a manner faithful to
  @Caro_2023, and satisfy the sanity conditions applied by theory (Parseval's identity,
  post-selection rate, attenuation bounds)?
+ At feasible sample budgets, does the honest pair $(V, P)$ accept with probability
  $gt.eq 1 - delta$ and do cheating strategies induce rejection at rates consistent with soundness
  analysis?
+ How tight are the protocol's preconditions in practice? In particular, how does the Fourier
  resolution threshold $theta.alt$ act as it crosses its formal validity boundary?

== Objectives and Contributions <sec:contributions>

The objective of this report is to provide first and foremost an empirical characterisation of the
protocol from Caro et al. @Caro_2023[Thm. 12], together with a re-usable MoS-state emulator. The
contributions are as follows:
+ A faithful implementation of the MoS protocol, split into a state-level package (`mos`) with both
  a circuit-based and `Statevector`-based implementation, and a protocol-level package `ql`
  realising the pair $(V, P)$ from @Caro_2023[Thm. 12]. @lemma:original establishes the equivalence
  of the two backends and enables fast completeness simulations up to $n=16$.
+ Seven experiments across soundness, completeness, robustness, and parameter sensitivity, each
  targeting a specific result from Caro et al. @Caro_2023.
+ A novel empirical study of per-gate depolarising noise with no corresponding statement in
  @Caro_2023.
+ An explicit account of evidence limitations: hard-coded budgets, finite cheating strategies, and
  no real hardware execution during experimentation. Follow-up work is addressed in @ch:conclusions.

== Report Structure <sec:structure>

@ch:background begins by covering the necessary background in quantum information, interactive proof
systems, agnostic learning, and the Fourier analysis of specifically Boolean functions. @ch:mos
presents the MoS construction and the four-step protocol from @Caro_2023[Thm. 12] from a theoretical
standpoint. @ch:implementation describes the implementation of that protocol. @ch:experiments
reports on the 7 completed experiments. @ch:discussion discusses theory alignment, failure modes and
limitations, and finally @ch:conclusions concludes and proposes future work.
