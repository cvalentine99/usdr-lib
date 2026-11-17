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

Install this fork as Debian packages that replace Wavelet Lab's PPA packages of the same names. Every SoapySDR application then gets the fixes, CyberEther included, with no environment variables.

[`../packaging/build-debs.sh`](../packaging/build-debs.sh) builds them on the machine you run it on with upstream's `packaging/<distro>` files, the same steps upstream's Docker builder takes. It packages a committed revision through `git archive`, so uncommitted changes never end up in a package. Once, install the packaging tools on top of the build dependencies above:

```bash
sudo apt install debhelper dh-dkms dwarves
```

Then build and install:

```bash
vrf/packaging/build-debs.sh            # packages vrf/main; pass another revision to package that
V=<version printed by the script>
sudo apt install --allow-change-held-packages \
    ./output/vrf-resolute-amd64/{libusdr,libusdr-dev,soapysdr-module-usdr,usdr-tools}_${V}_amd64.deb
sudo apt-mark hold libusdr libusdr-dev soapysdr-module-usdr usdr-tools
vrf/tests/run-regression.sh            # no argument: tests what is installed
```

- **Version:** `<upstream>+vrf<commit date>.<time>~<codename>1`, for example `1.0.1+vrf20261116.1948~resolute1`. It sorts above the PPA's build of the same release (`1.0.1~resolute0`), so apt treats ours as the upgrade. The maintainer is this checkout's git identity.
- **Why hold:**
  - Without the hold, a newer PPA release would replace these packages and bring back the bugs this fork fixes.
  - The hold also blocks deliberate installs, which is why the install line passes `--allow-change-held-packages`. The same steps install a newer build of ours over an older one.
  - Release the hold when you've rebased onto that release and built new packages, or to go back to Wavelet Lab's packages: `sudo apt-mark unhold libusdr libusdr-dev soapysdr-module-usdr usdr-tools`, then `sudo apt install --allow-downgrades libusdr=<ppa version> libusdr-dev=<ppa version> soapysdr-module-usdr=<ppa version> usdr-tools=<ppa version>`.
- **Why these four:** `libusdr-dev`, `soapysdr-module-usdr` and `usdr-tools` each require the exact same `libusdr` version, so the four are installed together.
- **What's left alone:**
  - The kernel driver stays on Wavelet Lab's `usdr-dkms`. This fork doesn't change it, and reinstalling it would rebuild the module for no gain.
  - `usdr-dmonitor` is built but not needed.

**Don't `cmake --install` into `/usr/local` on a machine with these packages installed.** You'd end up with two SoapySDR plugins registering the same `usdr` driver. They share the `libusdr.so.0` soname, so one can run the other's library. To try a build, use the environment variables above.

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

Then build and install new packages as described under [Install](#install).

If a patch conflicts, check whether upstream fixed the same thing first. If they did, drop our patch rather than merging the two, and update the patch table in [`../README.md`](../README.md).

## Add a fix

1. Branch from upstream: `git switch -c fix/<topic> origin/main`.
2. Commit the fix. Explain the problem, the cause, and how it was tested.
3. Cherry-pick it onto `vrf/main`, rebuild, and run the regression.
4. Push both branches to `fork`, and add a row to the patch table in [`../README.md`](../README.md).
5. Optionally, open a PR to wavelet-lab/usdr-lib from the `fix/<topic>` branch.

Commits in this checkout use the repository's own git identity (`git config user.name` / `user.email`).
