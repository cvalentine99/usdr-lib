// SPDX-License-Identifier: MIT
//
// Measures the Soapy plugin's host decimator (src/soapysdr/usdr_soapy_decim.h) with test tones,
// without hardware. Fails if the passband up to 0.4 of the output rate deviates by more than
// 0.01 dB, or if any tone that would alias into that band comes through above -90 dB.

#include "usdr_soapy_decim.h"

#include <algorithm>
#include <cmath>
#include <cstdio>

typedef std::complex<float> cf;

// Output level in dB for a unit complex tone at f_in cycles per input sample
static double gain_db(unsigned factor, double f_in)
{
    UsdrHalfbandDecimator dec(factor);
    const size_t block = 3840, blocks = 120;
    std::vector<cf> in(block), out(block / factor);
    double phase = 0.0, power = 0.0;
    size_t count = 0;
    for (size_t b = 0; b < blocks; b++) {
        for (size_t i = 0; i < block; i++) {
            in[i] = cf(std::cos(phase), std::sin(phase));
            phase = std::fmod(phase + 2 * M_PI * f_in, 2 * M_PI);
        }
        dec.process(in.data(), block, out.data());
        if (b >= blocks / 2) {
            for (const cf &v : out) {
                power += std::norm(v);
                count++;
            }
        }
    }
    return 10 * std::log10(power / count + 1e-30);
}

int main()
{
    bool ok = true;
    for (unsigned factor : {2u, 8u, 64u}) {
        double pass_min = 1e9, pass_max = -1e9, alias_worst = -1e9;
        for (double fo = -0.40; fo <= 0.40001; fo += 0.05) {
            const double g = gain_db(factor, fo / factor);
            pass_min = std::min(pass_min, g);
            pass_max = std::max(pass_max, g);
        }
        for (unsigned k = 1; k < factor; k += (factor > 8 ? 7 : 1)) {
            for (double fo = -0.40; fo <= 0.40001; fo += 0.2) {
                alias_worst = std::max(alias_worst, gain_db(factor, (k + fo) / factor));
            }
        }
        const bool pass = pass_max - pass_min <= 0.01 && alias_worst <= -90.0;
        ok = ok && pass;
        printf("%s factor %-2u passband %+.4f..%+.4f dB, worst alias %.1f dB\n", pass ? "PASS" : "FAIL", factor,
               pass_min, pass_max, alias_worst);
    }
    return ok ? 0 : 1;
}
