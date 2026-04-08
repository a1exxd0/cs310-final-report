#import "../../template.typ": lemma, proof
== Mixture-of-Superpositions Simulator <sec:mos-simulator>

The `mos/__init__.py` module (@app:mos) provides a faithful implementation of the
mixture-of-superpositions-based quantum example `MoSState` from @def:mos. All other modules treat
the class `MoSState` as a black-box of either copies of the mixed quantum example state
$rho_cal(D)$, or classical samples $(x, y) tilde cal(D)$. Note that we use Lemma 1 from @Caro_2023
to draw equivalence between computational basis measurements on all $n + 1$ qubits of $rho_cal(D)$
and producing a sample from $cal(D)$ itself.

To build this state, we require the function distribution $F_cal(D)$ over ${0, 1}^(cal(X)_n)$
defined by sampling $f(x): cal(X)_n -> {0, 1}$ from the conditional label distribution independently
for each $x$. We achieve this by storing $phi$ as a length-$2^n$ array (an input for the constructor
of `MoSState`), with an input noise rate $eta$. We then pre-compute $phi_("eff")$, the effective phi
$bb(P)[y=1 | x]$ after independent label flips from noise.

#figure(caption: text[Precomputing $phi_("eff")$])[
  ```py
  # mos/__init__.py:127-129
  eta = self.noise_rate
  self._phi_effective: np.ndarray = (1 - 2 * eta) * self._phi + eta
  ```
]

To simulate sampling $f tilde F_cal(D)$, we can compute $2^n$ independent Bernoulli draws against
$phi_("eff")$.

#figure(
  caption: text[Vectorized $f tilde F_cal(D)$ sampling.],
)[
  ```py
  # mos/__init__.py:185-187
  def sample_f(self, rng: Optional[Generator] = None) -> np.ndarray:
    if rng is None:
        rng = self._rng
    return (rng.random(self.dim_x) < self._phi_effective).astype(np.uint8)
  ```
]

Notice that by $bb(P)_(f tilde F_cal(D)) [f = tilde(f)]$ from @sec:mos-construction, the product
form is exactly what makes labels independent across inputs. Function values at each $x$ depend only
on $phi(x)$, producing a binary array where:

#math.equation(block: true, numbering: none)[
  $
    f(x) = cases(
      1 "with probability" phi_("eff")(x),
      0 "with probability" 1 - phi_("eff")(x)
    )
  $
]

Crucially, the rest of the protocol does not see $f$ directly, it will either work with state
$rho_cal(D)$ or marginal $cal(D)$, of which both are mixtures over $f$.

Take $f$ to now be fixed. We can perform the standard textbook preparation of
$|psi_((cal(U)_n, f)) chevron.r = 1/sqrt(2^n) sum_x |x, f(x) chevron.r$ by applying $H^(times.o n)$
on the $x$ register, followed by an oracle that flips the label qubit on every $x$ where $f(x) = 1$:

#figure(
  caption: text[Circuit construction for $f$],
)[
  ```py
  # mos/__init__.py:297-308
  qr = QuantumRegister(self.n + 1, "q")
  qc = QuantumCircuit(qr, name="prepare_psi_f")

  for i in range(self.n):
      qc.h(qr[i])

  oracle = self._circuit_oracle_f(f)
  qc.compose(oracle, inplace=True)

  return qc
  ```
]

Following this, we define the oracle flipping the label qubit on $x: f(x) = 1$ `_circuit_oracle_f`:

#figure(
  caption: text[Circuit oracle $f$.],
)[
  ```py
  # mos/__init__.py:251-269
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
  ```
]

We note a practical limitation here: the construction is brute-force, creating up to $2^n$
multi-controlled gates, one for each $x: f(x) = 1$. This is feasible for small simulations, however
impractical for large $n$. Instead, we propose an alternative `Statevector`-based approach.

For a fixed $f$, the state $|psi_((cal(U)_n, f)) chevron.r = 1/sqrt(2^n) sum_x |x, f(x) chevron.r$
has exactly $2^n$ nonzero amplitudes, all equal to $2^((-n)/2)$. We write these using Qiskit's
@Qiskit_2024 little-endian convention. Qubit $n$ is the highest-index qubit and so maps
$|x, b chevron.r$ to index $x + b dot 2^n$.

