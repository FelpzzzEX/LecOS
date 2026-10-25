cd ..
mkdir -p inetutils-build

cd inetutils-build

# Configura o Inetutils desabilitando os servidores que não usaremos agora
../inetutils-2.5/configure \
    --prefix=/usr \
    --disable-servers \
    --disable-whois

make -j$(nproc)
make DESTDIR="$LOS" install

cd ..
