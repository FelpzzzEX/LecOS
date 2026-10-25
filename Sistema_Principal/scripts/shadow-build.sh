cd ..
mkdir -p shadow-build

cd shadow-build

../shadow-4.17.4/configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --disable-static \
    --without-libbsd \
    --without-selinux

make -j$(nproc)
make DESTDIR="$LOS" install

touch "$LOS/etc/shadow"
chmod 600 "$LOS/etc/shadow"

touch "$LOS/etc/gshadow"
chmod 600 "$LOS/etc/gshadow"

cd ..