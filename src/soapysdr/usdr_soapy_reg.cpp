// Copyright (c) 2023-2024 Wavelet Lab
// SPDX-License-Identifier: MIT

#include "usdr_soapy.h"
#include <SoapySDR/Registry.hpp>
#include <SoapySDR/Logger.hpp>
#include <cstring>

// Helper to check if a device matches the user-provided filter args
static bool matchesFilter(const SoapySDR::Kwargs &devArgs, const SoapySDR::Kwargs &matchArgs)
{
    for (const auto& kv : matchArgs) {
        // Skip type check since we're already in this module
        if (kv.first == "type") continue;

        auto it = devArgs.find(kv.first);
        if (it != devArgs.end()) {
            // If the key exists in device args, values must match
            if (it->second != kv.second) {
                return false;
            }
        }
    }
    return true;
}

static SoapySDR::KwargsList findIConnection(const SoapySDR::Kwargs &matchArgs)
{
    SoapySDR::KwargsList results;

    char buffer[4096];
    int count = usdr_dmd_discovery("", sizeof(buffer), buffer);
    char* dptr = buffer;

    for (int i = 0; i < count; i++) {
        const char* line_start = dptr;
        char* end = strchr(dptr, '\n');
        if (end) {
            *end = 0;
        }

        SoapySDR::Kwargs usdrArgs;
        usdrArgs["type"] = "usdr";
        usdrArgs["module"] = "usdr_soapy";
        usdrArgs["driver"] = "usdr";

        // Parse tab-separated key=value pairs from discovery line
        // Format: "key\tvalue@device_id" or just "bus\tusb@device_id"
        char* param = dptr;
        std::string device_addr;
        while (param && *param) {
            char* tab = strchr(param, '\t');
            if (tab) {
                *tab = 0;
                // param is the key, next segment is value
                const char* key = param;
                param = tab + 1;

                // Find next tab or end
                char* next_tab = strchr(param, '\t');
                const char* value = param;
                if (next_tab) {
                    *next_tab = 0;
                    param = next_tab + 1;
                } else {
                    param = nullptr;
                }

                // Extract device address from value (format: value@address)
                const char* at_sign = strchr(value, '@');
                if (at_sign) {
                    std::string val(value, at_sign - value);
                    device_addr = at_sign + 1;
                    usdrArgs[key] = val;
                    usdrArgs["addr"] = device_addr;
                } else {
                    usdrArgs[key] = value;
                }
            } else {
                // No more tabs, remaining is part of last value
                break;
            }
        }

        // Set standard fields
        if (device_addr.empty()) {
            device_addr = line_start;
        }
        usdrArgs["dev"] = device_addr;
        usdrArgs["media"] = "usdr";
        usdrArgs["name"] = "usdr";
        usdrArgs["serial"] = ""; // Will be filled from device if available
        usdrArgs["label"] = std::string("USDR: ") + device_addr;

        // Filter by matchArgs - only include devices that match user criteria
        if (matchesFilter(usdrArgs, matchArgs)) {
            results.push_back(usdrArgs);
        }

        dptr = end ? end + 1 : nullptr;
        if (!dptr) break;
    }

    return results;
}

static SoapySDR::Device *makeIConnection(const SoapySDR::Kwargs &args)
{
    return new SoapyUSDR(args);
}

static SoapySDR::Registry registerIConnection("usdr", &findIConnection, &makeIConnection, SOAPY_SDR_ABI_VERSION);


