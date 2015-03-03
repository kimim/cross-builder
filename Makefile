include config.mk

lc_all=posix
path=$(SYSROOT)/bin:/bin:/usr/bin
TEMP_PREFIX=/build-temp-arm
BUILD_PATH=build-$(TARGET)

binutils_v = 2.25
gcc_v = 4.9.2
gmp_v = 6.0.0
mpfr_v = 3.1.2
mpc_v = 1.0.2
linux_v = 2.6.34
glibc_v = 2.11.2
glibc-ports_v = 2.11
gdb_v = 7.1

all: prerequest install-cross

prerequest:
	set +h && mkdir -p $(SYSROOT)/bin && mkdir -p $(PREFIX)/include && \
	mkdir -p $(TEMP_PREFIX)
	export path lc_all

decompress-src:
	tar -xvf src/gmp-$(gmp_v).tar.bz2
	tar -xvf src/mpfr-$(mpfr_v).tar.xz
	tar -xvf src/mpc-$(mpc_v).tar.gz
	tar -xvf src/binutils-$(binutils_v).tar.gz
	tar -xvf src/gcc-$(gcc_v).tar.bz2

install-deps: gmp mpfr mpc

gmp: gmp-$(gmp_v)
	mkdir -p $(BUILD_PATH)/gmp-$(gmp_v) && 		\
	cd $(BUILD_PATH)/gmp-$(gmp_v) && 			\
	../../gmp-$(gmp_v)/configure --prefix=$(TEMP_PREFIX) &&	\
	make && make install

mpfr: mpfr-$(mpfr_v) gmp
	mkdir -p $(BUILD_PATH)/mpfr-$(mpfr_v) && 	\
	cd $(BUILD_PATH)/mpfr-$(mpfr_v) && 			\
	../../mpfr-$(mpfr_v)/configure ldflags="-wl,-search_paths_first"	\
	--build=$(BUILD) --host=$(HOST) --target=$(TARGET) 					\
	--with-gmp=$(TEMP_PREFIX) --prefix=$(TEMP_PREFIX) &&				\
	make all && make install

mpc: mpc-$(mpc_v) gmp mpfr
	mkdir -p $(BUILD_PATH)/mpc-$(mpc_v) &&		\
	cd $(BUILD_PATH)/mpc-$(mpc_v) && 			\
	../../mpc-$(mpc_v)/configure --with-mpfr=$(TEMP_PREFIX)		\
	--with-gmp=$(TEMP_PREFIX) --prefix=$(TEMP_PREFIX)			\
	--build=$(BUILD) --host=$(HOST) --target=$(TARGET) 			\
	--enable-static --disable-shared &&							\
	make && make install

install-cross: install-deps cross-binutils cross-gcc

cross-binutils: binutils-$(binutils_v)
	mkdir -p $(BUILD_PATH)/binutils-$(binutils_v) && 	\
	cd $(BUILD_PATH)/binutils-$(binutils_v) && 			\
	../../binutils-$(binutils_v)/configure --prefix=$(SYSROOT)			\
	--target=$(TARGET) --with-sysroot --disable-nls --disable-werror &&	\
	make && make install

cross-gcc: gcc-$(gcc_v)
	mkdir -p $(BUILD_PATH)/gcc-$(gcc_v) && 	\
	cd $(BUILD_PATH)/gcc-$(gcc_v) && 		\
	../../gcc-$(gcc_v)/configure --target=$(TARGET) --prefix=$(SYSROOT) \
	--disable-nls --enable-languages=c,c++ --with-gmp=$(TEMP_PREFIX)    \
	--with-mpfr=$(TEMP_PREFIX) --with-mpc=$(TEMP_PREFIX) && 			\
	make all-gcc && make all-target-libgcc && \
	make install-gcc && make install-target-libgcc
