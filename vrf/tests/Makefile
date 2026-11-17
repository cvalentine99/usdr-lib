# SPDX-License-Identifier: MIT
#
# Builds the xMASS hardware regression tools. See ../docs/hardware-regression.md.
#
#   make                                  # tools in ./out, xsdr-revision linked to ../../build
#   make USDR_BUILD=/path/to/usdr-lib/build

USDR_SRC   ?= ../../src
USDR_BUILD ?= ../../build
OUT        ?= out
CC         ?= cc
CXX        ?= c++
CFLAGS     ?= -O2 -Wall
CXXFLAGS   ?= -O2 -Wall -std=c++11

SOAPY_TOOLS = rxtest rate-sequence whichdev capture

all: $(addprefix $(OUT)/,$(SOAPY_TOOLS) xsdr-revision decimator-response)

$(OUT):
	mkdir -p $@

$(addprefix $(OUT)/,$(SOAPY_TOOLS)): $(OUT)/%: %.c | $(OUT)
	$(CC) $(CFLAGS) -o $@ $< -lSoapySDR -lm

$(OUT)/xsdr-revision: xsdr-revision.c | $(OUT)
	$(CC) $(CFLAGS) -I$(USDR_SRC)/lib/models -I$(USDR_SRC)/lib/port -o $@ $< \
		-L$(USDR_BUILD)/lib -Wl,-rpath,$(abspath $(USDR_BUILD)/lib) -lusdr

$(OUT)/decimator-response: decimator-response.cpp $(USDR_SRC)/soapysdr/usdr_soapy_decim.h | $(OUT)
	$(CXX) $(CXXFLAGS) -I$(USDR_SRC)/soapysdr -o $@ $<

clean:
	rm -rf $(OUT)

.PHONY: all clean
