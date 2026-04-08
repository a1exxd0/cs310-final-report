#import "../../template.typ": proof, theorem

=== Approximate Quantum Fourier Sampling from MoS <sec:qfs-from-mos>


#theorem(name: "Approximate fourier sampling over Mixture of Superpositions")[
  Let $cal(D)$ be a probability distribution over $cal(X)_n times {0, 1}$ with
  $cal(D)_cal(X)_n = cal(U)_n$. Let
  $rho_cal(D) = bb(E)_(f tilde F_cal(D))[ |phi_((cal(U)_n, f)) chevron.r chevron.l phi_((cal(U)_n, f))| ]$
  be our MoS quantum example from @def:mos. Given a copy of $rho_cal(D)$, first apply the unitary
  $H^(times.o (n + 1))$, then measure all $n + 1$ qubits in the computational basis. The measurement
  outcomes of this procedure satisfy the following:
  + The computational basis on the last qubit gives outcomes ${0, 1}$ with equal probability.
  + Conditioned on having ovserved outcome 1 for the last qubit, the computational basis measurement
    on the first $n$ qubits outputs a string $s in {0, 1}^n$ with probability

  $
    1/2^n (1 - bb(E)_(x tilde cal(U)_n) [(phi.alt(x))^2]) + (hat(phi.alt)(s))^2
  $ <eq:sample_probability_of_mos>

  Caro et al. @Caro_2023 state that, with probability $1/2$, produce a sample from a distribution
  uniformly close to the squared Fourier spectrum of the label-bias function $phi$.
]

#proof[See @Caro_2023[p. 26]]

