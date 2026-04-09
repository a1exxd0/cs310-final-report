= MoSState Class - An implementation of the MoS concept from Caro et al. @Caro_2023 <app:mos>

For the sake of conciseness, all comments have been removed from all appendices, but are available
in source code.

== State constructor <fig:mos_constructor>

#figure(
  caption: text[Constructor for the `MoSState` class.],
)[
  ```py
  class MoSState:
      def __init__(
          self,
          n: int,
          phi: Union[Callable[[int], float], np.ndarray],
          noise_rate: float = 0.0,
          seed: Optional[int] = None,
      ):
          if n < 1:
              raise ValueError(f"n must be >= 1, got {n}")
          if not 0.0 <= noise_rate <= 0.5:
              raise ValueError(f"noise_rate must be in [0, 0.5], got {noise_rate}")

          self.n: int = n
          self.dim_x: int = 2**n
          self.dim_total: int = 2 ** (n + 1)
          self.noise_rate: float = noise_rate
          self._rng: Generator = default_rng(seed)

          if callable(phi):
              self._phi = np.array(
                [phi(x) for x in range(self.dim_x)], dtype=np.float64
              )
          else:
              self._phi = np.asarray(phi, dtype=np.float64).copy()
              if len(self._phi) != self.dim_x:
                  raise ValueError(...)

          if not np.all((self._phi >= 0.0) & (self._phi <= 1.0)):
              raise ValueError("All phi values must be in [0, 1]")

          eta = self.noise_rate
          self._phi_effective: np.ndarray = (1 - 2 * eta) * self._phi + eta

          self._noise_damping: float = 1.0 - 2.0 * eta
  ```
]

== Property accessors <fig:mos_property_accessors>

#figure(
  caption: text[Property accessors for phi in both ${0, 1}$ and ${-1, 1}$ conventions.],
)[
  ```py
  @property
  def phi(self) -> np.ndarray:
      return self._phi

  @property
  def tilde_phi(self) -> np.ndarray:
      return 1.0 - 2.0 * self._phi

  @property
  def phi_effective(self) -> np.ndarray:
      return self._phi_effective

  @property
  def tilde_phi_effective(self) -> np.ndarray:
      return 1.0 - 2.0 * self._phi_effective
  ```
]

== $f tilde F_cal(D)$ sampler

#figure(
  caption: text[Sampling $f tilde F_cal(D)$.],
)[
  ```py
  def sample_f(self, rng: Optional[Generator] = None) -> np.ndarray:
      if rng is None:
          rng = self._rng

      return (rng.random(self.dim_x) < self._phi_effective).astype(np.uint8)
  ```
]

== State preparation <fig:mos_state_preparation>

#figure(
  caption: text[Both pure state preparation $|psi_((cal(U)_n, f)) chevron.r$ and circuit preparation
    for producing $|psi_((cal(U)_n, f)) chevron.r$.],
)[
  ```py
  def statevector_f(self, f: np.ndarray) -> Statevector:
      sv_data = np.zeros(self.dim_total, dtype=np.complex128)
      amp = 1.0 / np.sqrt(self.dim_x)

      for x in range(self.dim_x):
          idx = x + int(f[x]) * self.dim_x
          sv_data[idx] = amp

      return Statevector(sv_data)

  def _circuit_oracle_f(self, f: np.ndarray) -> QuantumCircuit:
      qr = QuantumRegister(self.n + 1, "q")
      qc = QuantumCircuit(qr, name="oracle_f")

      for x in range(self.dim_x):
          if f[x] == 1:
              ctrl_state = format(x, f"0{self.n}b")
              if self.n == 1:
                  qc.cx(0, 1, ctrl_state=ctrl_state)
              else:
                  qc.mcx(
                      control_qubits=list(range(self.n)),
                      target_qubit=self.n,
                      ctrl_state=ctrl_state,
                  )

      return qc

  def circuit_prepare_f(self, f: np.ndarray) -> QuantumCircuit:
      qr = QuantumRegister(self.n + 1, "q")
      qc = QuantumCircuit(qr, name="prepare_psi_f")

      for i in range(self.n):
          qc.h(qr[i])

      oracle = self._circuit_oracle_f(f)
      qc.compose(oracle, inplace=True)

      return qc

  def circuit_prepare_f_initialize(self, f: np.ndarray) -> QuantumCircuit:
      sv = self.statevector_f(f)
      qr = QuantumRegister(self.n + 1, "q")
      qc = QuantumCircuit(qr, name="prepare_psi_f_init")
      qc.initialize(sv, qr)
      return qc

  ```
]

