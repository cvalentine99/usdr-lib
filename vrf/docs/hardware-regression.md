# Hardware regression

Run this on every build before using or shipping it, after rebasing on upstream, and after any hardware or gateware change. It's RX only, so nothing is transmitted, and takes under a minute.

## Run it

1. Close anything that holds the xSDRs (CyberEther, GQRX and so on).
2. Run, from the repository root:

   ```bash
   vrf/tests/run-regression.sh build    # test the build in ./build without installing it
   vrf/tests/run-regression.sh          # or: test the installed driver
   ```

It builds the tools in `vrf/tests/out`, prints PASS or FAIL for each check, and exits non-zero if anything failed.

Settings:

- `XSDR_COUNT`: modules expected (default 4).
- `XSDR_DEV`: the module used for the rate tests (default `usdr1`).
- `SPECTRUM=1`: add the spectrum comparison. That needs `numpy` for `PYTHON` (default `python3`) and real signals around `SPECTRUM_FREQ` (default 96.9 MHz, the FM band at our site).

## Checks and expected results

| Check | Covers | Pass when | Baseline (vrf/main, 2026-11-16) |
|---|---|---|---|
| Host decimator response | The decimation filters (no hardware) | Passband within 0.01 dB, aliases ≤ −90 dB, at factors 2, 8 and 64 | Worst alias −96.4 dB |
| Module revisions | Printed for the record | — | All four: HWID `803001a1`, no DDC/DUC, gateware 2025-09-24 |
| Discovery | SoapySDR finds every module | `XSDR_COUNT` found | 4 |
| `usdrN` opens `/dev/usdrN` | Device selection | Each opens its own node | All four |
| 0.1, 1 (CS16), 2, 2 (2 ch) and 3.84 MSps | Host decimation | Delivered rate within 0.5%, no errors, timestamps continuous and present | All exact |
| 10 and 61.44 MSps (CS16) | Direct rates | Delivered rate within 0.5%, no errors | 10.0002 and 61.4424 MSps |
| Double pump in and out (#117) | Rate changes across 72 MSps | 10:2, 80:2 refused, 80:1, 10:2, 80:1, 10:2 | As expected |
| Spectrum (`SPECTRUM=1`) | Decimated samples match reality | Median passband deviation ≤ 0.5 dB, alias excess ≤ 3 dB | 0.09 dB and +0.0 dB |

The spectrum check compares a 1 MSps capture (decimated by 8) with a 10 MSps direct capture of the same band. Where each strong out-of-band signal would alias, it compares the decimated capture with what the direct capture shows at that same frequency. As a negative control, decimating the direct capture by simply keeping every 10th sample (no filter) gives +27.8 dB, which fails.

## Manual check: CyberEther

Run the four-module flowgraph against the build:

```bash
SOAPY_SDR_ROOT=/nonexistent SOAPY_SDR_PLUGIN_PATH=$PWD/build/soapysdr LD_LIBRARY_PATH=$PWD/build/lib \
    ~/CyberEther/build/cyberether vrf/tests/cyberether/xmass-4x-xsdr.yml
```

It opens all four modules at 2 MSps, 93.3 MHz, with 30 dB manual gain. Expect all four spectra to update, and Throughput to show 16.0 / 16.0 MB/s on each. Buffer Loss can show a little right after the window opens; it should stop growing.

## Not covered

- **TX:** nothing is transmitted.
- **The #117 exception:** the first rate after opening above 72 MSps, with a stream, then a lower rate. This is known to fail; see the [operating notes](xmass-operating-notes.md).
- **100 MSps:** known to fail.

## Tools

All are in `vrf/tests` and are built into `vrf/tests/out` by `make`.

| Tool | Use |
|---|---|
| `rxtest "<args>" <rate> <seconds> [CF32\|CS16] [channels]` | Streams and reports the delivered rate, errors, timestamp gaps and power |
| `rate-sequence "<args>" <MSps>:<ch> ...` | Changes rate and channel count on one open device; 0 channels only sets the rate |
| `whichdev "<filter>"` | Shows which `/dev/usdr*` a SoapySDR selection really opens |
| `xsdr-revision [connection ...]` | HWID and gateware build of each module, through libusdr |
| `capture "<args>" <rate> <freq> <samples> <out.cf32> [gain]` | Saves CF32 samples for `compare.py` |
| `compare.py <direct.cf32> <rate> <decimated.cf32> <rate>` | Compares a decimated capture with a direct one |
| `decimator-response` | Measures the host decimator with test tones |
| `cyberether/xmass-4x-xsdr.yml` | The CyberEther flowgraph above |
