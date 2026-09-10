cd ..
mkdir util-build

cd util-linux-2.41.5
./autogen.sh
cd ..

cd util-build
../util-linux-2.41.5/configure \
    --disable-liblastlog2 \
    --prefix=/usr

make -j$(nproc)

mv "$LOS/usr/lib/libc.a" "$LOS/usr/lib/libc.a.lecos"
mv "$LOS/usr/lib/libc.so" "$LOS/usr/lib/libc.so.lecos"
mv "$LOS/usr/lib/libc_nonshared.a" "$LOS/usr/lib/libc_nonshared.a.lecos"

make DESTDIR="$LOS" install

mv "$LOS/usr/lib/libc.a.lecos" "$LOS/usr/lib/libc.a"
mv "$LOS/usr/lib/libc.so.lecos" "$LOS/usr/lib/libc.so"
mv "$LOS/usr/lib/libc_nonshared.a.lecos" "$LOS/usr/lib/libc_nonshared.a"

cd ..