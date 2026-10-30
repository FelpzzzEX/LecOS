#!/bin/bash
# =============================================================================
# instalar-lecosfetch.sh - instalador COMPLETO do lecosfetch (arquivo único)
#
# Este arquivo já contém tudo: o script lecosfetch, o arquivo de configuração
# e os logos. Não é preciso baixar nem copiar mais nada.
#
# COMO USAR (no sistema principal, na pasta onde está este arquivo):
#
#   docker exec -i -w /LOS LecOS-dev bash -s < instalar-lecosfetch.sh
#
# Ou, dentro do contêiner de desenvolvimento, no diretório /LOS:
#
#   bash instalar-lecosfetch.sh
#
# O QUE FAZ:
#   1. Cria, na árvore 'root', os arquivos do lecosfetch;
#   2. Monta a imagem lecos.img e copia SOMENTE esses arquivos para ela;
#   3. Desmonta tudo, deixando a imagem pronta para o QEMU.
#
# OPÇÕES:
#   (nenhuma)        instala (ou atualiza) o lecosfetch
#   --desinstalar    remove o lecosfetch, os logos que acompanham o instalador
#                    e a configuração (logos criados por você são mantidos)
#   -h, --help       mostra esta ajuda
#
# ARQUIVOS INSTALADOS NO LecOS:
#   /usr/bin/lecosfetch                 o programa
#   /etc/lecosfetch.conf                a configuração (preservada se já existir)
#   /usr/share/lecosfetch/logos/*.txt   os logos
# =============================================================================

set -e

IMG=${IMG:-lecos.img}
RAIZ=${RAIZ:-root}
MNT=${MNT:-/mnt}

ACAO=instalar
case "$1" in
    ""|--instalar)   ;;
    --desinstalar)   ACAO=desinstalar ;;
    -h|--help)       echo "Uso: bash instalar-lecosfetch.sh [--desinstalar]"; exit 0 ;;
    *)               echo "Opção desconhecida: $1 (use -h)"; exit 1 ;;
esac

STAGE=$(mktemp -d)
DEV=""

limpar() {
    if [ -n "$DEV" ]; then
        sync
        umount "$MNT" 2>/dev/null </dev/null || true
        kpartx -d "$DEV" > /dev/null 2>&1 </dev/null || true
        losetup -d "$DEV" 2>/dev/null </dev/null || true
    fi
    rm -rf "$STAGE"
}
trap limpar EXIT

# -----------------------------------------------------------------------------
# Arquivos embutidos neste instalador (gravados em uma pasta temporária)
# -----------------------------------------------------------------------------
criar_arquivos() {
mkdir -p "$STAGE/logos"

cat > "$STAGE/lecosfetch" <<'__ARQUIVO_LECOSFETCH__'
#!/bin/bash
# lecosfetch - mostra informações do LecOS ao lado de um logo em ASCII
# Lê tudo direto do /proc, do /sys e do /etc, sem programas extras.
#
# Uso: lecosfetch [-l LOGO] [-c COR] [-n] [-L] [-h]

# Caminhos padrão (as variáveis LECOSFETCH_* permitem testar fora do LecOS)
CONF=${LECOSFETCH_CONF:-/etc/lecosfetch.conf}
DIR_LOGOS=${LECOSFETCH_LOGOS:-/usr/share/lecosfetch/logos}

# Valores padrão (podem ser alterados no arquivo de configuração)
LOGO=lecos
COR_LOGO=6
COR_TITULO=6

ajuda() {
    echo "Uso: lecosfetch [opções]"
    echo "  -l NOME   usa o logo NOME (arquivo NOME.txt em $DIR_LOGOS)"
    echo "  -c COR    cor do logo, de 1 a 7 (0 = sem cor)"
    echo "  -n        não mostra o logo"
    echo "  -L        lista os logos disponíveis"
    echo "  -h        mostra esta ajuda"
}

listar() {
    for arq in "$DIR_LOGOS"/*.txt; do
        [ -e "$arq" ] || { echo "Nenhum logo encontrado em $DIR_LOGOS"; return; }
        nome=${arq##*/}
        echo "${nome%.txt}"
    done
}

