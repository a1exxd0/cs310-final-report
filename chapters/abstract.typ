#pagebreak(weak: true)
#v(1fr)
#pad(x: 2cm)[
  #align(center)[
    #text(size: 17pt, weight: "bold")[Abstract]
    #v(0.5em)

    We present the first faithful implementation and systematic empirical evaluation of the
    Mixture-of-Superpositions (MoS) protocol for classically verifiable quantum learning, due to
    Caro, Hinsche, Ioannou, Nietner, and Sweke. The protocol enables a classical client to delegate
    a distribution-agnostic Boolean-function learning task to an untrusted quantum server and verify
    the result using only classical samples. Our implementation comprises two Python packages: a
    state-level simulator that prepares MoS quantum examples and performs Fourier sampling via
    postselected Hadamard measurement, and a protocol-level layer that realises the four-step
    interactive proof between a quantum prover and a classical verifier. We design seven
    experiments, spanning over 30,000 trials, that probe the protocol along four empirical axes:
    completeness, soundness, robustness, and sensitivity. Beyond preconditions, we identify two
    failure modes: a vanishing-margin acceptance ceiling for adversarial mixed-coefficient
    strategies and a sharp prover-side breakdown under per-gate depolarising noise, the latter lying
    outside the scope of current theoretical analyses. We discuss limitations including sub-analytic
    sample budgets, exponential simulation cost, and the absence of real hardware execution, and
    outline directions for future work.
  ]

  #v(5em)

  #align(center)[
    #par(justify: false)[
      *Keywords:* Quantum Verification, Mixture of Superpositions, Fourier Learning,
      Distribution-Agnostic learning, Boolean Function Learning, Classical Verification
    ]
  ]
]
#v(1fr)
