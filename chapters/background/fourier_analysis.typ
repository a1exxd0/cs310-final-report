#import "../../template.typ": definition, proof, theorem

== Fourier Analysis for Classical and Quantum Learning <sec:fourier-analysis>

Where Fourier analysis is typically performed over periodic functions, here the domain is the finite
set ${0, 1}^n$, the Boolean hypercube. Let $f: {0, 1}^n -> {0, 1}$, a Boolean function. It is often
convenient to work with the equivalent ${-1, 1}$-valued representation $g: {0, 1}^n -> {-1, 1}$
obtained via the bijection $g(x) = (-1)^(f(x)) = 1 - 2f(x)$. This signed representation interacts
cleanly with algebraic structure and will be used throughout.

The space of all real-valued functions on ${0, 1}^n$ is equipped with the inner product:

#math.equation(block: true, numbering: none)[
  $
    chevron.l phi.alt, psi chevron.r =
    bb(E)_(x tilde cal(U)_n)[phi.alt(x) psi(x)] =
    1/sqrt(2^n) sum_(x in {0, 1}^n) phi.alt(x) psi(x)
  $
]

Where $cal(U)_n$ denotes the uniform distribution over ${0, 1}^n$ and makes the function space a
$2^n$-dimensional Hilbert space over $bb(R)$.

=== Parity Basis and Fourier Coefficients

For each $s in {0, 1}^n$, define the _parity function_:

#math.equation(block: true, numbering: none)[
  $chi_s: {0, 1}^n -> {-1, 1}, quad quad chi_s(x) = (-1)^(s dot x)$
]

#definition(name: "Fourier coefficients and expansion")[
  Let $phi.alt: {0, 1}^n -> bb(R)$. The Fourier coefficient of $phi.alt$ at frequency
  $s in {0, 1}^n$ is:

  #math.equation(block: true, numbering: none)[
    $hat(phi.alt)(s) = chevron.l phi.alt, chi_s chevron.r = bb(E)_(x tilde cal(U)_n)[phi.alt(x) chi_s (x))]$
  ]

  Since ${chi_s}_(s in {0, 1}^n)$ forms an orthonormal basis for $bb(R)^{0, 1}^n$, $phi.alt$
  decomposes uniquely as $phi.alt = sum_(s in {0, 1}^n) hat(phi.alt)(s) chi_s$. In other words,
  every function on the Boolean hypercube can be expressed as a unique linear combination of parity
  functions.
]

Following this, we can state a fundamental identity relating the $ell^2$-norm of a function to its
Fourier coefficients:

#theorem(name: "Parseval's Identity")[
  For any $phi.alt: {0, 1}^n -> bb(R)$:

  #math.equation(block: true, numbering: none)[
    $bb(E)_(x tilde cal(U)_n)[(phi.alt(x))^2] = sum_(s in {0, 1}^n) (hat(phi.alt)(s))^2$
  ]

  Note that if $phi.alt$ is ${-1, 1}$-valued, then $sum_(s in {0, 1}^n)(hat(phi.alt)(s))^2 = 1$, so
  the squared Fourier coefficients form a probability distribution over ${0, 1}^n$.
]

#proof[See @Odonnel_2021.]

The collection ${hat(phi.alt)(s)}_(s in {0, 1}^n)$ is the _Fourier spectrum_ of $phi.alt$. A
function with $k << 2^n$ non-zero Fourier coefficients is called Fourier-$k$-sparse, a property
enforced over learned functions in Caro et al. @Caro_2023. Parities $chi_s$ are the canonical
example: they have exactly one non-zero Fourier coefficient $hat(chi)_s (s) = 1$.

Fourier analysis directly governs the misclassification error of parity-based hypotheses. Let
$cal(D) = (cal(U)_n, phi)$ be a distribution over ${0, 1}^n times {0, 1}$ with uniform input
marginal, and let $phi.alt = 1 - 2 phi$ denote the signed conditional label expectation. For any
parity $chi_s$ one can show:

#math.equation(numbering: none, block: true)[
  $bb(P)_((x, b) tilde cal(D))[b eq.not chi_s (x)] = (1 - hat(phi.alt) (s)) / 2$
]

Consequently, the parity $chi_(s^*)$ with _largest_ Fourier coefficient $|hat(phi.alt) (s^*)|$
minimises the misclassification error over all parities. Agnostic parity learning is therefore
equivalent to identifying the heaviest Fourier coefficient of $phi.alt$, which is exploited by the
Goldreich-Leven algorithm @Goldreich_1989 and central to the verification framework of Caro et al.
@Caro_2023.

More generally, for Fourier-$k$-sparse learning, the optimal $k$-sparse hypothesis under $L^2$ error
measure is obtained by retaining the $k$-largest Fourier coefficients of $phi.alt$.

=== Quantum Fourier Sampling for Parity

Under a distribution $cal(D) = (cal(U)_n, f), f: {0, 1}^n -> {0, 1}$ (the _functional-agnostic_
setting in @sec:agnostic-learning) returning a sample $(x, f(x))$ drawn uniformly at random,
@eq:qses specialises to:

#math.equation(numbering: none, block: true)[
  $|psi_((cal(U)_n, f)) chevron.r = 1/sqrt(2^n) sum_(x in {0, 1}^n) |x, f(x) chevron.r$.
]

The algorithm for _quantum Fourier sampling_ @Bernstein_1993 is remarkably simple here: apply the
$(n + 1)$-fold Hadamard $H^(times.o (n + 1))$ to a single copy of $|psi_((cal(U)_n, f)) chevron.r$,
then measure all $n + 1$ qubits in the computational basis.

Conditioned on the last qubit measuring to $1$ (which occurs with probability $1/2$ @Caro_2023), the
first $n$ qubits are observed in state $s in {0, 1}^n$ with probability (if measured in the
computational basis):

#math.equation(block: true, numbering: none)[
  $bb(P)["outcome" s] = (hat(g) (s))^2$ with $g = (-1)^f$
]

#proof[See @Caro_2023[p. 19].]

Repeated quantum Fourier sampling, combined with the Dvoretzky-Kiefer-Wolfowitz (DKW) inequality
@Dvoretzky_1956 allows efficient recovery of a succinct $ell^infinity$-approximation to the entire
Fourier spectrum of $g$.

However, classically, no efficient procedure is known for recovering the Fourier spectrum in the
_distributional-agnostic_ setting (@sec:agnostic-learning) where labelling may be stochastic. Caro
et al. attempt to resolve this by introducing _mixture-of-superpositions_ examples, explored in
@sec:mos-construction.
