from IPython.display import display
import numpy as np
from qiskit.primitives import StatevectorSampler, StatevectorEstimator
from qiskit import QuantumCircuit, QuantumRegister, ClassicalRegister
from qiskit.quantum_info import Operator

# Original example circuit in notes
# circuit = QuantumCircuit(1)
# circuit.h(0)
# circuit.s(0)
# circuit.h(0)
# circuit.t(0)
# Second example
# The Hadmard gate does the Hadmard operation on Y and does nothign to X, so we have our
# simple-ish example which is just I \otimes H. The second operation is a controlled-NOT where
# Y is the control and X is the target. Controlled not sends |b> \to |b> and |a> \to 
# |a \oplus b> (so the first qubit is just a "control" since it is unchanged)
# This ends up creating the state |\phi^+> when run on state |00>
# circuit2 = QuantumCircuit(2)
# circuit2.h(0)
# circuit2.cx(0,1)
# 
# display(circuit2.draw(output="text"))
# display(Operator.from_circuit(circuit2).draw("text"))

circuit = QuantumCircuit(2)
circuit.rx(-1 * (np.pi)/2, 1)
circuit.cx(0,1)

display(circuit.draw(output="text"))
print("Optimizes to: ")
circuit = QuantumCircuit(2)
circuit.rz(np.pi/2, 0)
circuit.x(0)
# circuit.rx(-1 * np.pi/2, 1)
# circuit.rx(1 * np.pi/2, 1)
circuit.rzx(np.pi/2,0, 1)
display(circuit.draw(output="text"))

print("Example 2: ")
circuit = QuantumCircuit(3)
circuit.x(0)
circuit.x(1)
circuit.x(2)
circuit.ry(np.pi, 0)
circuit.cx(0, 1)
circuit.cx(1, 2)
circuit.rz(np.pi/3, 2)
circuit.cx(0,1)
circuit.ry(np.pi,0)
display(circuit.draw(output="text"))

print("Optimizes to: ")
circuit.rz(3 * np.pi/2, 0)
circuit.rz(np.pi, 1)
circuit.rz(np.pi, 2)
circuit.rzx(np.pi/2,0,1)
circuit.rz(np.pi/2, 0)
circuit.x(0)
circuit.rx(np.pi/2,1)
circuit.rz(5.25, 1)
circuit.rx(np.pi/2,1)
circuit.rz(3 * np.pi/2,1)
circuit.rzx(np.pi/2,2,1)
circuit.rz(5.82,1)
circuit.rx(np.pi/2,1)
circuit.rz(5.76,1)
circuit.rx(np.pi/2,1)
circuit.rz(0.46,1)
circuit.rzx(np.pi/2,2,1)
circuit.rz(3 * np.pi/2, 1)
circuit.rx(1.03,1)
circuit.rz(np.pi,2)
circuit.x(2)
circuit.rzx(np.pi/2,0,1)
circuit.rz(np.pi,0)
circuit.x(0)
display(circuit.draw(output="text"))
# from qiskit import QuantumCircuit
# qc = QuantumCircuit(3)
# qc.h(0)
# qc.p(np.pi / 2, 0)
# qc.cx(0, 1)
# qc.cx(0, 2)

# qc_measured = qc.measure_all(inplace = False)
# print(qc.draw("text"))
# 
# from qiskit.primitives import StatevectorSampler, StatevectorEstimator
# sampler = StatevectorSampler()
# job = sampler.run([qc_measured], shots=1000)
# result = job.result()
# to_print = result[0].data["meas"].get_counts()
# print(f"Counts: {to_print}")
# 
# 
# from qiskit.quantum_info import SparsePauliOp
# operator = SparsePauliOp.from_list([("XXY", 1), ("XYX", 1), ("YXX", 1), ("YYY", -1)])
# 
# 
# estimator = StatevectorEstimator()
# job = estimator.run([(qc, operator)], precision=1e-3)
# result = job.result()
# print(f"Expectation Values: {result[0].data.evs}")




# from qiskit.quantum_info import Statevector, Operator
# from numpy import sqrt
# 
# zero = Statevector.from_label("0")
# one = Statevector.from_label("1")
# psi = zero.tensor(one)
# display(psi.draw("text"))
# 
# 
# plus = Statevector.from_label("+")
# minus_i = Statevector.from_label("l")
# phi = plus.tensor(minus_i)
# display(phi.draw("text"))
# 
# H = Operator.from_label("H")
# I = Operator.from_label("I")
# X = Operator.from_label("X")
# display(H.tensor(I).draw("text"))
# display(H.tensor(I).tensor(X).draw("text"))
