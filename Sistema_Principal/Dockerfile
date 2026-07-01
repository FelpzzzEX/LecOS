# Selecionando a imagem do sistema operacional do nosso ambiente
FROM debian:trixie

# Executando comandos essenciais: instalando dependências e criando o diretório base
RUN apt update && apt install -y autoconf \
    automake \
    autopoint \
    bc \
    binutils \
    bison \
    bzip2 \
    dwarves \
    flex \
    gawk \
    gcc \
    gettext \
    git \
    gnupg2 \
    gperf \
    gzip \
    help2man \
    libelf-dev \
    libncurses5-dev \
    libssl-dev \
    libtool \
    m4 \
    make \
    nano \
    openssl \
    pahole \
    perl-base \
    pkgconf \
    python3 \
    rsync \
    tar \
    texinfo \
    texi2html \
    wget \
    xz-utils && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /LOS && mkdir /LOS/root && mkdir /LOS/root/boot \
    && mkdir /LOS/root/proc && mkdir /LOS/root/sys && mkdir /LOS/root/dev \
    && mkdir /LOS/root/usr && mkdir /LOS/root/usr/lib && mkdir /LOS/root/usr/lib64 \
    && mkdir /LOS/root/usr/bin && mkdir /LOS/root/usr/sbin

# Criando uma variável para facilitar o trabalho nas instalações - $LOS = /LOS/root
ENV LOS=/LOS/root

# Setando o diretório LOS como o principal do ambiente
WORKDIR /LOS

RUN cd /LOS/root/ && ln -s usr/lib lib && ln -s usr/lib64 lib64 && ln -s usr/bin bin && ln -s usr/sbin sbin    

# Iniciando shell padrão
CMD [ "/bin/bash" ]