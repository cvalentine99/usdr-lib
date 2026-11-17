// SPDX-License-Identifier: MIT
//
// Enumerates with a SoapySDR filter, opens the single match the way applications do (enumerated
// arguments plus the filter), and prints which /dev/usdr* node the process actually opened.
//
//   whichdev "<filter>"
//
// OPENED matches=<n> dev=<dev argument of the match> node=<opened /dev/usdr*>

#include <SoapySDR/Device.h>
#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

int main(int argc, char **argv)
{
    if (argc < 2) {
        fprintf(stderr, "usage: %s \"<filter>\"\n", argv[0]);
        return 2;
    }

    SoapySDRKwargs filter = SoapySDRKwargs_fromString(argv[1]);
    size_t count = 0;
    SoapySDRKwargs *found = SoapySDRDevice_enumerate(&filter, &count);
    if (count != 1) {
        printf("OPENED matches=%zu node=none\n", count);
        return 1;
    }

    const char *dev_arg = "?";
    SoapySDRKwargs args = {0};
    for (size_t k = 0; k < found[0].size; k++) {
        SoapySDRKwargs_set(&args, found[0].keys[k], found[0].vals[k]);
        if (strcmp(found[0].keys[k], "dev") == 0) {
            dev_arg = found[0].vals[k];
        }
    }
    for (size_t k = 0; k < filter.size; k++) {
        SoapySDRKwargs_set(&args, filter.keys[k], filter.vals[k]);
    }

    SoapySDRDevice *dev = SoapySDRDevice_make(&args);
    if (!dev) {
        printf("OPENED matches=1 dev=%s node=make_failed\n", dev_arg);
        return 1;
    }

    char node[256] = "none";
    DIR *dir = opendir("/proc/self/fd");
    struct dirent *entry;
    while (dir && (entry = readdir(dir))) {
        char path[300], target[256];
        snprintf(path, sizeof(path), "/proc/self/fd/%s", entry->d_name);
        const ssize_t len = readlink(path, target, sizeof(target) - 1);
        if (len > 0) {
            target[len] = 0;
            if (strncmp(target, "/dev/usdr", 9) == 0) {
                snprintf(node, sizeof(node), "%s", target);
            }
        }
    }
    if (dir) {
        closedir(dir);
    }

    printf("OPENED matches=1 dev=%s node=%s\n", dev_arg, node);
    SoapySDRDevice_unmake(dev);
    return 0;
}
