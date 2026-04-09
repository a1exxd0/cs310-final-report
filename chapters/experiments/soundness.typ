#import "../../template.typ": definition

== Soundness Experiments <sec:soundness>

The soundness experiments measure whether the verifier rejects dishonest provers, instantiated as a
finite menu of hand-written cheating strategies that bypass the prover and feed adversarial input
directly to the verifier. Caro et al. @Caro_2023[Definition 7] state that the probability that the
verifier accepts a hypothesis with error exceeding $alpha dot "opt" + epsilon$ is at most $delta$.

@sec:soundness-single-parity treats single-parity targets and four cheating strategies;
@sec:soundness-multi-element treats $k$-sparse targets and a separate menu of strategies that probe
the Caro et al. @Caro_2023[Thm. 15] weight check.

=== Single-parity dishonest provers <sec:soundness-single-parity>

@def:iv requires that against any dishonest $P'$, the verifier output $h$ satisfies @eq:soundness.
The harness file `experiments/harness/soundness.py` bypasses the honest prover entirely and feeds
four adversarial transcripts directly into the verifier, recording whether $V$ accepts and whether
the resulting hypothesis is $epsilon$-close to the planted parity.

The data set `results/soundness_4_20_100.pb` contains $6800$ trials across $n in {4, dots, 20}$, 100
trials per $n$. Throughout, we fix
$epsilon = 0.3, delta = 0.1, theta.alt = epsilon = 0.3, a^2 = b^2 = 1$ and $m_V = 3000$ verifier
samples. The four cheating strategies are: a _random list_, five distinct random indices (so each
$s^*$ is present with probability $5 / 2^n$); _wrong parities_, the singleton ${(s^* + 1) mod 2^n}$;
the empty list $L = []$; and an _inflated list_ with ten random indices excluding $s^*$.

#figure(
  image("figures/soundness_1.png"),
  caption: text[
    Soundness against the four hand-written cheating strategies. On the left is the indicator
    $1 - bb(P)["accept" and "wrong"]$. On the right, the raw rejection rate.
  ],
) <fig:soundness_1>

#figure(
  caption: "Per-strategy rejection rate.",
)[
  #table(
    columns: 7,
    table.header[Strategy][$n = 4$][$n = 8$][$n = 12$][$n = 16$][$n = 20$][Bad accept],
    [Random list], [$71%$], [$97%$], [$100%$], [$100%$], [$100%$], [0/1700],
    [Wrong parity], [$100%$], [$100%$], [$100%$], [$100%$], [$100%$], [0/1700],
    [Empty list], [$100%$], [$100%$], [$100%$], [$100%$], [$100%$], [0/1700],
    [Inflated list], [$100%$], [$100%$], [$100%$], [$100%$], [$100%$], [0/1700],
  )
] <fig:soundness_table_1>

We distinguish acceptance in incorrect cases from a soundness violation: a cheating strategy may
happen to submit a hypothesis that is in fact $epsilon$-good, in which case acceptance is correct.
This is visible in @fig:soundness_1, @fig:soundness_table_1, where the 5-element list in the _random
list_ case happens to contain $s^*$. The observed counts match the analytical $5/2^n$ prediction
within a safe interval; at $n = 4$, we predict $31$ accepts out of $100$ and observe $29$.

In all rejection cases, the weight-check of @thm:protocol is responsible for rejection in every
cell. This is due to the implemented list-size bound $(64 b^2)/theta.alt^2$ never being triggered,
because the largest adversarial list submitted has $|L| = 10$. This is a weakness of the experiment
and an extension of future work to test this specific failure case.

=== Multi-element dishonest provers <sec:soundness-multi-element>

In this experiment, we sweep a cheating prover through four multi-element dishonest strategies:
_partial real_ being the weaker half of the real set of heavy coefficients and 3 random fakes;
_diluted list_, $k / 2$ weakest real coefficients and up to 20 padding; _entirely wrong_ indices
with fabricated large coefficients; and _subset plus noise_, which is the single heaviest Fourier
coefficient with 5 fakes.

#figure(
  caption: text[
    Rejection rates by strategy and Fourier-sparsity $k$.
  ],
)[
  #table(
    columns: 5,
    table.header[Strategy][$k = 2$ mean][$k = 2$ min][$k = 4$ mean][$k = 4$ min],
    [Partial real], [$100%$], [$100%$], [$100%$], [$100%$],
    [Diluted list], [$98.5%$], [$96%$], [$100%$], [$100%$],
    [Entirely wrong], [$100%$], [$100%$], [$100%$], [$100%$],
    [Subset plus noise], [$95.1%$], [$91%$], [$99.8%$], [$98%$],
  )
] <fig:soundness_table_2>

The most significant boundary cell in @fig:soundness_table_2 is for the strategy submitting the
single-heaviest real Fourier coefficient plus five random fakes, so it carries real signal.
