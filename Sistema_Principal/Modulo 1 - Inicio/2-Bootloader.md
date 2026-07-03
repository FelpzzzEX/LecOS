# **Bootloader**

Tendo o ambiente inicializado, podemos enfim começar o nosso projeto. Nesta etapa, após o `BIOS e UEFI` "acordarem" o hardware, eles então passam a responsabilidade para o `bootloader`, cujo será responsável por iniciar componentes do sistema em si, carregando o `kernel` e o `initrd/initramfs`, começando o processo de inicialização e montando o sistema de arquivos virtual, parte essa que será utilizada pelo kernel ao iniciar o ambiente de fato.

---

## **Componente utilizado**

Neste sistema, estaremos utilizando o `GNU GRUB` como bootloader, sendo um componente do ecossistema GNU e principal bootloader utilizado em distribuições Linux modernas, sendo uma solução robusta e prática para a inicialização.

<div align="center">

![GRUB](https://github.com/FelpzzzEX/Imagens/blob/87d45fbacc2c1b3f60fa7200abb5969e12a9037a/Captura_de_tela_20260624_021346.png)

</div>

>Imagem 1: Tela inicial do GNU GRUB, onde o usuário é capaz de escolher qual sistema deseja acessar.

Ele foi selecionado pela aproximação do ambiente real de desenvolvimento de distribuições modernas. O `Syslinux` utilizado na base inicial, apesar de funcional e bastante leve, é mais utilizado em **sistemas embarcados**, mídias de instalação e distribuições voltadas ao minimalismo. Já o `GNU GRUB` oferece suporte unificado aos modos `BIOS e UEFI`, maior flexibilidade na manipulação de kernels e initramfs, além de recursos avançados de inicialização. Dessa forma, sua utilização torna o sistema construído mais próximo das soluções adotadas em distribuições Linux de propósito geral, permitindo explorar mecanismos de inicialização encontrados em ambientes reais de produção.

---

## **Montando o disco**

Antes de, de fato, partirmos para o bootloader, precisamos montar nosso arquivo de disco. Se recordarmos do tutorial passado, em nossa **base inicial**, ao criarmos o arquivo de `boot`, utilizamos o seguinte comando:

```bash
# Não execute!
dd if=/dev/zero of=boot bs=1M count=50
```

Nessa etapa, faremos algo parecido novamente, pois será a nossa imagem _"bootável"_, arquivo esse que irá nos permitir inicializar o sistema em uma máquina virtual. Vale ressaltar que a imagem será significativamente maior do que a que geramos anteriormente, dada a natureza dos componentes utilizados neste ambiente.

Para iniciarmos, executaremos o seguinte comando estando **dentro** do container:

```bash
# Devido ao tamanho, pode levar alguns segundos para executar
dd if=/dev/zero of=lecos.img bs=1M count=10240
```

Com este comando, estaremos criando um arquivo de 10GB denominado `lecos.img`, arquivo este que será utilizado para dar início ao nosso sistema.

>Para saber se está dentro do container e no diretório correto, basta verificar o seu terminal se apresentar algo parecido com `root@a75d5a072e7a:/LOS#`, sendo `root` o usuário atual e `a75d5a072e7a` o ID do container, por fim, `/LOS` é o diretório onde estaremos montando o sistema e rodando todos os comandos. 
>>Tenha certeza de estar sempre nesse diretório antes de rodar qualquer script ou criar quaisquer arquivos.

Em seguida, tendo a nossa imagem "bootável" criada, estaremos formatando ela para criarmos a partição interna, nos possibilitando instalar o bootloader que irá carregar os componentes. Para isso, rodaremos o seguinte comando:

```bash 
# fdisk é o utilitário que utilizamos para criar e modificar tabelas de partições
fdisk lecos.img
``` 

Este comando abrirá uma série de opções no terminal, onde será informado que uma nova tabela de partições do tipo `DOS` (MBR, utilizada BIOS) foi criada. A partir disso, estaremos criando as partições de fato. No terminal, você verá uma mensagem parecida com esta:

```bash
Device does not contain a recognized partition table.
Created a new DOS (MBR) disklabel with disk identifier 0x85b40d4d.

Command (m for help):
```

Essa é a parte de configuração da partição no fdisk, onde iremos inserir os seguintes comandos para estarmos montando nosso arquivo, sendo eles:

* **n** - Ao inserirmos `n`, estamos indicando a criação de uma nova partição no arquivo, preparando o mesmo para as próximas etapas;
* **p** - A diretriz `p` indica que a partição criada será primária;
* **1** - Indica que sera a partição número 1;
* **[Enter]** - Será o primeiro setor do nosso arquivo. Para isso, iremos utilizar o padrão fornecido, então basta pressionarmos `Enter` para prosseguir;
* **[Enter]** - O mesmo para a etapa anterior, pressionaremos `Enter` novamente, levando o sistema a utilizar o restante do espaço presente no arquivo;
* **w** - Por fim, inserimos a diretriz `w`, que irá salvar nossas escolhas e gravar em nosso arquivo.

Com todo o processo finalizado, podemos enfim prosseguir com a geração do nosso arquivo bootável. A partir daqui, estaremos utilizando o formato `ext4`, para isso, precisaremos criar nosso "pendrive virtual" como vimos durante o processo da `base inicial`.

```bash
# Comando para criar o loop device
mknod /dev/loop0 b 7 0
```

Dispositivo de loop criado, seguiremos para o processo de montagem, onde pegaremos nosso arquivo de imagem `lecos.img` e, utilizando o loop device criado anteriormente, permitiremos a utilização do mesmo. Para isso, utilizaremos o seguinte comando:

```bash
# Permite o kernel compreender e manipular o arquivo .img
losetup -fP --show lecos.img
```

Onde:

* **losetup**: Configura um dispositivo de loop (cria um "HD falso" a partir de um arquivo);
* **-f (Find)**:Encontra automaticamente o primeiro /dev/loop livre (geralmente o loop0);
* **-P (Partscan)**: Força o kernel a ler a tabela de partições (criadas no fdisk) e tentar criar os nós das partições;
* **--show**: Imprime na tela qual dispositivo foi usado (ex: /dev/loop0).

Com isso, dentro do loop device, a partição indicada é criada, gerando assim `/dev/loop0p1`, onde p1 indica a partição criada, cujo configuramos anteriormente como a primeira do arquivo. No entanto, mesmo que a partição seja criada, a arquitetura do `Docker` pode acabar conflitando com o sistema, fazendo com que o container não enxergue-a ou que o acesso ao dispositivo seja travado. Para resolver isso, utilizaremos o `kpartx`, utilitário que lê o `loop device` e cria dispositivos virtuais, permitindo o acesso às partições criadas, sendo armazenadas em `/dev/mapper/`. Para realizar essa tarefa, rodamos o seguinte comando:

```bash
# Gera o dispositivo virtual contendo a partição de loop0 
kpartx -av /dev/loop0
```

Com a partição montada, podemos enfim formatá-la no formato `ext4`, nos retornando de vez uma imagem capaz de bootar o nosso sistema. Para isso, executamos o comando a seguir, que simplesmente utiliza o formato `ext4` apontado para nossa partição criada, que fica em `/dev/mapper/loop0p1`:

```bash
# Formatando a partição 1 no formato ext4 
mkfs.ext4 /dev/mapper/loop0p1
```

Feito isso, nosso arquivo bootável está, enfim, pronto para receber os arquivos que iremos compilar e montar. Para sermos capazes disso, assim como na `base inicial`, precisamos "plugar" esse arquivo em um diretório, sendo esse o `/mnt`, um diretório dedicado a montagem temporária de sistemas de arquivos, sendo utilizado para que possamos manipular o conteudo presente no arquivo. Faremos essa etapa com o seguinte comando:

```bash
# Montamos a partição 1 do loop device em '/mnt'
mount /dev/mapper/loop0p1 /mnt
```

Seguindo a mesma lógica que vimos anteriormente, onde, ao montar o `loop0p1` em `/mnt`, podemos ter o acesso aos seus arquivos, além de podermos remover e, no nosso caso, adicionar dentro dele, uma vez que não somos capazes de editar o `lecos.img` presente nele, sendo necessário a montagem em um diretorio para que nos possibilite realizar tal tarefa.

| Diretório\Estado | Conteúdo |
| :--: | :--: |
| /mnt (desmontado) | -vazio- |
| /mnt (loop0p1 montado) | [inserir conteudo] |

>Tabela 1: Representação do processo de montagem de um arquivo em um diretorio.

Após essa etapa, podemos enfim instalar o `GRUB` em nossa partição, e para isso, utilizaremos o comando a seguir, onde a instalação será feita diretamente em `/mnt`, uma vez que é onde `/dev/mapper/loop0p1` esta presente e permite adições:

```bash
# Copiamos o diretorio 'boot', onde a configuração do GRUB será feita
cp -R /root/boot /mnt

# Comando para instalar o GRUB
grub-install --target=i386-pc --root-directory=/mnt --no-floppy --modules="normal part_msdos ext2 multiboot" /dev/loop0
```

Onde, detalhando as diretrizes:

* **--target=i386-pc**: Define a arquitetura alvo -- i386-pc instrui o GRUB a compilar e instalar um bootloader clássico para BIOS usando MBR;
* **--root-directory=/mnt**: Diz ao instalador onde a pasta /boot/grub do seu sistema operacional deve ser criada;
* **--no-floppy**: Flag que impede o GRUB de procurar drives de disquete no seu sistema, pois pode causar travamentos ou erros em ambientes virtualizados;
* **--modules**: Força o GRUB a embutir módulos específicos diretamente na imagem principal, garantindo que consiga ler o disco antes mesmo do kernel carregar:
  * **normal**: Modo de operação padrão do GRUB;
  * **part_msdos**: Ensina o GRUB a ler tabelas de partição MBR;
  * **ext2**: Ensina o GRUB a ler o sistema de arquivos ext4;
  * **multiboot**: Suporte para carregar kernels compatíveis com a especificação Multiboot;
* **/dev/loop0**: O alvo final. O estágio 1 do GRUB é cravado nos primeiros 512 bytes do HD inteiro (o MBR), por isso apontamos para o dispositivo raiz.

Com o GRUB instalado em nossa imagem bootável, podemos iniciar a configuração do mesmo, que é feita através de um arquivo de configuração, de modo bastante intuitivo. Iniciamos através do seguinte comando 

```bash
# Cria o arquivo de configuração do GRUB
nano /mnt/boot/grub/grub.cfg
```

E inserimos o seguinte texto:

```nano
menuentry 'LecOS' {
        set root='(hd0,1)'
        linux /boot/bzImage root=/dev/sda1 rw
}
```

Este arquivo, basicamente, define o "título" da opção que irá aparecer no GRUB (em nosso caso, `LecOS`) enquanto define as variáveis necessarias:

* **set root**: Define, para o GRUB, o diretório raiz a ser carregado, no caso, nossa imagem `lecos.img`;
  * **hd0,1**: Indica o primeiro disco encontrado (`hd0`) e, dentro dele, a primeira partição;
* **linux /boot/bzImage**: Fornece o caminho para que o GRUB possa acessar e carregar o kernel Linux;
* **root=/dev/sda1 rw**: Define, para o kernel Linux, o sistema de arquivos a ser utilizado;
  * **rw**: Garante permissões de `leitura e escrita` para a partição /dev/sda1.

Com o arquivo escrito, podemos sair do `Nano` (o editor de texto que estamos utilizando), basta pressionarmos o comando `Ctrl + O` para salvar e `Ctrl + X` para sair, concluindo assim nosso arquivo de configuração e permitindo o boot inicial do GRUB.

Após isso, iremos sincronizar as configurações feitas para garantir sua aplicação antes de iniciarmos o ambiente, para isso, rodaremos algumas vezes o comando `sync`:

```bash
# Repita o comando algumas vezes para garantir que nosso trabalho será salvo
sync
```

Uma medida simples, mas serve para garantir que nossa imagem execute sem maiores problemas. Após essa etapa, podemos enfim desmontar nosso arquivo do diretório `/mnt` e desacoplar do `loop0`, pois nosso trabalho com eles já foi concluído.

```bash
# Desmontar o arquivo do diretório /mnt
umount /mnt

# Desacoplar o arquivo do loop device
losetup -d /dev/loop0
```

Por fim, iremos copiar o arquivo `lecos.img`, agora contendo o GRUB, para o nosso sistema principal através do comando `docker cp` que vimos anteriormente:

```bash
# Copia 'lecos.img' para o diretório atual do usuário
docker cp [CONTAINER ID]:/LOS/lecos.img .
```

E após a cópia, executamos o mesmo com o sistema `QEMU`:

```bash
# Utilizamos o QEMU para bootar a imagem
qemu-system-x86_64 lecos.img
```

Após executarmos, veremos a tela inicial do GRUB (Imagem 1), onde aparecerão as opções de boot para iniciarmos -- em nosso caso, somente `LecOS`. Ao selecionarmos, seremos recebidos por uma mensagem de erro, uma vez que, embora o boot tenha sido realizado, a imagem ainda está "crua", não possuindo utilitários, programas ou mesmo o kernel Linux, sendo o causador da mensagem de erro. 

![GRUB_Erro](https://github.com/FelpzzzEX/Imagens/blob/a85a62f695715170a32d078dddebd789ec27c147/Captura_de_tela_20260703_150938.png)
>Imagem 2: Erro do GRUB por não localizar o kernel na pasta indicada.

Na próxima etapa, iremos nos aprofundar no boot, passando pelo kernel, memória primária e secundária até a inicialização de fato do nosso sistema.