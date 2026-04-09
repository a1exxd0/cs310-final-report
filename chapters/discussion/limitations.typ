== Limitations <sec:limitations>

The most consequential limitation is sample budget. Every experiment in @ch:experiments hard-codes
sample count and shot count regardless of $n$, or other protocol parameters. The analytic verifier
budget for a list of size $|L| = 10, epsilon = 0.3, delta = 0.1$ is approximately $3.8 times 10^7$.
The experiments use three orders of magnitude fewer and means that the resource scaling of
@Caro_2023[Thm. 12] is not validated by present data.

The other experimental limitations are inherently from the simulation substrate. Wall-clock cost is
dominated by the $2^(n + 1)$-dimensional `Statevector` construction, so any observed cost growth is
a property of the simulator and not the protocol. Furthermore, the brute-force circuit-based oracle
construction required for @sec:robustness-gate-noise is exponential in $n$ for both time and gate
count, so cannot extend past $n = 8$ without exceeding reasonable time limits.

Finally, no experiment was run on real quantum hardware, and it is a valid extension of this work to
do so.
