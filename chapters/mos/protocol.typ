#import "../../template.typ": proof, theorem

== The Four-Step Protocol <sec:protocol>

#theorem(name: "Classical verification of quantum learning with MoS")[
  Let $theta.alt in (2^(-(n/2 - 3)), 1)$. Let $0 lt.eq a lt.eq b lt.eq 1$. Let $delta in (0, 1)$ and
  $epsilon gt.eq 2 sqrt(b^2 - a^2)$. The class of $n$-bit parities is efficiently proper 1-agnostic
  verifiable w.r.t. $cal(D)_(cal(U)_n; gt.eq theta.alt) inter cal(D)_(cal(U)_n; [a^2, b^2])$ by a
  classical verifier $V$ with access to classical random examples, interacting with a quantum prover
  $P$ with access to MoS quantum examples. This can be achieved by a pair $(V, P)$ that uses only a
  single round of communication. Caro et al. @Caro_2023[p. 45] describe the following protocol for a
  classical $V$ and honest quantum prover $P$:

  + $V$ asks $P$ to provide a list $L = {s_1, dots, s_(|L|)} subset {0, 1}^n$ of length
    $|L| lt.eq (64b^2)/theta.alt^2$ consisting of pairwise distinct $n$-bit strings whose associated
    Fourier coefficients are nonzero.
  + $P$ follows the procedure in @Caro_2023[p. 27] to produce, with success probability
    $gt.eq 1 - delta/2$ a succinctly represented $tilde(phi.alt): cal(X)_n -> [-1, 1]$ such that
    $||tilde(phi.alt) - hat(phi.alt)||_infinity lt.eq theta.alt/2$ and
    $||tilde(theta)||_0 lt.eq (64 b^2)/theta.alt^2$. If $P$ obtains an output that violates the
    $||dot||_0$ bound, then $P$ declares failure and the interation aborts. Otherwise, $P$ sends the
    list $L = {s in {0, 1}^n: |tilde(phi.alt)(s) gt.eq theta.alt/2}$ to $V$.
  + If $V$ recieves a list $L$ of length $|L| > (64 b^2)/theta.alt^2$, $V$ rejects the interaction.
    Otherwise, $V$ uses $cal(O)((|L|^2 log ((|L|)/delta)) / epsilon^4)$ classical random examples
    from $cal(D)$ to obtain simultaneously $(epsilon^2/(16|L|))$-accurate estimates $hat(xi)(s)$ of
    $hat(phi.alt)(s)$ for all $s in L$ with success probability $gt.eq 1 - delta / 2$. For
    $t in.not L$, the verifier's estimate $hat(gamma)(t)$ for $hat(g)(t)$ is just 0.
  + If $sum_(ell = 1)^(|L|) (hat(xi)(s_ell))^2 gt.eq a^2 - epsilon^2/8$, then $V$ determines
    $s_("out") in "argmax"_(1 lt.eq ell lt.eq |L|) hat(xi))s$ and outputs the hypothesis
    $h: cal(X)_n -> {0, 1}, h(x) = s_("out") dot x$. If
    $sum_(ell = 1)^(|L|) (hat(xi)(s_ell))^2 lt a^2 - epsilon^2/8$ then $V$ outputs reject.
]

#proof[See @Caro_2023[p. 45].]
