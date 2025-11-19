// Copyright (c) 2023-2024 Wavelet Lab
//
// This work is dual-licensed under MIT and GPL 2.0.
// You can choose between one of them if you use this work.
//
// SPDX-License-Identifier: (GPL-2.0 WITH Linux-syscall-note) OR MIT

#ifndef PCIE_URAM_REGS_H
#define PCIE_URAM_REGS_H

/**
 * @file pcie_uram_regs.h
 * @brief PCIe URAM Register Map Definitions
 *
 * This header defines the hardware register offsets and configuration
 * constants for the PCIe URAM driver. It is shared between the kernel
 * driver and userspace library to eliminate hardcoded addresses.
 */

/* DMA Stream Status Registers */

/**
 * RX DMA status register base offset
 * Used for reading RX DMA diagnostic information during buffer allocation timeouts
 * Register block size: 12 bytes (3x 32-bit registers)
 */
#define PCIE_URAM_RX_DMA_STATUS_BASE    4

/**
 * TX DMA status register base offset
 * Used for reading TX DMA diagnostic information during buffer allocation timeouts
 * Register block size: 16 bytes (4x 32-bit registers)
 */
#define PCIE_URAM_TX_DMA_STATUS_BASE    28

/* Interrupt Bucket Configuration */

/**
 * Interrupt bucket size (number of entries)
 * Each bucket can hold 128 interrupt events for batched processing
 */
#define PCIE_URAM_IRQ_BUCKET_SIZE       128

/**
 * Interrupt bucket max scan size
 * Maximum number of entries to scan in one IRQ invocation (2 banks of 128)
 */
#define PCIE_URAM_IRQ_BUCKET_MAX_SCAN   (2 * PCIE_URAM_IRQ_BUCKET_SIZE)

/**
 * Interrupt bucket entry size (in 32-bit words)
 * Each interrupt event consists of 4x 32-bit words
 */
#define PCIE_URAM_IRQ_BUCKET_ENTRY_WORDS 4

/**
 * Interrupt bucket buffer mask
 * Used for circular buffer indexing: (index * 4) & 0x3ff
 */
#define PCIE_URAM_IRQ_BUCKET_BUFFER_MASK 0x3ff

#endif /* PCIE_URAM_REGS_H */
