#import "../../template.typ": definition

== Interactive Proof Systems <sec:ips>

An interactive proof system formalises the idea that a computationally weak party (the _verifier_)
can become convinced of the truth of a statement by engaging in a dialogue with a powerful party
(the _prover_). The notion was introduced by Goldwasser, Micali, and Rackoff @Goldwasser_1985.

#definition(name: "Interactive proof system")[
  An _interactive proof system_ for a language $L$ is a protocol between a computationally unbounded
  prover $P$ and a probabilistic polynomial-time verifier $V$. After exchanging a polynomial number
  of messages on common input $x$, the verifier outputs _accept_ or _reject_. The protocol must
  satisfy:

  + *Completeness:* for each $k$ and for sufficiently large $x in L$, the verifier $V$ halts and
    accepts with probability at least $1 - |x|^(-k)$.
  + *Soundness:* for each $k$ and for sufficiently large $x in.not L$, for any cheating prover $P'$,
    the verifier $V$ accepts with probability at most $|x|^(-k)$.
] <def:ips>

The complexity class _NP_ can be viewed as a degenerate interactive proof: the prover sends a single
certificate and the verifier checks it _deterministically_ and in polynomial time with perfect
soundness. Allowing the verifier to use randomness and to exchange multiple rounds of messages with
the prover yields a more powerful proof model. The resulting complexity class _IP_, the set of all
languages admitting an interactive proof system, was shown by Shamir @Shamir_1992 to equal _PSPACE_.
Thus:

#math.equation(
  block: true,
  numbering: none,
)[
  _NP_ $subset.eq$ _IP_ $=$ _PSPACE_
]

=== Beyond Language Recognition

@def:ips is stated for language membership, but the IP paradigm extends naturally to settings where
the claim being verified is not "$x in L$" but rather "a computation was performed correctly".

The protocol of Caro et al. @Caro_2023 is an instance of this pattern. The claim under verification
is that a quantum learner has produced a hypothesis that approximates a target Boolean function $f$.
The prover is a bounded-error quantum polynomial-time (BQP) machine and the verifier is entirely
classical (BPP). In their protocol, the verifier issues challenges and checks the prover's responses
against classical samples, which we will explore in @sec:verifying-ql.
