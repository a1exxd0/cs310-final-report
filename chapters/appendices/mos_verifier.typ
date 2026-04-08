= Implementation of the Verifier from Caro et al. @Caro_2023

For the sake of conciseness, all comments have been removed from all appendices, but are available
in source code. The file we describe in this appendix `ql/verifier.py` is especially large, so we
omit less important code.

== Verification outcomes and hypothesis types <fig:verifier_types>
#figure(
  caption: text[
    Classes representing outcomes of the protocol and hypotheses over Caro et al. @Caro_2023[Theorem
      12, 15].
  ],
)[
  ```py
  class VerificationOutcome(Enum):
      ACCEPT = "accept"
      REJECT_LIST_TOO_LARGE = "reject_list_too_large"
      REJECT_INSUFFICIENT_WEIGHT = "reject_insufficient_weight"

  class HypothesisType(Enum):
      PARITY = "parity"
      FOURIER_SPARSE = "fourier_sparse"
  ```
]

== Parity hypothesis for 1-agnostic learning <fig:verifier_parity_hypothesis>
#figure(
  caption: text[
    Output hypothesis of the protocol from @Caro_2023[Theorem 12].
  ],
)[
  ```py
  @dataclass(frozen=True)
  class ParityHypothesis:
      s: int
      n: int
      estimated_coefficient: float

      def evaluate(self, x: int) -> int:
          return bin(self.s & x).count("1") % 2

      def evaluate_batch(self, xs: np.ndarray) -> np.ndarray:
          return np.array(
              [bin(self.s & int(x)).count("1") % 2 for x in xs],
              dtype=np.uint8,
        )
  ```
]

== Fourier-k-sparse hypothesis for 2-agnostic learning <fig:verifier_fourier_hypothesis>
#figure(
  caption: text[
    Output hypothesis of the protocol from @Caro_2023[Theorem 15].
  ],
)[
  ```py
  @dataclass(frozen=True)
  class FourierSparseHypothesis:
      coefficients: dict[int, float]
      n: int

      def g(self, x: int) -> float:
          val = 0.0
          for s, coeff in self.coefficients.items():
              parity = bin(s & x).count("1") % 2
              chi_s = 1.0 - 2.0 * parity
              val += coeff * chi_s
          return val

      def evaluate(self, x: int, rng: Optional[Generator] = None) -> int:
          if rng is None:
              rng = default_rng()
          gx = self.g(x)
          p = (1.0 - gx) ** 2 / (2.0 * (1.0 + gx**2))
          p = np.clip(p, 0.0, 1.0)
          return int(rng.random() < p)

      def evaluate_batch(
          self, xs: np.ndarray, rng: Optional[Generator] = None
      ) -> np.ndarray:
          if rng is None:
              rng = default_rng()
          return np.array([self.evaluate(int(x), rng=rng) for x in xs], dtype=np.uint8)
  ```
]

== Verification result <fig:verifier_verification_result>

#figure(
  caption: text[
    Complete protocol result summary.
  ],
)[
  ```py
  @dataclass(frozen=True)
  class VerificationResult:
      outcome: VerificationOutcome
      hypothesis: Optional[Union[ParityHypothesis, FourierSparseHypothesis]]
      hypothesis_type: Optional[HypothesisType]
      verifier_estimates: dict[int, float]
      accumulated_weight: float
      acceptance_threshold: float
      list_received: list[int]
      list_size_bound: int
      n: int
      epsilon: float
      num_classical_samples: int

      @property
      def accepted(self) -> bool:
          return self.outcome == VerificationOutcome.ACCEPT
  ```
]

== MoSVerifier Constructor <fig:verifier_constructor>

#figure(
  caption: text[
    Constructor for the `MoSVerifier` class.
  ],
)[
  ```py
  class MoSVerifier:
      def __init__(
          self,
          mos_state: MoSState,
          seed: Optional[int] = None,
      ):
          self.state = mos_state
          self.n = mos_state.n
          self._seed = seed
          self._rng: Generator = default_rng(seed)
  ```
]

== General verifier logic <fig:verifier_logic>

#figure(
  caption: text[
    Verification logic from @thm:protocol.
  ],
)[
  ```py
  def _verify_core(
      self,
      prover_message: ProverMessage,
      epsilon, delta, theta, a_sq, b_sq,
      hypothesis_type: HypothesisType,
      k: Optional[int],
      num_samples: int = 0,
  ) -> VerificationResult:
      n = self.n
      L = prover_message.L
      list_size_bound = int(np.ceil(64.0 * b_sq / theta**2))
      if len(L) > list_size_bound:
          return VerificationResult(
              outcome=VerificationOutcome.REJECT_LIST_TOO_LARGE, ...
          )
      L_size = len(L)
      if hypothesis_type == HypothesisType.PARITY:
          per_coeff_tolerance = epsilon**2 / (16.0 * max(L_size, 1))
      else:
          per_coeff_tolerance = epsilon**2 / (256.0 * k**2 * max(L_size, 1))
      if L_size > 0:
          num_samples = int(
              np.ceil(2.0 / per_coeff_tolerance**2 * np.log(4.0 * L_size / delta))
          )
          num_samples = max(num_samples, 100)
      verifier_estimates = self._estimate_coefficients_independently(
          L=L,
          num_samples=num_samples,
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
      if hypothesis_type == HypothesisType.PARITY:
          hypothesis = self._build_parity_hypothesis(L, verifier_estimates)
      else:
          hypothesis = self._build_fourier_sparse_hypothesis(L, verifier_estimates, k)
      return VerificationResult(
          outcome=VerificationOutcome.ACCEPT, ...
      )
  ```
]

== Verifier coefficient estimation <fig:verifier_coefficient_estimation>

#figure(
  caption: text[
    Classical Fourier coefficient estimator for the verifier.
  ],
)[
  ```py
  def _estimate_coefficients_independently(
      self,
      L: list[int],
      num_samples: int,
  ) -> dict[int, float]:
      if len(L) == 0 or num_samples == 0:
          return {s: 0.0 for s in L}

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
          est = np.clip(est, -1.0, 1.0)
          estimates[s] = est

      return estimates
  ```
]

== Building hypotheses <fig:verifier_build_hypotheses>

#figure(
  caption: text[
    Functions to build hypotheses for @Caro_2023[Thm. 12, 15].
  ],
)[
  ```py
  def _build_parity_hypothesis(
      self,
      L: list[int],
      verifier_estimates: dict[int, float],
  ) -> ParityHypothesis:
      if not L:
          return ParityHypothesis(s=0, n=self.n, estimated_coefficient=0.0)

      s_out = max(L, key=lambda s: abs(verifier_estimates.get(s, 0.0)))
      return ParityHypothesis(
          s=s_out,
          n=self.n,
          estimated_coefficient=verifier_estimates.get(s_out, 0.0),
      )

  def _build_fourier_sparse_hypothesis(
      self,
      L: list[int],
      verifier_estimates: dict[int, float],
      k: int,
  ) -> FourierSparseHypothesis:
      sorted_L = sorted(
          L, key=lambda s: abs(verifier_estimates.get(s, 0.0)), reverse=True
      )

      top_k = sorted_L[:k]
      coefficients = {s: verifier_estimates.get(s, 0.0) for s in top_k}
      return FourierSparseHypothesis(coefficients=coefficients, n=self.n)
  ```
]
