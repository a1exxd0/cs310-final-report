== Architecture Overview <sec:architecture-overview>

The implementation of the Caro et al. @Caro_2023 protocol in @thm:protocol is split into two Python
packages that reflect a deliberate separation between _state_-level quantum machinery and
_protocol_-level interactive verification. Throughout this implementation, we heavily rely on the
Qiskit @Qiskit_2024 package, an open source, Python-based, high-performance software stack for
quantum computing.

#figure(
  caption: text[
    A summary of files directly responsible for protocol simulation and their corresponding links to
    theory.
  ],
  gap: 1em,
)[
  #table(
    columns: (auto, auto, auto, auto),
    inset: 5pt,

    align: auto,
    table.header([*Package*], [*Module*], [*Public classes*], [*Report anchor*]),

    `mos`, `mos/__init__.py`, `MoSState`, text[@def:mos (MoS state); @sec:mos-construction],

    `mos`, `mos/sampler.py`, text[`QuantumFourierSampler`; `QFSResult`], text[@sec:qfs-from-mos],

    `ql`,
    `ql/prover.py`,
    text[`MoSProver`; `SpectrumApproximation`; `ProverMessage`],
    text[@thm:protocol; Corollary 5 and Lemma 3 of Caro et al. @Caro_2023],

    `ql`,
    `ql/verifier.py`,
    text[`MoSVerifier`; `ParityHypothesis`; `FourierSparseHypothesis`; `VerificationResult`],
    text[@thm:protocol],
  )
]

