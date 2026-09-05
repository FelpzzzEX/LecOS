<div align="center">

# **Framework didático para construção de distribuições GNU/Linux**
![Static Badge](https://img.shields.io/badge/Sistema-GNU/Linux-black?logo=linux) ![Static Badge](https://img.shields.io/badge/Framework-LecOS-red?logo=bookstack) ![Static Badge](https://img.shields.io/badge/Formato-Markdown-yellow?logo=markdown) ![Static Badge](https://img.shields.io/badge/Ferramenta-Bash-green?logo=gnubash) ![Static Badge](https://img.shields.io/badge/Build-Docker-blue?logo=docker) ![Static Badge](https://img.shields.io/badge/Run-QEMU-white?logo=qemu)

</div>

## Introdução

Durante a minha graduação, seguindo meus estudos relacionados a sistemas operacionais (S.O.), voltado para distribuições GNU/Linux, me deparei com algumas metodologias que ajudavam a entender melhor todo o processo de construção, como por exemplo o famoso `Linux From Scrath`, um livro que ensina, etapa por etapa, o processo de construção de um sistema de propósito geral. No entanto, tais metodologias, normalmente, exigem um certo nível de conhecimento prévio para conseguir absorver melhor o conteúdo proposto, o que pode servir como uma barreira para algumas pessoas curiosas em aprender mais a fundo sobre o assunto.

Tendo isso em mente e após algumas pesquisas, notei que existem materiais didáticos espalhados por diversas fontes, que acabavam sendo peças importantes para aprender a montar uma distribuição de forma didática, resolvi propôr como tema de Trabalho de Conclusão de Curso (TCC) a criação de um framework destinado a facilitar o aprendizado relacionado a S.O. de maneira prática utilizando de sistemas GNU/Linux, permitindo que os alunos consigam aplicar os conceitos teóricos enquanto constroem um sistema minimalista, porém funcional.

---

## Etapas

Para iniciar o processo do framework, optei por iniciar com uma abordagem mais simples de se concluir e aprender, pois mesmo que seja algo menos robusto, ela fornece uma base valiosa que será utilizada posteriormente no framework, na construção do sistema de propósito geral, servindo como uma ponte entre os conteúdos em vez de já iniciarmos na parte "complexa" do framework.

### Base Inicial

Nesta etapa, o sistema construído tem um escopo bem mais simples, tendo como proposta principal fornecer uma base sólida e simplificada para que os alunos possam aprender conceitos fundamentais a respeito da construção de um S.O., embora não utilize componentes do ecossistema GNU, ainda possui um grande valor educativo que ajudará em etapas posteriores.

Para realizar a construção do sistema, basta acessar o tutorial presente no arquivo [Base Inicial](Primeiros_Passos/base-inicial.md), nele contém o passo a passo explicando o processo de construção, desde a compilação do Kernel Linux até o boot, sendo uma experiência relativamente rápida, mas que servirá de base para o sistema principal do Framework.

### LecOS

Sistema principal do framework.

**[Em construção...]**

<div align="center">

| **Componente** | **Versão utilizada** |
| :--: | :--: |
| **Kernel Linux** | 6.12.108 |
| **GNU Bash** | 5.2.37 |
| **GNU Coreutils** | 9.7 |
| **GNU Nano** | 8.4 |
| **Glibc** | 2.41 |
| **Ncurses** | 6.6 |
| **Util-Linux** | 2.41.5 |
| **Systemd** | 257.13 |
| **XFCE** | 4.20 |

</div>

As versões dos componentes foram selecionadas com base na distribuição **Debian Stable**, uma vez que é um dos sistemas mais confiáveis em questão de compatibilidade e estabilidade de componentes. No entanto, não conterá os patches e correções específicas do Debian, garantindo a reprodutibilidade e independência do framework com as versões upstream desses componentes.

---

## Licença

Este projeto está licenciado sob a **GNU Free Documentation License v1.3 (GFDL-1.3)**. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.