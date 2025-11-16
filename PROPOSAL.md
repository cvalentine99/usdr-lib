# Proposed Improvements for `usdr-lib`

This document captures actionable changes that would improve maintainability, driver coverage, and contributor experience. Each section maps to code that already exists in the repository so work can start immediately.

## 1. Stabilize and Document the PCIe URAM Path

* **Rationale.** The `pcie_uram` stack under `src/lib/lowlevel/pcie_uram/` contains multiple hard-coded addresses, TODO markers about cache coherency, and missing resource clean-up in the kernel driver (`driver/usdr_pcie_uram.c`).
* **Proposed changes.**
  1. Introduce a single configuration structure that encapsulates BAR offsets and buffer addresses so the driver and user-space library stop duplicating constants.
  2. Add cache-coherency helpers (flush/invalidate wrappers) and make them no-ops on coherent platforms.
  3. Extend the kernel driver to cleanly unchain transfer descriptors before module unload, reducing the risk of leaks when the hardware is hot-plugged.
  4. Document the complete bring-up flow (`insmod`, DMA registration, IRQ routing) in `README.md` so integrators do not have to reverse-engineer the required order of operations.
* **Benefits.** Makes PCIe deployments reproducible and simplifies debugging of DMA stalls.

## 2. Close the Feature Gap in the SoapySDR Plugin

* **Rationale.** `src/soapysdr/usdr_soapy.cpp` still carries TODOs for autodetecting reference clocks, reporting hardware time support, and providing register readback. Without these features the module lags behind other Soapy drivers.
* **Proposed changes.**
  1. Implement `getReferenceClockRate()` using the LMS/LMK device helpers already available under `src/lib/hw/` so auto-detected clocks propagate to Soapy clients.
  2. Wire the existing register access helpers into the Soapy logging interface to support `--dump-regs` style debugging.
  3. Provide a capability flag that explicitly reports whether hardware time is supported; default to `false` on boards that cannot guarantee synchronization.
  4. Cover the new behavior with unit tests under `src/tests/` and include a cookbook example in `README.md` that shows how GNU Radio detects the driver.
* **Benefits.** Users can rely on the Soapy layer for timing-sensitive applications and receive actionable diagnostics.

## 3. Add CI Guardrails and Test Targets

* **Rationale.** The repository ships multiple kernel modules, user-space libraries, and tools but has no automated verification described in `README.md`. Failures (for example, the unfinished asynchronous USB APIs) go unnoticed until manual testing.
* **Proposed changes.**
  1. Define a containerized build in `docker/` that installs the documented dependencies and runs `cmake .. && make` for the full tree.
  2. Add a `ctest` target that executes `src/tests` and `src/utests` binaries, even if some tests are temporarily marked `EXPECT_SKIP`.
  3. Integrate the build/test workflow into GitHub Actions so every push validates that Soapy, USB, and PCIe components compile simultaneously.
  4. Publish the workflow status badge near the top of `README.md` to advertise the CI contract to downstream packagers.
* **Benefits.** Prevents regressions, lowers review burden, and gives contributors immediate feedback about toolchain compatibility.

## 4. Expand Contributor-Facing Documentation

* **Rationale.** New contributors currently have to read scattered source files to understand board support (`src/lib/device/*`), calibration utilities, and streaming backends.
* **Proposed changes.**
  1. Add a `docs/` tree with short architecture notes for each major subsystem (devices, low-level buses, Soapy plugin).
  2. Move the existing TODO inventory (`TODO_REPORT.md`) into that folder and cross-link it from the README.
  3. Provide templates for adding new boards, covering required hooks such as `*_ctrl.c` implementations and LMK/AFE initialization sequences.
* **Benefits.** Speeds up onboarding and codifies conventions that currently live only in tribal knowledge.

---

These proposals deliberately focus on work that is already hinted at by TODO markers or missing automation. Prioritizing them would make the original repository easier to build, extend, and maintain.
