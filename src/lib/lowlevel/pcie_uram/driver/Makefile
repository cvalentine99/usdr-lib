
ifneq ($(KERNELRELEASE),)

ccflags-y += $(shell grep -E 'class_create\s*.*\s*const char' $(srctree)/include/linux/device/class.h >/dev/null && echo -DHAVE_CLASS_CREATE_ONE_ARG)
obj-m += usdr_pcie_uram.o

else

KERNELDIR ?= /lib/modules/$(shell uname -r)/build


modules modules_install clean::
	make -C $(KERNELDIR) M=$(PWD) $@

clean::
	rm -f *.o Module.markers modules.order

endif

