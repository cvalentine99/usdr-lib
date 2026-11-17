// SPDX-License-Identifier: MIT
//
// Streams RX from one device the way an application such as CyberEther does and reports how it
// went on a single parseable line.
//
//   rxtest "<device args>" <rate> <seconds> [CF32|CS16] [channels]
//
// RESULT rate=<requested> applied=<getSampleRate> mtu=<getStreamMTU> delivered=<samples/s per
// channel, after the first read> timeouts=<n> errors=<n> gaps=<timestamp jumps> notime=<reads
// without SOAPY_SDR_HAS_TIME> power=<mean |x|^2 of channel 0>

#include <SoapySDR/Device.h>
#include <SoapySDR/Formats.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>

static double now(void)
{
    struct timespec t;
    clock_gettime(CLOCK_MONOTONIC, &t);
    return t.tv_sec + t.tv_nsec / 1e9;
}

int main(int argc, char **argv)
{
    if (argc < 4) {
        fprintf(stderr, "usage: %s \"<device args>\" <rate> <seconds> [CF32|CS16] [channels]\n", argv[0]);
        return 2;
    }

    const double rate = atof(argv[2]);
    const double seconds = atof(argv[3]);
    const char *fmt = argc > 4 ? argv[4] : SOAPY_SDR_CF32;
    const size_t nch = argc > 5 ? (size_t)atoi(argv[5]) : 1;
    const int cs16 = strcmp(fmt, SOAPY_SDR_CS16) == 0;
    const size_t bytes = cs16 ? 4 : 8;
    const size_t chunk = 8192;   // what CyberEther reads per call

    SoapySDRKwargs args = SoapySDRKwargs_fromString(argv[1]);
    SoapySDRKwargs none = {0};
    SoapySDRDevice *dev = SoapySDRDevice_make(&args);
    if (!dev) {
        printf("RESULT rate=%.0f status=make_failed error=\"%s\"\n", rate, SoapySDRDevice_lastError());
        return 1;
    }

    if (SoapySDRDevice_setSampleRate(dev, SOAPY_SDR_RX, 0, rate) != 0) {
        printf("RESULT rate=%.0f status=rate_failed error=\"%s\"\n", rate, SoapySDRDevice_lastError());
        SoapySDRDevice_unmake(dev);
        return 1;
    }
    SoapySDRDevice_setFrequency(dev, SOAPY_SDR_RX, 0, 96.9e6, &none);
    const double applied = SoapySDRDevice_getSampleRate(dev, SOAPY_SDR_RX, 0);

    const size_t channels[] = {0, 1};
    SoapySDRStream *stream = SoapySDRDevice_setupStream(dev, SOAPY_SDR_RX, fmt, channels, nch, &none);
    if (!stream) {
        printf("RESULT rate=%.0f status=stream_failed error=\"%s\"\n", rate, SoapySDRDevice_lastError());
        SoapySDRDevice_unmake(dev);
        return 1;
    }
    const size_t mtu = SoapySDRDevice_getStreamMTU(dev, stream);
    SoapySDRDevice_activateStream(dev, stream, 0, 0, 0);

    void *bufs[2] = {malloc(chunk * bytes), malloc(chunk * bytes)};
    long long total = 0, prev_time = -1, prev_count = 0;
    int timeouts = 0, errors = 0, gaps = 0, notime = 0;
    double power = 0.0, start = 0.0;
    const double t0 = now();

    while (now() - t0 < seconds) {
        int flags = 0;
        long long time_ns = 0;
        const int n = SoapySDRDevice_readStream(dev, stream, bufs, chunk, &flags, &time_ns, 100000);
        if (n == SOAPY_SDR_TIMEOUT) {
            timeouts++;
            continue;
        }
        if (n <= 0) {
            errors++;
            continue;
        }

        // The first read only marks the start, so startup latency doesn't skew the rate
        if (start == 0.0) {
            start = now();
        } else {
            total += n;
        }

        if (!(flags & SOAPY_SDR_HAS_TIME)) {
            notime++;
        } else {
            if (prev_time >= 0) {
                const double expected = prev_time + prev_count * 1e9 / applied;
                if (fabs(time_ns - expected) > 2e9 / applied) {
                    gaps++;
                }
            }
            prev_time = time_ns;
            prev_count = n;
        }

        for (int i = 0; i < n; i++) {
            double re, im;
            if (cs16) {
                re = ((short *)bufs[0])[2 * i] / 32768.0;
                im = ((short *)bufs[0])[2 * i + 1] / 32768.0;
            } else {
                re = ((float *)bufs[0])[2 * i];
                im = ((float *)bufs[0])[2 * i + 1];
            }
            power += re * re + im * im;
        }
    }

    const double elapsed = now() - start;
    printf("RESULT rate=%.0f status=ok fmt=%s ch=%zu applied=%.0f mtu=%zu delivered=%.0f timeouts=%d errors=%d "
           "gaps=%d notime=%d power=%.3g\n",
           rate, fmt, nch, applied, mtu, start > 0.0 && elapsed > 0.0 ? total / elapsed : 0.0, timeouts, errors,
           gaps, notime, total ? power / total : 0.0);

    SoapySDRDevice_deactivateStream(dev, stream, 0, 0);
    SoapySDRDevice_closeStream(dev, stream);
    SoapySDRDevice_unmake(dev);
    free(bufs[0]);
    free(bufs[1]);
    return 0;
}
