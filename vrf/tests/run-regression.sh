#!/usr/bin/env bash
# SPDX-License-Identifier: MIT
#
# Hardware regression for the xMASS. See ../docs/hardware-regression.md.
#
#   vrf/tests/run-regression.sh [usdr-lib build dir]
#
# With a build dir, tests that build's libusdr and SoapySDR plugin without installing them (other
# SoapySDR plugins are hidden for the run). Without one, tests what is installed.
#
# RX only: nothing is transmitted. Close anything that holds the xSDRs (CyberEther, GQRX, ...)
# first. Takes about two minutes.
#
# Environment:
#   XSDR_COUNT    xSDRs expected on the card (default 4)
#   XSDR_DEV      xSDR used for the rate tests (default usdr1)
#   SPECTRUM=1    also compare a host-decimated capture with a direct one (needs a signal at
#                 SPECTRUM_FREQ, default 96.9e6, and numpy for PYTHON, default python3)

set -u

HERE=$(cd "$(dirname "$0")" && pwd)
BUILD=${1:-}
XSDR_COUNT=${XSDR_COUNT:-4}
XSDR_DEV=${XSDR_DEV:-usdr1}
DEV="driver=usdr,bus=pci,device=$XSDR_DEV"
OUT=$HERE/out

if [ -n "$BUILD" ]; then
    BUILD=$(cd "$BUILD" && pwd) || exit 2
    make -s -C "$HERE" USDR_BUILD="$BUILD" || exit 2
    export SOAPY_SDR_ROOT=/nonexistent SOAPY_SDR_PLUGIN_PATH="$BUILD/soapysdr" LD_LIBRARY_PATH="$BUILD/lib"
else
    make -s -C "$HERE" || exit 2
fi
export SOAPY_SDR_LOG_LEVEL=${SOAPY_SDR_LOG_LEVEL:-ERROR}

PASS=0
FAIL=0

report() { # report <PASS|FAIL> <check> <detail>
    printf '%-4s  %-42s %s\n' "$1" "$2" "$3"
    if [ "$1" = PASS ]; then PASS=$((PASS + 1)); else FAIL=$((FAIL + 1)); fi
}

field() { # field <key> <line>
    sed -n "s/.*[[:space:]]$1=\([^[:space:]]*\).*/\1/p" <<< "$2"
}

near() { # near <value> <target>: within 0.5%
    awk -v v="$1" -v t="$2" 'BEGIN { exit !(v > t * 0.995 && v < t * 1.005) }'
}

echo "Testing ${BUILD:-the installed driver}, rate tests on $XSDR_DEV"
echo

# 1. Host decimator response, no hardware
if out=$("$OUT/decimator-response"); then
    report PASS "host decimator response" "$(grep -o 'worst alias [^,]*' <<< "$out" | sort | tail -1)"
else
    report FAIL "host decimator response" "$(tr '\n' ';' <<< "$out")"
fi

# 2. Gateware and HWID of every xSDR, for the record
"$OUT/xsdr-revision" 2>/dev/null | sed 's/^/      /'

# 3. Discovery
found=$(SoapySDRUtil --find="driver=usdr" 2>/dev/null | grep -c 'driver = usdr')
if [ "$found" -eq "$XSDR_COUNT" ]; then
    report PASS "discovery finds $XSDR_COUNT xSDRs" "found $found"
else
    report FAIL "discovery finds $XSDR_COUNT xSDRs" "found $found"
fi

# 4. Each selection opens its own device node
for n in $(seq 0 $((XSDR_COUNT - 1))); do
    line=$("$OUT/whichdev" "driver=usdr, device=usdr$n" 2>/dev/null | grep '^OPENED')
    node=$(field node "$line")
    if [ "$node" = "/dev/usdr$n" ]; then
        report PASS "usdr$n opens /dev/usdr$n" "$node"
    else
        report FAIL "usdr$n opens /dev/usdr$n" "${node:-no output}"
    fi
