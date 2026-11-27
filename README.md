<div align="center">

# **Framework didático para construção de distribuições GNU/Linux**
![Static Badge](https://img.shields.io/badge/Sistema-GNU/Linux-black?logo=linux) ![Static Badge](https://img.shields.io/badge/Framework-LecOS-red?logo=bookstack) ![Static Badge](https://img.shields.io/badge/Formato-Markdown-yellow?logo=markdown) ![Static Badge](https://img.shields.io/badge/Ferramenta-Bash-green?logo=gnubash) ![Static Badge](https://img.shields.io/badge/Build-Docker-blue?logo=docker) ![Static Badge](https://img.shields.io/badge/Run-QEMU-white?logo=qemu)

</div>

## Introdução

Durante a minha graduação, ao estudar sistemas operacionais (S.O.) com foco em distribuições GNU/Linux, deparei-me com algumas metodologias que ajudam a entender todo o processo de construção de um sistema, como o famoso `Linux From Scratch`, um livro que ensina, etapa por etapa, a construir um sistema de propósito geral. No entanto, essas metodologias normalmente exigem um certo nível de conhecimento prévio para que o conteúdo seja bem absorvido, o que pode ser uma barreira para quem tem curiosidade em aprender mais a fundo sobre o assunto.

Com isso em mente e após algumas pesquisas, percebi que existem materiais didáticos espalhados por diversas fontes, e que eles são peças importantes para aprender a montar uma distribuição de forma didática. Por isso, propus como tema de Trabalho de Conclusão de Curso (TCC) a criação de um framework que facilita o aprendizado de S.O. de maneira prática, utilizando sistemas GNU/Linux e permitindo que os alunos apliquem os conceitos teóricos enquanto constroem um sistema minimalista, porém funcional.

---

## Etapas

Para iniciar o framework, optei por uma abordagem mais simples de concluir e de aprender. Mesmo sendo menos robusta, ela fornece uma base valiosa que será utilizada na construção do sistema de propósito geral, servindo como uma ponte entre os conteúdos, em vez de começarmos direto pela parte "complexa" do framework.

### Base Inicial

Nesta etapa, o sistema construído tem um escopo bem mais simples. Sua proposta principal é fornecer uma base sólida e simplificada para que os alunos aprendam conceitos fundamentais da construção de um S.O. Embora não utilize componentes do ecossistema GNU, ela tem grande valor educativo e ajudará nas etapas posteriores.

Para construir o sistema, basta acessar o tutorial [Base Inicial](Primeiros_Passos/base-inicial.md), que traz o passo a passo do processo, desde a compilação do Kernel Linux até o boot. É uma experiência relativamente rápida, mas que servirá de base para o sistema principal do framework.

### LecOS (Sistema Principal)

Este é o sistema principal do framework: uma distribuição GNU/Linux minimalista, construída do zero, em que cada componente é apresentado na mesma ordem em que entra em ação quando um computador é ligado. Em vez de apenas montar o sistema, o objetivo é entender, na prática, o papel de cada peça, partindo de um computador desligado até chegar a um sistema GNU/Linux em pleno funcionamento.

> O **LecOS** é o sistema usado como exemplo ao longo dos tutoriais. Em seu próprio projeto, cada aluno dará um nome ao seu sistema.

O caminho percorrido pelo framework é:

**BIOS/UEFI → Bootloader (GRUB) → Kernel Linux → Init system (Systemd, PID 1) → Processos → Entrada e saída → Sistema de arquivos (ext4)**

O conteúdo está dividido em 4 módulos e 11 etapas:

<div align="center">

| **Módulo** | **Etapas** | **O que aprendemos** |
| :--: | :--: | :--: |
| **1 - Início** | [BIOS/UEFI](Sistema_Principal/Modulo%201%20-%20Inicio/0-BIOS_UEFI.md), [Ambiente de Desenvolvimento](Sistema_Principal/Modulo%201%20-%20Inicio/1-Ambiente.md), [Bootloader](Sistema_Principal/Modulo%201%20-%20Inicio/2-Bootloader.md) | Como o hardware desperta e entrega o controle ao software |
| **2 - Boot** | [Kernel](Sistema_Principal/Modulo%202%20-%20Boot/3-Kernel.md), [Memória](Sistema_Principal/Modulo%202%20-%20Boot/4-Memoria.md), [Init](Sistema_Principal/Modulo%202%20-%20Boot/5-Init.md) | O papel do kernel, a diferença entre RAM e disco e o primeiro processo |
| **3 - Processos** | [Userland](Sistema_Principal/Modulo%203%20-%20Processos/6-Userland.md), [Init System](Sistema_Principal/Modulo%203%20-%20Processos/7-Init_System.md), [Processos](Sistema_Principal/Modulo%203%20-%20Processos/8-Processos.md) | A userland GNU, o Systemd como PID 1 e o ciclo de vida dos processos |
| **4 - Final** | [Entrada e Saída](Sistema_Principal/Modulo%204%20-%20Final/9-Entrada_e_Saida.md), [Sistema de Arquivos](Sistema_Principal/Modulo%204%20-%20Final/10-Sistema_de_Arquivos.md), [Encerramento](Sistema_Principal/Modulo%204%20-%20Final/11-Encerramento.md) | Como o sistema conversa com o hardware, organiza os dados e o desafio final |

</div>

> Tabela 1: Módulos e etapas do sistema principal.

Ao longo das etapas, há exercícios práticos com capturas de tela para o registro do progresso, e o framework termina com um desafio final: construir o seu próprio programa de exibição de informações do sistema (um "fetch"), lendo os dados diretamente do sistema em execução.

#### Como começar

A construção é feita dentro de um contêiner [Docker](https://www.docker.com/), e o sistema criado é executado em uma máquina virtual com o [QEMU](https://www.qemu.org/). Por isso, será necessário ter instalados:

* Docker;
* QEMU (`qemu-system-x86_64`);
* Git.

Em computadores com Windows, todo o processo deve ser realizado dentro do terminal do **WSL 2**, conforme explicado na seção "Preparando o ambiente no Windows (WSL 2)" da [Base Inicial](Primeiros_Passos/base-inicial.md). A imagem do sistema construído ocupa 10 GB, portanto é importante ter espaço livre em disco.

Para iniciar, basta clonar o repositório e seguir para a etapa [Ambiente de Desenvolvimento](Sistema_Principal/Modulo%201%20-%20Inicio/1-Ambiente.md), que explica como subir o contêiner de trabalho com o script `init.sh`:

```bash
git clone --depth 1 https://github.com/FelpzzzEX/LecOS.git
```

Para facilitar a leitura, os blocos de comandos dos tutoriais são precedidos por uma etiqueta que indica **onde** executá-los: `[HOST]` (sistema operacional principal), `[CONTAINER]` (contêiner Docker) e `[VM]` (sistema criado, em execução no QEMU).

#### Componentes

<div align="center">

| **Componente** | **Versão utilizada** |
| :--: | :--: |
| **Kernel Linux** | 6.12.108 |
| **GNU Bash** | 5.2.37 |
| **GNU Coreutils** | 9.7 |
| **GNU Inetutils** | 2.6 |
| **GNU Nano** | 8.4 |
| **Glibc** | 2.41 |
| **Ncurses** | 6.6 |
| **Util-Linux** | 2.41.5 |
| **Shadow-Utils** | 4.17.4 |
| **Linux-PAM** | 1.7.0 |
| **Libxcrypt** | 4.5.2 |
| **Systemd** | 257.13 |

</div>

> Tabela 2: Componentes utilizados na construção do Sistema Principal e suas respectivas versões.

As versões dos componentes foram selecionadas com base na distribuição **Debian Stable**, por ser uma das mais confiáveis em compatibilidade e estabilidade de componentes. No entanto, o sistema não contém os patches e as correções específicas do Debian, o que garante a reprodutibilidade e a independência do framework em relação às versões *upstream* desses componentes.

---

## Licença

Este projeto está licenciado sob a **GNU Free Documentation License v1.3 (GFDL-1.3)**. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.