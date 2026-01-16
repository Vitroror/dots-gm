#!/bin/bash

# --- VARIÁVEIS DE CAMINHO ---
REPO_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SOURCE_DIR="$REPO_ROOT/dotconfig"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

# --- LISTA DE PACOTES ---
PACOTES_PACMAN=(
    "hyprland"
    "waybar"
    "hyprpaper"
    "hyprlock"
    "swaync"
    "rofi-wayland"
    "wlogout"
    "hyprshot"
    "pipewire"
    "wireplumber"
    "cava"
    "pamixer"
    "libpulse"
    "playerctl"
    "kitty"
    "fish"
    "neovim"
    "thunar"
    "gvfs-smb"
    "blueman"
    "networkmanager"
    "libnotify"
    "lm_sensors"
    "btop"
    "curl"
    "kvantum"
    "papirus-icon-theme"
    "ttf-font-awesome"
    "ttf-jetbrains-mono-nerd"
    "ttf-fira-code-nerd"
)

# --- LISTA DE PASTAS ---
PASTAS_PARA_COPIAR=(
    "hypr"
    "waybar"
    "kitty"
    "rofi"
    "fish"
    "swaync"
    "cava"
    "wlogout"
    "nvim"
    "nwg-look"
    "gtk-3.0"
    "gtk-4.0"
    "Kvantum"
)

# --- 1. INSTALAÇÃO ---
echo "--- Iniciando Instalação ---"

if command -v pacman &> /dev/null; then
    echo "Instalando pacotes oficiais..."
    sudo pacman -Syu --needed --noconfirm "${PACOTES_PACMAN[@]}"
else
    echo "ERRO: Pacman não encontrado."
    exit 1
fi

# --- 2. COPIANDO ARQUIVOS (A MUDANÇA ESTÁ AQUI) ---
echo "--- Copiando configurações de: $SOURCE_DIR ---"

if [ ! -d "$SOURCE_DIR" ]; then
    echo "ERRO: Pasta 'dotconfig' não encontrada!"
    exit 1
fi

mkdir -p "$BACKUP_DIR"

for pasta in "${PASTAS_PARA_COPIAR[@]}"; do
    origem="$SOURCE_DIR/$pasta"
    destino="$CONFIG_DIR/$pasta"

    if [ -d "$origem" ]; then
        # Se já existe (seja pasta, arquivo ou link), move para backup
        if [ -e "$destino" ]; then
            echo "Backup: Movendo $pasta antiga para $BACKUP_DIR..."
            mv "$destino" "$BACKUP_DIR/"
        fi
        
        # COPIA a pasta recursivamente (-r)
        echo "Copiando: $pasta -> ~/.config/"
        cp -r "$origem" "$destino"
    else
        echo "AVISO: Pasta '$pasta' não encontrada em 'dotconfig'. Pulando."
    fi
done

# --- 3. CONFIGURAÇÕES FINAIS ---
echo "--- Aplicando Ajustes Finais ---"
gsettings set org.gnome.desktop.interface gtk-theme "Materia-dark-compact"
gsettings set org.gnome.desktop.interface icon-theme "Nordzy-dark" 2>/dev/null
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

if [[ $SHELL != *"fish"* ]]; then
    echo "Configurando Fish..."
    chsh -s $(which fish)
fi

echo "--- Concluído! ---"
echo "Agora você PODE excluir a pasta deste repositório ($REPO_ROOT) sem problemas."
echo "Suas configurações estão salvas e independentes em ~/.config"
