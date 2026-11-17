// SPDX-License-Identifier: MIT
//
// Captures CF32 samples from channel 0 to a file, for compare.py.
//
//   capture "<device args>" <rate> <frequency> <samples> <out.cf32> [gain dB]
//
// The first half second is dropped so startup transients don't land in the file.

#include <SoapySDR/Device.h>
#include <SoapySDR/Formats.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    if (argc < 6) {
        fprintf(stderr, "usage: %s \"<device args>\" <rate> <frequency> <samples> <out.cf32> [gain dB]\n", argv[0]);
        return 2;
    }

    const double rate = atof(argv[2]);
    const long want = atol(argv[4]);
    SoapySDRKwargs args = SoapySDRKwargs_fromString(argv[1]);
    SoapySDRKwargs none = {0};
    SoapySDRDevice *dev = SoapySDRDevice_make(&args);
    if (!dev) {
        fprintf(stderr, "make failed: %s\n", SoapySDRDevice_lastError());
        return 1;
    }

    if (SoapySDRDevice_setSampleRate(dev, SOAPY_SDR_RX, 0, rate) != 0) {
        fprintf(stderr, "setSampleRate failed: %s\n", SoapySDRDevice_lastError());
        return 1;
    }
    SoapySDRDevice_setFrequency(dev, SOAPY_SDR_RX, 0, atof(argv[3]), &none);
    SoapySDRDevice_setGain(dev, SOAPY_SDR_RX, 0, argc > 6 ? atof(argv[6]) : 30.0);

    const size_t channel = 0;
    SoapySDRStream *stream = SoapySDRDevice_setupStream(dev, SOAPY_SDR_RX, SOAPY_SDR_CF32, &channel, 1, &none);
    if (!stream) {
        fprintf(stderr, "setupStream failed: %s\n", SoapySDRDevice_lastError());
        return 1;
    }
    SoapySDRDevice_activateStream(dev, stream, 0, 0, 0);

    FILE *out = fopen(argv[5], "wb");
    if (!out) {
        perror(argv[5]);
        return 1;
    }
    float *buf = malloc(8192 * 2 * sizeof(float));
    void *bufs[] = {buf};
    long got = 0, skip = (long)(rate * 0.5);
    while (got < want) {
        int flags = 0;
        long long time_ns = 0;
        const int n = SoapySDRDevice_readStream(dev, stream, bufs, 8192, &flags, &time_ns, 200000);
        if (n <= 0) {
            continue;
        }
        if (skip > 0) {
            skip -= n;
            continue;
        }
        fwrite(buf, 2 * sizeof(float), n, out);
        got += n;
    }
    fclose(out);
    printf("captured %ld samples at %.3f MSps\n", got, SoapySDRDevice_getSampleRate(dev, SOAPY_SDR_RX, 0) / 1e6);

    SoapySDRDevice_deactivateStream(dev, stream, 0, 0);
    SoapySDRDevice_closeStream(dev, stream);
    SoapySDRDevice_unmake(dev);
    free(buf);
    return 0;
}
