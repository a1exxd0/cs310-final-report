#import "../../template.typ": definition

== Quantum Preliminaries <sec:quantum-preliminaries>

=== Dirac Notation for Quantum Mechanics

The bra-ket notation @Dirac_1939 introduced by Paul Dirac in 1939 provides a concise algebraic
framework for the manipulation of vectors and linear functionals within a Hilbert space $cal(H)$.
Throughout this report, all Hilbert spaces are finite-dimensional and are isomorphic to $bb(C)^2^n$
for some $n in bb(N)$, a complex vector space equipped with an inner product.

#definition(name: "Bra-ket notation")[
  A ket vector $|psi chevron.r$ is an element of the Hilbert space $cal(H)$, representing a quantum
  state. In a finite-dimensional basis, this corresponds to a column vector in $bb(C)^d$. A bra
  vector $chevron.l phi.alt|$ is an element of the dual space $cal(H)^*$, obtained as the Hermitian
  conjugate transpose of its corresponding ket: $chevron.l phi.alt| = (|phi.alt chevron.r)^dagger$.
]

The inner product $chevron.l phi|psi chevron.r$ of two states
$|phi chevron.r comma |psi chevron.r in cal(H)$ yields a scalar in $bb(C)$. The outer product
$|phi chevron.r chevron.l psi|$ is the rank-1 linear operator on $cal(H)$ defined by its action on
an arbitrary state $|chi chevron.r in cal(H)$:
#math.equation(
  block: true,
  numbering: none,
)[$ |phi chevron.r chevron.l psi|)|chi chevron.r = chevron.l psi|chi chevron.r |phi chevron.r $]

=== Qubits and State Vectors

A _qubit_ is the fundamental unit of quantum information, analogous to a classical bit.
Mathematically, the state of a single qubit is a unit vector in the two-dimensional complex Hilbert
space $bb(C)^2$.

#definition(name: "Computational basis")[
  The _computational basis_ of $bb(C)^2$ consists of two orthonormal column vectors:

  #math.equation(
    block: true,
    numbering: none,
  )[
    $
      |0 chevron.r = mat(1; 0), quad quad
      |1 chevron.r = mat(0; 1).
    $
  ]

  An arbitrary single-qubit state can be written as a _superposition_:

  #math.equation(
    block: true,
    numbering: none,
  )[
    $
      |psi chevron.r = alpha|0 chevron.r + beta|1 chevron.r, quad quad
      alpha, beta in bb(C), quad quad
      |alpha|^2 + |beta|^2 = 1.
    $
  ]

  The constraint $|alpha|^2 + |beta|^2 = 1$ is the _normalisation condition_, ensuring that
  $|psi chevron.r$ is a unit vector under the standard inner product
  $chevron.l phi.alt|psi chevron.r = sum_i overline(phi.alt_i) psi_i$.
]

The state space of an $n$-qubit system is constructed via tensor product. Concretely, $n$ qubits
inhabit the Hilbert space:

#math.equation(
  block: true,
  numbering: none,
)[
  $ (bb(C)^2)^(times.o n) tilde.equiv bb(C)^2^n $
]

Which has dimension $2^n$. The computational basis of this space is indexed by $n$-bit strings:

#math.equation(
  block: true,
  numbering: none,
)[
  $ {|x chevron.r: x in {0, 1}^n} $
]

Where for example $|x_1, dots, x_n chevron.r = |x_1 chevron.r times.o dots times.o |x_n chevron.r$.
A general $n$-qubit pure state takes the form:

#math.equation(
  block: true,
  numbering: none,
)[
  $
    |psi chevron.r = sum_(x in {0, 1}^n) alpha_x|x chevron.r, quad quad
    sum_x |alpha_x|^2 = 1
  $
]

In the protocol of @ch:implementation, the prover prepares $(n + 1)$-qubit registers: $n$ qubits
encoding the input domain ${0, 1}^n$ and one ancilla qubit used for postselection (see
@sec:measurement).

=== Quantum Gates

A quantum gate acting on $k$ qubits is a $2^k times 2^k$ unitary matrix $U$ (where
$U^dagger U = bb(I)$). Unitarity guarantees that gate application preserves the normalisation
condition and is reversible. We introduce only the gates that appear in the verification protocol.

