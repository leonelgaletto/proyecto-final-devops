#!/bin/bash

# Actualizamos la lista de paquetes
sudo apt-get update -y

# Instalamos Docker
sudo apt-get install -y docker.io

# Iniciamos el servicio de Docker
sudo systemctl start docker
sudo systemctl enable docker

# Añadimos el usuario 'ubuntu' (el usuario por defecto) al grupo de Docker
# Esto nos permite correr comandos de Docker sin usar 'sudo'
sudo usermod -aG docker ubuntu
