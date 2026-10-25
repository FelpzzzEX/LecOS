#!/bin/bash

"$LOS/usr/lib64/ld-linux-x86-64.so.2" \
  --library-path "$LOS/usr/lib/systemd:$LOS/usr/lib64:$LOS/usr/lib:$LOS/lib64:$LOS/lib" \
  "$LOS/usr/bin/systemd-sysusers" --root="$LOS"

mkdir -p "$LOS/etc/systemd/system/getty.target.wants"

ln -sfn /usr/lib/systemd/system/getty@.service \
  "$LOS/etc/systemd/system/getty.target.wants/getty@tty1.service"

cd /LOS/Componentes

wget https://www.kernel.org/pub/linux/utils/kbd/kbd-2.9.0.tar.xz

tar -xf kbd-2.9.0.tar.xz

cd kbd-2.9.0

./configure \
  --prefix=/usr \
  --bindir=/usr/bin \
  --sbindir=/usr/sbin \
  --datadir=/usr/share \
  --disable-nls \
  --disable-vlock \
  --disable-tests \
  --disable-rpath

make -j"$(nproc)"

make DESTDIR="$LOS" install

mkdir -p "$LOS/etc"

cat > "$LOS/etc/vconsole.conf" <<'EOF'
KEYMAP=br-abnt2
EOF

gzip -dc "$LOS/usr/share/keymaps/i386/qwerty/br-abnt2.map.gz" \
  > "$LOS/usr/share/keymaps/i386/qwerty/br-abnt2.map"