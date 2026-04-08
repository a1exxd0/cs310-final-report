== Classical Verifier <sec:verifier>

The honest quantum prover from @sec:prover and the verifier $V$ we implement here together realise
the (V, P) pair of @thm:protocol.

Upon reciept of prover $P$'s list, we immediately perform the list size check in step three of
@thm:protocol, before any classical samples are drawn from $cal(D)$:

#figure(
  caption: text[
    List size bound derived from @thm:parseval-identity.
  ],
)[
  ```py
  # ql/verifier.py:464-479
  list_size_bound = int(np.ceil(64.0 * b_sq / theta**2))

  if len(L) > list_size_bound:
      return (
        VerificationResult(
          outcome=VerificationOutcome.REJECT_LIST_TOO_LARGE, ...
        )
      )
  ```
]

Then, performing independent re-estimation, we calculate a per-coefficient tolerance depending on
the hypothesis type from @fig:verifier_types, and derive the accumulated-weight check from Caro et
al. @Caro_2023[eq. 109, 118]:

#figure(
  caption: text[
    Tolerance and acceptance-threshold bounding on results for verification.
  ],
)[
  ```py
  # ql/verifier.py:486-533
  if hypothesis_type == HypothesisType.PARITY:
      per_coeff_tolerance = epsilon**2 / (16.0 * max(L_size, 1))
  else:
      per_coeff_tolerance = epsilon**2 / (256.0 * k**2 * max(L_size, 1))

  num_samples = int(
      np.ceil(2.0 / per_coeff_tolerance**2 * np.log(4.0 * L_size / delta))
  )

  accumulated_weight = sum(verifier_estimates.get(s, 0.0) ** 2 for s in L)
  if hypothesis_type == HypothesisType.PARITY:
      acceptance_threshold = a_sq - epsilon**2 / 8.0
  else:
      acceptance_threshold = a_sq - epsilon**2 / (128.0 * k**2)

  if accumulated_weight < acceptance_threshold:
      return VerificationResult(
          outcome=VerificationOutcome.REJECT_INSUFFICIENT_WEIGHT, ...
      )
  ```
]

The variable `verifier_estimates` from above is derived by a coefficient estimation function within
the verifier completely independent of the prover.

#figure(
  caption: "Classical sampling protocol for the verifier.",
)[
  ```py
  # ql/verifier.py:597-617
  xs, ys = self.state.sample_classical_batch(
      num_samples=num_samples,
      rng=self._rng,
  )

  signed_labels = 1.0 - 2.0 * ys.astype(np.float64)
  estimates: dict[int, float] = {}
  for s in L:
      parities = np.array(
          [bin(s & int(x)).count("1") % 2 for x in xs],
          dtype=np.float64,
      )
      chi_s = 1.0 - 2.0 * parities
      est = float(np.mean(signed_labels * chi_s))
      estimates[s] = est
  ```
]
