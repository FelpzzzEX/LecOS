# **Framework didático para construção de distribuições GNU/Linux**

## Introdução

Durante a minha graduação, seguindo meus estudos relacionados a sistemas operacionais (S.O.), voltado para distribuições GNU/Linux, me deparei com algumas metodologias que ajudavam a entender melhor todo o processo de construção, como por exemplo o famoso `Linux From Scrath`, um livro que ensina, etapa por etapa, o processo de construção de um sistema de propósito geral. No entanto, tais metodologias, normalmente, exigem um certo nível de conhecimento prévio para conseguir absorver melhor o conteúdo proposto, o que pode servir como uma barreira para algumas pessoas curiosas em aprender mais a fundo sobre o assunto.

Tendo isso em mente e após algumas pesquisas, notei que existem materiais didáticos espalhados por diversas fontes, que acabavam sendo peças importantes para aprender a montar uma distribuição de forma didática, resolvi propôr como tema de Trabalho de Conclusão de Curso (TCC) a criação de um framework destinado a facilitar o aprendizado relacionado a S.O. de maneira prática utilizando de sistemas GNU/Linux, permitindo que os alunos consigam aplicar os conceitos teóricos enquanto constroem um sistema minimalista, porém funcional.

---
## Etapas

Para iniciar o processo do framework, optei por iniciar com uma abordagem mais simples de se concluir e aprender, pois mesmo que seja algo menos robusto, ela fornece uma base valiosa que será utilizada posteriormente no framework, na construção do sistema de propósito geral, servindo como uma ponte entre os conteúdos em vez de já iniciarmos na parte "complexa" do framework.

### KompaktOS

Nesta etapa, o sistema construído tem um escopo bem mais simples, tendo como proposta principal fornecer uma base sólida e simplificada para que os alunos possam aprender conceitos fundamentais a respeito da construção de um S.O., embora não utilize componentes do ecossistema GNU, ainda possui um grande valor educativo que ajudará em etapas posteriores.

Para realizar a construção do sistema, basta acessar o tutorial presente no arquivo [Base Inicial](base-inicial.md), nele contém o passo a passo explicando o processo de construção, desde a compilação do Kernel Linux até o boot, sendo uma experiência relativamente rápida, mas que servirá de base para o sistema principal do Framework.

### LecOS

Sistema principal do framework.

**[Em construção...]**

### LecOS - Libre

Versão voltada a software livre.

**[Em construção...]**

---
## Licença

Este projeto está licenciado sob a **GNU General Public License v2.0 (GPLv2)**. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.