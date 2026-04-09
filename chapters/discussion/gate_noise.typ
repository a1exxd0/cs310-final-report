== Gate noise as an open frontier

@sec:robustness-gate-noise is the only experiment we produce outside the promise universe of Caro et
al. @Caro_2023, whose analysis treats the quantum prover as a black box. Subsequent work by Ma, Su,
and Deng @Ma_2024 partially close this gap and provide the some analytic perspective in which the
cliff observed at $n gt.eq 6$ can be interpreted.

Ma et al. @Ma_2024 consider two noise models the original Caro et al. @Caro_2023 paper do not. The
first is _measurement noise_: independent bit flips of rate $eta$ applied to the QFS output string
after the circuit has been executed. They prove that under this model, the parity-learning verifier
is still 1-agnostically verifiable. The second is end-of-circuit depolarisation of the QFS state,
treated as a per-qubit depolarizing channel where they prove that 1-agnostic verifiability survives
under some conditions. Both bounds are output-side: per gate depolarising noise does not appear
directly in either statement and formalized theory is yet to be explored here.
