#import "../../template.typ": definition

== Mixture-of-Superpositions Construction <sec:mos-construction>

Let $cal(D)$ be a distribution over $cal(X)_n times {0, 1}$. Let $F_cal(D)$ be the probability
distribution over ${0, 1}^(cal(X)_n)$ defined by sampling $f(x)$ from the conditional label
distribution independently for each $x in cal(X)_n$. Let
$phi: cal(X)_n -> [0, 1] = bb(E)_((x, y) tilde cal(D))[y | x = z]$, the conditional label
expectation of distribution $cal(D)$. That is, for any $tilde(f): cal(X)_n -> {0, 1}$:

#math.equation(block: true, numbering: none)[
  $
    bb(P)_(f tilde F_cal(D)) [f = tilde(f)] &= product_(z in cal(X)_n) bb(P)_((x, y) tilde cal(D)) [tilde(f)(z) = y | x = z] \
    &= product_(z in cal(X)_n) (phi(z)tilde(f)(z) + (1 - phi(z))(1 - tilde(f)(z)))
  $
]

In simpler words, we say that the probability that the random $f$ equals a specific $tilde(f)$ is
the product over all inputs of the probability that the label at $z$ equals the label at
$tilde(f)(z)$.

#definition(
  name: "Mixture-of-superpositions quantum examples for distributional-agnostic learning",
)[
  Let $phi.alt = 1 - 2 phi$. Then a mixture-of-superpositions quantum example for $cal(D)$ is a copy
  of the $(n + 1)$-qubit state:

  #math.equation(block: true, numbering: none)[
    $
      rho_cal(D) =
      bb(E)_(f tilde F_cal(D))[ |phi.alt_((cal(D)_cal(X)_n, f)) chevron.r chevron.l phi.alt_((cal(D)_cal(X)_n, f))| ]
    $
  ]
] <def:mos>

We can see this follows from the fact that if there were a fixed deterministic target function
$f: cal(X)_n -> {0, 1}$, then a quantum example consistent with marginal $cal(D)_cal(X)_n$ is the
pure state:

$
  |phi.alt_((cal(D)_cal(X)_n, f)) chevron.r = sum_(x in cal(X)_n) sqrt(cal(D)_(cal(X)_n)(x)) |x chevron.r|f(x) chevron.r
$ <eq:marginal-quantum-example>

However, under a general distribution $cal(D) = cal(X)_n times {0, 1}$, there is no fixed target
function and labels $phi(x) = y$ are random according to $bb(P)[y = 1 | x]$. Therefore, there is no
single pure state of the form in @eq:marginal-quantum-example that correctly represents the
data-generating process.

The distribution $F_cal(D)$ allows us to overcome this as we sample a deterministic
$tilde(f) tilde F_cal(D)$. Conditioned on $f = tilde(f)$, labels are perfectly consistent and the
quantum example is again pure. This defines the classical-quantum ensemble:

#math.equation(block: true, numbering: none)[
  $
    {bb(P)[f = tilde(f)], |phi.alt_((cal(D)_cal(X)_n, tilde(f))) chevron.r}_tilde(f)
  $
]

Since the learner does not observe $f$ as a classically random variable, the unobserved classical
randomness becomes mixing and creates a classical-quantum state on the joint space:

#math.equation(block: true, numbering: none)[
  $
    rho_(c q) = sum_f bb(P)_(f tilde F_cal(D))[f] |f chevron.r chevron.l f| times.o
    |phi.alt_((cal(D)_cal(X)_n, f)) chevron.r chevron.l phi.alt_((cal(D)_cal(X)_n, f))|
  $
]

Where $|f chevron.r chevron.l f|$ is the projector encoding the classical event that the sampled
function is $f$, and
$|phi.alt_((cal(D)_cal(X)_n, f)) chevron.r chevron.l phi.alt_((cal(D)_cal(X)_n, f))|$ is the density
operator corresponding to the quantum example conditioned on $f$, meeting @def:mos.
