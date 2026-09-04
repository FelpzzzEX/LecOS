cd ..

cd coreutils
./bootstrap
cd ..

cd coreutils-build
export FORCE_UNSAFE_CONFIGURE=1
../coreutils/configure --without-selinux --disable-libcap --prefix=/usr

make -j$(nproc)
make DESTDIR=$LOS install
cd ..