done

# 5. RX rates, including host decimation below 5 MSps
check_rx() { # check_rx <label> <rate> <format> <channels> <timestamps expected 1|0>
    local line
    line=$("$OUT/rxtest" "$DEV" "$2" 3 "$3" "$4" 2>/dev/null | grep '^RESULT')
    local delivered errors gaps notime
    delivered=$(field delivered "$line")
    errors=$(field errors "$line")
    gaps=$(field gaps "$line")
    notime=$(field notime "$line")
    if [ "$(field status "$line")" = ok ] && near "${delivered:-0}" "$2" && [ "$errors" = 0 ] && [ "$gaps" = 0 ] &&
        { [ "$5" = 0 ] || [ "$notime" = 0 ]; }; then
        report PASS "$1" "$(awk -v d="$delivered" 'BEGIN { printf "%.4f MSps", d / 1e6 }'), MTU $(field mtu "$line")"
    else
        report FAIL "$1" "${line:-no output}"
    fi
}
check_rx "0.1 MSps 1 ch (host decimation)" 100000 CF32 1 1
check_rx "1 MSps 1 ch CS16 (host decimation)" 1000000 CS16 1 1
check_rx "2 MSps 1 ch (CyberEther default)" 2000000 CF32 1 1
check_rx "2 MSps 2 ch (host decimation)" 2000000 CF32 2 1
check_rx "3.84 MSps 1 ch (host decimation)" 3840000 CF32 1 1
check_rx "10 MSps 1 ch (direct)" 10000000 CF32 1 0
check_rx "61.44 MSps 1 ch CS16 (direct)" 61440000 CS16 1 0

# 6. Double pump in and out without reopening (#117)
statuses=$("$OUT/rate-sequence" "$DEV" 10:2 80:2 80:1 10:2 80:1 10:2 2>/dev/null | grep '^STEP' |
    sed -n 's/.*status=\([a-z_]*\).*/\1/p' | tr '\n' ' ')
expected="ok stream_failed ok ok ok ok "
if [ "$statuses" = "$expected" ]; then
    report PASS "double pump in and out (#117)" "10:2 80:2(refused) 80:1 10:2 80:1 10:2"
else
    report FAIL "double pump in and out (#117)" "got: $statuses"
fi

# 7. Optional: host-decimated spectrum against a direct capture
if [ "${SPECTRUM:-0}" = 1 ]; then
    tmp=$(mktemp -d)
    freq=${SPECTRUM_FREQ:-96.9e6}
    "$OUT/capture" "$DEV" 10e6 "$freq" 20000000 "$tmp/direct.cf32" > /dev/null 2>&1
    "$OUT/capture" "$DEV" 1e6 "$freq" 2000000 "$tmp/decim.cf32" > /dev/null 2>&1
    result=$("${PYTHON:-python3}" "$HERE/compare.py" "$tmp/direct.cf32" 10e6 "$tmp/decim.cf32" 1e6 2>&1)
    median=$(sed -n 's/.*median deviation \([0-9.]*\) dB.*/\1/p' <<< "$result")
    worst=$(sed -n 's/.*worst alias spot: \([-+0-9.]*\) dB.*/\1/p' <<< "$result")
    if [ -n "$median" ] && [ -n "$worst" ] && awk -v m="$median" -v w="$worst" 'BEGIN { exit !(m <= 0.5 && w <= 3) }'; then
        report PASS "decimated spectrum matches direct" "median deviation $median dB, worst alias spot $worst dB"
    else
        report FAIL "decimated spectrum matches direct" "$(tr '\n' ';' <<< "$result")"
    fi
    rm -rf "$tmp"
fi

echo
echo "$PASS passed, $FAIL failed"
echo "Manual: open vrf/tests/cyberether/xmass-4x-xsdr.yml in CyberEther and check all four spectra update."
[ "$FAIL" -eq 0 ]
