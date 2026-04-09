== Robustness Experiments <sec:robustness>

The robustness experiments probe how the protocol degrades when one of its assumptions is perturbed.
In @sec:robustness-label-flip, we sweep the $eta$ noise parameter from Caro et al. @Caro_2023[Lemma
  6], and in @sec:robustness-gate-noise, we report a purely exploratory study of per-gate
depolarising noise (of which Caro et al. make no theoretical prediction).

=== Label-flip noise sweep <sec:robustness-label-flip>

For a target parity $s^*$ @Caro_2023[Lemma 6] gives the conditional QFS distribution:

#math.equation(block: true, numbering: none)[
  $bb(P)[s|b = 1] = (4 eta - 4 eta^2)/2^n + (1 - 2 eta)^2 hat(g)(s)^2, g = (-1)^f$
]

So the fourier mass accumulated at $s^*$ should track $(1 - 2 eta)^2$ exactly, perturbed only by an
$n$-independent uniform term. We observe the protocol entering its formal breakdown at
$eta_("max") approx 0.4470$, the root at which the $(1 - 2 eta)^2 - epsilon^2 / 8$ of @thm:protocol
becomes negative.

The noise sweep experiment contains $approx 17000$ trials across $n in {4, dots, 16}$ and 13 noise
rates

#math.equation(block: true, numbering: none)[
  $
    eta in {0.00, 0.05, 0.1, 0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.42, 0.44, 0.46, 0.48}
  $
]

Where the four largest $eta$ cross the aforementioned theoretical breakdown for $epsilon = 0.3$.

#figure(
  caption: text[
    Measured Fourier mass at $s^*$ against the prediction $(1 - 2 eta)^2$ on single-parity targets.
  ],
)[
  #box(
    clip: true,
    inset: (bottom: -9%),
    image("figures/robustness_1.png"),
  )
] <fig:robustness_1>

#figure(
  table(
    columns: 4,
    align: (center, center, center, center),
    stroke: none,
    table.hline(stroke: 1.5pt),
    table.header($eta$, $(1 - 2 eta)^2$, [mean over $n$], [rel. err]),
    table.hline(stroke: 0.75pt),
    $0.00$, $1.0000$, $1.0000$, $0.0%$,
    $0.05$, $0.8100$, $0.8103$, $0.0%$,
    $0.10$, $0.6400$, $0.6404$, $0.1%$,
    $0.15$, $0.4900$, $0.4894$, $0.1%$,
    $0.20$, $0.3600$, $0.3611$, $0.3%$,
    $0.25$, $0.2500$, $0.2509$, $0.4%$,
    $0.30$, $0.1600$, $0.1615$, $0.9%$,
    $0.35$, $0.0900$, $0.0913$, $1.5%$,
    $0.40$, $0.0400$, $0.0407$, $1.8%$,
    $0.42$, $0.0256$, $0.0258$, $0.9%$,
    table.hline(stroke: 1.5pt),
  ),
  caption: [Re-decoded filtered median of the QFS mass at $s^*$, averaged over $n in {4, dots, 16}$
    averaged against the $(1 - 2 eta)^2$ prediction. Relative error stays below $1.8%$ everywhere on
    the feasible side of $eta_"max"$.],
) <tab:robustness_1>

@fig:robustness_1 overlays median QFS mass at $s^*$ on the theoretical curve $(1 - 2 eta)^2$.
@tab:robustness_1 shows the mean over $n$ matches theory to within $1.8%$ relative error at every
$eta lt.eq 0.42$.

=== Gate-level depolarising noise <sec:robustness-gate-noise>

This experiment probes the robustness of the protocol to per-gate depolarising noise (whilst the
verifier samples a noiseless $rho_cal(D)$); unlike every other experiment, Caro et al. @Caro_2023
provide no theoretical reference point here.

The produced data set `results/gate_noise_4_8_50.pb` contain 50 trials for $n in {4, dots, 8}$, and
12 per-gate error rates with label noise $eta = 0$:

#math.equation(block: true, numbering: none)[
  $
    p in {0, 0.0001, 0.0005, 0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5}
  $
]

In this simulation, we force execution to circuit mode, so the oracle is compiled as a gate circuit.
This is necessary for per-gate noise simulation, and is why it is infeasible to run this for
$n gt 8$.

#figure(
  caption: text[
    Acceptance rate against prover-side per-gate depolarising noise rate $p$, broken out by $n$.
  ],
)[
  #image("figures/robustness_2.png")
] <fig:robustness_2>

Notice @fig:robustness_2 shows sharp degradation to noise $p$ with $n$, however the protocol appears
unexpectedly robust for $n lt 6$ and large $p$. Note the uniform noise floor $1/2^n$ exceeds the
extraction threshold $theta.alt^2/4 = 0.0225$ precisely when $n lt.eq 5$, so even a maximally
depolarised QFS circuit emits a list that trivially contains the target string. In this case, the
list-size bound $(64 b^2) / theta.alt^2$ will not flag for small $n$.
