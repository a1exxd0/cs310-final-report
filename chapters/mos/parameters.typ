== Protocol Parameters <sec:protocol-parameters>

@thm:protocol exposes five primitive parameters: the agnostic accuracy $epsilon$, the confidence
$delta$, the Fourier-resolution threshold $theta.alt$, and the bracket $[a^2, b^2]$ on the second
moment $EE_(x tilde cal(U)_n)[tilde(phi)(x)^2]$ @Caro_2023[Def. 14]. These parameters are not
independent: Caro et al. @Caro_2023 require
$
  theta.alt in (2^(-(n\/2 - 3)), 1), quad
  0 <= a <= b <= 1, quad
  delta, epsilon in (0, 1), quad
  epsilon >= 2 sqrt(b^2 - a^2).
$
The last inequality couples the achievable accuracy to the bracket width and collapses to the
unconstrained case $epsilon > 0$ whenever $a = b$, which is exactly what happens in the noiseless
functional setting: a single underlying parity saturates Definition~14 with $a^2 = b^2 = 1$.
@tab:protocol-params pins each symbol from Theorem~3 to an identifier in the codebase, separating
parameters the caller supplies at invocation time from quantities the implementation derives
automatically.

#figure(
  table(
    columns: (auto, 1fr, auto),
    align: (left, left, left),
    table.hline(),
    table.header([*Symbol*], [*Meaning*], [*Codebase identifier*]),
    table.hline(),
    table.cell(colspan: 3, emph[State-class parameters (`mos/`)]),
    table.hline(),
    [$n$], [number of input bits], [`MoSState.n`],
    table.hline(),
    [$eta$], [label-flip noise rate], [`MoSState.noise_rate`],
    table.hline(),
    [$tilde(phi)$], [signed bias $1 - 2 phi.alt$, values in $[-1, 1]$], [`MoSState.tilde_phi`],
    [$tilde(phi)_"eff"$],
    [noise-damped bias $(1 - 2 eta) tilde(phi)$],
    [`MoSState.tilde_phi_effective`],
    [$rho_(cal(D))$], [mixture-of-superpositions state], [`MoSState`, `QuantumFourierSampler`],
    table.hline(),
    table.cell(colspan: 3, emph[Protocol parameters (`ql/prover.py`, `ql/verifier.py`)]),
    [$theta.alt$], [Fourier resolution threshold], [`theta`],
    [$epsilon$], [agnostic accuracy, $epsilon >= 2 sqrt(b^2 - a^2)$], [`epsilon`],
    [$delta$], [confidence parameter], [`delta`],
    [$a^2, b^2$], [second-moment bracket (Definition~14)], [`a_sq`, `b_sq`],
    [$L$], [heavy-coefficient list sent by the prover], [`ProverMessage.L`],
    table.hline(),
    table.cell(colspan: 3, emph[Derived quantities (auto-computed; overridable for ablations)]),
    [$64 b^2 \/ theta.alt^2$], [Step~3 list-size bound], [`list_size_bound`],
    [$epsilon^2 \/ (16|L|)$], [Step~3 per-coefficient tolerance], [`per_coeff_tolerance`],
    [$a^2 - epsilon^2 \/ 8$], [Step~4 acceptance threshold], [`acceptance_threshold`],
    [QFS shots (DKW)], [$Theta(log(1\/delta) \/ theta.alt^4)$], [`qfs_shots`],
    [classical examples (Hoeffding)],
    [$Theta(|L|^2 log(|L|\/delta) \/ epsilon^4)$],
    [`num_classical_samples`],
    table.hline(),
  ),
  caption: [@thm:protocol parameters and their codebase identifiers.],
) <tab:protocol-params>

*Noise convention.*
The parity experiments inject label noise through `MoSState.noise_rate`~$= eta$, which damps the
effective signed bias by a factor $1 - 2 eta$ and therefore the squared second moment by
$(1 - 2 eta)^2$. For a single underlying parity, $tilde(phi)_"eff"$ is still a
$plus.minus(1 - 2 eta)$-valued function of $x$, so $EE[tilde(phi)_"eff"^2] = (1 - 2 eta)^2$ exactly;
Definition~14 collapses with $a^2 = b^2 = (1 - 2 eta)^2$, the regime constraint
$epsilon >= 2 sqrt(b^2 - a^2)$ reduces to the trivial $epsilon > 0$, and the Step~4 acceptance
threshold of @thm:protocol becomes $(1 - 2 eta)^2 - epsilon^2 \/ 8$.

