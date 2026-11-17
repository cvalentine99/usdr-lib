# Valentine RF usdr-lib

This fork of [wavelet-lab/usdr-lib](https://github.com/wavelet-lab/usdr-lib) carries the fixes Valentine RF needs for the xMASS card (four xSDR modules on one PCIe carrier). We build and ship from it ourselves rather than waiting on upstream releases.

## Branches

| Branch | Contents |
|---|---|
| `vrf/main` | What we build and ship: upstream `main`, the patches below, and this `vrf/` folder. |
| `fix/*` | One branch per fix, based on upstream `main`. These are what we offer upstream. |
| `main` | Mirrors upstream `main`. Never commit to it. |

## Patches on top of upstream

| Patch | Upstream |
|---|---|
| fix(xsdr): select MMCM VCO limits by FPGA family | [PR #138](https://github.com/wavelet-lab/usdr-lib/pull/138) |
| fix(xsdr): explain an out-of-spec MMCM VCO at low sample rates | PR #138 |
| fix(soapysdr): open the selected device | PR #138 |
| fix(soapysdr): advertise the documented xSDR ranges | PR #138 |
| feat(soapysdr): decimate RX on the host below 5 MSps without FPGA DDC | PR #138 |
| fix(xsdr): leave double pump mode and restore rails after high rates | Fixes issue #117. Not offered upstream yet (branch `fix/xsdr-dpump-117`). |
| build: set an install RPATH outside system library directories | Fixes issue #39. Not offered upstream yet (branch `fix/install-rpath-39`). |

Each commit message explains its change and how it was tested.

## Documents

- [xMASS operating notes](docs/xmass-operating-notes.md): the hardware, the sample rates that work, known issues, and diagnostics.
- [Build and release](docs/build-and-release.md): building, testing a build without installing it, and updating from upstream.
- [Hardware regression](docs/hardware-regression.md): the checks to run before shipping a build, and their expected results.

The test programs are in [`tests/`](tests). `tests/run-regression.sh` runs the scripted checks.
