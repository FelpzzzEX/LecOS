# **Inicialização (Init)**

Chegamos, enfim, à parte principal do nosso framework: a inicialização do sistema. Nas etapas anteriores, nós preparamos o terreno para que isso se tornasse possível:

* Preparamos nosso ambiente de desenvolvimento
* Instalamos o bootloader (**GNU GRUB**)
* Inserimos o **Kernel Linux** em nossa imagem
* Realizamos uma inicialização de testes com o **initramfs**

Com isso, verificamos cada processo relacionado ao **boot** de um sistema operacional, desde a **BIOS/UEFI**, passando por conceitos gerais envolvidos no boot, até a inicialização de fato, que é o conteúdo/processo que estaremos vendo nesta etapa.

## **A inicialização**

Em sistemas operacionais baseados em Unix, `init` (initialization) é o primeiro processo iniciado durante a inicialização do sistema, sendo um processo que continua a ser executado até o sistema ser desligado. Ele é o ancestral direto ou indireto de todos os outros processos que se iniciam após a inicialização do sistema, adotando automaticamente todos os processos órfãos.

O init é iniciado pelo kernel usando um nome de arquivo definido de forma rígida. Uma pane do kernel ocorrerá se o mesmo estiver impossibilitado de iniciar o processo init (o conhecido **kernel panic**). Normalmente, o identificador de processo 1 é atribuído ao init (**PID 1**).

> Os processos serão aprofundados no próximo módulo.

## **O arquivo init**

O processo de inicialização, como visto durante o boot utilizando o **initramfs**, necessita de um arquivo para inicializar os componentes essenciais do sistema. Com isso, para continuarmos a construção, estaremos inserindo em nosso sistema o arquivo `init`, sendo este um script que será iniciado pelo kernel durante a inicialização, permitindo que o sistema monte os sistemas de arquivos virtuais necessários e, posteriormente, disponibilize um shell para interação com o usuário.

Para isso, o script já está pronto no diretório `Componentes_Principais` do nosso repositório, visando facilitar o processo em geral. No entanto, iremos repassar o conteúdo dele logo abaixo — não copie o código a seguir, será apenas para visualizarmos.

```
#!/bin/bash

mount -t proc proc /proc
mount -t sysfs sysfs /sys

while true; do
    /bin/bash
done
```

* **#!/bin/bash**: indica que o script deverá ser interpretado pelo **Bash**, utilizando o executável localizado em `/bin/bash`
* **mount -t proc proc /proc**: monta o sistema de arquivos virtual **proc** no diretório `/proc`. Esse sistema de arquivos fornece informações sobre os processos e outros recursos do kernel
* **mount -t sysfs sysfs /sys**: monta o sistema de arquivos virtual **sysfs** no diretório `/sys`, disponibilizando informações sobre dispositivos, drivers e outros componentes gerenciados pelo kernel
* **while true; do /bin/bash; done**: cria um laço que inicia o **Bash** como um processo filho do `init`. Caso o Bash seja encerrado com `exit`, o laço inicia um novo shell, mantendo o `PID 1` em execução

> É importante que o processo **init** permaneça em execução durante o funcionamento do sistema. Como ele ocupa o **PID 1**, encerrá-lo significa que o kernel ficará sem seu processo de inicialização.

Com isso, estaremos copiando o script para dentro do nosso ambiente de desenvolvimento através do comando `docker cp`, indicando o caminho a ser instalado. Em nosso sistema principal, inserimos:

```bash
# Entra no diretório 'Componentes_Principais'
cd Componentes_Principais

# Copia o arquivo 'init' para dentro do contêiner
docker cp init LecOS-dev:/LOS/root/sbin 
```

Com isso, nosso script de inicialização estará pronto para ser utilizado no diretório `root/sbin`, permitindo que o kernel Linux localize e execute o arquivo. No entanto, para isso ser possível, precisamos dar a permissão de execução para o script, utilizando mais uma vez do comando `chmod +x`:

```bash
# Fornece a permissão de execução para o script 'init'
chmod +x root/sbin/init
```

> O arquivo `init` pode ser colocado em `/`, `/bin` ou `/sbin`, desde que seja executável. O `/sbin/init` é o local tradicional para o processo de inicialização, sendo um dos caminhos procurados pelo kernel quando nenhum outro `init` é especificado.

