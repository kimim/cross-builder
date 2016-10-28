binutils_v = 2.25
gcc_v = 6.2.0
gmp_v = 6.0.0
mpfr_v = 3.1.3
mpc_v = 1.0.3
linux_v = 2.6.34
glibc_v = 2.11.2
glibc-ports_v = 2.11
gdb_v = 7.10

binutils_url=http://ftp.gnu.org/gnu/binutils/
gcc_url=http://ftp.gnu.org/gnu/gcc/
gmp_url=http://ftp.gnu.org/gnu/gmp/
mpfr_url=http://ftp.gnu.org/gnu/mpfr/
gdb_url=http://ftp.gnu.org/gnu/gdb/

get-src: gmp-src mpfr-src gdb-src mpc-src gcc-src binutils-src
	rm -f *.html*

gmp-src:
	wget $(gmp_url) -O gmp.html
	wget $(gmp_url)$(shell htmltree gmp.html | grep \ \"gmp.*[:digit:].*.xz\" | tail -n 1 | cut -d \" -f 2) -P src

mpfr-src:
	wget $(mpfr_url) -O mpfr.html
	wget $(mpfr_url)$(shell htmltree mpfr.html | grep \ \"mpfr.*[:digit:].*.xz\" | tail -n 1 | cut -d \" -f 2) -P src

gdb-src:
	wget $(gdb_url) -O gdb.html
	wget $(gdb_url)$(shell htmltree gdb.html | grep \ \"gdb.*[:digit:].*.gz\" | tail -n 1 | cut -d \" -f 2) -P src

mpc-src:
	wget $(mpc_url) -O mpc.html
	wget $(mpc_url)$(shell htmltree mpc.html | grep \ \"mpc.*[:digit:].*.gz\" | tail -n 1 | cut -d \" -f 2) -P src

gcc-src:
	wget $(gcc_url) -O gcc.html
	wget $(gcc_url)$(shell htmltree gcc.html | grep \ \"gcc-[:digit:].*\.tar\.gz\" | tail -n 1 | cut -d \" -f 2) -P src

binutils-src:
	wget $(binutils_url) -O binutils.html
	wget $(binutils_url)$(shell htmltree binutils.html | grep \ \"binutils-.*\.tar\.gz\" | tail -n 1 | cut -d \" -f 2) -P src
