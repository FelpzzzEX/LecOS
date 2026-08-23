#!/bin/bash

clear

echo "Iniciando desenvolvimento do LecOS!"
echo "[Sistema] - Construindo ambiente de desenvolvimento..."

echo "
[Armazenamento] - Criando o volume de persistência de dados, caso pausas sejam necessárias"
docker volume create lecos_data

echo "
[Sistema] - Gerando o container de desenvolvimento"

docker run -d --name LecOS-dev --privileged -v lecos_data:/LOS felpzzex/lecos:latest tail -f /dev/null

echo "
[Sistema] - Ambiente completo! Bem-vindo(a) ao ambiente de construção do


    "
echo "░██                                 ░██████     ░██████   
░██                                ░██   ░██   ░██   ░██  
░██          ░███████   ░███████  ░██     ░██ ░██         
░██         ░██    ░██ ░██    ░██ ░██     ░██  ░████████  
░██         ░█████████ ░██        ░██     ░██         ░██ 
░██         ░██        ░██    ░██  ░██   ░██   ░██   ░██  
░██████████  ░███████   ░███████    ░██████     ░██████   
                                                          
                                                          
                                                          "

echo "[Sistema] - Acessando o ambiente...
"

docker exec -it LecOS-dev bash