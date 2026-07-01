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

>Para saber se está dentro do container e no diretório correto, basta verificar o seu terminal se apresentar algo parecido com `root@a75d5a072e7a:/LOS#`, sendo `root` o usuário atual e `a75d5a072e7a` o ID do sistema, por fim, `/LOS` é o diretório onde estaremos montando o sistema e rodando todos os comandos. Tenha certeza de estar sempre nesse diretório antes de rodar qualquer script ou criar quaisquer arquivos.

