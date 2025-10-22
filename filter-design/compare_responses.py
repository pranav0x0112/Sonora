import numpy as np
from fir_design import coeffs, output_float

with open('../build/sim_output.txt', 'r') as f:
    lines = f.readlines()

bsv_outputs = []
for line in lines:
    if 'OUTPUT[' in line:
        # Extract the value after '='
        value = int(line.split('=')[1].strip())
        # Convert from Q15 back to float
        bsv_outputs.append(value / 32768.0)

bsv_outputs = np.array(bsv_outputs[:31])
python_outputs = output_float[:31]

abs_diff = np.abs(bsv_outputs - python_outputs)
max_error = np.max(abs_diff)
rmse = np.sqrt(np.mean(abs_diff**2))

print("\nImpulse Response Comparison:")
print("Index  Python        BSV           Diff")
print("-" * 45)
for i in range(31):
    print(f"{i:2d}:    {python_outputs[i]:+.8f}  {bsv_outputs[i]:+.8f}  {abs_diff[i]:+.8f}")

print("\nError Metrics:")
print(f"Maximum Absolute Error: {max_error:.8f}")
print(f"Root Mean Square Error: {rmse:.8f}")

if max_error < 0.0001 and rmse < 0.00005:
    print("\n PASS: BSV implementation matches Python reference!")
else:
    print("\n  WARNING: Error exceeds expected quantization noise")