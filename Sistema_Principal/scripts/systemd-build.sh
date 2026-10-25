#!/bin/bash

set -e

cd ..

echo "========================================"
echo "  LecOS - libcap 2.75"
echo "========================================"

rm -rf libcap-build
mkdir -p libcap-build
cd libcap-build

make -C ../libcap-2.75 \
    prefix=/usr \
    lib=lib \
    -j$(nproc)

make -C ../libcap-2.75 \
    prefix=/usr \
    lib=lib \
    DESTDIR="$LOS" \
    install

cd ..


echo "========================================"
echo "  LecOS - kmod 34.2"
echo "========================================"

rm -rf kmod-build
mkdir -p kmod-build
cd kmod-build

../kmod-34.2/configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --with-rootlibdir=/usr/lib \
    --disable-manpages

make -j$(nproc)

make DESTDIR="$LOS" install

cd ..


echo "========================================"
echo "  LecOS - zstd 1.5.7"
echo "========================================"

rm -rf zstd-build
mkdir -p zstd-build
cd zstd-build

make -C ../zstd-1.5.7 \
    PREFIX=/usr \
    DESTDIR="$LOS" \
    -j$(nproc)

make -C ../zstd-1.5.7 \
    PREFIX=/usr \
    DESTDIR="$LOS" \
    install

cd ..

set -Eeuo pipefail

echo "========================================"
echo "  Systemd 257.13"
echo "========================================"

# ============================================================
# CONFIGURACAO
# ============================================================

: "${LOS:?ERRO: variável LOS não definida}"

SYSTEMD_SRC="/LOS/Componentes/systemd-257.13"
SYSTEMD_BUILD="/LOS/Componentes/systemd-build"

echo "Rootfs LecOS: $LOS"
echo "Systemd:      $SYSTEMD_SRC"

cd /LOS/Componentes

# Limpa build anterior
rm -rf "$SYSTEMD_BUILD"
mkdir -p "$SYSTEMD_BUILD"

# ============================================================
# AMBIENTE DE COMPILACAO
# ============================================================

export SYSROOT="$LOS"

export PKG_CONFIG_PATH="$SYSROOT/usr/lib/pkgconfig:$SYSROOT/usr/share/pkgconfig"
export PKG_CONFIG_SYSROOT_DIR="$SYSROOT"

export CPPFLAGS="--sysroot=$SYSROOT -I$SYSROOT/usr/include"
export CFLAGS="$CPPFLAGS"
export CXXFLAGS="$CPPFLAGS"

export LDFLAGS="--sysroot=$SYSROOT \
-L$SYSROOT/usr/lib \
-L$SYSROOT/usr/lib64 \
-Wl,-rpath-link,$SYSROOT/usr/lib \
-Wl,-rpath-link,$SYSROOT/usr/lib64"

echo
echo "========================================"
echo "  AMBIENTE DE COMPILACAO   "
echo "========================================"

echo "CPPFLAGS=$CPPFLAGS"
echo "CFLAGS=$CFLAGS"
echo "LDFLAGS=$LDFLAGS"
echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH"

# ============================================================
# VERIFICANDO DEPENDENCIAS
# ============================================================

echo
echo "========================================"
echo "  VERIFICANDO DEPENDENCIAS"
echo "========================================"

echo
echo "--- libcap ---"

test -f "$LOS/usr/include/sys/capability.h" \
    || { echo "ERRO: sys/capability.h nao encontrado"; exit 1; }

test -f "$LOS/usr/lib/libcap.so" \
    || { echo "ERRO: libcap.so nao encontrado"; exit 1; }

echo "OK: libcap"
echo "    Header: $LOS/usr/include/sys/capability.h"
echo "    Lib:    $LOS/usr/lib/libcap.so"

echo
echo "--- teste do compilador ---"

echo '#include <sys/capability.h>' | \
    gcc -I"$LOS/usr/include" -E -x c - >/dev/null

echo "OK: sys/capability.h"

echo
echo "--- libkmod ---"

test -f "$LOS/usr/lib/libkmod.so" \
    || { echo "ERRO: libkmod.so nao encontrado"; exit 1; }

