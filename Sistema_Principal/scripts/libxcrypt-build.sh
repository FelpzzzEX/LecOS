cd ..

mkdir -p libxcrypt-build

cd libxcrypt-build

../libxcrypt-4.5.2/configure \
    --prefix=/usr \
    --libdir=/usr/lib \
    --enable-hashes=strong,glibc \
    --enable-obsolete-api=no \
    --disable-static \
    --disable-failure-tokens

make -j$(nproc)

make check

make DESTDIR="$LOS" install

cd ..
