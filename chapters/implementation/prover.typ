#import "../../template.typ": corollary, proof

== Quantum Prover <sec:prover>

Recall @thm:protocol, step 2. The prover `P` is responsible for obtaining a succinctly represented
$tilde(phi.alt): cal(X)_n -> [-1, 1]$.

#corollary()[
  Let $cal(D)$ be a probability distribution over $cal(X)_n times {0, 1}$ with
  $cal(D)_cal(X)_n = cal(U)_n$. Let $delta, epsilon in (0, 1)$. Assume $epsilon gt 2^(-(n/2 - 2))$.
  Then there exists a quantum algorithm that, given $cal(O)(n (log(1/(delta epsilon^2)))/epsilon^4)$
  copies of $rho_cal(D)$, uses an efficient number of single-qubit gates, an efficient amount of
  classical memory and an efficient amount of classical computation time, outputs with success
  probability $gt.eq 1 - delta$, a succinctly represented $tilde(phi.alt): cal(X)_n -> [-1, 1]$ such
  that $||tilde(phi.alt) - hat(phi.alt)||_infinity lt.eq epsilon$ and
  $||tilde(phi)||_0 lt.eq (16 bb(E)_(x tilde cal(U)_n) [(phi.alt(x)^2)])/(epsilon^2) lt.eq (16)/epsilon^2$.
] <cor:sampling_rho>

#proof[
  As from Caro et al. @Caro_2023[p. 28], but restated informally for conciseness. We begin with
  @eq:sample_probability_of_mos after applying $H^(times.o (n + 1))$ to a single copy of
  $rho_cal(D)$ and measuring. The first term of this statement is at most $2^(-n)$, so this samples
  approximately from the squared Fourier spectrum.

  Sample $rho_cal(D)$ a total of $m = cal(O)(log(1/delta)/epsilon^4)$ times. By the DKW inequality
  @Dvoretzky_1956, the empirical distribution $tilde(q)_m$ satisfies
  $||q - tilde(q)_m|| lt.eq epsilon^2/8$ with probability $gt.eq 1 - delta/2$.

  Compile the list $L = {s: tilde(q)_m (s, 1) gt.eq epsilon^2/4}$. The approximation guarantee
  ensures:
  #math.equation(block: true, numbering: none)[
    $
      & |hat(phi.alt)(s)| gt.eq epsilon => s in L ("completeness") \
      & s in L => |hat(phi.alt)(s)| gt.eq epsilon/4 ("soundness")
    $
  ]

  By Parseval's identity (@thm:parseval-identity) we can bound $|L| lt.eq 16/epsilon^2$.
]

We implement the prover `P`'s entire conversation with the verifier in one method, `run_protocol`
(@fig:prover_running). First computing the number of required shots $m$:

#figure()[
  ```py
  #ql/prover.py:315-320
  tau = theta**2 / 8.0
  if qfs_shots is None:
      m_postselected = int(np.ceil(2.0 * np.log(4.0 / delta) / tau**2))
      # Post-selection succeeds ~1/2 the time, so need ~2m total shots.
      # Add a safety margin for finite-sample fluctuation.
      qfs_shots = int(np.ceil(2.5 * m_postselected))
  ```
]

After running the sampler from @sec:sampling_from_mos_state, we convert the raw postselected QFS
counts into the sparse `SpectrumApproximation` (@fig:prover_spectrum_approximation), and finally
extract heavy coefficients in @fig:prover_estimate_extract. We also provide a diagnostic estimator
for coefficients, as well as a function for exact heavy coefficients for testing purposes.
