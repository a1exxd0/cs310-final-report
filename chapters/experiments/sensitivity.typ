#import "../../template.typ": definition

== Sensitivity and Practical Limitations <sec:sensitivity>

The sensitivity experiments characterise how the protocol depends on its tunable parameters, and on
the Fourier structure of the target function.

=== Bent functions <sec:sensitivity-bent>

#definition(name: "Bent function")[
  A bent function is a Boolean function $f: bb(F)_2^n -> F_2$ where $n$ is even and achieves maximal
  nonlinearity. Equivalently, $f$ is bent if and only if its Walsh-Hadamard transform

  #math.equation(block: true, numbering: none)[
    $
      hat(f)(w) = sum_(x in bb(F)_n^2) (-1)^(f(x) plus.o chevron.l w, x chevron.r)
    $
  ]

  satisfies $|hat(f)(w)| = 2^(n / 2), forall w in bb(F)_2^n$. In other words, the function's Fourier
  spectrum is perfectly flat in magnitude.
]

The target function in this case is the canonical Maiorana-McFarland bent function
$f(x, y) = chevron.l x, y, chevron.r mod 2$ over $(bb(F)_2)^(n/2)$, for which
$|hat(g)(s)| = 2^(-(n / 2))$ uniformly on all $2^n$ input strings.

From the conditional probability $bb(P)[s|b = 1]$ in @sec:robustness-label-flip, we can set
$bb(E)_x[phi(x)^2] = 1$ and $eta = 0$ to collapse the distribution to $bb(P)[s|b = 1] = 2^(-n)$,
i.e. exactly uniform and information-theoretically indistinguishable from sampling noise.

From Caro et al. @Caro_2023[Corollary 5, p.28] we guarantee inclusion of $s in L$ when
$|hat(g)(s)| gt.eq epsilon$ and excludes $s$ when $|hat(g)(s)| lt epsilon/2$. For bent coefficients
$2^(-n/2)$ at $epsilon = 0.3$, this locates a crossover at $n = 2 log_2(2/epsilon) approx 5.47$.

At $n = 4$ all 16 flat-spectrum coefficients clear the conditional QFS extraction threshold
mentioned in @sec:robustness-gate-noise of 0.0225, so the returned $L$ will contain $s^*$ and $V$
will accept. At $n = 6$, the prover recovers at most one or two spurious coefficients per trial and
the verifier rejects.

#figure(
  caption: text[Recovered list size versus $n$],
)[
  #image("figures/sensitivity_1.png")
] <fig:sensitivity_1>

The sharp breakdown at $n = 6$ in @fig:sensitivity_1 demonstrates this behaviour exactly.

=== $theta$-sensitivity <sec:sensitivity-theta>

This experiment sweeps the Fourier resolution parameter $theta.alt$ against a fixed _sparse plus
noise_: a dominant coefficient at a random parity $s^*, c_("dom") = 0.7$ with three secondary
coefficients at $c_("sec") = 0.1$. To reiterate, the $theta.alt$ parameter is precisely responsible
for lower-bounding the magnitude of all non-zero Fourier coefficients of the conditional label
expectation $phi$. Every Fourier coefficient is either zero or at least $theta.alt$ in absolute
value.

With this, we can observe the interesting boundary at $theta.alt = 0.2 = 2 c_("sec")$ - the
extraction boundary in @fig:sensitivity_2 with the frontier visible as a vertical yellow band.

#figure(
  caption: text[
    A heatmap of acceptance rate parameterised by $n$, $theta$.
  ],
)[
  #image("figures/sensitivity_2.png")
] <fig:sensitivity_2>

Notice that we accept with low probability past the frontier $theta.alt = 0.2$, where $phi$ no
longer satisfies the "no small non-zero Fourier coefficients" promise required by the paper, even
when the dominant parity is still in hand.