## **Removendo o initramfs**

Nos preparando para a inicialização real do sistema, iremos primeiramente preparar a nossa imagem para receber todos os arquivos necessários. Para isso, inicialmente, estaremos removendo o `initramfs` que criamos na etapa anterior, uma vez que ele já não é mais necessário em nosso processo, visto que sua finalidade foi somente para verificar a volatilidade da memória RAM.

Em nosso ambiente de desenvolvimento, dentro do diretório `/LOS`, iremos montar mais uma vez nossa imagem em `/mnt` para manipularmos seu conteúdo:

```bash
# Montamos novamente a imagem em /mnt
mknod /dev/loop0 b 7 0
losetup -fP --show lecos.img
kpartx -av /dev/loop0
mount /dev/mapper/loop0p1 /mnt
```

Em sequência, verificando o conteúdo presente em `/mnt/boot/` utilizando o comando `ls` (**list**), podemos conferir a presença do kernel Linux (**bzImage**), o diretório do GNU GRUB e nosso `initramfs.cpio.gz`. Estaremos removendo somente o último, deixando nossa imagem livre para configurarmos o arquivo de inicialização real posteriormente. Para realizar a remoção, utilizaremos mais uma vez o comando `rm` (**remove**), consistindo em `rm [CAMINHO-ARQUIVO]`:

```bash
# Remove 'initramfs.cpio.gz' da imagem
rm /mnt/boot/initramfs.cpio.gz

# Adicionalmente, removemos do nosso diretório raiz 
rm initramfs.cpio.gz
```

E finalizando as correções, iremos remover a sessão de nosso arquivo `grub.cfg` que cita diretamente o então removido initramfs:

```nano
menuentry 'LecOS' {
      set root='(hd0,1)'
      linux /boot/bzImage root=/dev/sda1 rw
      initrd /boot/initramfs.cpio.gz <-- Linha a ser removida
}
```

Feitas as alterações, basta salvar o arquivo e fechar o editor (`Ctrl` + `O` e `Ctrl` + `X`, respectivamente), deixando assim nossa imagem pronta para receber os componentes restantes que irão compor o nosso sistema.

<div align="center">

![reminitram]()

</div>

> Imagem 1: 

## **Compilando os componentes finais**

Com o terreno preparado, estaremos inserindo os últimos componentes necessários em nosso sistema, permitindo sua utilização de forma mais prática e eficiente, tornando a experiência mais completa para o usuário. O processo será similar ao que vimos anteriormente, restando três componentes para finalizarmos a construção base do nosso sistema operacional, sendo eles o `GNU Coreutils`, `GNU Nano` e `Util-Linux`. 

Abaixo, estaremos realizando o passo a passo para a instalação enquanto conhecemos mais sobre esses componentes e suas utilidades em ambientes GNU/Linux.

### **GNU Coreutils**

O GNU Coreutils é um componente bastante consolidado nos sistemas operacionais GNU/Linux, uma vez que ele se tornou o padrão de diversas distribuições por fornecer os comandos utilitários para se interagir e realizar as tarefas básicas do sistema, podendo citar:

* **ls (list)**: Lista os diretórios e arquivos existentes
* **cd (change directory)**: Muda para o diretório desejado
* **mkdir (make directory)**: Cria um diretório novo
* **rm (remove)**: Remove um arquivo

Para instalarmos o componente em nosso sistema, estaremos utilizando o script presente no diretório `Componentes/scripts/`, sendo ele o `coreutils-build.sh`. Com isso em mente, primeiro precisamos fornecer a permissão de execução ao script, utilizando novamente o comando `chmod +x` seguido da execução do script.

```bash
# Fornece a permissão de execução para o script 
chmod +x coreutils-build.sh

# Executa o script
./coreutils-build.sh
```

<div align="center">

![coreutil]()

</div>

> Imagem 2:

Com isso, conseguimos instalar com sucesso o GNU Coreutils em nosso sistema, encaminhando para o próximo componente, o **GNU Nano**.

### **GNU Nano**

