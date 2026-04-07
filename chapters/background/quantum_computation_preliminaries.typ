#import "../../template.typ": definition

== Quantum Preliminaries <sec:quantum-preliminaries>

=== Hilbert Spaces

In the circuit model of quantum computation, the fundamental unit of information is the _qubit_, mathematically described by a state vector in the two-dimensional Hilbert space $bb(C)^2$.

#definition(name: "Hilbert space")[
  A Hilbert space $cal(H)$ is a complex vector space equipped with an inner product $chevron.l dot, dot chevron.r : cal(H) times cal(H) -> bb(C)$ satisfying, for all $f, g, h in cal(H)$ and $alpha in bb(C)$:

  + Conjugate symmetry: $chevron.l f, g chevron.r = overline(chevron.l g comma f chevron.r)$
  + Linearity in the second argument: $chevron.l f, alpha g + h chevron.r = alpha chevron.l f, g chevron.r + chevron.l f, h chevron.r$
  + Positive definiteness: $chevron.l f, f chevron.r >= 0$ with equality if and only if $f = 0$

  together with completeness under the induced norm $||f|| = sqrt(chevron.l f comma f chevron.r)$. Since every finite-dimensional inner product space is automatically complete, the Hilbert spaces in this report are simply $bb(C)^d$ with the standard inner product.

  We adopt the convention that the inner product is linear in the second argument and conjugate-linear in the first, consistent with the standard in mathematics and theoretical computer science.
]

=== Dirac Notation for Quantum Mechanics

The bra-ket notation @Dirac_1939 introduced by Paul Dirac in 1939 provides a concise algebraic framework for the manipulation of vectors and linear functionals within a Hilbert space $cal(H)$. Throughout this report, all Hilbert spaces are finite-dimensional.

#definition(name: "Ket vector")[
  A ket $|psi chevron.r$ is an element of the Hilbert space $cal(H)$, representing a quantum state. In a finite-dimensional basis, this corresponds to a column vector in $bb(C)^d$.
]

#definition(name: "Bra vector")[
  A bra $chevron.l phi.alt|$ is an element of the dual space $cal(H)^*$, obtained as the Hermitian conjugate transpose of its corresponding ket: $chevron.l phi.alt| = (|phi.alt chevron.r)^dagger$.
]

#definition(name: "Inner product")[
  The inner product $chevron.l phi|psi chevron.r$ of two states $|phi chevron.r comma |psi chevron.r in cal(H)$ yields a scalar in $bb(C)$.
]

#definition(name: "Outer product")[
  The outer product $|phi chevron.r chevron.l psi|$ is the rank-1 linear operator on $cal(H)$ defined by its action on an arbitrary state $|chi chevron.r in cal(H)$:
  #math.equation(
    block: true,
    numbering: none,
  )[$ |phi chevron.r chevron.l psi|)|chi chevron.r = chevron.l psi|chi chevron.r |phi chevron.r $]
]

=== Qubits and State Vectors

Where a classical bit assumes a definite value in ${0, 1}$, a _qubit_ can occupy a _superposition_ of both values simultaneously. This distinction is the source of the computational phenomena that quantum algorithms exploit.

#definition(name: "Computational basis")[
  The computational basis of $bb(C)^2$ consists of two orthonormal vectors:

  #math.equation(block: true, numbering: none)[$|0 chevron.r = mat(1; 0), quad quad |1 chevron.r = mat(0; 1).$]
]

#definition(name: "Qubit")[
  A qubit is a unit vector in the Hilbert space $bb(C)^2$. The most general single-qubit state is a sum of computational basis states:

  #math.equation(block: true, numbering: none)[
    $|psi chevron.r = alpha|0 chevron.r + beta|1 chevron.r, quad quad
    alpha, beta in bb(C), quad quad
    |alpha|^2 + |beta|^2 = 1.$
  ]
]

For an $n$-qubit system, the state space is the tensor product $(bb(C)^2)^(times.o n) tilde.equiv bb(C)^2^n$ with computational basis ${|x chevron.r: x in {0, 1}^n}$. Since an arbitrary state requires specifying all $2^n$ complex amplitudes, classical simulation of $n$-qubit systems incur $Theta(2^n)$ memory, the binding constraint in practice.

=== Quantum Gates

=== Measurement


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
