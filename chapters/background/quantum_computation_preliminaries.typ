#import "../../template.typ": definition

== Quantum Preliminaries <sec:quantum-preliminaries>

=== Dirac Notation for Quantum Mechanics

The bra-ket notation @Dirac_1939 introduced by Paul Dirac in 1939 provides a concise algebraic framework
for the manipulation of vectors and linear functionals within a Hilbert space $cal(H)$. Throughout this
report, all Hilbert spaces are finite-dimensional and are isomorphic to $bb(C)^2^n$ for some $n in bb(N)$,
a complex vector space equipped with an inner product.

#definition(name: "Bra-ket notation")[
  A ket vector $|psi chevron.r$ is an element of the Hilbert space $cal(H)$, representing a quantum state.
  In a finite-dimensional basis, this corresponds to a column vector in $bb(C)^d$.
  A bra vector $chevron.l phi.alt|$ is an element of the dual space $cal(H)^*$, obtained as the Hermitian
  conjugate transpose of its corresponding ket: $chevron.l phi.alt| = (|phi.alt chevron.r)^dagger$.
]

#definition(name: "Inner product")[
  The inner product $chevron.l phi|psi chevron.r$ of two states $|phi chevron.r comma |psi chevron.r in cal(H)$
  yields a scalar in $bb(C)$.
]

#definition(name: "Outer product")[
  The outer product $|phi chevron.r chevron.l psi|$ is the rank-1 linear operator on $cal(H)$ defined by its
  action on an arbitrary state $|chi chevron.r in cal(H)$:
  #math.equation(
    block: true,
    numbering: none,
  )[$ |phi chevron.r chevron.l psi|)|chi chevron.r = chevron.l psi|chi chevron.r |phi chevron.r $]
]

=== Qubits and State Vectors

A _qubit_ is the fundamental unit of quantum information, analogous to a classical bit. Mathematically, the
state of a single qubit is a unit vector in the two-dimensional complex Hilbert space $bb(C)^2$.

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

  The constraint $|alpha|^2 + |beta|^2 = 1$ is the _normalisation condition_, ensuring that $|psi chevron.r$ is
  a unit vector under the standard inner product $chevron.l phi.alt|psi chevron.r = sum_i overline(phi.alt_i) psi_i$.
]

The state space of an $n$-qubit system is constructed via tensor product. Concretely, $n$ qubits inhabit
the Hilbert space:

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

In the protocol of @ch:implementation, the prover prepares $(n + 1)$-qubit registers: $n$ qubits encoding the input domain ${0, 1}^n$ and one ancilla qubit used for postselection (see @sec:measurement).

=== Quantum Gates

=== Measurement <sec:measurement>


// TODO: ~250 words. Only material needed to understand the protocol circuits.
// Audience: final-year UG, no quantum knowledge, elementary LA assumed.

// - Qubits and state vectors: qubit as unit vector in C^2, computational basis
//   {|0>, |1>}, superposition α|0> + β|1> with |α|^2 + |β|^2 = 1.
//   Frame via LA: column vectors, inner products.
//
// - Multi-qubit systems: tensor product (C^2)^{⊗n}, computational basis
//   {|x> : x ∈ {0,1}^n}, dimension 2^n. Needed because the protocol operates
//   on (n+1)-qubit registers.
//
// - Quantum gates: unitary matrices. Only the gates the protocol uses:
//   Pauli-X, Hadamard H, and the n-fold Hadamard H^{⊗n}. Give the 2×2 matrix
//   for H explicitly. MCX too.
//
// - Measurement: Born rule — measuring Σ_x α_x|x> in the computational basis
//   yields outcome x with probability |α_x|^2, collapsing the state.
//   This is the mechanism behind postselection in the MoS protocol.
//
// - Partial measurement and postselection: measuring a subset of qubits,
//   conditional state of remaining qubits. Brief definition of postselection
//   (accepting only runs where a designated qubit yields a specific outcome).
//   Directly needed for the MoS construction (b=1 postselection).
//
// - Forward pointer: the Hadamard transform H^{⊗n}|x> =
//   1/√(2^n) Σ_s (-1)^{<s,x>}|s> connects quantum measurement probabilities
//   to Fourier coefficients; this connection is developed in §2.4.
