# xMASS operating notes

This describes how the xMASS behaves with this fork's `vrf/main`, as measured on our card on 2026-11-16, and where that differs from the stock 1.0.1 packages.

## Hardware

- **xMASS:** a PCIe card (x4 slot, 2 lanes used) carrying four xSDR M.2 modules, with synchronized clocking. It has 8 RX and 8 TX channels in total. Slot A is the master. ([Wavelet Lab docs](https://docs.wsdr.io/hardware/xmass.html))
- **xSDR:** an LMS7002M RF chip and an AMD Artix-7 FPGA, with 2 RX and 2 TX channels. Documented: 30 MHz to 3.8 GHz, 0.1 to 100 MSps. ([docs](https://docs.wsdr.io/hardware/xsdr.html))
- **On Linux:** the `usdr_pcie_uram` kernel module (package `usdr-dkms`) creates one node per xSDR, `/dev/usdr0` to `/dev/usdr3`.
- **Which xSDR controls the carrier:** on our card, opening `usdr0` initializes the carrier's LMK05318 clock chip. Opening `usdr1`–`usdr3` logs `[XMSS] GPIO expander initialization failed!` at INFO level, presumably because only slot A reaches the carrier's controls. All four open and stream normally despite that message.
- **Opening order:** CyberEther with all four xSDRs open at once, `usdr0` first, streams on all four. We haven't tested opening `usdr0` while the others are already streaming.

## Identifying the gateware

Run `vrf/tests/out/xsdr-revision` (see [hardware regression](hardware-regression.md)). Our card reports the same thing for all four modules:

| Field | Value | Meaning |
|---|---|---|
| HWID | `0x803001a1` | |
| Device id (HWID bits 23:16) | `0x30` | xSDR (`0x2e` would be XTRX, `0x31` SSDR, `0x33` SSDR Pro) |
| PHY config (HWID bits 7:0) | `0xa1` | `0x80` separate clock divider, `0x20` TX MMCM, `0x01` single MMCM |
| FPGA DDC/DUC (PHY bit `0x04`) | absent | Low rates can't be decimated in the FPGA |
| Gateware build (`USR_ACCESS`) | 2025-09-24 14:24:18 | Newer than the 2024-08-09 images in wavelet-lab/firmwares |

## Sample rates

Without the FPGA DDC, rates below about 4.76 MSps can only be reached by slowing the link clock between the LMS7002M and the FPGA, which takes the FPGA's MMCM VCO below its 600 MHz minimum. With the stock 1.0.1 driver, where that fails varies by module: `usdr0` fails at 2.1 MSps and below, while `usdr1` and `usdr3` still lock at 2.1 MSps.

What `vrf/main` does:

| Rate | Behaviour |
|---|---|
| RX below 5 MSps, down to 0.1 MSps | **Host decimation.** The link runs at rate × 2^k (at least 5 MSps) and the SoapySDR plugin decimates with half-band filters. The passband is flat within 0.001 dB up to 0.4 × rate, and aliases are at least 90 dB down. Reads come in decimated packets, with hardware timestamps. |
| 5 to 72 MSps | Direct. Two channels (MIMO) work. |
| Above 72 MSps | Double pump: one channel only. The I/O and LMS 1.25 V rails are boosted. Tested at 80 MSps. |
| 100 MSps | Fails: `CGEN: VCO=1600000000 is out of range ... can't tune VCO for data clock`. Not fixed. |
| TX below about 4.76 MSps | Still runs the MMCM out of spec (there is no host interpolation). It may or may not lock, depending on the module. |

Host decimation turns off when TX is used, because TX and RX share one hardware rate. This happens when an application sets a TX rate or opens a TX stream; RX then falls back to the direct rate.

## Known issues

| Issue | Status in `vrf/main` |
|---|---|
| SoapySDR opened `usdr0` whichever xSDR was selected | Fixed |
| Low RX rates fail or run out of spec | Fixed by host decimation. TX is still open. |
| After a rate above 72 MSps, rate changes fail until the device is reopened (#117) | Fixed, with one exception: if the **first** rate after opening is above 72 MSps and a stream runs at it, later lower rates fail with `LML Calibration failed: RX_BADNESS=...`. Reopen the device to recover. |
| 100 MSps fails | Open |
| Discovery reports serial `012345678` for every module | Open (hard-coded in `usdr_soapy_reg.cpp`) |
| No automatic gain control | The driver doesn't offer it. Use manual gain. |
| On the direct path, apps reading 8192 samples per call get a "jitter buffer" warning | Open. Packets are 3840 or 7680 samples. Harmless at the rates we tested. |
| `[XMSS] GPIO expander initialization failed!` on `usdr1`–`usdr3` | Cosmetic as far as we've seen |

## Using it

- **SoapySDR device arguments:** `driver=usdr,bus=pci,device=usdr1`. Extra options:
  - `host_decim=0` turns host decimation off.
  - `loglevel=6` shows detailed libusdr logs.
- **Probe a module:**

  ```bash
  SoapySDRUtil --probe="driver=usdr,bus=pci,device=usdr1"
  ```

- **Gain:** manual only. Stages are LNA 0–30 dB, TIA 0–12 dB, PGA −12 to 19 dB; −12 to 61 dB in total.
- **Antennas:** AUTO, LNAH, LNAL, LNAW.
- **CyberEther:** use the SoapySDR block, pick the module in Device, and turn Automatic Gain off. With `vrf/main` the 2 MSps default works. With the stock driver, use 5 MSps or more.

## Diagnostics

| Log line | Meaning |
|---|---|
| `SoapyUSDR::setSampleRate(...) running the link at X MSps and decimating RX by D on the host` | Host decimation is active |
| `MMCM VCO ... is below the 600 MHz minimum; the LML clock lock is not guaranteed` | Direct path below spec. It locked, but may not on another module. |
| `MMCM Ready flag timed out: VCO ... below the 600 MHz minimum ... Use a sample rate of at least ...` | Direct path below spec, and it failed |
| `High samplerate set, activating double pump mode` / `leaving double pump mode` | Crossing 72 MSps |
| `In double pump mode only SISO mode is allowed` | Two channels requested above 72 MSps |
| `can't tune VCO for data clock` | The LMS7002M clock generator failed to tune (100 MSps, or #117 before the fix) |
| `LML Calibration failed: RX_BADNESS=...` | The FPGA↔LMS7002M link didn't calibrate. See the #117 exception above. |

Useful switches:

- `SOAPY_SDR_LOG_LEVEL=INFO` (or `DEBUG`) shows the plugin's messages.
- The `loglevel=6` device argument shows libusdr's detail: clock generator tuning, MMCM settings and calibration.
- To run a build without installing it, see [build and release](build-and-release.md).