# Converte um número de 1 a 7 no código de cor ANSI correspondente
codigo_cor() {
    case $1 in
        [1-7]) printf '\e[3%sm' "$1" ;;
    esac
}

# 1) Configuração: o arquivo primeiro, as opções da linha de comando depois
[ -r "$CONF" ] && . "$CONF"

SEM_LOGO=nao
while [ $# -gt 0 ]; do
    case $1 in
        -l) LOGO=$2; shift ;;
        -c) COR_LOGO=$2; shift ;;
        -n) SEM_LOGO=sim ;;
        -L) listar; exit 0 ;;
        -h|--help) ajuda; exit 0 ;;
        *)  ajuda; exit 1 ;;
    esac
    shift
done

ESC=$'\e'
RESET="${ESC}[0m"
NEGRITO="${ESC}[1m"
C_LOGO=$(codigo_cor "$COR_LOGO")
C_TIT=$(codigo_cor "$COR_TITULO")

# 2) Logo: só aceitamos letras, números, '-' e '_' no nome
LOGO_L=()
if [ "$SEM_LOGO" = nao ]; then
    case $LOGO in
        ""|*[!A-Za-z0-9_-]*)
            echo "lecosfetch: nome de logo inválido: '$LOGO'" >&2
            exit 1 ;;
    esac
    if [ -r "$DIR_LOGOS/$LOGO.txt" ]; then
        mapfile -t LOGO_L < "$DIR_LOGOS/$LOGO.txt"
    else
        echo "lecosfetch: logo '$LOGO' não encontrado em $DIR_LOGOS (use -L para listar)" >&2
        exit 1
    fi
fi

# 3) Coleta das informações

# Usuário e nome da máquina
usuario=$(id -un)
read -r host < /proc/sys/kernel/hostname

# Sistema operacional (lido em um subshell para não poluir nossas variáveis)
so=$(. /etc/os-release 2>/dev/null; echo "${PRETTY_NAME:-$NAME}")
[ -z "$so" ] && so="Linux"

# Kernel e arquitetura
read -r kernel < /proc/sys/kernel/osrelease
arq=$(uname -m)

# Init: nome do PID 1 e, se possível, a versão do Systemd
read -r init < /proc/1/comm
versao=$(systemctl --version 2>/dev/null | head -n 1)
[ -n "$versao" ] && init=$versao

# Tempo ligado
read -r seg _ < /proc/uptime
seg=${seg%.*}
d=$((seg / 86400)); h=$((seg % 86400 / 3600)); m=$((seg % 3600 / 60))
tempo=""
[ "$d" -gt 0 ] && tempo="$d dias, "
[ "$h" -gt 0 ] && tempo+="$h h, "
tempo+="$m min"

# Quantidade de processos: cada diretório numérico do /proc é um processo
procs=0
for dir in /proc/[0-9]*; do procs=$((procs + 1)); done

# Shell e terminal
shell="bash ${BASH_VERSION%%(*}"
terminal=$(tty 2>/dev/null) || terminal="desconhecido"

# CPU: modelo e quantidade de processadores
cpu="" ; ncpu=0
while IFS=: read -r chave valor; do
    case $chave in
        "model name"*) [ -z "$cpu" ] && cpu=${valor# } ;;
        processor*)    ncpu=$((ncpu + 1)) ;;
    esac
done < /proc/cpuinfo
[ -z "$cpu" ] && cpu="desconhecida"

# Memória: valores em kB no /proc/meminfo
total=0; disp=0
while read -r chave valor _; do
    case $chave in
        MemTotal:)     total=$valor ;;
        MemAvailable:) disp=$valor ;;
    esac
done < /proc/meminfo
usada_mb=$(( (total - disp) / 1024 )); total_mb=$((total / 1024))
[ "$total_mb" -gt 0 ] && pct=$((usada_mb * 100 / total_mb)) || pct=0

