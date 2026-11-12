# **Inicialização (Init)**

Chegamos, enfim, à parte principal do nosso framework: a inicialização do sistema. Nas etapas anteriores, nós preparamos o terreno para que isso se tornasse possível:

* Preparamos nosso ambiente de desenvolvimento
* Instalamos o bootloader (**GNU GRUB**)
* Inserimos o **Kernel Linux** em nossa imagem
* Realizamos uma inicialização de testes com o **initramfs**

Com isso, verificamos cada processo relacionado ao **boot** de um sistema operacional, desde a **BIOS/UEFI**, passando por conceitos gerais envolvidos no boot, até a inicialização de fato, que é o processo que veremos nesta etapa.

## **A inicialização**

Em sistemas operacionais baseados em Unix, `init` (initialization) é o primeiro processo iniciado durante a inicialização do sistema, continuando a ser executado até o sistema ser desligado. Ele é o ancestral direto ou indireto de todos os outros processos que se iniciam após a inicialização do sistema, adotando automaticamente todos os processos órfãos.

O init é iniciado pelo kernel usando um nome de arquivo definido de forma rígida. Ocorrerá uma pane do kernel caso ele esteja impossibilitado de iniciar o processo init (o conhecido **kernel panic**). Normalmente, o identificador de processo 1 é atribuído ao init (**PID 1**).

> Os processos serão aprofundados no próximo módulo.

## **O arquivo init**

O processo de inicialização, como visto durante o boot utilizando o **initramfs**, necessita de um arquivo para inicializar os componentes essenciais do sistema. Com isso, para continuarmos a construção, inseriremos em nosso sistema o arquivo `init`, um script que será iniciado pelo kernel durante a inicialização, permitindo que o sistema monte os sistemas de arquivos virtuais necessários e, posteriormente, disponibilize um shell para interação com o usuário.

Para isso, o script já está pronto no diretório `Componentes_Principais` do nosso repositório, visando facilitar o processo em geral. No entanto, repassaremos o conteúdo dele logo abaixo — não copie o código a seguir, será apenas para visualizarmos.

```
#!/bin/bash

mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

while true; do
    /bin/bash
done
```

* **#!/bin/bash**: indica que o script deverá ser interpretado pelo **Bash**, utilizando o executável localizado em `/bin/bash`
* **mount -t proc proc /proc**: monta o sistema de arquivos virtual **proc** no diretório `/proc`. Esse sistema de arquivos fornece informações sobre os processos e outros recursos do kernel
* **mount -t sysfs sysfs /sys**: monta o sistema de arquivos virtual **sysfs** no diretório `/sys`, disponibilizando informações sobre dispositivos, drivers e outros componentes gerenciados pelo kernel
* **mount -t devtmpfs devtmpfs /dev**: monta o sistema de arquivos virtual **devtmpfs** no diretório `/dev`, onde o kernel disponibiliza os arquivos de dispositivo
* **while true; do /bin/bash; done**: cria um laço que inicia o **Bash** como um processo filho do `init`. Caso o Bash seja encerrado com `exit`, o laço inicia um novo shell, mantendo o `PID 1` em execução

> É importante que o processo **init** permaneça em execução durante o funcionamento do sistema. Como ele ocupa o **PID 1**, encerrá-lo significa que o kernel ficará sem seu processo de inicialização.

Com isso, copiaremos o script para dentro do nosso ambiente de desenvolvimento através do comando `docker cp`, indicando o caminho onde ele será instalado. Em nosso sistema principal, inserimos:

```bash
# Entra no diretório 'Componentes_Principais'
cd Componentes_Principais

# Copia o arquivo 'init' para dentro do container
docker cp init LecOS-dev:/LOS/root/sbin 
```

<div align="center">

