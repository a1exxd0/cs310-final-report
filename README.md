<div align="center">

[![Typst](https://img.shields.io/badge/Built_with-Typst-239dad)](https://typst.app/)
[![Stars](https://img.shields.io/github/stars/a1exxd0/cs310-final-report)](https://github.com/a1exxd0/cs310-final-report/stargazers)
[![Last commit](https://img.shields.io/github/last-commit/a1exxd0/cs310-final-report)](https://github.com/a1exxd0/cs310-final-report/commits)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

# Implementing and Empirically Evaluating the Mixture-of-Superpositions-based Protocol for Classically Verifiable Quantum Learning

**CS310 Final Year Project Report — University of Warwick**

Alex Do · Supervised by Dr. Matthias Caro · April 2026

</div>

---

### Abstract

We present the first faithful implementation and systematic empirical evaluation of the Mixture-of-Superpositions (MoS) protocol for classically verifiable quantum learning, due to Caro, Hinsche, Ioannou, Nietner, and Sweke. The protocol enables a classical client to delegate a distribution-agnostic Boolean-function learning task to an untrusted quantum server and verify the result using only classical samples. Our implementation comprises two Python packages: a state-level simulator that prepares MoS quantum examples and performs Fourier sampling via postselected Hadamard measurement, and a protocol-level layer that realises the four-step interactive proof between a quantum prover and a classical verifier. We design seven experiments, spanning over 30,000 trials, that probe the protocol along four empirical axes: completeness, soundness, robustness, and sensitivity. Beyond preconditions, we identify two failure modes: a vanishing-margin acceptance ceiling for adversarial mixed-coefficient strategies and a sharp prover-side breakdown under per-gate depolarising noise, the latter lying outside the scope of current theoretical analyses. We discuss limitations including sub-analytic sample budgets, exponential simulation cost, and the absence of real hardware execution, and outline directions for future work.

### Companion Code

The implementation accompanying this report is available at [**a1exxd0/mos-quantum-learning**](https://github.com/a1exxd0/mos-quantum-learning).

### Prerequisites

- [Typst](https://typst.app/) (`brew install typst` on macOS)

### Build

```sh
typst compile main.typ   # build PDF
typst watch main.typ     # recompile on changes
```
