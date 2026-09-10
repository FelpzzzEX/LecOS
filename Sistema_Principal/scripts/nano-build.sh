cd ..
mkdir nano-build

cd nano-8.4
./autogen.sh
cd ..

cd nano-build
../nano-8.4/configure --prefix=/usr

make -j$(nproc)
make DESTDIR=$LOS install
cd ..