# Disco: espaço usado na raiz
read -r d_usado d_total d_pct <<< "$(df -h --output=used,size,pcent / | tail -n 1)"

# Carga média
read -r c1 c2 c3 _ < /proc/loadavg

# 4) Monta as linhas de informação
INFO=()
titulo="$usuario@$host"
INFO+=("${NEGRITO}${C_TIT}${titulo}${RESET}")
INFO+=("${titulo//?/-}")

campo() {
    local rotulo
    printf -v rotulo '%-10s' "$1"
    INFO+=("${C_TIT}${rotulo}${RESET}$2")
}

campo "SO"        "$so ($arq)"
campo "Kernel"    "$kernel"
campo "Init"      "$init"
campo "Uptime"    "$tempo"
campo "Processos" "$procs"
campo "Shell"     "$shell"
campo "Terminal"  "$terminal"
campo "CPU"       "$cpu ($ncpu)"
campo "RAM"       "$usada_mb MiB / $total_mb MiB ($pct%)"
campo "Disco"     "$d_usado / $d_total ($d_pct)"
campo "Carga"     "$c1 $c2 $c3"

# Barra com as 8 cores do terminal
paleta=""
for i in 0 1 2 3 4 5 6 7; do paleta+="${ESC}[4${i}m   "; done
INFO+=("" "${paleta}${RESET}")