O GNU Nano é um editor de texto bastante utilizado em distribuições GNU/Linux, sendo um dos mais conhecidos e populares entre os usuários pela sua praticidade de uso, sendo inclusive o editor que utilizamos durante o nosso framework, possuindo uma curva de aprendizado bem menor se comparado a outras alternativas mais robustas, como `Vim`, `Neo Vim`, `GNU Emacs`, etc.

Para instalar o Nano em nosso sistema, estaremos realizando o mesmo processo anterior, fornecendo a permissão de execução para o script de build e, logo em seguida, o executando:

```bash
# Fornece a permissão de execução 
chmod +x nano-build.sh

# Executa o script
./nano-build.sh
```

<div align="center">

![nanoi]()

</div>

> Imagem 3:

Tendo o GNU Nano instalado, podemos partir para o então útimo componente, o **Util-Linux**.

### **Util-Linux**

O Util-Linux é um utilitário dedicado a funções específicas do kernel Linux, sendo um dos poucos componentes utilizados que não faz parte do Projeto GNU. Com este componente instalado, somos capazes de realizar funções e executar comandos realizados ao gerenciamento de discos do sistema, como o comando `fdisk` que formata um arquivo de disco/imagem.

Assim como os componentes anteriores, iremos realizar a instalação através do script de build, sendo necessário fornecer, novamente, a permissão de execução:

```bash
# Fornece a permissão de execução ao script 
chmod +x uLinux-build.sh

# Executa o script de build 
./uLinux-build.sh
```

Com isso, teremos enfim todos os componentes necessários para iniciar o nosso ambiente completo, partindo então para o boot definitivo do nosso sistema operacional!

## **O boot definitivo**

Seguindo para a etapa final do nosso projeto, agora que temos todos os componentes instalados, podemos enfim preparar a nossa imagem bootável. Para isso, iremos copiar **todo** o conteúdo do diretório `root` para dentro da imagem, até então montada em `/mnt`, consolidando assim a sua estrutura.

Ainda dentro do nosso ambiente de desenvolvimento, utilizaremos o seguinte comando para copiar o conteúdo para dentro da nossa imagem bootável:

```bash
# Copia o conteúdo de 'root' para '/mnt'
cp -R root/* /mnt
```

Com isso, basta sincronizarmos as alterações e, por fim, desmontar o a imagem do loop device, deixando assim a nossa imagem pronta para utilizar:

```bash
# Sincronize as alterações
sync

# Desmonta 'lecos.img' de '/mnt' e remoção do loop device
umount /mnt
kpartx -d /dev/loop0
losetup -d /dev/loop0
```

Então, com tudo feito, passaremos para o nosso sistema principal, onde copiaremos a imagem de dentro do contêiner para fora utilizando o `docker cp`:

```bash
# Copia 'lecos.img' para o diretório atual
docker cp [ID_CONTAINER]:/LOS/lecos.img .
```

Após a cópia ser concluída, basta realizarmos o boot através do `QEMU` mais uma vez:

```bash
# Realiza o boot no QEMU
qemu-system-x84_86 lecos img 
```

E, depois de uma bela jornada, temos enfim, o nosso sistema operacional rodando completamente! Dessa vez, sem memória RAM, tudo através do disco virtual criado na imagem, garantindo que quaisquer modificações e alterações feitas dentro do sistema serão gravadas e mantidas, independente de reiniciarmos o ambiente (vá, faça o teste!). Com isso, temos a base completa do nosso trabalho, todos os componentes comunica

## **Próximos passos**

Parabéns por ter chegado até aqui, já estamos na metade do conteúdo apresentado pelo framework. Todo o caminho percorrido resultou em um sistema minimalista e funcional utilizando de componentes fundamentais de uma distribuição GNU/Linux. No entanto, embora o nosso sistema pareça "completo", ainda é somente a base dele, existindo mais conteúdos e componentes a serem abordados, desde a questão de processos, entrada e saída de dados e até mesmo a interface gráfica, onde estaremos repassando suas filosofias e funcionamento, além de visualizarmos na prática seus casos de uso.

Como sempre, um excelente trabalho até aqui, continue neste ritmo pois estamos chegando lá! Nos vemos no próximo módulo, onde enfim entraremos na parte relacionada aos processos de um sistema operacional e como funcionam e são gerenciados. Até breve!