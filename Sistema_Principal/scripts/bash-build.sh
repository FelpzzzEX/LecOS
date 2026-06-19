mkdir bash-build
cd bash-build

../bash/configure --prefix=/usr

make -j$(nproc)
make DESTDIR=$LOS install
cd ..

ln -s bash root/bin/sh