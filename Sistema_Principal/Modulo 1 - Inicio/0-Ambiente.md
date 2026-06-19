# **Sistema principal - LecOS**

Após realizarmos os [Primeiros Passos](Primeiros_Passos/base-inicial.md) do nosso Framework, iniciaremos agora a etapa definitiva, onde focaremos não na construção, mas no entendimento por trás de cada componente dos sistemas operacionais, utilizando uma distribuição mínima como base para repassarmos nos conceitos fundamentais da disciplina.

---

## **Componentes**

Este sistema contém alguns componentes a mais, possuindo uma natureza mais modular, sendo estes:

* Kernel Linux (64-bit);
* GNU Coreutils;
* Bash;
* Glibc;
* Nano;
* Ncurses;
* Util-Linux;
* GNU GRUB (bootloader).

Como mencionado anteriormente, o processo consistirá em passar por cada etapa do processo do sistema operacional, do `boot` até a inicialização do sistema, visando o entendimento dos conceitos e sistemas, ao invés de simplesmente entender como montar um sistema operacional.

O trabalho será desenvolvido também dentro de um container `Docker`, mas dessa vez, contaremos com um script de inicialização do ambiente visando um desenvolvimento mais dinâmico uma vez que já passamos por isso nos primeiros passos.

---

## **Fluxo**

Neste trabalho, não ficaremos presos somente nos componentes que iremos montar, mas também repassaremos em conceitos fundamentais dos sistemas operacionais, deixando nosso fluxo de trabalho da seguinte forma:

```mermaid
flowchart LR
    subgraph Boot["Processo de boot"]
      A["BIOS"] -->|Carrega| B["Bootloader"]
      C["UEFI"] -->|Carrega| B
      B -->|Carrega| D["Kernel"]
      B -->|Carrega| E["Initrd/Initramfs"]
    end

    subgraph Init["Inicialização do sistema"]
      F["Init System"]
      F -->|Inicia| G["Processos"]
    end

    subgraph FS["Sistemas de Arquivos"]
      H["File System Virtual"]
      I["File System Real"]
      J["Inicialização"]
      J -->|Utiliza| H
    end

    E -->|Monta| H
    D -->|Cria| I
    D --> J
    J --> D
    I --> F
    
```

---

## **Inicialização do ambiente**

Para iniciarmos o nosso trabalho, precisamos criar o nosso ambiente de desenvolvimento. Para isso, estaremos utilizando um script para isso, o `init.sh`. Esse script contém os comandos necessários para a inicialização do container onde faremos o trabalho. Para isso, precisamos primeiramente fornecer a permissão para que ele possa ser executado, portanto, dentro do diretório (Sistema Principal)[Sistema_Principal], inserimos o seguinte comando:

```bash
chmod +x init.sh
```

Esse comando, basicamente, torna o script `init.sh` executável para o nosso sistema, possibilitando subir todo o ambiente com apenas essa instrução, tornando o _setup_ do ambiente mais prático e direto - não estamos aprendendo a subir o ambiente, mas sim a entender o sistema operacional que construiremos nele.

Após fornecer a permissão, podemos enfim iniciar nosso trabalho, ainda no diretório, executaremos:

```bash
./init.sh
```

Esse script executará os comandos necessários para deixar nosso ambiente de trabalho pronto, como:

```bash
# Cria um volume para persistência de dados
# (Pode pausar quando necessário sem perder o progresso)
docker volume create lecos_data

# Cria o container de trabalho "LecOS-dev"
# Utiliza a imagem "lecos" criada para este propósito
docker run -d --name LecOS-dev --privileged -v lecos_data:/LOS/root felpzzex/lecos:latest tail -f /dev/null
```

Por fim, o script também copia arquivos essenciais para o nosso ambiente, como o Kernel Linux já previamente compilado (no mesmo ambiente), o arquivo de inicialização e os scripts de build para cada ferramenta de nossa userland. Caso esteja interessado, pode verificar o conteúdo presente acessando o arquivo [init.sh](Sistema_Principal/init.sh).

Após a execução do script, você entrará no sistema de desenvolvimento do nosso framework, onde iremos montar a distribuição mínima enquanto nos aprofundamos nos conceitos fundamentais de um S.O.