== Density matrix of $rho_cal(D)$

This is used explicitly for testing and is not seen in experimental code.

#figure(
  caption: text[
    Approximate density matrix $rho_cal(D)$ by Monte-Carlo.
  ],
)[
  ```py
  def density_matrix(
      self,
      num_samples: int = 1000,
      rng: Optional[Generator] = None,
  ) -> DensityMatrix:
      if rng is None:
          rng = self._rng

      rho_data = np.zeros((self.dim_total, self.dim_total), dtype=np.complex128)

      for _ in range(num_samples):
          f = self.sample_f(rng)
          sv = self.statevector_f(f)
          rho_data += np.outer(sv.data, sv.data.conj())

      rho_data /= num_samples
      return DensityMatrix(rho_data)
  ```
]

== Classical sampling mechanisms <fig:mos_classical_samplers>

#figure(
  caption: text[Classical sampling tools.],
)[
  ```py
  def sample_classical(
      self,
      rng: Optional[Generator] = None,
  ) -> Tuple[int, int]:
      if rng is None:
          rng = self._rng

      x = rng.integers(0, self.dim_x)
      y = int(rng.random() < self._phi_effective[x])
      return x, y

  def sample_classical_batch(
      self,
      num_samples: int,
      rng: Optional[Generator] = None,
  ) -> Tuple[np.ndarray, np.ndarray]:
      if rng is None:
          rng = self._rng

      xs = rng.integers(0, self.dim_x, size=num_samples)
      ys = (rng.random(num_samples) < self._phi_effective[xs]).astype(np.uint8)
      return xs, ys
  ```
]

== Fourier analysis tools <fig:mos_fourier_analysis>

#figure(
  caption: text[
    A set of tools for fourier analysis of `MoSState`'s properties.
  ],
)[
  ```py
  def fourier_coefficient(self, s: int, *, effective: bool = True) -> float:
      tphi = self.tilde_phi
      parities = np.array([bin(s & x).count("1") % 2 for x in range(self.dim_x)])
      chi_s = 1.0 - 2.0 * parities  # (-1)^{s·x}
      coeff = float(np.mean(tphi * chi_s))
      if effective:
          coeff *= self._noise_damping
      return coeff

  def fourier_spectrum(self, *, effective: bool = True) -> np.ndarray:
      tphi = self.tilde_phi
      spectrum = np.empty(self.dim_x, dtype=np.float64)
      for s in range(self.dim_x):
          parities = np.array([bin(s & x).count("1") % 2 for x in range(self.dim_x)])
          chi_s = 1.0 - 2.0 * parities
          spectrum[s] = float(np.mean(tphi * chi_s))
      if effective:
          spectrum *= self._noise_damping
      return spectrum

  def parseval_check(self, *, effective: bool = True) -> Tuple[float, float]:
      spectrum = self.fourier_spectrum(effective=effective)
      fourier_sum = float(np.sum(spectrum**2))
      if effective:
          expected_sq = float(np.mean(self.tilde_phi_effective**2))
      else:
          expected_sq = float(np.mean(self.tilde_phi**2))
      return fourier_sum, expected_sq

  def qfs_probability(self, s: int) -> float:
      tphi_eff = self.tilde_phi_effective
      E_sq = float(np.mean(tphi_eff**2))
      coeff = self.fourier_coefficient(s, effective=True)
      return (1.0 - E_sq) / self.dim_x + coeff**2

  def qfs_distribution(self) -> np.ndarray:
      spectrum_eff = self.fourier_spectrum(effective=True)
      tphi_eff = self.tilde_phi_effective
      E_sq = float(np.mean(tphi_eff**2))
      return (1.0 - E_sq) / self.dim_x + spectrum_eff**2
  ```
]
