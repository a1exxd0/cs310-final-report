== Classically Verifying Quantum Learning <sec:verifying-ql>

Following from the notion of an interactive proof system (@def:ips) and developing from the previous
@sec:fourier-analysis, the central question (which we implement in this report) becomes: can a
classical verifier, with access to only classical random examples or statistical queries, reliably
delegate an agnostic learning task to an untrusted quantum prover?

Goldwasser, Rothblum, Shafer, and Yehudayoff @Goldwasser_2021 introduce a formal framework of
interactive proofs for Probably Approximately Correct (PAC) learning. A key observation of their
work is that verification is trivial in the realizable PAC setting (the verifier can simply test the
prover's hypothesis on fresh examples) but becomes non-trivial in the agnostic setting, where
optimal achievable error is unknown to both parties. In the agnostic case, checking whether a
candidate hypothesis is near-optimal requires knowledge of the best-in-benchmark-class error, which
is what makes the learning problem hard.

However, Caro, Hinsche, Ioannou, Nieter, and Sweke @Caro_2023 extend this framework to the quantum
setting. Their main result establishes an efficient one-round interactive protocol to solve
distributional 1-agnostic parity learning over a restricted class of distributions. We will explore
this protocol in @ch:mos.
