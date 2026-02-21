#!/data/data/com.termux/files/usr/bin/bash

GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${CYAN}[*] Memulai instalasi V-Encode (Automated-Video-Processor)...${NC}"

if [ ! -d "$HOME/storage" ]; then
    echo -e "${YELLOW}[!] Meminta izin akses penyimpanan...${NC}"
    termux-setup-storage
    sleep 3
fi

echo -e "${YELLOW}[1/3] Memperbarui sistem package...${NC}"
pkg update -y && pkg upgrade -y

echo -e "${YELLOW}[2/3] Menginstal dependencies...${NC}"
pkg install git ffmpeg jq fontconfig -y
pkg install fontconfig-utils

echo -e "${YELLOW}[3/3] Mengunduh binary V-Encode...${NC}"
if curl -L -o "$PREFIX/bin/V-Encode" "https://github.com/Mindsetmot/Automated-Video-Processor/raw/main/V-Encode"; then
    chmod +x "$PREFIX/bin/V-Encode"
    echo -e "\n${GREEN}[✓] Instalasi Selesai!${NC}"
    echo -e "${GREEN}[i] Ketik 'V-Encode' untuk menjalankan tool.${NC}"
else
    echo -e "\n${RED}[×] Gagal mengunduh binary. Periksa koneksi internet kamu!${NC}"
    exit 1
fi