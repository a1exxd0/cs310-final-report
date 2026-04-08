== Protocol Parameters (INCOMPLETE, CHECK) <sec:protocol-parameters>

The protocol's behaviour is governed by five interrelated parameters: the agnostic accuracy
$epsilon$, the confidence $delta$, the Fourier-resolution threshold $theta.alt$, and the bracket
$[a^2, b^2]$ on $bb(E)_(x tilde cal(U)_n)[tilde(phi.alt)(x)^2]$. @tab:protocol-parameters maps each
symbol in @Caro_2023[Theorem 12, p. 45] to the corresponding identifier in `mos/`, `ql/prover.py`,
and `ql/verifier.py`.

The interlocking relationships from Theorem 12 are reproduced verbatim by the simulation. The
accuracy is coupled to the bracket width through $epsilon gt.eq 2 sqrt(b^2 - a^2)$, which collapses
to the unconstrained case $epsilon > 0$ when $a = b$ (e.g.~the noiseless functional setting). The
honest `MoSProver` extracts at most $16 \/ theta.alt^2$ heavy frequencies — the tighter Parseval
bound it can prove for itself — while `MoSVerifier._verify_core` enforces the looser
malicious-prover bound $|L| lt.eq 64 b^2 \/ theta.alt^2$ on whatever list it receives. From the
Hoeffding inequality, the verifier draws $cal(O)((|L|^2 log(|L|/delta))/epsilon^4)$ classical
examples to obtain simultaneous $epsilon^2 \/ (16|L|)$-accurate estimates $hat(xi)(s)$, then accepts
iff $sum_(s in L) hat(xi)(s)^2 gt.eq a^2 - epsilon^2 \/ 8$. Under the noisy distributional setting
(`MoSState.noise_rate` $eta > 0$), the effective spectrum is damped by $1 - 2 eta$, so the
experimental harness sets $a^2 = b^2 = (1 - 2 eta)^2$ for the parity case.

#figure(
  table(
    columns: (auto, auto, auto, auto),
    align: (left, left, left, left),
    stroke: 0.5pt,
    table.header([*Symbol*], [*Caro et al. (Thm 12, p. 45)*], [*Codebase identifier*], [*Module*]),
    [$n$], [number of input bits], [`MoSState.n`], [`mos`],
    [$eta$], [label-flip noise rate], [`MoSState.noise_rate`], [`mos`],
    [$tilde(phi.alt)$],
    [$1 - 2 phi$, the $plus.minus 1$-valued bias],
    [`MoSState.tilde_phi`],
    [`mos`],

    [$tilde(phi.alt)_("eff")$],
    [$(1 - 2 eta) tilde(phi.alt)$],
    [`MoSState.tilde_phi_effective`],
    [`mos`],

    [$rho_cal(D)$], [MoS state], [`MoSState` + `QuantumFourierSampler`], [`mos`],
    [$theta.alt$], [Fourier resolution threshold], [`theta` kwarg], [`ql/{prover,verifier}`],
    [$epsilon$],
    [agnostic accuracy ($gt.eq 2sqrt(b^2-a^2)$)],
    [`epsilon` kwarg],
    [`ql/{prover,verifier}`],

    [$delta$], [confidence parameter], [`delta` kwarg], [`ql/{prover,verifier}`],
    [$a^2,b^2$],
    [bracket on $bb(E)[tilde(phi.alt)^2]$ (Def. 14)],
    [`a_sq`, `b_sq` (`verify_parity`)],
    [`ql/verifier`],

    [$L$], [heavy-coefficient list], [`ProverMessage.L`], [`ql/prover`],
    [$64 b^2 \/ theta.alt^2$], [list-size bound (Step 3)], [`list_size_bound`], [`ql/verifier`],
    [Step 1 copies],
    [QFS shots, $cal(O)(log(1/delta) \/ theta.alt^4)$],
    [`qfs_shots` (auto from $delta,theta.alt$)],
    [`ql/prover`],

    [Step 2 examples],
    [$cal(O)((|L|^2 log(|L|/delta)) \/ epsilon^4)$],
    [`num_classical_samples`],
    [`ql/verifier`],

    [$epsilon^2 \/ (16|L|)$], [per-coefficient tolerance], [`per_coeff_tolerance`], [`ql/verifier`],
    [$a^2 - epsilon^2 \/ 8$],
    [acceptance threshold (Step 4)],
    [`acceptance_threshold`],
    [`ql/verifier`],
  ),
  caption: [Mapping of Theorem 12 parameters to codebase identifiers. Sample-complexity rows give
    the auto-computed defaults used when no explicit override is passed; both
    `MoSProver.run_protocol` and `MoSVerifier.verify_parity` accept manual overrides for ablation
    experiments.],
) <tab:protocol-parameters>

Notes on a few subtleties baked into the prose so you can decide whether to keep them:

- Honest-prover vs.\ malicious-prover list bound. ql/prover.py:490 truncates L at 16 / theta**2 (the
  tight Parseval bound), while ql/verifier.py:464 allows up to ceil(64 times b_sq / theta^2). The
  discrepancy is intentional and matches Caro et al. — the verifier needs the looser bound to be
  sound against an adversary that pads L.
- Auto-computed sample budgets. MoSProver.run_protocol derives qfs_shots from 2.5 * 2 * log(4/δ) /
  (θ²/8)²
(ql/prover.py:316-321) and MoSVerifier.\_verify_core derives num_samples from the Hoeffding bound
(ql/verifier.py:493-501); both expose overrides which is why I phrased the table rows as defaults.
- Noise feeding into a², b². The dissertation harness translates noise_rate η into a_sq = b_sq = (1
  - 2η)². If your
experiments don't all do that — e.g., the gate-noise sweep may use a different convention — let me
know and I'll adjust the last sentence.

TODO: FINISH DRAFTING THIS
