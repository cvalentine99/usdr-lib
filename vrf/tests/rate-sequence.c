// SPDX-License-Identifier: MIT
//
// Changes the RX rate and channel count in sequence on one open device, streaming briefly at each
// step. Covers wavelet-lab/usdr-lib#117: after a double pump rate (> 72 MSps), MIMO and normal
// rates must work again without reopening the device.
//
//   rate-sequence "<device args>" <MSps>:<channels> [<MSps>:<channels> ...]
//
// A channel count of 0 only sets the rate. Each step prints:
// STEP rate=<MSps> ch=<n> status=ok|rate_failed|stream_failed delivered=<samples/s per channel> errors=<n>

#include <SoapySDR/Device.h>
#include <SoapySDR/Formats.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static double now(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec + t.tv_nsec / 1e9;
}

static void step(SoapySDRDevice *dev, double msps, unsigned nch)
{
    if (SoapySDRDevice_setSampleRate(dev, SOAPY_SDR_RX, 0, msps * 1e6) != 0) {
        printf("STEP rate=%g ch=%u status=rate_failed\n", msps, nch);
        return;
    }
    if (nch == 0) {
        printf("STEP rate=%g ch=0 status=ok\n", msps);
        return;
    }

    const size_t channels[] = {0, 1};
    SoapySDRKwargs none = {0};
    SoapySDRStream *stream = SoapySDRDevice_setupStream(dev, SOAPY_SDR_RX, SOAPY_SDR_CS16, channels, nch, &none);
    if (!stream) {
        printf("STEP rate=%g ch=%u status=stream_failed\n", msps, nch);
        return;
    }

    SoapySDRDevice_activateStream(dev, stream, 0, 0, 0);
    const size_t mtu = SoapySDRDevice_getStreamMTU(dev, stream);
    void *bufs[2] = {malloc(mtu * 4), malloc(mtu * 4)};
    long long total = 0;
    int errors = 0;
    double start = 0.0;
    const double t0 = now();
    while (now() - t0 < 1.0) {
        int flags = 0;
        long long time_ns = 0;
        const int n = SoapySDRDevice_readStream(dev, stream, bufs, mtu, &flags, &time_ns, 100000);
        if (n > 0) {
            if (start == 0.0) {
                start = now();
            } else {
                total += n;
            }
        } else if (n != SOAPY_SDR_TIMEOUT) {
            errors++;
        }
    }
    printf("STEP rate=%g ch=%u status=ok delivered=%.0f errors=%d\n", msps, nch,
           start > 0.0 ? total / (now() - start) : 0.0, errors);

    SoapySDRDevice_deactivateStream(dev, stream, 0, 0);
    SoapySDRDevice_closeStream(dev, stream);
    free(bufs[0]);
    free(bufs[1]);
}

int main(int argc, char **argv)
{
    if (argc < 3) {
        fprintf(stderr, "usage: %s \"<device args>\" <MSps>:<channels> [...]\n", argv[0]);
        return 2;
    }

    SoapySDRKwargs args = SoapySDRKwargs_fromString(argv[1]);
    SoapySDRDevice *dev = SoapySDRDevice_make(&args);
    if (!dev) {
        printf("STEP status=make_failed error=\"%s\"\n", SoapySDRDevice_lastError());
        return 1;
    }

    for (int i = 2; i < argc; i++) {
        double msps;
        unsigned nch;
        if (sscanf(argv[i], "%lf:%u", &msps, &nch) == 2) {
            step(dev, msps, nch);
        }
    }

    SoapySDRDevice_unmake(dev);
    return 0;
}
