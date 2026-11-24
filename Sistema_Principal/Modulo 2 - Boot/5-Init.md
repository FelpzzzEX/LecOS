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

Após removermos o `initramfs`, precisamos atualizar novamente o arquivo de configuração do GNU GRUB, removendo a referência ao componente que não será mais utilizado e personalizando o nome apresentado durante a inicialização do sistema.

Para isso, utilizaremos o editor de texto GNU Nano, acessando o arquivo `grub.cfg` localizado no diretório de inicialização da imagem:

```bash
# Abre o arquivo de configuração do GRUB
nano /mnt/boot/grub/grub.cfg
```

Dentro do arquivo, localize a entrada correspondente ao nosso sistema e realize as seguintes alterações:

```nano
menuentry '[NOME-DO-SISTEMA]' {
      set root='(hd0,1)'
      linux /boot/bzImage root=/dev/sda1 rw
}
```

Substitua `[NOME-DO-SISTEMA]` pelo nome escolhido para o seu sistema operacional. Observe também que a linha `initrd /boot/initramfs.cpio.gz` foi removida, uma vez que não utilizaremos mais o initramfs nesta versão.

Após realizar as alterações, salve o arquivo e feche o editor utilizando `Ctrl + O`, `Enter` e `Ctrl + X`, respectivamente. Dessa forma, o GRUB estará configurado para inicializar diretamente o sistema instalado na imagem.

<div align="center">

