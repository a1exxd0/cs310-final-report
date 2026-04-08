= The `QuantumFourierSampler` for sampling from MoS <app:qfs>

For the sake of conciseness, all comments have been removed from all appendices, but are available

== Constructor <fig:qfs_sampler_consructor>

#figure(
  caption: "Constructor for the sampling MoS wrapper",
)[
  ```py
  class QuantumFourierSampler:
    _MODES = {"statevector", "circuit"}

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

== Sampling mechanism <fig:qfs_sampler_sampling>

#figure(
  caption: text[Exposed sampling and state functions],
)[
  ```py
  def sample(
      self,
      shots: int,
      mode: str = "statevector",
  ) -> QFSResult:
      if shots < 1:
          raise ValueError(f"shots must be >= 1, got {shots}")
      if mode not in self._MODES:
          raise ValueError(
              f"Unknown mode {mode!r}; expected one of {sorted(self._MODES)}"
          )

      dispatch = {
          "statevector": self._sample_statevector,
          "circuit": self._sample_circuit,
      }
      raw_counts = dispatch[mode](shots)
      ps_counts, ps_shots = self._postselect(raw_counts)

      return QFSResult(
          raw_counts=raw_counts,
          postselected_counts=ps_counts,
          total_shots=shots,
          postselected_shots=ps_shots,
          n=self.n,
          mode=mode,
      )

  def theoretical_distribution(self) -> np.ndarray:
      return self.state.qfs_distribution()

  def fourier_coefficient(
      self,
      s: int,
      effective: bool = True,
  ) -> float:
      return self.state.fourier_coefficient(s, effective=effective)
  ```
]

=== Inner sampling mechanism <fig:qfs_sampler_inner_sampling>

#figure(
  caption: "Statevector-based sampling and postselection logic",
)[
  ```py
  def _sample_statevector(self, shots: int) -> dict[str, int]:
      n = self.n
      dim_total = self.state.dim_total
      counts: dict[str, int] = {}

      h_circuit = QuantumCircuit(n + 1, name="H_all")
      for q in range(n + 1):
          h_circuit.h(q)

      for _ in range(shots):
          f = self.state.sample_f(rng=self._rng)
          psi_f = self.state.statevector_f(f)
          psi_h = psi_f.evolve(h_circuit)

          probs = psi_h.probabilities()
          idx = self._rng.choice(dim_total, p=probs)
          bitstring = format(idx, f"0{n + 1}b")
          counts[bitstring] = counts.get(bitstring, 0) + 1

      return counts

  def _postselect(
      self,
      raw_counts: dict[str, int],
  ) -> tuple[dict[str, int], int]:
      ps_counts: dict[str, int] = {}
      ps_total = 0
      for bitstring, count in raw_counts.items():
          if bitstring[0] == "1":
              s_bits = bitstring[1:]
              ps_counts[s_bits] = ps_counts.get(s_bits, 0) + count
              ps_total += count
      return ps_counts, ps_total
  ```
]

#figure(
  caption: "Circuit-based (slower) sampling mechanism",
)[
  ```py
  def _sample_circuit(self, shots: int) -> dict[str, int]:
      if self.n > 12:
          warnings.warn(...)

      n = self.n
      counts: dict[str, int] = {}

      circuits = []
      for _ in range(shots):
          f = self.state.sample_f(rng=self._rng)
          qc = self.state.circuit_prepare_f(f)
          for q in range(n + 1):
              qc.h(q)
          qc.measure_all()
          circuits.append(qc)

      if self._noise_model is not None:
          from qiskit_aer import AerSimulator
          from qiskit import transpile

          backend = AerSimulator(noise_model=self._noise_model)
          for qc in circuits:
              child_seed = int(self._rng.integers(0, 2**31))
              qc_t = transpile(qc, backend)
              result = backend.run(
                  qc_t, shots=1, seed_simulator=child_seed
              ).result()
              for bitstring, cnt in result.get_counts().items():
                  # AerSimulator may include spaces in bitstrings;
                  # strip them for consistency.
                  bs = bitstring.replace(" ", "")
                  counts[bs] = counts.get(bs, 0) + cnt
      else:
          child_rng = default_rng(int(self._rng.integers(0, 2**31)))
          sampler = StatevectorSampler(seed=child_rng)
          job = sampler.run(circuits, shots=1)
          for pub_result in job.result():
              for bitstring, cnt in pub_result.data.meas.get_counts().items():
                  counts[bitstring] = counts.get(bitstring, 0) + cnt

      return counts


  ```
]

== QFSResult class <fig:qfs_sampler_result>

#figure(
  caption: "Compacted results from the Fourier sampling subroutine.",
)[
  ```py
  @dataclass(frozen=True)
  class QFSResult:
      raw_counts: dict[str, int]
      postselected_counts: dict[str, int]
      total_shots: int
      postselected_shots: int
      n: int
      mode: str

      @property
      def postselection_rate(self) -> float:
          if self.total_shots == 0:
              return 0.0
          return self.postselected_shots / self.total_shots

      def empirical_distribution(self) -> np.ndarray:
          dim = 2**self.n
          dist = np.zeros(dim, dtype=np.float64)
          if self.postselected_shots == 0:
              return dist
          for bitstring, count in self.postselected_counts.items():
              s = int(bitstring, 2)
              dist[s] += count
          dist /= self.postselected_shots
          return dist
  ```
]