#figure(
  caption: text[Statevector for $f$ construction.],
)[
  ```py
  # mos/__init__.py:217-224
  sv_data = np.zeros(self.dim_total, dtype=np.complex128)
  amp = 1.0 / np.sqrt(self.dim_x)

  for x in range(self.dim_x):
      idx = x + int(f[x]) * self.dim_x
      sv_data[idx] = amp

  return Statevector(sv_data)
  ```
]

#lemma()[
  The `statevector`-based construction of $f$ and the true-to-literature circuit based construction
  of $f$ are identical under the assumption of no gate noise; both produce, for any
  $f: {0, 1}^n -> {0, 1}$, the state:

  #math.equation(block: true, numbering: none)[
    $
      |psi_f chevron.r = 1/sqrt(2^n) sum_(x=0)^(2^n - 1) |x, f(x) chevron.r
    $
  ]
]

#proof[
  We write $|x, b chevron.r$ for the basis state where the input register holds
  $x in {0, dots, 2^n - 1}$ and the label qubit holds $b in {0, 1}$. Under the little-endian
  convention, this corresponds to array index $x + b dot 2^n$.

  The method `statevector_f` constructs a vector $v in bb(C)^2^(n + 1)$ defined by:

  #math.equation(block: true, numbering: none)[
    $
      v_j = cases(
        1/sqrt(2^n) "if" j = x + f(x) dot 2^n "for some" x in {0, dots, 2^n - 1},
        0 "otherwise"
      )
    $
  ]

  Since the map $x -> x + f(x) dot 2^n$ is injective, exactly $2^n$ entries are nonzero, each equal
  to $1/sqrt(2^n)$. The squared norm is $2^n dot 1/2^n = 1$. By the index convention, $v$
  represents:

  #math.equation(block: true, numbering: none)[
    $
      1/sqrt(2^n) sum_x |x, f(x) chevron.r = |psi_f chevron.r
    $
  ]

  All other basis states, namely $|x, overline(f(x)) chevron.r$ recieve zero amplitude due to a
  deterministic $f$.

  For the circuit-based preparation, we start with an application of $(H^(times.o n) times.o I)$ to
  input register $|0 chevron.r^(times.o(n + 1))$:

  #math.equation(block: true, numbering: none)[
    $
      (H^(times.o n) times.o I)|0 chevron.r^(times.o(n + 1)) =
      1/sqrt(2^n)sum_x |x, 0 chevron.r
    $
  ]

  Then, it suffices to show the oracle defined on computational basis states by the unitary
  $U_f|x, b chevron.r = |x, b plus.o f(x) chevron.r$ that:

  #math.equation(block: true, numbering: none)[
    $
      U_f dot 1/sqrt(2^n) sum_x |x, 0 chevron.r =
      1/sqrt(2^n) sum_x |x, f(x) chevron.r = |psi_f chevron.r
    $
  ]

  For each $x: f(x) = 1$, the circuit places an _MCX_ gate that flips qubit $n$ conditioned on the
  input register being $|x chevron.r$. Gates for distinct $x, x'$ commute because they have
  orthogonal control states, so at most one fires on any basis state. Since the circuit contains
  only gates for $x: f(x) = 1$, the label qubit is flipped if and only if $f(x) = 1$. That is, the
  circuit maps $|y, b chevron.r -> |y, b plus.o f(y) chevron.r$, which is exactly $U_f$.
]

For classical sampling of $f tilde F_cal(D)$, we can simulate this by measuring the mixed state
$rho_cal(D)$ in the computational basis @Caro_2023.

#proof[
  By definition of $rho_cal(D)$, the probability of observing output string
  $(x, b) in cal(X)_n times {0, 1}$ when measuring all $(n + 1)$ qubits in the computational basis
  is given by:

  #math.equation(block: true, numbering: none)[
    $
      chevron.l x, b|rho_cal(D)|x, b chevron.r &= bb(E)_(f tilde F_cal(D)) [ |chevron.l x, b| psi_((cal(D)_cal(X)_n, f)) chevron.r|^2 ] \
      &= bb(E)_(f tilde F_cal(D)) [cal(D)_cal(X)_n (x) delta_(b, f(x))] \
      &= cal(D)_cal(X)_n (x) bb(P)_(f tilde F_cal(D)) [f(x) = b] \
      &= cal(D) (x, b)
    $
  ]
  As claimed.
]

