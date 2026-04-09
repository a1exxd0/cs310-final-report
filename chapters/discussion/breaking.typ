== Protocol failure modes <sec:breaking>

Two distinct failure modes appear, the first of which is a _vanishing-margin acceptance ceiling_. In
the multi-element soundness experiment of @sec:soundness-multi-element, the _subset plus noise_
strategy rejected with a per-cell minimum at $k=2$ of $91%$. Whilst this sits above the required
$1 - delta = 0.9$, we can identify that this is derived from the structure of the adversarial
strategy itself. Namely, that we submit a heavy Fourier coefficient alongside spurious lighter
coefficients. One can observe a similar behaviour in @sec:soundness-single-parity for the _random
parity_ case.

The second failure mode is _prover-side_ breakdown, where the formal preconditions of @thm:protocol
break down. In the @sec:robustness-gate-noise, this manifests as the empty-list transition past
$eta_("max")$, the prover correctly declares failure rather than producing a wrong hypothesis. We
also observe this pattern of behaviour across @sec:sensitivity-theta, @sec:sensitivity-bent and
more, where the cause of rejection is structural and not adversarial (and the verifier responds
correctly in any case).
