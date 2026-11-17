#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""Compares a host-decimated capture with a direct, wider capture of the same band.

    compare.py <direct.cf32> <direct rate> <decimated.cf32> <decimated rate>

Both captures should be taken back to back at the same frequency and gain (see capture.c), with
the direct rate at least 5 MSps so it doesn't use host decimation itself. Prints:

- how closely the decimated spectrum matches the centre of the direct one over +-40% of the
  decimated rate (shape after level matching), and
- for the strongest signals outside the decimated band, how much more the decimated capture shows
  where they would alias than the direct capture shows at that same frequency. Near 0 dB means
  no visible alias, even when a real signal already sits at that spot.

Needs numpy.
"""

import sys

import numpy as np


def psd(path, fs, nfft):
    x = np.fromfile(path, dtype=np.complex64)
    x = x[: (len(x) // nfft) * nfft].reshape(-1, nfft)
    w = np.blackman(nfft)
    p = (np.abs(np.fft.fftshift(np.fft.fft(x * w, axis=1), axes=1)) ** 2).mean(0) / (w**2).sum() / fs
    f = np.fft.fftshift(np.fft.fftfreq(nfft, 1 / fs))
    return f, 10 * np.log10(p + 1e-30)


def main():
    if len(sys.argv) != 5:
        print(__doc__)
        return 2

    direct, fs_d, decim, fs_m = sys.argv[1], float(sys.argv[2]), sys.argv[3], float(sys.argv[4])
    bin_hz = 1e3
    fd, pd = psd(direct, fs_d, int(fs_d / bin_hz))
    fm, pm = psd(decim, fs_m, int(fs_m / bin_hz))

    band = (np.abs(fm) <= 0.4 * fs_m) & (np.abs(fm) > 5 * bin_hz)   # skip the DC spike
    pd_on_fm = np.interp(fm[band], fd, pd)
    offset = np.median(pm[band] - pd_on_fm)                         # level difference between captures
    diff = pm[band] - pd_on_fm - offset
    print(f"passband: median deviation {np.median(np.abs(diff)):.2f} dB, "
          f"95th percentile {np.percentile(np.abs(diff), 95):.2f} dB")

    floor_d = np.median(pd[np.abs(fd) < 0.4 * fs_m])
    oob = (np.abs(fd) > 0.6 * fs_m) & (np.abs(fd) < 0.45 * fs_d)
    seen = []
    worst = -1e9
    for i in np.argsort(pd[oob])[::-1]:
        f0 = fd[oob][i]
        if any(abs(f0 - s) < 50 * bin_hz for s in seen):
            continue
        seen.append(f0)
        alias = ((f0 + fs_m / 2) % fs_m) - fs_m / 2
        if abs(alias) < 5 * bin_hz or abs(alias) > 0.4 * fs_m:
            continue                                                # DC spike or decimator transition band
        # What the decimated capture shows there, beyond what the direct capture shows at that frequency
        excess = pm[np.argmin(np.abs(fm - alias))] - (np.interp(alias, fd, pd) + offset)
        worst = max(worst, excess)
        print(f"out-of-band signal at {f0 / 1e6:+.3f} MHz, {pd[oob][i] - floor_d:+5.1f} dB over the direct floor "
              f"-> {excess:+5.1f} dB excess where it would alias ({alias / 1e3:+.0f} kHz)")
        if len(seen) >= 6:
            break
    print(f"worst alias spot: {worst:+.1f} dB excess")
    return 0


if __name__ == "__main__":
    sys.exit(main())
