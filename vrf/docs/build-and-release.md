# Build and release

## Remotes

| Remote | URL | Use |
|---|---|---|
| `origin` | `https://github.com/wavelet-lab/usdr-lib.git` | Upstream. Fetch only. |
| `fork` | `https://github.com/cvalentine99/usdr-lib.git` | Ours. `vrf/main` and the `fix/*` branches live here. |

Pushing needs a GitHub login on the machine. `gh auth login` followed by `gh auth setup-git` is the simplest way to get one.

## Build

Dependencies on Ubuntu 26.04 (other recent Ubuntu and Debian releases are similar):

```bash
sudo apt install build-essential cmake python3-yaml dwarves libusb-1.0-0-dev check libsoapysdr-dev
```

Build `vrf/main` (GUI and debug tools off, since we don't use them):

```bash
git switch vrf/main
cmake -S src -B build -DCMAKE_BUILD_TYPE=Release -DENABLE_GUI=OFF -DENABLE_DMONITOR=OFF
cmake --build build -j
```

The libraries end up in `build/lib`, the SoapySDR plugin in `build/soapysdr`, and the tools in `build/tools`.

## Run a build without installing it

These variables make SoapySDR applications use the build instead of the installed packages:

```bash
export SOAPY_SDR_ROOT=/nonexistent SOAPY_SDR_PLUGIN_PATH=$PWD/build/soapysdr LD_LIBRARY_PATH=$PWD/build/lib
```

`SOAPY_SDR_ROOT=/nonexistent` stops SoapySDR loading the installed plugins, so other radios (PlutoSDR and so on) are hidden while it's set. For example, to run CyberEther against the build:

```bash
SOAPY_SDR_ROOT=/nonexistent SOAPY_SDR_PLUGIN_PATH=$HOME/usdr-lib/build/soapysdr LD_LIBRARY_PATH=$HOME/usdr-lib/build/lib ~/CyberEther/build/cyberether
```

## Test

Run the [hardware regression](hardware-regression.md) on every build you intend to use:

```bash
vrf/tests/run-regression.sh build
```

## Install

Packaging from this fork isn't set up yet. That's the next step.

Until it is, **don't `cmake --install` on a machine that has Wavelet Lab's packages installed**. You'd end up with two SoapySDR plugins registering the same `usdr` driver. With the RPATH fix, an installed build at least loads its own `libusdr`, but the duplicate plugin is still a problem. Use the environment variables above instead.

The kernel driver comes from Wavelet Lab's `usdr-dkms` package. This fork doesn't change it.

## Update from upstream

```bash
git fetch origin
git switch vrf/main
git rebase origin/main
cmake --build build -j
vrf/tests/run-regression.sh build
git push --force-with-lease fork vrf/main
git push fork origin/main:main
```

If a patch conflicts, check whether upstream fixed the same thing first. If they did, drop our patch rather than merging the two, and update the patch table in [`../README.md`](../README.md).

## Add a fix

1. Branch from upstream: `git switch -c fix/<topic> origin/main`.
2. Commit the fix. Explain the problem, the cause, and how it was tested.
3. Cherry-pick it onto `vrf/main`, rebuild, and run the regression.
4. Push both branches to `fork`, and add a row to the patch table in [`../README.md`](../README.md).
5. Optionally, open a PR to wavelet-lab/usdr-lib from the `fix/<topic>` branch.

Commits in this checkout use the repository's own git identity (`git config user.name` / `user.email`).
