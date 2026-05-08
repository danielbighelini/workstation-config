#!/usr/bin/env bash

set -e

echo "Atualizando pacotes..."

sudo apt update

echo "Instalando ferramentas básicas..."

sudo apt install -y \
    git \
    curl \
    wget \
    unzip \
    python3 \
    python3-pip \
    ansible \
    vim \
    tmux \
    jq \
    htop

echo "Bootstrap concluído."
