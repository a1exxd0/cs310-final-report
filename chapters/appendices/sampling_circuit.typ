= Circuit diagram of sampling MoS with $n = 3$ <fig:mos-qfs-circuit-diagram>

#import "@preview/quill:0.7.2": *

#figure(
  quantum-circuit(
    // --- n input qubits ---
    lstick($rho_cal(D)$, n: 3),
    setwire(0),
    1,
    lstick($x_1$),
    setwire(1),
    $H$,
    meter(),
    setwire(2),
    rstick($s_1$),
    [\ ],

    setwire(0),
    2,
    lstick($x_2$),
    setwire(1),
    $H$,
    meter(),
    setwire(2),
    rstick($s_2$),
    [\ ],

    setwire(0),
    2,
    lstick($x_3$),
    setwire(1),
    $H$,
    meter(),
    setwire(2),
    rstick($s_3$),
    [\ ],

    // --- label qubit ---
    setwire(0),
    2,
    lstick($y$),
    setwire(1),
    $H$,
    meter(),
    setwire(2),
    rstick([post-select $b = 1$]),
  ),
  caption: [
    *Mixture-of-superpositions quantum Fourier sampling.*
    A single copy of the $(n+1)$-qubit mixed state $rho_D$ is prepared (left block), Hadamard gates
    $H$ are applied to every qubit, and all qubits are measured in the computational basis. The
    label qubit ($y$) is post-selected on outcome $b = 1$, which succeeds with probability
    $1 slash 2$. The remaining $n$-bit string $s = (s_1 , dots.h , s_n)$ yields an approximate
    Fourier sample of $phi = 1 - 2 phi.alt$.
  ],
)