To avoid overhead of quantum simulation, we can instead sample $x tilde U_n$, and
$y tilde "Bernoulli"(phi_("eff")(x))$ directly, which works on the same distribution, but without
having to use a $2^((n+1))$-dimension state vector.

#figure(
  caption: text[A singular sample $x tilde U_n$ and $y tilde "Bernoulli"(phi_("eff")(x))$.],
)[
  ```py
  # mos/__init__.py:412-417
  if rng is None:
    rng = self._rng # a numpy.Generator

  x = rng.integers(0, self.dim_x)
  y = int(rng.random() < self._phi_effective[x])
  return x, y
  ```
]

We provide a vectorized implementation `sample_classical_batch`, available in
@fig:mos_classical_samplers.

=== Implementation of Fourier analysis over MoS

Recall from @def:fourier-coefficients-and-expansion, for the Fourier coeffient $hat(phi.alt)(s)$
where $chi_s (x) = (-1)^(s dot x)$ and $phi.alt = 1 - 2 phi$:

#math.equation(block: true, numbering: none)[
  $
    hat(phi.alt)(s) = bb(E)_(x tilde U_n)[phi.alt(x) dot chi_s (x)]
  $
]

Then, we can calculate the exact Fourier coefficient at $s$ with:

#figure(
  caption: text[The fourier coefficient calculation for some specific $s$.],
)[
  ```py
  # mos/__init__.py:482-489
  tphi = self.tilde_phi
  parities = np.array([bin(s & x).count("1") % 2 for x in range(self.dim_x)])
  chi_s = 1.0 - 2.0 * parities  # (-1)^{s·x}
  coeff = float(np.mean(tphi * chi_s))
  if effective:
      coeff *= self._noise_damping
  return coeff
  ```
]

We provide both a function to compute the full Fourier spectrum `fourier_spectrum` for all $s$ via
repetition of the above, as well as a function to verify Parseval's identity `parseval_check`:

#math.equation(block: true, numbering: none)[
  $
    sum_s hat(phi.alt)(s)^2 = bb(E)[phi.alt(x)^2],
  $
]

available in @fig:mos_fourier_analysis.

Now recall from @eq:sample_probability_of_mos that if one applies $H^(times.o (n + 1))$ to a copy of
$rho_cal(D)$, and measures all qubits in the computational basis post-selecting on the label qubit
being $|1 chevron.r$, then the conditional distribution over the first $n$ bits is:

#math.equation(block: true, numbering: none)[
  $
    bb(P)[s | b = 1] =
    1/2^n (1 - bb(E)_(x tilde cal(U)_n) [(phi.alt(x))^2]) + (hat(phi.alt)(s))^2
  $
]

We compute this as follows:

#figure(
  caption: text[Computed probability of observing $s$, conditioned on the last qubit being $1$.],
)[
  ```py
  tphi_eff = self.tilde_phi_effective
  E_sq = float(np.mean(tphi_eff**2))
  coeff = self.fourier_coefficient(s, effective=True)
  return (1.0 - E_sq) / self.dim_x + coeff**2
  ```
]

We provide a function `qfs_distribution` to calculate the full QFS distribution over ${0, 1}^n$ in
@fig:mos_fourier_analysis.

=== Sampling from `MoSState`

The package `mos/sampler.py` is the only place in the codebase of which performs Hadamard-basis
measurements of a MoS state, depending only on `MoSState` from @app:mos. In the case of
`Statevector`-based simulation, we sample an independent $f$ per "shot", and draw a single
measurement outcome per $f$:

#figure(
  caption: text[Sampling $f$ from the `MoSState` construction and performing a final measurement on
    the evolved state.],
)[
  ```py
  # mos/sampler.py:312-332
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
  ```
]

We provide a circuit-based sampler as well as the postselection mechanism in
@fig:qfs_sampler_inner_sampling, with dispatch between sampling mechanisms as follows:

#figure(
  caption: text[`sample` function dispatch],
)[
  ```py
  # mos/sampler.py:227:241
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
  ```
]

Note that we store `postselected_counts` - although not a meaningful statistic for the actual
verification procedure in @thm:protocol, it is important for checking protocol correctness to
theory. We collect a number of statistics in a similar fashion for testing.
