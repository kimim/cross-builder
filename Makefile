include conf/config.mk

lc_all=posix
path=$(SYSROOT)/bin:/bin:/usr/bin
TEMP_PREFIX=/build-temp-arm
BUILD_PATH=build-$(TARGET)


all: install-cross

prepare: prerequest decompress-src

include conf/getsrc.mk

prerequest:
	set +h && mkdir -p $(SYSROOT)/bin && mkdir -p $(PREFIX)/include && \
	mkdir -p $(TEMP_PREFIX)
	export path lc_all

decompress-src:
	tar -xvf src/gmp-$(gmp_v).tar.bz2 -C src
	tar -xvf src/mpfr-$(mpfr_v).tar.xz -C src
	tar -xvf src/mpc-$(mpc_v).tar.gz -C src
	tar -xvf src/binutils-$(binutils_v).tar.gz -C src
	tar -xvf src/gcc-$(gcc_v).tar.bz2 -C src
	tar -xvf src/gdb-$(gdb_v).tar.xz -C src

install-deps: gmp mpfr mpc

gmp: src/gmp-$(gmp_v)
	mkdir -p $(BUILD_PATH)/gmp-$(gmp_v) && 			\
	cd $(BUILD_PATH)/gmp-$(gmp_v) && 			\
	../../src/gmp-$(gmp_v)/configure --prefix=$(TEMP_PREFIX) &&	\
	make && make install

mpfr: src/mpfr-$(mpfr_v) gmp
	mkdir -p $(BUILD_PATH)/mpfr-$(mpfr_v) && 		\
	cd $(BUILD_PATH)/mpfr-$(mpfr_v) && 			\
	../../src/mpfr-$(mpfr_v)/configure ldflags="-wl,-search_paths_first"	\
	--build=$(BUILD) --host=$(HOST) --target=$(TARGET) 			\
	--with-gmp=$(TEMP_PREFIX) --prefix=$(TEMP_PREFIX) &&			\
	make all && make install

mpc: src/mpc-$(mpc_v) gmp mpfr
	mkdir -p $(BUILD_PATH)/mpc-$(mpc_v) &&			\
	cd $(BUILD_PATH)/mpc-$(mpc_v) && 			\
	../../src/mpc-$(mpc_v)/configure --with-mpfr=$(TEMP_PREFIX)		\
	--with-gmp=$(TEMP_PREFIX) --prefix=$(TEMP_PREFIX)		\
	--build=$(BUILD) --host=$(HOST) --target=$(TARGET) 		\
	--enable-static --disable-shared &&				\
	make && make install

install-cross: install-deps cross-binutils cross-gcc

cross-binutils: src/binutils-$(binutils_v)
	mkdir -p $(BUILD_PATH)/binutils-$(binutils_v) && 		\
	cd $(BUILD_PATH)/binutils-$(binutils_v) && 			\
	../../src/binutils-$(binutils_v)/configure --prefix=$(SYSROOT)		\
	--target=$(TARGET) --with-sysroot --disable-nls --disable-werror &&	\
	make && make install

cross-gcc: src/gcc-$(gcc_v)
	mkdir -p $(BUILD_PATH)/gcc-$(gcc_v) && 		\
	cd $(BUILD_PATH)/gcc-$(gcc_v) && 		\
	../../src/gcc-$(gcc_v)/configure --target=$(TARGET) --prefix=$(SYSROOT) 	\
	--disable-nls --enable-languages=c,c++ --with-gmp=$(TEMP_PREFIX)    	\
	--with-mpfr=$(TEMP_PREFIX) --with-mpc=$(TEMP_PREFIX) && 		\
	make all-gcc && make all-target-libgcc && \
	make install-gcc && make install-target-libgcc

cross-gdb: src/gdb-$(gdb_v)
	mkdir -p $(BUILD_PATH)/gdb-$(gdb_v) && 		\
	cd $(BUILD_PATH)/gdb-$(gdb_v) && 		\
	../../src/gdb-$(gdb_v)/configure --target=$(TARGET) --prefix=$(SYSROOT) &&	\
	make && make instal

clean:
	rm build* -rf
