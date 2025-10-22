import numpy as np
import matplotlib.pyplot as plt
from scipy.signal import firwin, freqz, lfilter

# Filter design parameters
fs = 48000  # Sampling frequency
cutoff_hz = 4000 
num_taps = 31
window_type = 'kaiser'
beta = 8.6

coeffs = firwin(num_taps, cutoff_hz, fs=fs, window=(window_type, beta))

q15_coeffs = np.round(coeffs * 32768).astype(np.int16)

impulse = np.zeros(100)
impulse[0] = 1.0

output_float = lfilter(coeffs, [1.0], impulse)

if __name__ == '__main__':
    print("\nFilter Coefficients:")
    print("Index  Float          Q15")
    print("-" * 40)
    for i, (f, q) in enumerate(zip(coeffs, q15_coeffs)):
        print(f"{i:2d}:    {f:+.8f}    {q:+6d}")

    print("\nImpulse Response (first 31 samples):")
    print("Index  Output")
    print("-" * 30)
    for i in range(31):
        print(f"{i:2d}:    {output_float[i]:+.8f}")

    plt.figure(figsize=(10,6))

    plt.subplot(211)
    w, h = freqz(coeffs, worN=8000)
    plt.plot((w/np.pi)*(fs/2), 20 * np.log10(np.abs(h)))
    plt.title("FIR Low-Pass Filter (Kaiser window)")
    plt.xlabel("Frequency (Hz)")
    plt.ylabel("Magnitude (dB)")
    plt.grid(True)

    plt.subplot(212)
    plt.stem(range(31), output_float[:31])
    plt.title("Impulse Response (first 31 samples)")
    plt.xlabel("Sample")
    plt.ylabel("Amplitude")
    plt.grid(True)

    plt.tight_layout()
    plt.show()

    # Save floating-point, Q15 coefficients and impulse response to file
    with open("../docs/fir_coeffs.txt", "w") as f:
        f.write("Filter Coefficients:\n")
        f.write("Index  Float          Q15\n")
        f.write("-" * 40 + "\n")
        for i, (flt, q15) in enumerate(zip(coeffs, q15_coeffs)):
            f.write(f"{i:2d}:    {flt:+.8f}    {q15:+6d}\n")
        
        f.write("\nImpulse Response (first 31 samples):\n")
        f.write("Index  Output\n")
        f.write("-" * 30 + "\n")
        for i in range(31):
            f.write(f"{i:2d}:    {output_float[i]:+.8f}\n")
            
    print(f"\nSum of coefficients: {coeffs.sum():.8f}") 
    print(f"Sum of Q15 coeffs (scaled back): {q15_coeffs.sum()/32768:.8f}")
    print(f"\n[INFO] Saved coefficients and impulse response to docs/fir_coeffs.txt")
    print(f"[INFO] Saved {len(coeffs)} coefficients to docs/fir_coeffs.txt")