![copiadocker](https://github.com/FelpzzzEX/Imagens/blob/9db97f9242f5ae12cf28aa4c038b542d92b70751/init.png)

</div>

> Imagem 1: Copiando o script de inicialização para `/LOS/root/sbin`.

Com isso, nosso script de inicialização estará pronto para ser utilizado no diretório `root/sbin`, permitindo que o kernel Linux localize e execute o arquivo. No entanto, para isso ser possível, precisamos dar a permissão de execução ao script, utilizando mais uma vez o comando `chmod +x`, agora dentro do container, no diretório `/LOS`:

```bash
# Fornece a permissão de execução para o script 'init'
chmod +x root/sbin/init
```

> Quando nenhum outro `init` é especificado, o kernel procura o processo de inicialização em `/sbin/init`, `/etc/init` e `/bin/init` (e, como último recurso, `/bin/sh`), desde que o arquivo seja executável. O `/sbin/init` é o local tradicional para o processo de inicialização.

<div align="center">

![chmod](https://github.com/FelpzzzEX/Imagens/blob/9db97f9242f5ae12cf28aa4c038b542d92b70751/init2.png)

</div>

> Imagem 2: Fornecendo a permissão de execução para o script de inicialização.

## **Removendo o initramfs**

Preparando-nos para a inicialização real do sistema, iremos primeiro preparar a nossa imagem para receber todos os arquivos necessários. Para isso, inicialmente, removeremos o `initramfs` que criamos na etapa anterior, uma vez que ele já não é necessário em nosso processo, visto que sua finalidade foi somente verificar a volatilidade da memória RAM.

Em nosso ambiente de desenvolvimento, dentro do diretório `/LOS`, montaremos mais uma vez nossa imagem em `/mnt` para manipularmos seu conteúdo:

```bash
# Montamos novamente a imagem em /mnt
mknod /dev/loop0 b 7 0
losetup -fP --show lecos.img
kpartx -av /dev/loop0
mount /dev/mapper/loop0p1 /mnt
```

Em sequência, verificando o conteúdo presente em `/mnt/boot/` utilizando o comando `ls` (**list**), podemos conferir a presença do kernel Linux (**bzImage**), do diretório do GNU GRUB e do nosso `initramfs.cpio.gz`. Removeremos somente este último, deixando nossa imagem livre para configurarmos o arquivo de inicialização real posteriormente. Para realizar a remoção, utilizaremos mais uma vez o comando `rm` (**remove**), consistindo em `rm [CAMINHO-ARQUIVO]`:

```bash
# Remove 'initramfs.cpio.gz' da imagem
rm /mnt/boot/initramfs.cpio.gz

# Adicionalmente, removemos do nosso diretório raiz 
rm initramfs.cpio.gz
```

E, finalizando as correções, removeremos a linha do nosso arquivo `grub.cfg` que cita diretamente o initramfs, agora removido:

```nano
menuentry 'LecOS' {
      set root='(hd0,1)'
      linux /boot/bzImage root=/dev/sda1 rw
      initrd /boot/initramfs.cpio.gz <-- Linha a ser removida
}
```

Feitas as alterações, basta salvar o arquivo e fechar o editor (`Ctrl` + `O`, `Enter` para confirmar e `Ctrl` + `X`, respectivamente), deixando assim nossa imagem pronta para receber os componentes restantes que irão compor o nosso sistema.

<div align="center">

![reminitram](https://github.com/FelpzzzEX/Imagens/blob/9db97f9242f5ae12cf28aa4c038b542d92b70751/rminitfs.png)

</div>

> Imagem 3: Removendo o initramfs do nosso ambiente e da imagem bootável.

## **Compilando os componentes finais**

Com o terreno preparado, inseriremos os últimos componentes necessários em nosso sistema, permitindo sua utilização de forma mais prática e eficiente e tornando a experiência mais completa para o usuário. O processo será similar ao que vimos anteriormente, restando três componentes para finalizarmos a construção base do nosso sistema operacional, sendo eles o `GNU Coreutils`, o `GNU Nano` e o `Util-Linux`. 

Abaixo, realizaremos o passo a passo para a instalação enquanto conhecemos mais sobre esses componentes e suas utilidades em ambientes GNU/Linux.

### **GNU Coreutils**

O GNU Coreutils é um componente bastante consolidado nos sistemas operacionais GNU/Linux, uma vez que ele se tornou o padrão de diversas distribuições por fornecer os comandos utilitários para se interagir e realizar as tarefas básicas do sistema, podendo-se citar:

* **ls (list)**: Lista os diretórios e arquivos existentes
* **cp (copy)**: Copia arquivos e diretórios
* **mkdir (make directory)**: Cria um diretório novo
* **rm (remove)**: Remove um arquivo

Para instalarmos o componente em nosso sistema, utilizaremos o script presente no diretório `Componentes/scripts/`, sendo ele o `coreutils-build.sh`. Com isso em mente, primeiro precisamos fornecer a permissão de execução ao script, utilizando novamente o comando `chmod +x`, seguido da execução do script.

```bash
# Dentro de 'scripts', fornece a permissão de execução para o script 
chmod +x coreutils-build.sh

# Executa o script
./coreutils-build.sh
```

<div align="center">

![coreutil](https://github.com/FelpzzzEX/Imagens/blob/9db97f9242f5ae12cf28aa4c038b542d92b70751/coreutils.png)

</div>

> Imagem 4: Instalando o tarball do GNU Coreutils.

Com isso, conseguimos instalar com sucesso o GNU Coreutils em nosso sistema, encaminhando-nos para o próximo componente, o **GNU Nano**.

### **GNU Nano**

O GNU Nano é um editor de texto bastante utilizado em distribuições GNU/Linux, sendo um dos mais conhecidos e populares entre os usuários pela sua praticidade de uso. Ele é, inclusive, o editor que utilizamos durante o nosso framework, possuindo uma curva de aprendizado bem menor se comparado a outras alternativas mais robustas, como `Vim`, `Neovim`, `GNU Emacs`, etc.

Para instalar o Nano em nosso sistema, realizaremos o mesmo processo anterior, fornecendo a permissão de execução para o script de build e, logo em seguida, executando-o:

```bash
# Fornece a permissão de execução 
chmod +x nano-build.sh

# Executa o script
./nano-build.sh
```

<div align="center">

![nanoi](https://github.com/FelpzzzEX/Imagens/blob/9db97f9242f5ae12cf28aa4c038b542d92b70751/nano.png)

</div>

> Imagem 5: Instalando o tarball do GNU Nano.

Tendo o GNU Nano instalado, podemos partir para o último componente, o **Util-Linux**.

### **Util-Linux**

O Util-Linux é um conjunto de utilitários dedicado a funções específicas do kernel Linux, sendo um dos poucos componentes utilizados que não fazem parte do Projeto GNU. Com este componente instalado, somos capazes de realizar funções e executar comandos relacionados ao gerenciamento de discos do sistema, como o comando `fdisk`, que particiona um arquivo de disco/imagem.

Assim como os componentes anteriores, realizaremos a instalação através do script de build, sendo necessário fornecer, novamente, a permissão de execução:

```bash
# Fornece a permissão de execução ao script 
chmod +x uLinux-build.sh

# Executa o script de build 
./uLinux-build.sh
```

<div align="center">

![ulinuki](https://github.com/FelpzzzEX/Imagens/blob/9db97f9242f5ae12cf28aa4c038b542d92b70751/ulinux.png)

</div>

> Imagem 6: Instalando o tarball do Util-Linux.

Com isso, teremos enfim todos os componentes necessários para iniciar o nosso ambiente completo, partindo então para o boot definitivo do nosso sistema operacional!

## **O boot definitivo**

Seguindo para a etapa final da construção da base do nosso sistema, agora que temos todos os componentes instalados, podemos enfim preparar a nossa imagem bootável. Para isso, copiaremos **todo** o conteúdo do diretório `root` para dentro da imagem, até então montada em `/mnt`, consolidando assim a sua estrutura.

Ainda dentro do nosso ambiente de desenvolvimento, no diretório principal (**LOS**), utilizaremos o seguinte comando para copiar o conteúdo para dentro da nossa imagem bootável:

```bash
# Copia o conteúdo de 'root' para '/mnt'
cp -R root/* /mnt
```

Com isso, basta sincronizarmos as alterações e, por fim, desmontar a imagem e remover o loop device, deixando assim a nossa imagem pronta para utilizar:

```bash
# Sincronize as alterações
sync

# Desmonta 'lecos.img' de '/mnt' e remove o loop device
umount /mnt
kpartx -d /dev/loop0
losetup -d /dev/loop0
```

Então, com tudo feito, passaremos para o nosso sistema principal, onde copiaremos a imagem de dentro do container para fora utilizando o `docker cp`:

```bash
# Copia 'lecos.img' para o diretório atual
docker cp [ID_CONTAINER]:/LOS/lecos.img .
```

Após a cópia ser concluída, basta realizarmos o boot através do `QEMU` mais uma vez, inserindo o seguinte comando no terminal:

```bash
# Realiza o boot no QEMU
qemu-system-x86_64 lecos.img 
```

E, depois de uma bela jornada, temos enfim o nosso sistema operacional rodando completamente! Dessa vez, sem o initramfs na memória RAM, tudo é feito através do disco virtual criado na imagem, garantindo que quaisquer modificações e alterações feitas dentro do sistema sejam gravadas e mantidas, independentemente de reiniciarmos o ambiente (vá, faça o teste!). Com isso, temos a base completa do nosso trabalho, com todos os componentes funcionando e interagindo com o sistema de forma esperada. É uma base sólida para o que trabalharemos a seguir!

<div align="center">

![lecoscomplete](https://github.com/FelpzzzEX/Imagens/blob/aacd9869f39ec8c1e5d47626ae1b6feb9ac1c0b5/Etapa5-framework/Captura%20de%20tela_2026-09-11_20-12-10.png)

</div>

> Imagem 7: Interagindo com o sistema operacional após o boot.

<div align="center">

![lecoscompletereboot](https://github.com/FelpzzzEX/Imagens/blob/aacd9869f39ec8c1e5d47626ae1b6feb9ac1c0b5/Etapa5-framework/Captura%20de%20tela_2026-09-11_20-14-19.png)

</div>

> Imagem 8: Persistência dos dados e alterações após o reboot do sistema.

## **Próximos passos**

Parabéns por ter chegado até aqui, já estamos na metade do conteúdo apresentado pelo framework. Todo o caminho percorrido resultou em um sistema minimalista e funcional, utilizando componentes fundamentais de uma distribuição GNU/Linux. No entanto, embora o nosso sistema pareça "completo", ele ainda é somente a base, existindo mais conteúdos e componentes a serem abordados, desde a questão de processos e de entrada e saída de dados até mesmo a interface gráfica, onde repassaremos suas filosofias e funcionamento, além de visualizarmos na prática seus casos de uso.

Como sempre, um excelente trabalho até aqui. Continue neste ritmo, pois estamos chegando lá! Nos vemos no próximo módulo, onde enfim entraremos na parte relacionada aos processos de um sistema operacional e a como eles funcionam e são gerenciados. Até breve!