*Pauli-X gate.*
The Pauli-X gate is the quantum analogue of a classical _NOT_ gate, applied to a single qubit and
swapping $|0 chevron.r <-> |1 chevron.r$:

#math.equation(
  block: true,
  numbering: none,
)[
  $
    X = mat(0, 1; 1, 0)
  $
]

*Hadamard gate.*
The Hadamard gate maps computational basis states to uniform superpositions over a single qubit:

#math.equation(
  block: true,
  numbering: none,
)[
  $
    H = 1/sqrt(2) mat(1, 1; 1, -1)
  $
]

Its action on the computational basis is, for $b in {0, 1}$:

#math.equation(
  block: true,
  numbering: none,
)[
  $
    H|b chevron.r = 1/sqrt(2) sum_(y in {0, 1}) (-1)^(b dot y) |y chevron.r
  $
]

*$n$-fold Hadamard.* Applying $H$ independently to each of $n$ qubits yields $H^(times.o n)$, which
acts on computational basis states as:

#math.equation(
  block: true,
  numbering: none,
)[
  $
    H^(times.o n)|x chevron.r = 1/sqrt(2^n) sum_(y in {0, 1}^n) (-1)^(x dot y) |y chevron.r
  $
]

Where $x dot y = plus.o.big_(i=1)^n x_i y_i$ denotes the bitwise inner product modulo 2. This is the
discrete analogue of the Fourier transform over $bb(F)^n_2$ and is central to the Quantum Fourier
Sampling (QFS) subroutine in @sec:fourier-analysis.

*Multi-controlled-X (MCX) Gate.* The MCX gate flips a designated target qubit if and only if all $n$
control qubits are in state $|1 chevron.r$. In this protocol, MCX gates are used within an oracle
$U_f$ that encodes a boolean function $f: {0, 1}^n -> {0, 1}$ via:

#math.equation(
  block: true,
  numbering: none,
)[
  $
    U_f|x chevron.r|b chevron.r = |x chevron.r|b plus.o f(x) chevron.r
  $
]

The MCX gate is central to the implementation we provide in @ch:implementation.

=== Measurement <sec:measurement>

#definition(name: "Born rule")[
  The fundamental measurement postulate states that measuring an $n$-qubit state
  $|psi chevron.r = sum_x a_x|x chevron.r$ yields outcome $x in {0, 1}^n$ with probability:

  #math.equation(
    block: true,
    numbering: none,
  )[
    $
      bb(P)["outcome" x] = |a_x|^2
    $
  ]

  And the post-measurement state collapses to $|x chevron.r$.
]

When only a subset of $n$ qubits is measured, the remaining qubits are left in a conditional state
determined by the measurement outcome. Consider an $(n + 1)$-qubit state written as:

#math.equation(
  block: true,
  numbering: none,
)[
  $
    |psi chevron.r = sum_(x in {0, 1}^n) sum_(b in {0, 1}) alpha_(x, b) |x chevron.r |b chevron.r
  $
]

Measuring the last qubit and obtaining outcome $b_0$ occurs with probability:

#math.equation(
  block: true,
  numbering: none,
)[
  $
    p_b_0 = sum_x |a_(x, b_0)|^2
  $
]

And the conditional (post-measurement) state of the first $n$ qubits is:

#math.equation(
  block: true,
)[
  $
    |psi_b_0 chevron.r = 1/sqrt(p_b_0) sum_x a_(x, b_0) |x chevron.r
  $
] <eq:post-measurement>

#definition(name: "Postselection")[
  _Postselection_ is the procedure of discarding all runs of a quantum computation except those in
  which a designated measurement yields a specific outcome. The resulting (accepted) state is the
  conditional state in @eq:post-measurement corresponding to that outcome.
]

In the construction of Caro et al.'s classical verification for quantum learning protocol @Caro_2023
(which we implement in @sec:prover), the prover prepares an $(n + 1)$-qubit state and measures the
ancilla qubit. Only runs yielding outcome $b = 1$ are retained, the measurement shapes the amplitude
distribution of the remaining $n$-qubits into one that encodes a desired Fourier spectrum.
