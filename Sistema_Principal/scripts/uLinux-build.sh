mkdir util-build

cd util-linux
./autogen.sh
cd ..

cd util-build
../util-linux/configure --disable-liblastlog2 --prefix=/usr

make -j$(nproc)
make DESTDIR=$LOS install
cd ..