![reminitram](https://github.com/FelpzzzEX/Imagens/blob/9db97f9242f5ae12cf28aa4c038b542d92b70751/rminitfs.png)

</div>

> Imagem 3: Removendo o initramfs do nosso ambiente e da imagem bootável.

## **Compilando os componentes finais**

Com o terreno preparado, inseriremos os últimos componentes necessários em nosso sistema, permitindo sua utilização de forma mais prática e eficiente e tornando a experiência mais completa para o usuário. O processo será similar ao que vimos anteriormente, restando três componentes para finalizarmos a construção base do nosso sistema operacional, sendo eles o `GNU Coreutils 9.7`, o `GNU Nano 8.4` e o `Util-Linux 2.41.5`. 

Os tarballs dos componentes serão baixados através do `wget` novamente e **precisam estar no diretório `/LOS/Componentes`**, pois os scripts de build procuram o código-fonte nesse local. Além disso, é necessário baixar exatamente as versões indicadas, caso contrário o script falhará. Abaixo, realizaremos o passo a passo para a instalação de cada um deles, enquanto conhecemos mais sobre esses componentes e suas utilidades em ambientes GNU/Linux.

<div align="center">

| **Componente** | **Versão** | **Arquivo a baixar** | **Diretório gerado** | **Script de build** |
| :--: | :--: | :--: | :--: | :--: |
| **GNU Coreutils** | 9.7 | `coreutils-9.7.tar.gz` | `coreutils-9.7` | `coreutils-build.sh` |
| **GNU Nano** | 8.4 | `nano-8.4.tar.gz` | `nano-8.4` | `nano-build.sh` |
| **Util-Linux** | 2.41.5 | `util-linux-2.41.5.tar.gz` | `util-linux-2.41.5` | `uLinux-build.sh` |

</div>

> Tabela 1: Versões, arquivos e scripts de build dos componentes finais.

### **GNU Coreutils**

O GNU Coreutils é um componente bastante consolidado nos sistemas operacionais GNU/Linux, uma vez que ele se tornou o padrão de diversas distribuições por fornecer os comandos utilitários para se interagir e realizar as tarefas básicas do sistema, podendo-se citar:

* **ls (list)**: Lista os diretórios e arquivos existentes
* **cp (copy)**: Copia arquivos e diretórios
* **mkdir (make directory)**: Cria um diretório novo
* **rm (remove)**: Remove um arquivo

Para instalarmos o componente em nosso sistema, primeiro precisamos baixar a versão `9.7` do GNU Coreutils no diretório `/LOS/Componentes` e extrair o seu conteúdo, da mesma forma que fizemos com os componentes da etapa anterior (substitua `[LINK-COREUTILS-9.7]` pelo link do componente):

```bash
# Entra no diretório de componentes
cd /LOS/Componentes

# Baixa o tarball do GNU Coreutils 9.7
wget [LINK-COREUTILS-9.7]

# Extrai o conteúdo do tarball
tar -xzf coreutils-9.7.tar.gz
```

Com o código-fonte extraído, utilizaremos o script presente no diretório `Componentes/scripts/`, sendo ele o `coreutils-build.sh`. Primeiro precisamos fornecer a permissão de execução ao script, utilizando novamente o comando `chmod +x`, seguido da execução do script.

```bash
# Acessa o diretório de scrips 
cd /LOS/Componentes/scripts

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

Para instalar o Nano em nosso sistema, realizaremos o mesmo processo anterior, começando pelo download da versão `8.4` no diretório `/LOS/Componentes` e pela extração do tarball (substitua `[LINK-NANO-8.4]` pelo link do componente):

```bash
# Entra no diretório de componentes
cd /LOS/Componentes

# Baixa o tarball do GNU Nano 8.4
wget [LINK-NANO-8.4]

# Extrai o conteúdo do tarball
tar -xzf nano-8.4.tar.gz
```

Em seguida, fornecemos a permissão de execução para o script de build e, logo depois, o executamos:

```bash
# Acessa o diretório de scrips 
cd /LOS/Componentes/scripts

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

Assim como os componentes anteriores, começaremos baixando a versão `2.41.5` no diretório `/LOS/Componentes` e extraindo o tarball (substitua `[LINK-UTIL-LINUX-2.41.5]` pelo link do componente):

```bash
# Entra no diretório de componentes
cd /LOS/Componentes

# Baixa o tarball do Util-Linux 2.41.5
wget [LINK-UTIL-LINUX-2.41.5]

# Extrai o conteúdo do tarball
tar -xzf util-linux-2.41.5.tar.gz
```

Em seguida, realizaremos a instalação através do script de build, sendo necessário fornecer, novamente, a permissão de execução:

```bash
# Acessa o diretório de scrips 
cd /LOS/Componentes/scripts

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

E, depois de uma bela jornada, temos enfim nosso sistema operacional rodando completamente! Dessa vez, sem a utilização do initramfs, todo o ambiente é executado diretamente a partir do disco virtual criado na imagem, permitindo que arquivos e modificações sejam preservados após o desligamento e a reinicialização do sistema.

Entretanto, é importante compreender que o kernel Linux não grava necessariamente todas as alterações no disco no exato momento em que elas são realizadas. Para otimizar o desempenho, o sistema utiliza um mecanismo chamado *page cache*, que mantém temporariamente em memória os dados modificados antes de enviá-los ao dispositivo de armazenamento.

Por esse motivo, ao criar, modificar ou excluir arquivos, pode existir um intervalo até que as alterações sejam efetivamente gravadas na imagem. Para garantir que os dados pendentes sejam enviados ao disco antes de desligar o sistema, utilizaremos o comando `sync`, que solicita a sincronização dos dados armazenados em memória com o dispositivo de armazenamento.

Com isso, temos a base completa do nosso trabalho, com todos os componentes funcionando e interagindo de forma esperada. Essa estrutura representa uma base sólida para os próximos conteúdos do framework!

<div align="center">

![lecoscomplete](https://github.com/FelpzzzEX/Imagens/blob/aacd9869f39ec8c1e5d47626ae1b6feb9ac1c0b5/Etapa5-framework/Captura%20de%20tela_2026-09-11_20-12-10.png)

</div>

> Imagem 7: Interagindo com o sistema operacional após o boot.

<div align="center">

![lecoscompletereboot](https://github.com/FelpzzzEX/Imagens/blob/aacd9869f39ec8c1e5d47626ae1b6feb9ac1c0b5/Etapa5-framework/Captura%20de%20tela_2026-09-11_20-14-19.png)

</div>

> Imagem 8: Persistência dos dados e alterações após o reboot do sistema.

### **Sexto Exercício — Teste de Persistência em Disco**

Nesta atividade, iremos verificar experimentalmente a persistência dos dados em nosso sistema operacional, agora executado diretamente a partir do disco virtual, sem a utilização do initramfs.

Primeiramente, com o sistema inicializado no QEMU, crie um arquivo chamado `teste.txt`, escrevendo nele o seu número de matrícula. Para isso, execute os seguintes comandos no terminal:

```bash
# Cria o arquivo e escreve o número de matrícula
echo "[NÚMERO DE MATRÍCULA]" > /teste.txt

# Exibe o conteúdo do arquivo
cat /teste.txt

# Sincroniza as alterações com o disco
sync
```

Após executar os comandos, registre uma captura de tela do terminal, demonstrando que o arquivo foi criado e que seu conteúdo corresponde ao número de matrícula informado.

Em seguida, desligue completamente o sistema e encerre sua execução no QEMU. Após isso, inicialize novamente a imagem `lecos.img`, repetindo o procedimento de boot até retornar ao terminal do sistema operacional.

Com o sistema novamente em execução, execute o comando abaixo para verificar se o arquivo continua presente:

```bash
# Verifica a existência e exibe o conteúdo do arquivo
if [ -f /teste.txt ]; then
    echo "Arquivo encontrado!"
    cat /teste.txt
else
    echo "Arquivo não encontrado!"
fi
```

Registre uma segunda captura de tela, demonstrando que o arquivo continua existindo e que seu conteúdo foi preservado após a reinicialização.

Ao finalizar, inclua **as duas capturas de tela no relatório**, organizando-as de maneira que seja possível comparar os resultados antes e depois do desligamento. Apresente também uma breve explicação sobre o comportamento observado, destacando a diferença entre o armazenamento temporário em memória RAM e a persistência dos dados no disco.

O objetivo desta atividade é demonstrar que, diferentemente do que observamos na etapa anterior, os arquivos armazenados no sistema de arquivos da imagem podem permanecer disponíveis após o desligamento e a reinicialização do sistema, desde que as alterações tenham sido efetivamente gravadas no disco.

## **Próximos passos**

Parabéns por ter chegado até aqui, já estamos na metade do conteúdo apresentado pelo framework. Todo o caminho percorrido resultou em um sistema minimalista e funcional, utilizando componentes fundamentais de uma distribuição GNU/Linux.

No entanto, embora o nosso sistema pareça "completo", ele ainda é somente a base, existindo mais conteúdos e componentes a serem abordados, desde a questão de processos e de entrada e saída de dados até mesmo a interface gráfica, onde repassaremos suas filosofias e funcionamento, além de visualizarmos na prática seus casos de uso.

Como sempre, um excelente trabalho até aqui. Continue neste ritmo, pois estamos chegando lá! Nos vemos no próximo módulo, onde enfim entraremos na parte relacionada aos processos de um sistema operacional e a como eles funcionam e são gerenciados. Até breve!