# 5) Exibição: logo à esquerda, informações à direita
larg=0
for linha in "${LOGO_L[@]}"; do
    [ "${#linha}" -gt "$larg" ] && larg=${#linha}
done

linhas=${#INFO[@]}
[ "${#LOGO_L[@]}" -gt "$linhas" ] && linhas=${#LOGO_L[@]}

# Se o logo for menor que as informações, ele é centralizado na vertical
recuo=$(( (linhas - ${#LOGO_L[@]}) / 2 ))

echo
for ((i = 0; i < linhas; i++)); do
    if [ "$SEM_LOGO" = nao ]; then
        j=$((i - recuo)); linha_logo=""
        [ "$j" -ge 0 ] && linha_logo=${LOGO_L[j]-}
        printf '  %s%-*s%s   %s\n' "$C_LOGO" "$larg" "$linha_logo" "$RESET" "${INFO[i]}"
    else
        printf '  %s\n' "${INFO[i]}"
    fi
done
echo
__ARQUIVO_LECOSFETCH__

cat > "$STAGE/lecosfetch.conf" <<'__ARQUIVO_CONF__'
# Configuração do lecosfetch (sintaxe do Bash: NOME=valor)

# Logo a ser exibido: nome do arquivo em /usr/share/lecosfetch/logos, sem o ".txt"
LOGO=lecos

# Cor do logo e dos títulos: de 1 a 7
# (1=vermelho 2=verde 3=amarelo 4=azul 5=magenta 6=ciano 7=branco, 0=sem cor)
COR_LOGO=6
COR_TITULO=6
__ARQUIVO_CONF__

cat > "$STAGE/logos/lecos-grande.txt" <<'__LOGO_LECOS_GRANDE__'
 _                    ___   ____
| |      ___    ___  / _ \ / ___|
| |     / _ \  / __|| | | |\___ \
| |___ |  __/ | (__ | |_| | ___) |
|_____| \___|  \___| \___/ |____/
__LOGO_LECOS_GRANDE__

cat > "$STAGE/logos/lecos-slogan.txt" <<'__LOGO_LECOS_SLOGAN__'
 _                 ___    ___
| |     ___   __  / _ \  / __|
| |__  / -_) / _|| (_) | \__ \
|____| \___| \__| \___/  |___/

    GNU/Linux minimalista
__LOGO_LECOS_SLOGAN__

cat > "$STAGE/logos/lecos-texto.txt" <<'__LOGO_LECOS_TEXTO__'
 _                 ___    ___
| |     ___   __  / _ \  / __|
| |__  / -_) / _|| (_) | \__ \
|____| \___| \__| \___/  |___/
__LOGO_LECOS_TEXTO__

cat > "$STAGE/logos/lecos.txt" <<'__LOGO_LECOS__'
  .----------------.
  |                |
  |   _            |
  |  | |           |
  |  | |           |
  |  | |_____      |
  |  |_______|     |
  |                |
  '----------------'
        LecOS
__LOGO_LECOS__

cat > "$STAGE/logos/terminal.txt" <<'__LOGO_TERMINAL__'
 .-----------------.
 | $ _             |
 |                 |
 |                 |
 '-----------------'
        _|___|_
__LOGO_TERMINAL__

cat > "$STAGE/logos/tux.txt" <<'__LOGO_TUX__'
      .--.
     |o_o |
     |:_/ |
    //   \ \
   (|     | )
  /'\_   _/`\
  \___)=(___/
__LOGO_TUX__

}

# -----------------------------------------------------------------------------
# Instalação e remoção em uma raiz de sistema (árvore 'root' ou imagem montada)
# -----------------------------------------------------------------------------
instalar_em() {
    local destino=$1
    mkdir -p "$destino/usr/bin" "$destino/usr/share/lecosfetch/logos" "$destino/etc"
    cp "$STAGE/lecosfetch" "$destino/usr/bin/lecosfetch"
    chmod +x "$destino/usr/bin/lecosfetch"
    cp "$STAGE"/logos/*.txt "$destino/usr/share/lecosfetch/logos/"
    if [ -e "$destino/etc/lecosfetch.conf" ]; then
        echo "      (configuração existente preservada)"
    else
        cp "$STAGE/lecosfetch.conf" "$destino/etc/lecosfetch.conf"
    fi
}

remover_de() {
    local destino=$1 logo
    rm -f "$destino/usr/bin/lecosfetch" "$destino/etc/lecosfetch.conf"
    for logo in "$STAGE"/logos/*.txt; do
        rm -f "$destino/usr/share/lecosfetch/logos/${logo##*/}"
    done
    rmdir "$destino/usr/share/lecosfetch/logos" "$destino/usr/share/lecosfetch" 2>/dev/null || true
}

executar() {
    if [ "$ACAO" = instalar ]; then instalar_em "$1"; else remover_de "$1"; fi
}

# -----------------------------------------------------------------------------
# Execução
# -----------------------------------------------------------------------------
[ -f "$IMG" ] || {
    echo "Erro: imagem '$IMG' não encontrada em $(pwd)."
    echo "Execute dentro do contêiner, no diretório /LOS (ou use o comando docker exec -w /LOS)."
    exit 1
}
if mountpoint -q "$MNT" 2>/dev/null; then
    echo "Erro: $MNT já está em uso. Desmonte-o antes (umount $MNT)."
    exit 1
fi

criar_arquivos

echo "[1/3] Árvore '$RAIZ'..."
executar "$RAIZ"

echo "[2/3] Montando a imagem..."
# (os comandos abaixo recebem </dev/null para não consumirem o script, que
# pode estar sendo lido pela entrada padrão com "bash -s")
[ -e /dev/loop0 ] || mknod /dev/loop0 b 7 0 </dev/null
DEV=$(losetup -fP --show "$IMG" </dev/null)
kpartx -av "$DEV" > /dev/null </dev/null
mount "/dev/mapper/$(basename "$DEV")p1" "$MNT" </dev/null

echo "[3/3] Imagem..."
executar "$MNT"

echo
if [ "$ACAO" = instalar ]; then
    echo "lecosfetch instalado com sucesso!"
else
    echo "lecosfetch removido."
fi
echo "Próximo passo (no sistema principal):"
echo "  docker cp LecOS-dev:/LOS/$IMG ."
echo "  qemu-system-x86_64 $IMG"
[ "$ACAO" = instalar ] && echo "No LecOS, execute: lecosfetch   (opções: lecosfetch -h)"
exit 0
