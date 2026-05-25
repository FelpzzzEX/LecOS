# Selecionando a imagem do sistema operacional do nosso ambiente
FROM debian:trixie-slim

# Executando comandos essenciais: instalando dependências e criando o diretório base
RUN apt update && apt install -y autoconf \
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
    libelf-dev \
    libncurses5-dev \
    libssl-dev \
    libtool \
    make \
    openssl \
    pahole \
    perl-base \
    rsync \
    tar \
    texinfo \
    texi2html \
    xz-utils && \
    mkdir -p /LOS && mkdir /LOS/root 

# Criando uma variável para facilitar o trabalho nas instalações - $LOS = /LOS/root
ENV LOS=/LOS/root

# Setando o diretório LOS como o principal do ambiente
WORKDIR /LOS

# Clonando o repositório do Kernel Linux, Bash, Coreutils, Util-Linux, Nano, Glibc e Ncurses (somente o último commit)
RUN git clone --depth 1 https://github.com/torvalds/linux.git && \
    git clone --depth 1 https://git.savannah.gnu.org/git/bash.git && \
    git clone --depth 1 https://github.com/coreutils/coreutils && \
    git clone --depth 1 https://github.com/util-linux/util-linux && \
    git clone --depth 1 https://git.savannah.gnu.org/git/nano.git && \
    git clone --depth 1 https://sourceware.org/git/glibc

# Iniciando shell padrão
CMD [ "/bin/bash" ]