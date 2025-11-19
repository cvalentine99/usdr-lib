# Makefile for USDR library build and testing
# This Makefile provides convenience targets for building userspace and kernel components

.PHONY: all userspace driver clean help test update-todos

# Default target
all: userspace

help:
	@echo "USDR Library Build Targets:"
	@echo "  make userspace    - Build userspace libraries and tools"
	@echo "  make driver       - Build PCIe kernel module"
	@echo "  make all          - Build userspace only (default)"
	@echo "  make clean        - Clean build artifacts"
	@echo "  make test         - Run basic syntax checks"
	@echo "  make update-todos - Update TODO_REPORT.md with current TODO items"
	@echo ""
	@echo "Note: Driver build requires kernel headers:"
	@echo "  sudo apt install linux-headers-\$$(uname -r)"

# Build userspace libraries and tools
userspace:
	@echo "==> Configuring userspace build..."
	@mkdir -p build
	cd build && cmake ../src
	@echo "==> Building userspace..."
	cd build && $(MAKE) -j4
	@echo "==> Userspace build complete!"

# Build kernel driver
driver:
	@echo "==> Building PCIe kernel driver..."
	cd src/lib/lowlevel/pcie_uram/driver && $(MAKE)
	@echo "==> Driver build complete!"
	@echo ""
	@echo "To load the driver:"
	@echo "  sudo insmod src/lib/lowlevel/pcie_uram/driver/usdr_pcie_uram.ko"

# Clean build artifacts
clean:
	@echo "==> Cleaning userspace build..."
	rm -rf build
	@echo "==> Cleaning driver build..."
	cd src/lib/lowlevel/pcie_uram/driver && $(MAKE) clean || true
	@echo "==> Clean complete!"

# Basic syntax/header checks
test:
	@echo "==> Checking pcie_uram_regs.h..."
	@if [ -f src/lib/lowlevel/pcie_uram/pcie_uram_regs.h ]; then \
		echo "  ✓ pcie_uram_regs.h exists"; \
		grep -q "PCIE_URAM_RX_DMA_STATUS_BASE" src/lib/lowlevel/pcie_uram/pcie_uram_regs.h && \
		echo "  ✓ PCIE_URAM_RX_DMA_STATUS_BASE defined"; \
		grep -q "PCIE_URAM_TX_DMA_STATUS_BASE" src/lib/lowlevel/pcie_uram/pcie_uram_regs.h && \
		echo "  ✓ PCIE_URAM_TX_DMA_STATUS_BASE defined"; \
		grep -q "PCIE_URAM_IRQ_BUCKET_SIZE" src/lib/lowlevel/pcie_uram/pcie_uram_regs.h && \
		echo "  ✓ PCIE_URAM_IRQ_BUCKET_SIZE defined"; \
	else \
		echo "  ✗ pcie_uram_regs.h not found!"; \
		exit 1; \
	fi
	@echo "==> Checking that hardcoded addresses were removed..."
	@if grep -n "pcie_reg_op_iommap(d, 4," src/lib/lowlevel/pcie_uram/pcie_uram_main.c; then \
		echo "  ✗ Hardcoded address 4 still present!"; \
		exit 1; \
	else \
		echo "  ✓ Hardcoded address 4 removed"; \
	fi
	@if grep -n "pcie_reg_op_iommap(d, 28," src/lib/lowlevel/pcie_uram/pcie_uram_main.c; then \
		echo "  ✗ Hardcoded address 28 still present!"; \
		exit 1; \
	else \
		echo "  ✓ Hardcoded address 28 removed"; \
	fi
	@if grep -n "& 0x3ff" src/lib/lowlevel/pcie_uram/driver/usdr_pcie_uram.c | grep -v "PCIE_URAM_IRQ_BUCKET_BUFFER_MASK"; then \
		echo "  ✗ Hardcoded 0x3ff still present!"; \
		exit 1; \
	else \
		echo "  ✓ Hardcoded 0x3ff replaced"; \
	fi
	@echo "==> All checks passed!"

# Update TODO report
update-todos:
	@echo "==> Updating TODO report..."
	@./scripts/generate_todo_report.sh
	@echo "==> TODO report updated!"