test -f "$LOS/usr/lib/pkgconfig/libkmod.pc" \
    || { echo "ERRO: libkmod.pc nao encontrado"; exit 1; }

echo "OK: libkmod"

echo
echo "--- libblkid ---"

test -f "$LOS/usr/include/blkid/blkid.h" \
    || { echo "ERRO: blkid/blkid.h nao encontrado"; exit 1; }

test -f "$LOS/usr/lib/libblkid.so" \
    || { echo "ERRO: libblkid.so nao encontrado"; exit 1; }

test -f "$LOS/usr/lib/pkgconfig/blkid.pc" \
    || { echo "ERRO: blkid.pc nao encontrado"; exit 1; }

echo "OK: libblkid"

echo
echo "--- libmount ---"

test -f "$LOS/usr/include/sys/mount.h" \
    || { echo "ERRO: sys/mount.h nao encontrado"; exit 1; }

test -f "$LOS/usr/lib/libmount.so" \
    || { echo "ERRO: libmount.so nao encontrado"; exit 1; }

echo "OK: libmount"

echo
echo "--- libpam ---"

test -f "$LOS/usr/lib/libpam.so" \
    || { echo "ERRO: libpam.so nao encontrado"; exit 1; }

echo "OK: libpam"

echo
echo "--- pkg-config: libkmod ---"

PKG_CONFIG_PATH="$PKG_CONFIG_PATH" \
    pkg-config --modversion libkmod

echo "OK: libkmod"

# ============================================================
# MESON SETUP
# ============================================================

echo
echo "========================================"
echo "  MESON SETUP"
echo "========================================"

meson setup "$SYSTEMD_BUILD" \
    --prefix=/usr \
    --libdir=/usr/lib \
    --sysconfdir=/etc \
    --buildtype=release \
    -Dmode=release \
    -Dlogind=true \
    -Dsysusers=true \
    -Dtmpfiles=true \
    -Dpam=enabled \
    -Dkmod=enabled \
    -Dblkid=enabled \
    -Dfdisk=disabled \
    -Defi=false \
    -Dresolve=false \
    -Dnetworkd=false \
    -Dhomed=disabled \
    -Duserdb=false \
    -Dmachined=false \
    -Dportabled=false \
    -Dtimesyncd=false \
    -Dcoredump=false \
    -Doomd=false \
    -Dpstore=false \
    -Dopenssl=disabled \
    -Dzlib=disabled \
    -Dxz=disabled \
    -Dlz4=disabled \
    -Dzstd=enabled \
    -Ddefault-compression=zstd \
    -Ddbus=disabled \
    -Dselinux=disabled \
    -Dapparmor=disabled \
    -Dsmack=false \
    -Daudit=disabled \
    -Dacl=disabled \
    -Dman=disabled \
    -Dhtml=disabled \
    "$SYSTEMD_SRC"

# ============================================================
# COMPILACAO
# ============================================================

echo
echo "========================================"
echo "  COMPILANDO SYSTEMD"
echo "========================================"

meson compile \
    -C "$SYSTEMD_BUILD" \
    -j"$(nproc)"

# ============================================================
# INSTALACAO
# ============================================================

echo
echo "========================================"
echo "  INSTALANDO NO ROOTFS"
echo "========================================"

DESTDIR="$LOS" meson install \
    -C "$SYSTEMD_BUILD"

# ============================================================
# VERIFICACAO
# ============================================================

echo
echo "========================================"
echo "  VERIFICANDO A INSTALACAO"
echo "========================================"

echo
echo "--- systemd ---"
ls -lh "$LOS/usr/lib/systemd/systemd"

echo
echo "--- systemd-logind ---"
ls -lh "$LOS/usr/lib/systemd/systemd-logind"

echo
echo "--- systemd-sysusers ---"
ls -lh "$LOS/usr/bin/systemd-sysusers"

echo
echo "--- systemd-tmpfiles ---"
ls -lh "$LOS/usr/bin/systemd-tmpfiles"

echo
echo "--- systemd units ---"
find "$LOS/usr/lib/systemd/system" \
    -maxdepth 1 \
    -type f \
    | head -20

echo
echo "========================================"
echo "  BUILD DO SYSTEMD CONCLUIDO"
echo "========================================"