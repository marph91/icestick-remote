# https://stackoverflow.com/questions/29992174/scipy-fft-frequency-analysis-of-very-noisy-signal

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from scipy import signal

x = np.array([1, 1, 1, 1, 0, 0, 0, 0, 1, 1, 1, 1, 0, 0, 0, 0])
x = x - np.mean(x)
fs = 1e2

f, Pxx = signal.welch(x, fs, nperseg=1024)
f_res, Pxx_res = signal.welch(x, fs, nperseg=2048)

plt.subplot(3,1,1)
plt.plot(x)

plt.subplot(3,1,2)
plt.plot(f, Pxx)
plt.xlim([0, 1])
plt.xlabel('frequency [Hz]')
plt.ylabel('PSD')

plt.subplot(3,1,3)
plt.plot(f_res, Pxx_res)
plt.xlim([0, 1])
plt.xlabel('frequency [Hz]')
plt.ylabel('PSD')

plt.show()

Hn = np.fft.fft(x)
freqs = np.fft.fftfreq(len(Hn), 1/fs)
idx = np.argmax(np.abs(Hn))
freq_in_hertz = freqs[idx]
print('Main freq:', freq_in_hertz)
print('RMS amp:', np.sqrt(Pxx.max()))