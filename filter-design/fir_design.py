import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import firwin ,freqz

fs = 48000 # Sampling frequency
cutoff_hz = 4000 
num_taps = 31
window_type = 'kaiser'
beta = 8.6

if window_type == 'kaiser':
    coeffs = firwin(num_taps, cutoff_hz, fs=fs, window=(window_type, beta))
else:
    coeffs = firwin(num_taps, cutoff_hz, fs=fs, window=window_type)

w, h = freqz(coeffs, worN=8000)
plt.figure(figsize=(8,4))
plt.plot((w/np.pi)*(fs/2), 20 * np.log10(np.abs(h)))
plt.title("FIR Low-Pass Filter (Kaiser window)")
plt.xlabel("Frequency (Hz)")
plt.ylabel("Magnitude (dB)")
plt.grid(True)
plt.tight_layout()
plt.show()

np.savetxt("docs/fir_coeffs.txt", coeffs, fmt="%.8f")
print(f"[INFO] Saved {len(coeffs)} coefficients to coeffs/fir_coeffs.txt")