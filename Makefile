include conf/config.mk

lc_all=posix
path=$(SYSROOT)/bin:/bin:/usr/bin:/usr/local/bin
BUILD_PATH=build-$(TARGET)

all: install-cross

prepare: prerequest decompress-src

include conf/getsrc.mk

prerequest:
	mkdir -p src
	set +h && mkdir -p $(SYSROOT)/bin && mkdir -p $(SYSROOT)/include && \
	mkdir -p $(TEMP_PREFIX)
	export path lc_all

decompress-src:
	tar -xvf src/gmp-*.tar.xz -C src
	tar -xvf src/mpfr-*.tar.xz -C src
	tar -xvf src/mpc-*.tar.gz -C src
	tar -xvf src/binutils-*.tar.gz -C src
	tar -xvf src/gcc-*.tar.bz2 -C src
	tar -xvf src/gdb-*.tar.xz -C src

install-deps: gmp mpfr mpc

gmp:
	mkdir -p $(BUILD_PATH)/gmp && 			\
	cd $(BUILD_PATH)/gmp && 			\
	../../src/gmp-*/configure --prefix=$(TEMP_PREFIX) &&	\
	make && make install

mpfr: gmp
	mkdir -p $(BUILD_PATH)/mpfr && 		\
	cd $(BUILD_PATH)/mpfr && 			\
	../../src/mpfr-*/configure ldflags="-wl,-search_paths_first"	\
	--build=$(BUILD) --host=$(HOST) --target=$(TARGET) 			\
	--with-gmp=$(TEMP_PREFIX) --prefix=$(TEMP_PREFIX) &&			\
	make all && make install

mpc: gmp mpfr
	mkdir -p $(BUILD_PATH)/mpc &&			\
	cd $(BUILD_PATH)/mpc && 			\
	../../src/mpc-*/configure --with-mpfr=$(TEMP_PREFIX)		\
	--with-gmp=$(TEMP_PREFIX) --prefix=$(TEMP_PREFIX)		\
	--build=$(BUILD) --host=$(HOST) --target=$(TARGET) 		\
	--enable-static --disable-shared &&				\
	make && make install

install-cross: install-deps cross-binutils cross-gcc

cross-binutils:
	mkdir -p $(BUILD_PATH)/binutils && 		\
	cd $(BUILD_PATH)/binutils && 			\
	../../src/binutils-*/configure --prefix=$(SYSROOT)		\
	--target=$(TARGET) --with-sysroot --disable-nls --disable-werror &&	\
	make && make install

cross-gcc:
	mkdir -p $(BUILD_PATH)/gcc && 		\
	cd $(BUILD_PATH)/gcc && 		\
	../../src/gcc-*/configure --target=$(TARGET) --prefix=$(SYSROOT) 	\
	--disable-nls --enable-languages=c,c++ --with-gmp=$(TEMP_PREFIX)    	\
	--with-mpfr=$(TEMP_PREFIX) --with-mpc=$(TEMP_PREFIX) && 		\
	make all-gcc && make all-target-libgcc && \
	make install-gcc && make install-target-libgcc

cross-gdb:
	mkdir -p $(BUILD_PATH)/gdb && 		\
	cd $(BUILD_PATH)/gdb && 		\
	../../src/gdb-*/configure --target=$(TARGET) --prefix=$(SYSROOT) &&	\
	make && make instal

clean:
	rm -rf build*
