mkdir glibc-build

cd glibc-build
../glibc/configure --libdir=/lib --prefix=/usr

make -j$(nproc)
make DESTDIR=$LOS install
cd ..