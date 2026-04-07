#import "../../template.typ": definition

== Functional and Distributional-Agnostic Learning <sec:agnostic-learning>

This section establishes the learning-theoretic foundations underlying the classical verification of
quantum learning framework from Caro et al. @Caro_2023. We begin by formalising the case of the
agnostic learning task @Haussler_1992. There are two canonical choices documented:
- In _functional-agnostic_ learning with respect to uniformy random inputs, we assume the data
  consists of labelled inputs $(x_i, f(x_i))$ with $x_i$ drawn i.i.d. uniformly at random from
  $cal(X) = {0, 1}^n$ and $f: {0, 1}^n -> {0, 1}$, an unknown boolean function. We denote the
  data-generating distribution as $cal(D) = (cal(U)_n, f)$.
- In the _distributional-agnostic_ setting, with respect to uniformy random inputs, we no longer
  assume a perfectly descriptive $f$. In other words we assume samples labelled $(x_i, y_i)$ are
  drawn i.i.d. over some distribution $cal(D)$ over ${0, 1}^n times {0, 1}$ with uniform marginal
  over ${0, 1}^n$. We denote this as $cal(D) = (cal(U)_n, phi)$ where $phi$:

  #math.equation(numbering: none, block: true)[
    $ phi(x) = bb(P)_((x, y) tilde cal(D))[y = 1 | x] $
  ]

The goal in both types of learning is to learn an almost-optimal approximating function compared to
a benchmark class $cal(B)$, such that given an accuracy parameter $epsilon$, confidence parameter
$delta$, and access to training data i.i.d. from $cal(D)$, an $alpha$-agnostic learner has to
output, with success probability $gt.eq 1 - delta$ a hypothesis $h$ such that:

#math.equation(numbering: none, block: true)[
  $
    bb(P)_((x, y) tilde cal(D))[h(x) eq.not y] lt.eq
    alpha dot inf_(b in cal(B)) bb(P)_((x, y) tilde cal(D))[b(x) eq.not y] + epsilon
  $
]

In simpler words, the hypothesis is at most as incorrect as the best benchmark (by metric of
accuracy) for any input $x$, multiplied by $alpha$ with some additive error margin $epsilon$.

In quantum learning theory, a learner can have access the distribution $cal(D)$ with training data
canonically taken to consist of copies of the _quantum superposition example state_ @Bshouty_1995:

#math.equation(numbering: "(1)", block: true)[
  $
    |phi.alt_cal(D) chevron.r = sum_((x, y) in {0, 1}^n times {0, 1}) sqrt(cal(D)(x, y))|x, y chevron.r
  $
] <eq:qses>

Whilst the above data is at least as powerful as its classical counterpart (since we can simulate
classical data via computational basis measurements), it is unknown how to use copies of
$|phi.alt_cal(D) chevron.r$ to improve upon classical distributional-agnostic learning. Caro et al.
@Caro_2023 present a new idea of _mixture-of-superpositions_ (MoS) to attempty to overcome this.
