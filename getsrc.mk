binutils_v = 2.25
gcc_v = 4.9.2
gmp_v = 6.0.0
mpfr_v = 3.1.2
mpc_v = 1.0.3
linux_v = 2.6.34
glibc_v = 2.11.2
glibc-ports_v = 2.11
gdb_v = 7.1

get-src:
	wget http://ftp.gnu.org/gnu/binutils/binutils-$(binutils_v).tar.gz
	wget http://ftp.gnu.org/gnu/gcc/gcc-$(gcc_v)/gcc-$(gcc_v).tar.bz2
	wget http://ftp.gnu.org/gnu/gmp/gmp-$(gmp_v)a.tar.xz
	wget http://ftp.gnu.org/gnu/mpfr/mpfr-$(mpfr_v).tar.xz
	wget http://ftp.gnu.org/gnu/mpc/mpc-$(mpc_v).tar.gz
