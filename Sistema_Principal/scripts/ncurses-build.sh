cd ..
mkdir ncurses-build

cd ncurses-build
../ncurses-6.6/configure --with-shared --with-termlib --enable-widec --with-versioned-syms --prefix=/usr

make -j$(nproc)
make DESTDIR=$LOS install
cd ..

cd root
ln -s libncursesw.so.6 lib/libncurses.so.6
ln -s libtinfow.so.6 lib/libtinfo.so.6

cat > etc/ld.so.conf << "EOF"
/usr/lib
/usr/lib64
EOF

ldconfig -v -r ./