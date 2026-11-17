// SPDX-License-Identifier: MIT
//
// Reads /dm/revision from each uSDR/xSDR through libusdr and decodes it: the HWID (device id,
// PHY configuration, whether the gateware has the FPGA DDC/DUC) and the gateware build time
// from the FPGA USR_ACCESS register.
//
//   xsdr-revision [connection string ...]     default: bus=pci,device=usdr0 .. usdr3
//
// Connection strings go to libusdr directly, so write them without spaces after commas.

#include <dm_dev.h>
#include <stdint.h>
#include <stdio.h>

static void show(const char *conn)
{
    pdm_dev_t dev = NULL;
    if (usdr_dmd_create_string(conn, &dev) < 0) {
        printf("%-24s open failed\n", conn);
        return;
    }

    uint64_t revision = 0;
    if (usdr_dme_get_uint(dev, "/dm/revision", &revision) != 0) {
        printf("%-24s /dm/revision not available\n", conn);
        usdr_dmd_close(dev);
        return;
    }

    const unsigned hwid = (unsigned)(revision >> 32);
    const unsigned access = (unsigned)revision;
    printf("%-24s HWID %08x devid 0x%02x phycfg 0x%02x DDC/DUC %-3s gateware %04u-%02u-%02u %02u:%02u:%02u\n",
           conn, hwid, (hwid >> 16) & 0xff, hwid & 0xff, (hwid & 0x04) ? "yes" : "no",
           2000 + ((access >> 17) & 0x3f), (access >> 23) & 0x0f, (access >> 27) & 0x1f,
           (access >> 12) & 0x1f, (access >> 6) & 0x3f, access & 0x3f);
    usdr_dmd_close(dev);
}

int main(int argc, char **argv)
{
    if (argc > 1) {
        for (int i = 1; i < argc; i++) {
            show(argv[i]);
        }
        return 0;
    }

    for (int n = 0; n < 4; n++) {
        char conn[64];
        snprintf(conn, sizeof(conn), "bus=pci,device=usdr%d", n);
        show(conn);
    }
    return 0;
}
