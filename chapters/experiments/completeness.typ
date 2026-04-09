#import "../../template.typ": definition

== Completeness Experiments <sec:completeness>

The following experiments measure whether the verifier accepts the honest MoS prover and recovers a
hypothesis with low error. We begin by defining what _completeness_ and _soundness_ mean in the
context of our learning task.

#definition(name: text[Interactive verification of $alpha$-agnostic learning])[
  Let $cal(F) subset.eq {0, 1}^(cal(X)_n)$ be a benchmark class. Let $frak(D)$ be a family of
  probability distributions over $cal(X)_n times {0, 1}$. Let $alpha gt.eq 1$. We say that $cal(F)$
  is $alpha$-agnostic verifiable with respect to $frak(D)$ if there exists a pair of classical or
  quantum algorithms $(V, P)$ that satisfy the following conditions for every input accuracy
  parameter $epsilon in (0, 1)$ and every confidence parameter $delta in (0, 1)$:

  - *Completeness*: For any $cal(D) in frak(D)$ the random hypothesis $h: cal(X)_n -> {0, 1}$ that
    $V(epsilon, delta)$ outputs after interacting with honest prover $P$ satisfies:
  $
    bb(P)[h eq.not "reject" and ("err"_cal(D) (h) lt.eq alpha dot "opt"_cal(D) (cal(F)) + epsilon)] gt.eq 1 - delta
  $ <eq:completeness>
  - *Soundness*: For any $cal(D) in frak(D)$ and for any dishonest prover $P'$, the random
    hypothesis $h: cal(X)_n -> {0, 1}$ that $V(epsilon, delta)$ outputs after interacting with $P'$
    satisfies:
  $
    bb(P)[h eq.not "reject" and ("err"_cal(D) (h) gt alpha dot "opt"_cal(D) (cal(F)) + epsilon)] lt delta
  $ <eq:soundness>
] <def:iv>

=== Scaling baseline <sec:completeness-scaling>

The scaling experiment `experiments/harness/scaling.py` is the pure completeness baseline for
@Caro_2023[Thm. 12]. Each trial draws a uniformly random non-zero parity
$s^* in {1, dots, 2^n - 1}$, producing a noiseless functional target $phi(x) = s^* dot x$ for which
the Fourier spectrum is the indicator $hat(tilde(phi)) = chi_(s^*)$ with $a^2 = b^2 = 1$ (no noise).

The experiment is designed to confirm four predictions: that $bb(P)["accept"] gt.eq 1 - delta$; the
postselection rate is $1/2$; the list-size bound; the wall-clock cost of simulation on classical
computers as $n$ grows.

Data was collected into `results/scaling_4_16_100.pb`, with $1300$ trials spanning
$n in {4, dots, 16}$ and $100$ trials per $n$. Parameters were
$epsilon = 0.3, delta = 0.1, theta.alt = epsilon = 0.3$, and $a^2 = b^2 = 1$. Sample budgets were
hard-coded, with a fixed total of $6000$ copies of $rho_cal(D)$ per trial independent of $n$.

Acceptance and correctness of acceptance were $100%$ in all cases, so well above the required
$1 - delta = 0.9$. Median post-selection rate lay in $[0.496, 0.502]$ across all $n$, matching
@thm:approx_sampling's $1/2$-post-selection rate.

Wall-clock time rose from $0.36$s at $n = 4$ to $1203$s at $n = 16$, and is entirely dominated by
the $2^(n + 1)$-dimensional statevector simulator and not by any protocol quantity, seen in
@fig:scaling_1.

#figure(
  image("figures/scaling_1.png"),
  caption: text[Fixed-budget feasibility. Total samples per trial are pinned at \(6\,000\); the
    curve shows wall-clock time, whose growth is dominated by the $2^(n + 1)$-dimensional
    statevector simulator in `mos/__init__.py`, not by any protocol-level cost.],
) <fig:scaling_1>
