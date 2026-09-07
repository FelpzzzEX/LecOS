# **Inicialização (Init)**

Chegamos, enfim, na parte principal do nosso framework: a inicialização do sistema. Nas etapas anteriores, nós preparamos o terreno para isso se tornar possível:

* Preparamos nosso ambiente de desenvolvimento
* Instalamos o bootloader (**GNU GRUB**)
* Inserimos o **Kernel Linux** em nossa imagem
* Realizamos uma inicialização de testes com o **initramfs**

Com isso, verificamos cada processo relacionado ao **boot** de um sistema operacional, desde a **BIOS/UEFI**, conceitos gerais de sistemas envolvidos no boot, até a inicialização de fato, que é o conteúdo/processo que estaremos vendo nessa etapa.

## **A inicialização**

Em sistemas operacionais baseados em Unix, init (initialization) é o primeiro processo iniciado durante a inicialização do sistema, sendo um processo que continua a ser executado até o sistema ser desligado. Ele é o ancestral direto ou indireto de todos os outros processos que se iniciam após a inicialização do sistema, adotando automaticamente todos os processos órfãos. 

O init é iniciado pelo kernel usando um nome de arquivo codificado de forma rígida. Uma pane do kernel ocorrerá se o mesmo estiver impossibilitado de iniciar (os conhecidos **kernel panic**). Normalmente, o identificador de processo 1 é atribuído ao init (**PID 1**).

> Os processos serão aprofundados no próximo módulo.

## **O arquivo init**

a

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

## **Compilando os componentes**

a

## **O arquivo de inicialização**

a

## **O boot definitivo**

a

## **Próximos passos**

Parabéns por ter chegado até aqui, já estamos na metade do conteúdo apresentado pelo framework. Todo o caminho percorrido resultou em um sistema minimalista e funcional utilizando de componentes fundamentais de uma distribuição GNU/Linux. No entanto, embora tenhamos o nosso sistema "completo", ainda há mais conteúdos e componentes a serem abordados, desde a questão de processos, entrada e saída de dados e até mesmo a interface gráfica, onde estaremos repassando suas filosofias e funcionamento, além de visualizarmos na prática seus casos de uso.

Como sempre, um excelente trabalho até aqui, continue neste ritmo pois estamos chegando lá! Nos vemos no próximo módulo, onde enfim entraremos na parte relacionada aos processos de um sistema operacional e como funcionam e são gerenciados. Até breve!