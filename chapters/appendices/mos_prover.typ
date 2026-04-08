= Implementation of the Prover from Caro et al. @Caro_2023

For the sake of conciseness, all comments have been removed from all appendices, but are available
in source code.

== Approximation result class <fig:prover_spectrum_approximation>

#figure(
  caption: text[Succinct approximation of a Fourier spectrum.],
)[
  ```py
  @dataclass(frozen=True)
  class SpectrumApproximation:
      entries: dict[int, float]
      threshold: float
      n: int
      num_qfs_samples: int
      total_qfs_shots: int
  ```
]

== Prover's message to the verifier <fig:prover_message>

#figure(
  caption: text[
    The message the prover sends to the verifier in Caro et al. @Caro_2023, with some extra
    information for debugging, testing and analysis.
  ],
)[
  ```py
  @dataclass(frozen=True)
  class ProverMessage:
      L: list[int]
      estimates: dict[int, float]
      n: int
      epsilon: float
      theta: float
      spectrum_approx: SpectrumApproximation
      qfs_result: QFSResult
      num_classical_samples: int

      @property
      def list_size(self) -> int:
          """Number of candidate heavy coefficients."""
          return len(self.L)

      @property
      def total_copies_used(self) -> int:
          """Total MoS copies consumed (QFS + classical estimation)."""
          return self.spectrum_approx.total_qfs_shots + self.num_classical_samples
  ```
]

== Constructor of `MoSProver` <fig:prover_constructor>

#figure(
  caption: text[
    Constructor for the MoSProver
  ],
)[
  ```py
  class MoSProver:
      def __init__(
          self,
          mos_state: MoSState,
          seed: Optional[int] = None,
          noise_model: Optional[object] = None,
      ):
          self.state = mos_state
          self.n = mos_state.n
          self._seed = seed
          self._rng: Generator = default_rng(seed)
          self._noise_model = noise_model
  ```
]

== The central running protocol for sampling and aggregation of $rho_cal(D)$ <fig:prover_running>

#figure(
  caption: text[
    The central running protocol from @cor:sampling_rho.
  ],
)[
  ```py
  def run_protocol(
      self,
      epsilon: float,
      delta: float = 0.1,
      theta: Optional[float] = None,
      estimate_coefficients: bool = True,
      qfs_mode: str = "statevector",
      qfs_shots: Optional[int] = None,
      classical_samples: Optional[int] = None,
  ) -> ProverMessage:
      # Source code contains parameter validation here, we omit for conciseness.

      tau = theta**2 / 8.0
      if qfs_shots is None:
          m_postselected = int(np.ceil(2.0 * np.log(4.0 / delta) / tau**2))
          qfs_shots = int(np.ceil(2.5 * m_postselected))
      sampler = QuantumFourierSampler(
          self.state,
          seed=int(self._rng.integers(0, 2**31)),
          noise_model=self._noise_model,
      )
      qfs_result = sampler.sample(shots=qfs_shots, mode=qfs_mode)
      spectrum_approx = self._build_spectrum_approximation(
          qfs_result=qfs_result,
          theta=theta,
      )
      L = self._extract_heavy_list(
          spectrum_approx=spectrum_approx,
          theta=theta,
      )
      estimates: dict[int, float] = {}
      num_classical = 0
      if estimate_coefficients and len(L) > 0:
          estimates, num_classical = self._estimate_coefficients(
              L=L,
              epsilon=epsilon,
              delta=delta,
              num_samples_override=classical_samples,
          )
      return ProverMessage(
          ...
      )
  ```
]

== Building a Fourier spectrum approximation <fig:prover_build_spectrum>

#figure(
  caption: text[
    Build the spectrum approximation from sample results.
  ],
)[
  ```py
  def _build_spectrum_approximation(
      self,
      qfs_result: QFSResult,
      theta: float,
  ) -> SpectrumApproximation:
      n = self.n
      ps_total = qfs_result.postselected_shots

      extraction_threshold = theta**2 / 4.0

      entries: dict[int, float] = {}
      if ps_total > 0:
          for bitstring, count in qfs_result.postselected_counts.items():
              s = int(bitstring, 2)
              empirical_prob = count / ps_total
              if empirical_prob >= extraction_threshold:
                  entries[s] = empirical_prob

      return SpectrumApproximation(
          entries=entries,
          threshold=extraction_threshold,
          n=n,
          num_qfs_samples=ps_total,
          total_qfs_shots=qfs_result.total_shots,
      )
  ```
]

== Estimating and extracting heavy coefficients <fig:prover_estimate_extract>

#figure(
  caption: text[
    Extracting heavy coefficients and list truncation from the `SpectrumApproximation`.
  ],
)[
  ```py
  def _extract_heavy_list(
      self,
      spectrum_approx: SpectrumApproximation,
      theta: float,
  ) -> list[int]:
      L = sorted(
          spectrum_approx.entries.keys(),
          key=lambda s: spectrum_approx.entries[s],
          reverse=True,
      )

      parseval_bound = int(np.ceil(16.0 / theta**2))
      if len(L) > parseval_bound:
          L = L[:parseval_bound]

      return L
  ```
]

#figure(
  caption: "Fourier coefficient estimation.",
)[
  ```py
  def _estimate_coefficients(
      self,
      L: list[int],
      epsilon: float,
      delta: float,
      num_samples_override: Optional[int] = None,
  ) -> tuple[dict[int, float], int]:
      L_size = len(L)
      if L_size == 0:
          return {}, 0
      if num_samples_override is not None:
          num_samples = num_samples_override
      else:
          num_samples = int(np.ceil(2.0 / epsilon**2 * np.log(4.0 * L_size / delta)))
          num_samples = max(num_samples, 100)

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

      return estimates, num_samples

  def exact_heavy_coefficients(
      self,
      theta: float,
      *,
      effective: bool = True,
  ) -> list[tuple[int, float]]:
      spectrum = self.state.fourier_spectrum(effective=effective)
      heavy = [
          (s, float(spectrum[s]))
          for s in range(self.state.dim_x)
          if abs(spectrum[s]) >= theta
      ]
      heavy.sort(key=lambda t: abs(t[1]), reverse=True)
      return heavy
  ```
]
