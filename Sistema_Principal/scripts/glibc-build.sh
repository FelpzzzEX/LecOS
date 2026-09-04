cd ..
cd glibc-build

../glibc-2.41/configure --libdir=/lib --prefix=/usr

make -j$(nproc)
make DESTDIR=$LOS install
cd ..