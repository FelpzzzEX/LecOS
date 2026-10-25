cd ..
mkdir -p pam-build

cd pam-build

meson setup \
    --prefix=/usr \
    --libdir=/usr/lib \
    --sysconfdir=/etc \
    -Ddocs=disabled \
    -Dexamples=false \
    -Dxtests=false \
    -Dselinux=disabled \
    -Dnis=disabled \
    -Dlogind=disabled \
    ../Linux-PAM-1.7.0

meson compile -j$(nproc)

DESTDIR="$LOS" meson install

cd ..