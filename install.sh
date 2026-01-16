#!/bin/bash

# --- VARIÁVEIS DE CAMINHO ---
REPO_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SOURCE_DIR="$REPO_ROOT/dotconfig"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$HOME/.config_backup_$(date +%Y%m%d_%H%M%S)"

# --- 1. LISTA DE PACOTES COMBINADA ---
PACOTES=(
    # --- Essenciais ---
    "hyprland"
    "waybar"
    "hyprpaper"
    "hyprlock"
    "swaync"
    "rofi-wayland"
    "wlogout"
    "hyprshot"
    # --- Áudio e Multimídia ---
    "pipewire"
    "wireplumber"
    "cava"
    "pamixer"
    "libpulse"
    "playerctl"
    # --- Sistema e Ferramentas ---
    "kitty"
    "fish"
    "neovim"
    "thunar"
    "blueman"
    "networkmanager"
    "libnotify"
    "lm_sensors"
    "btop"
    "curl"
    "kvantum"
    # --- Temas e Aparência ---
    "nwg-look"
    "papirus-icon-theme"
    "materia-gtk-theme"
    "ttf-font-awesome"
    "ttf-jetbrains-mono-nerd"
    "ttf-fira-code-nerd"
    
    # --- PACOTES AUR ---
    "zen-browser-bin"       # Seu navegador
    "nordzy-icon-theme"     # Seus ícones (AUR)
    "ttf-geist-mono-nerd"   # Sua fonte principal (AUR)
)

# --- LISTA DE PASTAS PARA COPIAR ---
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

echo "--- INICIANDO SETUP ---"
echo "> Verificando pré-requisitos..."
if ! pacman -Qi git &> /dev/null || ! pacman -Qi base-devel &> /dev/null; then
    echo "Instalando git e base-devel (necessários para o AUR)..."
    sudo pacman -Syu --needed --noconfirm git base-devel
else
    echo "Pré-requisitos já instalados."
fi
if ! command -v yay &> /dev/null; then
    echo "> Yay não encontrado. Instalando automaticamente..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd "$REPO_ROOT" # Volta para a pasta do script
    echo "Yay instalado com sucesso!"
else
    echo "> Yay já está instalado."
fi
echo "> Instalando pacotes do sistema e do AUR..."
yay -S --needed --noconfirm "${PACOTES[@]}"
echo "> Copiando Dotfiles de: $SOURCE_DIR"
if [ ! -d "$SOURCE_DIR" ]; then
    echo "ERRO CRÍTICO: Pasta 'dotconfig' não encontrada!"
    exit 1
fi
mkdir -p "$BACKUP_DIR"
for pasta in "${PASTAS_PARA_COPIAR[@]}"; do
    origem="$SOURCE_DIR/$pasta"
    destino="$CONFIG_DIR/$pasta"
    if [ -d "$origem" ]; then
        # Backup se já existir algo
        if [ -e "$destino" ]; then
            echo "Backup: Movendo $pasta antiga para $BACKUP_DIR..."
            mv "$destino" "$BACKUP_DIR/"
        fi
        # Cópia Recursiva
        echo "Copiando: $pasta -> ~/.config/"
        cp -r "$origem" "$destino"
    else
        echo "AVISO: Pasta '$pasta' não encontrada em 'dotconfig'. Pulando."
    fi
done
echo "> Aplicando temas e shell..."
gsettings set org.gnome.desktop.interface gtk-theme "Materia-dark-compact"
gsettings set org.gnome.desktop.interface icon-theme "Nordzy-dark"
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
if [[ $SHELL != *"fish"* ]]; then
    echo "Mudando shell padrão para Fish..."
    chsh -s $(which fish)
fi
echo ""
echo "--- SETUP CONCLUÍDO COM SUCESSO! ---"
echo "1. Todos os pacotes (incluindo AUR) foram instalados."
echo "2. Suas configurações foram COPIADAS para ~/.config."
echo "3. Você pode apagar esta pasta ($REPO_ROOT) se quiser."
echo "4. Reinicie o computador para finalizar."
