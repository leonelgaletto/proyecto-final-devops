#!/bin/bash

sudo apt-get update -y

sudo apt-get install -y docker.io

sudo systemctl start docker
sudo systemctl enable docker

# Esto nos permite correr comandos de Docker sin usar 'sudo'
sudo usermod -aG docker ubuntu
