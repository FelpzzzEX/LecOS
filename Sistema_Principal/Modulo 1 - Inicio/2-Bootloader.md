# **Bootloader**

Tendo o ambiente inicializado, podemos enfim começar o nosso projeto. Nesta etapa, após o `BIOS e UEFI` "acordarem" o hardware, eles passam a responsabilidade para o `bootloader`, que será responsável por iniciar os componentes do sistema em si, carregando o `kernel` e o `initrd/initramfs`, começando o processo de inicialização e montando o sistema de arquivos virtual, parte que será utilizada pelo kernel ao iniciar o ambiente de fato.

---

## **Componente utilizado**

Neste sistema, utilizaremos o `GNU GRUB` como bootloader, um componente do ecossistema GNU e o principal bootloader das distribuições Linux modernas, sendo uma solução robusta e prática para a inicialização.

<div align="center">

![GRUB](https://github.com/FelpzzzEX/Imagens/blob/87d45fbacc2c1b3f60fa7200abb5969e12a9037a/Captura_de_tela_20260624_021346.png)

</div>

>Imagem 1: Tela inicial do GNU GRUB, onde o usuário é capaz de escolher qual sistema deseja acessar.

Ele foi selecionado pela proximidade com o ambiente real de desenvolvimento de distribuições modernas. O `Syslinux` utilizado na base inicial, apesar de funcional e bastante leve, é mais utilizado em **sistemas embarcados**, mídias de instalação e distribuições voltadas ao minimalismo. Já o `GNU GRUB` oferece suporte unificado aos modos `BIOS e UEFI`, maior flexibilidade na manipulação de kernels e initramfs, além de recursos avançados de inicialização. Dessa forma, sua utilização torna o sistema construído mais próximo das soluções adotadas em distribuições Linux de propósito geral, permitindo explorar mecanismos de inicialização encontrados em ambientes reais de produção.

---

## **Montando o disco**

Antes de, de fato, partirmos para o bootloader, precisamos montar nosso arquivo de disco. Se recordarmos o tutorial passado, em nossa **base inicial**, ao criarmos o arquivo de `boot`, utilizamos o seguinte comando:

```bash
# Não execute!
dd if=/dev/zero of=boot bs=1M count=50
```

Nesta etapa, faremos algo parecido novamente, pois será a nossa imagem _"bootável"_, arquivo que nos permitirá inicializar o sistema em uma máquina virtual. Vale ressaltar que a imagem será significativamente maior do que a que geramos anteriormente, dada a natureza dos componentes utilizados neste ambiente.

Para iniciarmos, executaremos o seguinte comando estando **dentro** do container:

```bash
# Devido ao tamanho, pode levar alguns segundos para executar
dd if=/dev/zero of=lecos.img bs=1M count=10240
```

Com este comando, criaremos um arquivo de 10GB denominado `lecos.img`, que será utilizado para dar início ao nosso sistema.

>Para saber se está dentro do container e no diretório correto, basta verificar se o seu terminal apresenta algo parecido com `root@a75d5a072e7a:/LOS#`, sendo `root` o usuário atual, `a75d5a072e7a` o ID do container e, por fim, `/LOS` o diretório onde montaremos o sistema e rodaremos todos os comandos.
>>Tenha certeza de estar sempre nesse diretório antes de rodar qualquer script ou criar quaisquer arquivos.

Em seguida, tendo a nossa imagem "bootável" criada, vamos particioná-la para criarmos a partição interna, o que nos possibilitará instalar o bootloader que irá carregar os componentes. Para isso, rodaremos o seguinte comando:

```bash 
# fdisk é o utilitário que utilizamos para criar e modificar tabelas de partições
fdisk lecos.img
``` 

Este comando abrirá uma série de opções no terminal, onde será informado que uma nova tabela de partições do tipo `DOS` (MBR, utilizada pela BIOS) foi criada. A partir disso, criaremos as partições de fato. No terminal, você verá uma mensagem parecida com esta:

```bash
Device does not contain a recognized partition table.
Created a new DOS (MBR) disklabel with disk identifier 0x85b40d4d.

Command (m for help):
```

Essa é a parte de configuração da partição no fdisk, onde inseriremos os seguintes comandos para montarmos nosso arquivo, sendo eles:

* **n** - Ao inserirmos `n`, indicamos a criação de uma nova partição no arquivo, preparando-o para as próximas etapas;
* **p** - A diretriz `p` indica que a partição criada será primária;
* **1** - Indica que será a partição número 1;
* **[Enter]** - Define o primeiro setor da partição. Para isso, utilizaremos o padrão fornecido, então basta pressionarmos `Enter` para prosseguir;
* **[Enter]** - Define o último setor. Assim como na etapa anterior, pressionaremos `Enter` novamente, levando o sistema a utilizar o restante do espaço presente no arquivo;
* **w** - Por fim, inserimos a diretriz `w`, que salvará nossas escolhas e as gravará em nosso arquivo.

<div align="center">

![Fdisk](https://github.com/FelpzzzEX/Imagens/blob/7dc7f6bb0b48e5216cd383c9857f07f739035ee8/Captura_de_tela_20260703_213323.png)

</div>

>Imagem 2: Sequência de comandos do utilitário `fdisk`, executado no arquivo `lecos.img`.

Com todo o processo finalizado, podemos enfim prosseguir com a geração do nosso arquivo bootável. A partir daqui, utilizaremos o formato `ext4`. Para isso, precisaremos criar nosso "pendrive virtual", como vimos durante o processo da `base inicial`.

```bash
# Comando para criar o loop device
mknod /dev/loop0 b 7 0
```

Dispositivo de loop criado, seguiremos para o processo de montagem, onde pegaremos nosso arquivo de imagem `lecos.img` e, utilizando o loop device criado anteriormente, permitiremos a utilização do mesmo. Para isso, utilizaremos o seguinte comando:

```bash
# Permite que o kernel compreenda e manipule o arquivo .img
losetup -fP --show lecos.img
```

Onde:

* **losetup**: Configura um dispositivo de loop (cria um "HD falso" a partir de um arquivo);
* **-f (Find)**: Encontra automaticamente o primeiro /dev/loop livre (geralmente o loop0);
* **-P (Partscan)**: Força o kernel a ler a tabela de partições (criadas no fdisk) e tentar criar os nós das partições;
* **--show**: Imprime na tela qual dispositivo foi usado (ex: /dev/loop0).

Com isso, dentro do loop device, a partição indicada é criada, gerando assim `/dev/loop0p1`, onde p1 indica a partição criada, que configuramos anteriormente como a primeira do arquivo. No entanto, mesmo que a partição seja criada, a arquitetura do `Docker` pode acabar conflitando com o sistema, fazendo com que o container não a enxergue ou que o acesso ao dispositivo seja travado.

Para resolver isso, utilizaremos o `kpartx`, utilitário que lê o `loop device` e cria dispositivos virtuais, permitindo o acesso às partições criadas, que ficam em `/dev/mapper/`. Para realizar essa tarefa, rodamos o seguinte comando:

```bash
# Gera o dispositivo virtual contendo a partição de loop0 
kpartx -av /dev/loop0
```

Com a partição mapeada, podemos enfim formatá-la no formato `ext4`, obtendo de vez uma imagem capaz de bootar o nosso sistema. Para isso, executamos o comando a seguir, que simplesmente aplica o formato `ext4` à nossa partição criada, que fica em `/dev/mapper/loop0p1`:

```bash
# Formatando a partição 1 no formato ext4 
mkfs.ext4 /dev/mapper/loop0p1
```

Feito isso, nosso arquivo bootável está, enfim, pronto para receber os arquivos que iremos compilar e montar. Para sermos capazes disso, assim como na `base inicial`, precisamos "plugar" esse arquivo em um diretório, sendo esse o `/mnt`, um diretório dedicado à montagem temporária de sistemas de arquivos, utilizado para que possamos manipular o conteúdo presente no arquivo. Faremos essa etapa com o seguinte comando:

```bash
# Montamos a partição 1 do loop device em '/mnt'
mount /dev/mapper/loop0p1 /mnt
```

Seguimos a mesma lógica que vimos anteriormente: ao montar o `loop0p1` em `/mnt`, passamos a ter acesso aos seus arquivos, além de podermos remover e, no nosso caso, adicionar novos arquivos dentro dele, uma vez que não somos capazes de editar o conteúdo de `lecos.img` diretamente, sendo necessária a montagem em um diretório para realizarmos tal tarefa.

<div align="center">

| Diretório\Estado | Conteúdo |
| :--: | :--: |
| /mnt (desmontado) | -vazio- |
| /mnt (loop0p1 montado) | lost+found |

</div>

>Tabela 1: Representação do processo de montagem de um arquivo em um diretório. O `lost+found` é o diretório contendo arquivos recuperados após erros ou corrupções no sistema de arquivos.

Após essa etapa, podemos enfim instalar o `GRUB` em nossa imagem. Para isso, utilizaremos o comando a seguir, onde a instalação será feita diretamente em `/mnt`, uma vez que é onde `/dev/mapper/loop0p1` está montada e permite adições:

```bash
# Criamos o diretório 'boot', onde a configuração do GRUB será feita
mkdir /mnt/boot 

# Comando para instalar o GRUB
grub-install --target=i386-pc --root-directory=/mnt --no-floppy --modules="normal part_msdos ext2 multiboot" /dev/loop0
```

Onde, detalhando as diretrizes:

* **--target=i386-pc**: Define a arquitetura alvo -- i386-pc instrui o GRUB a instalar um bootloader clássico para BIOS usando MBR;
* **--root-directory=/mnt**: Diz ao instalador onde a pasta /boot/grub do seu sistema operacional deve ser criada;
* **--no-floppy**: Flag que impede o GRUB de procurar drives de disquete no seu sistema, pois isso pode causar travamentos ou erros em ambientes virtualizados;
* **--modules**: Força o GRUB a embutir módulos específicos diretamente na imagem principal, garantindo que consiga ler o disco antes mesmo de o kernel carregar:
  * **normal**: Modo de operação padrão do GRUB;
  * **part_msdos**: Ensina o GRUB a ler tabelas de partição MBR;
  * **ext2**: Ensina o GRUB a ler sistemas de arquivos da família ext, incluindo o ext4;
  * **multiboot**: Suporte para carregar kernels compatíveis com a especificação Multiboot;
* **/dev/loop0**: O alvo final. O estágio 1 do GRUB é gravado nos primeiros 512 bytes do HD inteiro (o MBR), por isso apontamos para o dispositivo raiz.

Com o GRUB instalado em nossa imagem bootável, podemos iniciar a configuração dele, que é feita através de um arquivo de configuração, de modo bastante intuitivo. Iniciamos através do seguinte comando:

```bash
# Cria o arquivo de configuração do GRUB
nano /mnt/boot/grub/grub.cfg
```

E inserimos o seguinte texto:

```nano
menuentry '[NOME-DO-SISTEMA]' {
        set root='(hd0,1)'
        linux /boot/bzImage root=/dev/sda1 rw
}
```

Este arquivo, basicamente, define o "título" da opção que irá aparecer no GRUB (em nosso caso, `LecOS`) enquanto define as variáveis necessárias:

* **set root**: Define, para o GRUB, a partição raiz de onde os arquivos serão carregados, no caso, a partição de nossa imagem `lecos.img`;
  * **hd0,1**: Indica o primeiro disco encontrado (`hd0`) e, dentro dele, a primeira partição;
* **linux /boot/bzImage**: Fornece o caminho para que o GRUB possa acessar e carregar o kernel Linux;
* **root=/dev/sda1 rw**: Define, para o kernel Linux, a partição que será utilizada como sistema de arquivos raiz;
  * **rw**: Garante permissões de `leitura e escrita` para a partição /dev/sda1.

Com o arquivo escrito, podemos sair do `Nano` (o editor de texto que estamos utilizando): basta pressionarmos `Ctrl + O` (e `Enter` para confirmar) para salvar e `Ctrl + X` para sair, concluindo assim nosso arquivo de configuração e permitindo o boot inicial do GRUB.

Após isso, sincronizaremos as configurações feitas para garantir sua aplicação antes de iniciarmos o ambiente. Para isso, rodaremos algumas vezes o comando `sync`:

```bash
# Repita o comando algumas vezes para garantir que nosso trabalho será salvo
sync
```

É uma medida simples, mas serve para garantir que nossa imagem execute sem maiores problemas. Após essa etapa, podemos enfim desmontar nosso arquivo do diretório `/mnt`, pois nosso trabalho com ele já foi concluído.

```bash
# Desmontar o arquivo do diretório /mnt e remoção do loop device
umount /mnt
kpartx -d /dev/loop0
losetup -d /dev/loop0
```

Com isso, nossa imagem bootável está pronta para ser utilizada, contendo nosso `bootloader` instalado e devidamente configurada. Agora, para podermos realizar o boot em uma máquina virtual, copiaremos o arquivo `lecos.img` para o nosso sistema principal (fora do container) através do comando `docker cp` que vimos anteriormente:

```bash
# Copia 'lecos.img' para o diretório atual do usuário
docker cp [CONTAINER ID]:/LOS/lecos.img .
```

Após realizarmos a cópia, executaremos a imagem com o sistema `QEMU`, permitindo o boot em um ambiente virtual sem grandes problemas, bastando rodar o seguinte comando em nosso sistema principal:

```bash
# Utilizamos o QEMU para bootar a imagem
qemu-system-x86_64 lecos.img
```

Após executarmos, veremos a tela inicial do GRUB (Imagem 1), onde aparecerão as opções de boot para iniciarmos -- em nosso caso, somente o nome de nosso sistema (no caso deste tutorial, será `LecOS`). Ao selecionarmos, seremos recebidos por uma mensagem de erro, uma vez que, embora o boot tenha sido realizado, a imagem ainda está "crua", não possuindo utilitários, programas ou mesmo o kernel Linux, o que impede qualquer inicialização de acontecer.

Na próxima etapa, iremos nos aprofundar mais no processo de boot, iniciando pelo kernel e sua responsabilidade no sistema operacional, além de inserir o componente em nossa imagem bootável para continuarmos nosso trajeto até o sistema principal. Após isso, entraremos no conteúdo relacionado à memória primária e secundária do sistema até chegarmos, enfim, à inicialização de fato, onde teremos percorrido metade do processo. Nos vemos lá!