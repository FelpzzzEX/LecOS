mkdir nano-build

cd nano
rm -rf gnulib
git clone --depth 1 https://github.com/coreutils/gnulib.git
./autogen.sh
cd ..

cd nano-build
../nano/configure --prefix=/usr

make -j$(nproc)
make DESTDIR=$LOS install
cd ..