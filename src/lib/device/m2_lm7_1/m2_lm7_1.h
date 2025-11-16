// Copyright (c) 2023-2024 Wavelet Lab
// SPDX-License-Identifier: MIT

#ifndef _M2_LM7_1_H
#define _M2_LM7_1_H

#include "../device.h"
#include "xsdr_ctrl.h"

/**
 * Get the xsdr_dev_t structure from a device handle
 * @param udev Device handle
 * @return Pointer to xsdr_dev_t structure
 */
xsdr_dev_t* m2_lm7_1_get_xsdr_dev(pdevice_t udev);

#endif
