# **Bootloader**

Com o hardware "acordado", o `BIOS/UEFI` passa a responsabilidade para o `bootloader`, cujo será responsável por iniciar componentes do sistema em si, carregando o `kernel` e o `initrd/initramfs`, sendo responsáveis pela inialização e por montar o sistema de arquivos virtual, respectivamente.

Neste sistema, estaremos utilizando o GNU GRUB como bootloader, sendo um componente do ecossistema GNU e principal bootloader utilizado em distribuições Linux modernas (ao lado do systemd-boot), sendo uma solução robusta e prática para a inicialização.

---

## **Montando o disco**

Antes de, de fato, partirmos para o bootloader, precisamos montar nosso arquivo de disco. Se recordarmos do tutorial passado, ao criarmos o arquivo de `boot`, utilizamos o seguinte comando:

```bash
# Não execute!
dd if=/dev/zero of=boot bs=1M count=50
```

Nessa etapa, faremos algo parecido novamente, pois será a nossa imagem _"bootável"_, arquivo esse que irá nos permitir inicializar o sistema. Vale ressaltar que a imagem será significativamente maior do que a que geramos anteriormente, dada a natureza dos componentes utilizados neste ambiente.

Para iniciarmos, executaremos o seguinte comando:

```bash
dd if=/dev/zero of=lecos.img bs=1M count=2048
```

Com este comando, estaremos criando um arquivo de 2GB denominado `lecos.img`, arquivo este que será utilizado para dar início ao nosso sistema.
