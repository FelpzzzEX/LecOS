cd ..
mkdir coreutils-build

cd coreutils-9.7
./bootstrap
cd ..

cd coreutils-build
export FORCE_UNSAFE_CONFIGURE=1
../coreutils-9.7/configure --without-selinux --disable-libcap --prefix=/usr

make -j$(nproc)
make DESTDIR=$LOS install
cd ..