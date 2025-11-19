# TODO Inventory

This file records current TODO markers across the repository.
Update by running `make update-todos` from the repo root.

src/hwparser/gen_h.py:41:                # TODO: parse ucnt
src/lib/cal/cal_lo_iqimb.h:87:// TODO
src/lib/common/clock_gen.c:145:            // TODO: solution scoring
src/lib/device/device.c:128:// TODO: Move away
src/lib/device/device.c:245:        // TODO: Type checking! but assume with page is non-valid pointer, so backing up to link
src/lib/device/device_fe.c:149:    // TODO obtain cores base address
src/lib/device/device_fe.c:274:    //TODO deinit
src/lib/device/device_vfs.c:238:    no->ops.sstr = NULL;  // TODO
src/lib/device/device_vfs.c:239:    no->ops.sai64 = NULL; // TODO
src/lib/device/ext_fe_100_5000/ext_fe_100_5000.c:222:    // TODO estimate inacuracy to compensate in NCO later!!!
src/lib/device/m2_dsdr/dsdr_hiper.c:767:    // TODO: sanity check
src/lib/device/m2_dsdr/dsdr_hiper.c:800:    // TODO: find rational numbers for R/N
src/lib/device/m2_dsdr/dsdr_hiper.c:880:    // TODO: set default configuration
src/lib/device/m2_dsdr/m2_dsdr.c:1268:    // TODO wait for PLL to lock..
src/lib/device/m2_dsdr/m2_dsdr.c:1315:    // TODO check for AFE7903
src/lib/device/m2_dsdr/m2_dsdr.c:1430:                                          (d->type == DSDR_PCIE_HIPER_R0) ? 2 : 1 /* TODO FIXME!!! */, &d->lmk);
src/lib/device/m2_dsdr/m2_dsdr.c:307:// TODO extend to arbitary number of channels
src/lib/device/m2_dsdr/m2_dsdr.c:629:    // TODO issue FE cmd
src/lib/device/m2_dsdr/m2_dsdr.c:653:    // TODO issue FE cmd
src/lib/device/m2_lm6_1/m2_lm6_1.c:52:    { DNLL_IRQ_COUNT, 8 }, //TODO fix segfault when int count < configured
src/lib/device/m2_lm6_1/usdr_ctrl.c:391:    // TODO: Add ability to alter it
src/lib/device/m2_lm6_1/usdr_ctrl.c:427:    // TODO enable clock
src/lib/device/m2_lm6_1/usdr_ctrl.c:446:    // TODO disable clock
src/lib/device/m2_lm6_1/usdr_ctrl.c:471:    // TODO retrigger samplerate / TX / RX
src/lib/device/m2_lm6_1/usdr_ctrl.c:661:    // TODO: Apply si div
src/lib/device/m2_lm6_1/usdr_ctrl.c:700:    // TODO RX / TX selection
src/lib/device/m2_lm6_1/usdr_ctrl.c:723:    //TODO Set path to 1
src/lib/device/m2_lm7_1/lms7002m_ctrl.c:1169:        // TODO: optimize for TDD
src/lib/device/m2_lm7_1/lms7002m_ctrl.c:347:    res_freq = freq; //TODO !!!!!
src/lib/device/m2_lm7_1/m2_lm7_1.c:60:    { DNLL_IRQ_COUNT, 8 }, //TODO fix segfault when int count < configured
src/lib/device/m2_lm7_1/m2_lm7_1.c:627:        chan = 0; // TODO B
src/lib/device/m2_lm7_1/xsdr_ctrl.c:1002:    // TODO TCXO internal / external
src/lib/device/m2_lm7_1/xsdr_ctrl.c:1173:    // TODO retrigger samplerate / TX / RX
src/lib/device/m2_lm7_1/xsdr_ctrl.c:1238:        // TODO: Add proper delay calibration
src/lib/device/m2_lm7_1/xsdr_ctrl.c:1463:    // TODO: txdsp != 0 || rxdsp != 0 makes incorrect calibration
src/lib/device/m2_lm7_1/xsdr_ctrl.c:1512:        // TODO if TX was disabled enable TX
src/lib/device/m2_lm7_1/xsdr_ctrl.c:290:    // TODO: Check if MMCM is present
src/lib/device/m2_lm7_1/xsdr_ctrl.c:307:        lms7002m_afe_enable(&d->base.lmsstate, true, true, true, true); // TODO: Check if rx & tx, a & b is required!
src/lib/device/m2_lm7_1/xsdr_ctrl.c:329:        // TODO phase search
src/lib/device/m2_lm7_1/xsdr_ctrl.c:732:    // TODO Read configuration from FLASH
src/lib/device/m2_lm7_1/xsdr_ctrl.c:800:        // TODO check if we need this rail
src/lib/device/m2_lm7_1/xsdr_ctrl.h:119:// TODO add subdev for chaining
src/lib/device/m2_lsdr/m2_da09_4_ad45_2.c:1159:        // TODO: acticate/deactivate ADC
src/lib/device/m2_lsdr/m2_da09_4_ad45_2.c:835:    // TODO wait stble frequency!!!
src/lib/device/mdev.c:272:    // TODO aggregate
src/lib/device/mdev.c:303:    // TODO aggregate
src/lib/device/mdev.c:380:        // TODO proper parse with specific chnnel mixing
src/lib/device/mdev.c:450:// TODO error handling
src/lib/device/mdev.c:479:        // TODO check this
src/lib/device/pe_sync/pe_sync.c:156:    // TODO: power off
src/lib/device/pe_sync/pe_sync.c:213:    // TODO: Initialize LMK05318B
src/lib/device/u3_limesdr/limesdr_ctrl.c:13:// TODO: Rename these magic constants
src/lib/device/u3_limesdr/limesdr_ctrl.c:210:    // TODO
src/lib/device/u3_limesdr/limesdr_ctrl.c:344:    // TODO: AlignRX
src/lib/device/u3_limesdr/limesdr_ctrl.c:358:    // TODO: ResetStreamBuffers
src/lib/device/u3_limesdr/limesdr_ctrl.c:403:    // TODO set direct mode or do PLL with phase search
src/lib/device/u3_limesdr/u3_limesdr.c:351:    // TODO: pass channels
src/lib/device/u3_limesdr/u3_limesdr.c:376:    //return -EINVAL; TODO!!!
src/lib/hw/afe79xx/afe79xx.c:150:    // TODO: version check
src/lib/hw/lmk04832/lmk04832.c:315:        MAKE_LMK04832_CLKIN_TYPE(0, 0, (inpath == OSCIN) ? CLKIN_SEL_MANUAL_CLKIN0 : inpath, clkin1_demux, clkin0_demux), //TODO fix holdover state
src/lib/hw/lmk5c33216/lmk5c33216.c:78:    // TODO: Soft reset
src/lib/hw/lms6002d/lms6002d.c:186:    // TODO last step error!!!
src/lib/hw/lms6002d/lms6002d.c:334:    // TODO add thermal info
src/lib/hw/lms6002d/lms6002d.c:356:    // TODO add more options for failed locks
src/lib/hw/lms6002d/lms6002d.c:363:// TODO proper calibration
src/lib/hw/lms6002d/lms6002d.c:466:    // TODO RCAL adaptation
src/lib/hw/lms6002d/lms6002d.c:72:    // TODO replace through options
src/lib/hw/lms7002m/lms7002m.c:1368:    // TODO channel A/B
src/lib/hw/lms7002m/lms7002m.c:504:    //TODO: Disable COMPARATOR power
src/lib/hw/lms7002m/lms7002m.c:681:    // TODO disable comparators
src/lib/hw/lms7002m/lms7002m.h:263:    // RBB_MODE_EXT_ADC,  TODO
src/lib/hw/lms8001/lms8001.c:145:// TODO: Add profile
src/lib/hw/lms8001/lms8001.c:165:    // TODO: Prescaler DIV
src/lib/hw/si5332/si5332.c:578:    // TODO alternative PLL ref
src/lib/ipblks/lms64c_proto.c:117:                // TODO: Endianess
src/lib/ipblks/lms64c_proto.c:143:            // TODO: Endianess
src/lib/ipblks/streams/sfe_rx_4.c:149:    // TODO check device capabilities
src/lib/ipblks/streams/stream_limesdr.c:117:            // TODO: obtain packet size for dynamic packet rescaling
src/lib/ipblks/streams/stream_limesdr.c:18:// TODO: OP calls don't work at the moment
src/lib/ipblks/streams/stream_limesdr.c:19:// TODO: Dynamic RX packet reconfiguration doesn't work
src/lib/ipblks/streams/stream_limesdr.c:484:    // TODO dynamic rescaling
src/lib/ipblks/streams/stream_limesdr.c:512:    sparams.buffer_count = 16;                     // TODO: parameter
src/lib/ipblks/streams/stream_sfetrx4_dma32.c:1161:        // TODO obtain dynamic config
src/lib/ipblks/streams/stream_sfetrx4_dma32.c:1173:        // TODO obtain dynamic config
src/lib/ipblks/streams/stream_sfetrx4_dma32.c:150:        // TODO: Issue rx ready, should be put inside
src/lib/ipblks/streams/stream_sfetrx4_dma32.c:413:            ostat->opkttime = 0; // TODO
src/lib/ipblks/streams/stream_sfetrx4_dma32.c:58:    unsigned sync_base;  // TODO: for compatibility with OLD APIs
src/lib/ipblks/streams/stream_sfetrx4_dma32.c:641:    // TODO: Bifurcation proper set
src/lib/ipblks/streams/stream_sfetrx4_dma32.c:729:        // TODO: proper channel remap, now assuming bifurcation lanes are siblings
src/lib/ipblks/streams/stream_sfetrx4_dma32.c:752:    // TODO obtain exfe configuration constants
src/lib/ipblks/streams/stream_sfetrx4_dma32.c:946:        // TODO: proper lane bifurcation
src/lib/json_controller/controller.c:16:// TODO: get rid of this foo
src/lib/lowlevel/libusb_generic.c:334:        // TODO: check res
src/lib/lowlevel/libusb_generic.c:414:    // TODO Add synchronization to get all outstanging endpoints
src/lib/lowlevel/libusb_generic.c:575:        // TODO: Syncronize EPs
src/lib/lowlevel/libusb_generic.h:128:            return -ENOMEM; //TODO CLEANUP!!!!!
src/lib/lowlevel/libusb_generic.h:134:        ot[i]->timeout = 0; //TODO!!!
src/lib/lowlevel/libusb_generic.h:211:// TODO: get rid off ugly call
src/lib/lowlevel/libusb_generic.h:220:// TODO: on auto resubmit mode max_buffs must be more than max_reqs
src/lib/lowlevel/libusb_generic.h:62:        return -ESRCH; //TODO find better;
src/lib/lowlevel/pcie_uram/driver/usdr_pcie_uram.c:1099:    // TODO FLUSH CACHE on non-coherent devices
src/lib/lowlevel/pcie_uram/driver/usdr_pcie_uram.c:1100:    // TODO: this works only on non-muxed interrupts!!!
src/lib/lowlevel/pcie_uram/driver/usdr_pcie_uram.c:1340:        // TODO: Protect i2cc structure
src/lib/lowlevel/pcie_uram/driver/usdr_pcie_uram.c:1752:	// TODO: Unchain from list and free the memory
src/lib/lowlevel/pcie_uram/driver/usdr_pcie_uram.c:422:        //TODO block interrupt queue
src/lib/lowlevel/pcie_uram/driver/usdr_pcie_uram.c:481:        // TODO: based on event handler process data
src/lib/lowlevel/pcie_uram/pcie_uram_main.c:345:        // TODO: check if we need this sanity check, since evertyhing is checked in PCI
src/lib/lowlevel/pcie_uram/pcie_uram_main.c:640:    // TODO: don't call ioctl() on mmaped cache coherent interface
src/lib/lowlevel/pcie_uram/pcie_uram_main.c:676:    // TODO: Call to flush DMA buffers on non-coherent systems
src/lib/lowlevel/pcie_uram/pcie_uram_main.c:872:    // TODO class
src/lib/lowlevel/usb_ft601/usb_ft601_generic.c:117:        // TODO split to RD / WR packets
src/lib/lowlevel/usb_ft601/usb_ft601_libusb.c:378:    // TODO: Wait for outstanding IO
src/lib/lowlevel/usb_uram/usb_uram_generic.c:111:    // TODO Wrap to 128b
src/lib/lowlevel/usb_uram/usb_uram_generic.c:348:    // TODO move hwid to 0
src/lib/lowlevel/usb_uram/usb_uram_generic.h:24:    // TODO Get rid of duplication constant, use DMA caps to calculate actual size
src/lib/lowlevel/usb_uram/usb_uram_libusb.c:245:    // TODO obtain IDX
src/lib/lowlevel/usb_uram/usb_uram_libusb.c:271:    // TODO obtain IDX
src/lib/lowlevel/usb_uram/usb_uram_libusb.c:368:            //TODO packet notification
src/lib/lowlevel/usb_uram/usb_uram_libusb.c:369:            USDR_LOG("USBX", USDR_LOG_ERROR, "TODO!!!!!!!!!!!!!!!\n");
src/lib/lowlevel/usb_uram/usb_uram_libusb.c:820:    // TODO: Wait for outstanding IO
src/lib/lowlevel/usb_uram/usb_uram_webusb.c:71:            USDR_LOG("USBX", USDR_LOG_ERROR, "TODO!!!!!!!!!!!!!!!\n");
src/lib/lowlevel/usdr_lowlevel.c:59:    //TODO driver loading
src/lib/lowlevel/usdr_lowlevel.h:118:    // TODO Async operations
src/lib/lowlevel/verilator_ll/verilatorll_wrap.c:352:            //TODO atomic or
src/lib/lowlevel/verilator_ll/verilatorll_wrap.c:523:    // TODO Wrap to 128b
src/lib/lowlevel/verilator_ll/verilatorll_wrap.c:864:    // TODO discovery
src/lib/port/usdr_logging.h:53:// TODO
src/lib/xdsp/nco.c:27:    // TODO calc mask on absolute phase
src/soapysdr/usdr_soapy.cpp:186:        // TODO:
src/soapysdr/usdr_soapy.cpp:190:        // TODO:
src/soapysdr/usdr_soapy.cpp:376:    //TODO
src/soapysdr/usdr_soapy.cpp:785:    //some boards may not ever support hw time, so TODO
src/soapysdr/usdr_soapy.cpp:936:    // TODO
src/soapysdr/usdr_soapy.cpp:947:    // TODO
src/soapysdr/usdr_soapy_reg.cpp:17:    // TODO skip incompatible module
src/soapysdr/usdr_soapy_reg.cpp:26:        // TODO parse params
src/soapysdr/usdr_soapy_reg.cpp:27:        // TODO filter by matchArgs
src/tests/lms7_cal.c:506:    // TODO
src/utests/mock_lowlevel.c:129:// TODO Async operations
