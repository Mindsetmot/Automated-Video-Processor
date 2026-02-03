#!/data/data/com.termux/files/usr/bin/bash

# Warna
BLUE='\033[1;34m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
WHITE='\033[1;37m'
NC='\033[0m'

# Path & Config
FONT_DIR="$PREFIX/share/fonts/TTF"
CONFIG_FILE="$HOME/.vencode_config.conf"
CURRENT_BROWSE_DIR="/sdcard"
mkdir -p "$FONT_DIR"

# --- CEK DEPENDENCIES ---
if ! command -v jq &> /dev/null; then
    pkg install jq -y &>/dev/null
fi

if ! command -v fc-scan &> /dev/null; then
    pkg install fontconfig -y &>/dev/null
fi

# --- CEK TERMUX API ---
if ! command -v termux-wake-lock &> /dev/null; then
    echo -e "${YELLOW}[!] Paket 'termux-api' belum terinstall.${NC}"
    echo -e "${CYAN}[*] Disarankan install agar proses encoding tidak terhenti saat layar mati.${NC}"
    echo -ne "${YELLOW}[?] Install sekarang? (y/n): ${NC}"
    read -t 5 OPT_API # Timeout 5 detik agar tidak menggangu jika user mendiamkan
    
    if [[ "$OPT_API" == "y" || "$OPT_API" == "Y" ]]; then
        echo -e "${CYAN}[*] Menginstal termux-api...${NC}"
        pkg install termux-api -y
        echo -e "${GREEN}[✓] Berhasil. Pastikan aplikasi 'Termux:API' juga sudah terpasang.${NC}"
        sleep 2
    fi
fi

# Variabel Versi
LOCAL_VERSION="1.0.1"
JSON_URL="https://raw.githubusercontent.com/Mindsetmot/Automated-Video-Processor/main/version.json"
BIN_URL="https://github.com/Mindsetmot/Automated-Video-Processor/raw/main/V-Encode"
FFMPEG_VERSION=$(ffmpeg -version 2>/dev/null | head -n1 | cut -d " " -f3 || echo "Not Found")

# Cek Update
REMOTE_DATA=$(curl -s -L --connect-timeout 5 "$JSON_URL")
if [ -n "$REMOTE_DATA" ]; then
    REMOTE_VERSION=$(echo "$REMOTE_DATA" | jq -r '.version' 2>/dev/null)
    DISPLAY_VERSION=$(echo "$REMOTE_DATA" | jq -r '.version_display' 2>/dev/null)
    if [[ "$REMOTE_VERSION" != "$LOCAL_VERSION" && "$REMOTE_VERSION" != "null" && -n "$REMOTE_VERSION" ]]; then
        echo -e "${YELLOW}[!] Versi baru tersedia: ${DISPLAY_VERSION}${NC}"
        echo -ne "${YELLOW}[?] Update sekarang? (y/n): ${NC}"
        read OPT_UPDATE
        if [[ "$OPT_UPDATE" == "y" || "$OPT_UPDATE" == "Y" ]]; then
            echo -e "${CYAN}[*] Mengunduh pembaruan...${NC}"
            if curl -L -o "$PREFIX/bin/V-Encode.tmp" "$BIN_URL"; then
                mv "$PREFIX/bin/V-Encode.tmp" "$PREFIX/bin/V-Encode"
                chmod +x "$PREFIX/bin/V-Encode"
                echo -e "${GREEN}[✓] Update berhasil! Silakan jalankan ulang 'V-Encode'.${NC}"
                exit 0
            fi
        fi
    fi
fi

# --- FUNGSI PEMBANTU API ---
# Fungsi ini untuk menjalankan command API tanpa memunculkan error jika tidak diinstall
run_api() {
    if command -v "$1" &> /dev/null; then
        "$@" &> /dev/null
    fi
}

# --- FUNGSI LOGIKA ---
init_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        cat <<EOF > "$CONFIG_FILE"
FONT_NAME="DejaVuSans"
FONT_SIZE="22"
MARGIN_V="18"
CREDITS="MINDSETMOT"
SHOW_CREDITS="true"
CREDITS_FONT="Sans"
CREDITS_SIZE="20"
CREDITS_X="20"
CREDITS_Y="20"
CREDITS_START="0"
CREDITS_END="10"
EOF
    fi
    source "$CONFIG_FILE"
}

save_config() {
    cat <<EOF > "$CONFIG_FILE"
FONT_NAME="$FONT_NAME"
FONT_SIZE="$FONT_SIZE"
MARGIN_V="$MARGIN_V"
CREDITS="$CREDITS"
SHOW_CREDITS="$SHOW_CREDITS"
CREDITS_FONT="$CREDITS_FONT"
CREDITS_SIZE="$CREDITS_SIZE"
CREDITS_X="$CREDITS_X"
CREDITS_Y="$CREDITS_Y"
CREDITS_START="$CREDITS_START"
CREDITS_END="$CREDITS_END"
EOF
}

show_header() {
    clear
    echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
    printf "${BLUE}║${WHITE} %-46s ${BLUE}║${NC}\n" "          AUTOMATED VIDEO PROCESSOR"
    echo -e "${BLUE}╠════════════════════════════════════════════════╣${NC}"
    printf "${BLUE}║${NC} Tool Name  : %-33s ${BLUE}║${NC}\n" "V-Encode (Termux Edition)"
    printf "${BLUE}║${NC} Version    : %-33s ${BLUE}║${NC}\n" "v$LOCAL_VERSION-Stable"
    printf "${BLUE}║${NC} Engine     : %-33s ${BLUE}║${NC}\n" "FFmpeg ($FFMPEG_VERSION)"
    printf "${BLUE}║${NC} Status     : %-33s ${BLUE}║${NC}\n" "Optimized"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
}

get_font_family() {
    local font_path="$1"
    if command -v fc-scan &> /dev/null; then
        family=$(fc-scan --format "%{family}\n" "$font_path" | cut -d, -f1)
        echo "$family"
    else
        basename "$font_path" | sed 's/\.[^.]*$//'
    fi
}

# --- BROWSER ---
file_browser() {
    local mode=$1
    while true; do
        show_header
        echo -e "${BLUE}╭────────────────────────────────────────────────╮${NC}"
        [ "$mode" == "video" ] && printf "${BLUE}│${GREEN} %-46s ${BLUE}│${NC}\n" "                PILIH FILE VIDEO" || printf "${BLUE}│${CYAN} %-46s ${BLUE}│${NC}\n" "          PILIH FILE SUBTITLE"
        local d_dir="$CURRENT_BROWSE_DIR"
        [ ${#d_dir} -gt 38 ] && d_dir="...${d_dir: -35}"
        printf "${BLUE}│${YELLOW} Loc: %-41s ${BLUE}│${NC}\n" "$d_dir"
        echo -e "${BLUE}├────────────────────────────────────────────────┤${NC}"
        local items=( ".." )
        for d in "$CURRENT_BROWSE_DIR"/*/; do [ -d "$d" ] && items+=( "$d" ); done
        if [ "$mode" == "video" ]; then
            for f in "$CURRENT_BROWSE_DIR"/*.{mp4,mkv,avi,mov}; do [ -f "$f" ] && items+=( "$f" ); done
        else
            for f in "$CURRENT_BROWSE_DIR"/*.{srt,ass}; do [ -f "$f" ] && items+=( "$f" ); done
        fi
        for i in "${!items[@]}"; do
            local num=$(printf "%02d" "$i")
            local itm_name=$(basename "${items[$i]}")
            [ ${#itm_name} -gt 32 ] && itm_name="${itm_name:0:29}..."
            if [ "${items[$i]}" == ".." ]; then
                printf "${BLUE}│${CYAN} [%s]${YELLOW} %-41s ${BLUE}│${NC}\n" "$num" " [ KEMBALI KE ATAS ]"
            elif [ -d "${items[$i]}" ]; then
                printf "${BLUE}│${CYAN} [%s]${BLUE} [DIR] %-35s ${BLUE}│${NC}\n" "$num" "$itm_name"
            else
                printf "${BLUE}│${CYAN} [%s]${WHITE} %-41s ${BLUE}│${NC}\n" "$num" "$itm_name"
            fi
        done
        echo -e "${BLUE}╰────────────────────────────────────────────────╯${NC}"
        echo -ne " Pilih ('q' batal): "; read choice
        [[ "$choice" == "q" ]] && return 1
        
        # Penanganan Input Non-Angka
        if [[ ! "$choice" =~ ^[0-9]+$ ]]; then
            echo -e " ${RED}[!] Masukkan angka!${NC}"; sleep 1; continue
        fi
        
        local idx=$((10#$choice))
        if [ -z "${items[$idx]}" ]; then
            echo -e " ${RED}[!] Pilihan tidak ada!${NC}"; sleep 1; continue
        fi

        local selected="${items[$idx]}"
        if [ "$selected" == ".." ]; then
            CURRENT_BROWSE_DIR=$(dirname "$CURRENT_BROWSE_DIR")
        elif [ -d "$selected" ]; then
            CURRENT_BROWSE_DIR="$selected"
        else
            SELECTED_FILE="$selected"
            return 0
        fi
    done
}

# --- PERBAIKAN FUNGSI PROCESSOR ---
start_processing() {
    if ! file_browser "video"; then return; fi
    local video_file="$SELECTED_FILE"
    if ! file_browser "subtitle"; then return; fi
    local sub_file="$SELECTED_FILE"

    show_header
    echo -e "${BLUE}╭─────────────── KONFIRMASI PROSES ──────────────╮${NC}"
    local vn=$(basename "$video_file"); [ ${#vn} -gt 34 ] && vn="${vn:0:31}..."
    local sn=$(basename "$sub_file"); [ ${#sn} -gt 34 ] && sn="${sn:0:31}..."
    printf "${BLUE}│${NC} Video : %-38s ${BLUE}│${NC}\n" "$vn"
    printf "${BLUE}│${NC} Sub   : %-38s ${BLUE}│${NC}\n" "$sn"
    echo -e "${BLUE}├────────────────────────────────────────────────┤${NC}"
    printf "${BLUE}│${NC} ${CYAN}[01]${NC} %-41s ${BLUE}│${NC}\n" "Hardsub (MP4 - Kompatibel)"
    printf "${BLUE}│${NC} ${CYAN}[02]${NC} %-41s ${BLUE}│${NC}\n" "Softsub (MKV - Cepat)"
    printf "${BLUE}│${NC} ${CYAN}[00]${NC} %-41s ${BLUE}│${NC}\n" "Batal"
    echo -e "${BLUE}╰────────────────────────────────────────────────╯${NC}"
    echo -ne " Pilihan: "; read mode_choice
    
    [[ "$mode_choice" == "0" || "$mode_choice" == "00" || -z "$mode_choice" ]] && return
    if [[ ! "$mode_choice" =~ ^[0-9]+$ ]]; then echo -e " ${RED}[!] Input salah!${NC}"; sleep 1; return; fi

    run_api termux-wake-lock 
    output="${video_file%.*}_VEncode"
    
    if [ "$((10#$mode_choice))" == "1" ]; then
        echo -e "${GREEN}[*] Memulai Hardsub${NC}"
        local sub_path_esc=$(echo "$sub_file" | sed "s/'/\\\\\\'/g" | sed 's/:/\\:/g')
        
        # 1. Masukkan Filter Subtitle
        FILTER="subtitles='${sub_path_esc}':force_style='FontName=$FONT_NAME,FontSize=$FONT_SIZE,MarginV=$MARGIN_V'"
        
        # 2. Tambahkan Filter Credits jika statusnya "true"
        if [ "$SHOW_CREDITS" == "true" ]; then
            # Kita gabungkan filter dengan tanda koma (,)
            FILTER="$FILTER,drawtext=text='$CREDITS':font='${CREDITS_FONT}':fontcolor=white@0.75:fontsize=$CREDITS_SIZE:x=$CREDITS_X:y=$CREDITS_Y:enable='between(t,$CREDITS_START,$CREDITS_END)'"
        fi
        
        ffmpeg -y -i "$video_file" -vf "$FILTER" -c:v libx264 -preset superfast -pix_fmt yuv420p -c:a copy "${output}.mp4"
        
    elif [ "$((10#$mode_choice))" == "2" ]; then
        echo -e "${GREEN}[*] Memulai Softsub (Tanpa Credits)...${NC}"
        ffmpeg -y -i "$video_file" -i "$sub_file" -c copy -c:s srt "${output}.mkv"
    fi
    
    run_api termux-wake-unlock
    echo -e "\n${GREEN}[✓] Selesai!${NC}"; sleep 2
}

# --- SETTINGS & FONTS ---
import_font() {
    local target_var_name=$1
    while true; do
        show_header
        echo -e "${BLUE}╭────────────────────────────────────────────────╮${NC}"
        printf "${BLUE}│${YELLOW} %-46s ${BLUE}│${NC}\n" "          PILIH FONT DARI DOWNLOAD"
        echo -e "${BLUE}├────────────────────────────────────────────────┤${NC}"
        fonts=( /sdcard/Download/*.ttf /sdcard/Download/*.otf )
        if [ ! -e "${fonts[0]}" ]; then 
            printf "${BLUE}│${RED} %-46s ${BLUE}│${NC}\n" " [!] Tidak ada file font di Download."
            echo -e "${BLUE}╰────────────────────────────────────────────────╯${NC}"; sleep 2; return
        fi
        for i in "${!fonts[@]}"; do
            local d_name=$(basename "${fonts[$i]}"); [ ${#d_name} -gt 38 ] && d_name="${d_name:0:35}..."
            printf "${BLUE}│${CYAN} [%02d]${NC} %-41s ${BLUE}│${NC}\n" "$((i+1))" "$d_name"
        done
        printf "${BLUE}│${CYAN} [00]${NC} %-41s ${BLUE}│${NC}\n" "Kembali"
        echo -e "${BLUE}╰────────────────────────────────────────────────╯${NC}"
        echo -ne "\n Pilih Nomor: "; read f_choice
        [[ "$f_choice" == "0" || "$f_choice" == "00" || -z "$f_choice" ]] && return
        if [[ ! "$f_choice" =~ ^[0-9]+$ ]]; then continue; fi
        local idx=$((10#$f_choice - 1))
        if [ -f "${fonts[$idx]}" ]; then
            cp "${fonts[$idx]}" "$FONT_DIR/"
            local family=$(get_font_family "${fonts[$idx]}")
            eval "$target_var_name=\"$family\""
            echo -e " ${GREEN}[✓] Font $family dipilih!${NC}"; sleep 1; return
        fi
    done
}

menu_credits() {
    while true; do
        show_header
        echo -e "${BLUE}╭─────────────── PENGATURAN CREDITS ─────────────╮${NC}"
        printf "${BLUE}│${NC} ${CYAN}[01]${NC} Status  : %-31s ${BLUE}│${NC}\n" "$SHOW_CREDITS"
        printf "${BLUE}│${NC} ${CYAN}[02]${NC} Teks    : %-31s ${BLUE}│${NC}\n" "$CREDITS"
        printf "${BLUE}│${NC} ${CYAN}[03]${NC} Size    : %-31s ${BLUE}│${NC}\n" "$CREDITS_SIZE"
        printf "${BLUE}│${NC} ${CYAN}[04]${NC} Posisi  : X:%-3s Y:%-3s                     ${BLUE}│${NC}\n" "$CREDITS_X" "$CREDITS_Y"
        printf "${BLUE}│${NC} ${CYAN}[05]${NC} Durasi  : %-3ss s/d %-3ss                   ${BLUE}│${NC}\n" "$CREDITS_START" "$CREDITS_END"
        printf "${BLUE}│${NC} ${CYAN}[06]${NC} Font    : %-31s ${BLUE}│${NC}\n" "$CREDITS_FONT"
        printf "${BLUE}│${NC} ${CYAN}[00]${NC} Kembali %-33s ${BLUE}│${NC}\n" ""
        echo -e "${BLUE}╰────────────────────────────────────────────────╯${NC}"
        echo -ne " Pilih: "; read c_choice
        [[ "$c_choice" == "0" || "$c_choice" == "00" || -z "$c_choice" ]] && break
        if [[ ! "$c_choice" =~ ^[0-9]+$ ]]; then continue; fi
        case $((10#$c_choice)) in
            1) [[ "$SHOW_CREDITS" == "true" ]] && SHOW_CREDITS="false" || SHOW_CREDITS="true" ;;
            2) echo -ne " Teks: "; read CREDITS ;;
            3) echo -ne " Size: "; read CREDITS_SIZE ;;
            4) echo -ne " X: "; read CREDITS_X; echo -ne " Y: "; read CREDITS_Y ;;
            5) echo -ne " Start: "; read CREDITS_START; echo -ne " End: "; read CREDITS_END ;;
            6) import_font "CREDITS_FONT" ;;
        esac
    done
}

menu_settings() {
    while true; do
        show_header
        echo -e "${BLUE}╭────────────────── PENGATURAN ──────────────────╮${NC}"
        printf "${BLUE}│${NC} ${CYAN}[01]${NC} Font Name      : %-24s ${BLUE}│${NC}\n" "$FONT_NAME"
        printf "${BLUE}│${NC} ${CYAN}[02]${NC} Subtitle Size  : %-24s ${BLUE}│${NC}\n" "$FONT_SIZE"
        printf "${BLUE}│${NC} ${CYAN}[03]${NC} Margin Vertikal: %-24s ${BLUE}│${NC}\n" "$MARGIN_V"
        printf "${BLUE}│${NC} ${CYAN}[04]${NC} Atur Credits   : %-24s ${BLUE}│${NC}\n" "Konfigurasi ->"
        printf "${BLUE}│${NC} ${CYAN}[05]${NC} Import Font    : %-24s ${BLUE}│${NC}\n" "Dari Download"
        printf "${BLUE}│${NC} ${CYAN}[06]${NC} Reset Config   : %-24s ${BLUE}│${NC}\n" "Default"
        printf "${BLUE}│${NC} ${CYAN}[00]${NC} Simpan & Keluar %-25s ${BLUE}│${NC}\n" ""
        echo -e "${BLUE}╰────────────────────────────────────────────────╯${NC}"
        echo -ne " Pilih: "; read s_choice
        [[ "$s_choice" == "0" || "$s_choice" == "00" || -z "$s_choice" ]] && { save_config; break; }
        if [[ ! "$s_choice" =~ ^[0-9]+$ ]]; then continue; fi
        case $((10#$s_choice)) in
            1) available_fonts=( "$FONT_DIR"/* )
               if [ -e "${available_fonts[0]}" ]; then
                   show_header
                   echo -e "${BLUE}╭──────────────── PILIH FONT SISTEM ─────────────╮${NC}"
                   for i in "${!available_fonts[@]}"; do
                       printf "${BLUE}│${CYAN} [%02d]${NC} %-41s ${BLUE}│${NC}\n" "$((i+1))" "$(basename "${available_fonts[$i]}")"
                   done
                   echo -e "${BLUE}╰────────────────────────────────────────────────╯${NC}"
                   echo -ne " Pilih: "; read p_choice
                   if [[ "$p_choice" =~ ^[0-9]+$ ]]; then
                       idx=$((10#$p_choice - 1))
                       [ -f "${available_fonts[$idx]}" ] && FONT_NAME=$(get_font_family "${available_fonts[$idx]}")
                   fi
               fi ;;
            2) echo -ne " Size: "; read FONT_SIZE ;;
            3) echo -ne " Margin: "; read MARGIN_V ;;
            4) menu_credits ;;
            5) import_font "FONT_NAME" ;;
            6) rm -f "$CONFIG_FILE"; init_config ;;
        esac
    done
}

# --- MAIN LOOP ---
init_config
while true; do
    show_header
    echo -e "${BLUE}╭─────────────────── MENU UTAMA ─────────────────╮${NC}"
    printf "${BLUE}│${NC} ${CYAN}[01]${NC} %-41s ${BLUE}│${NC}\n" "Start Processing"
    printf "${BLUE}│${NC} ${CYAN}[02]${NC} %-41s ${BLUE}│${NC}\n" "Tool Settings"
    printf "${BLUE}│${NC} ${CYAN}[03]${NC} %-41s ${BLUE}│${NC}\n" "Open GitHub"
    printf "${BLUE}│${NC} ${CYAN}[04]${NC} %-41s ${BLUE}│${NC}\n" "Open Editor"
    printf "${BLUE}│${NC} ${CYAN}[00]${NC} %-41s ${BLUE}│${NC}\n" "Exit"
    echo -e "${BLUE}╰────────────────────────────────────────────────╯${NC}"
    echo -ne "\n Pilih Menu: "; read main_choice
    
    # Validasi Input Menu Utama
    if [[ ! "$main_choice" =~ ^[0-9]+$ ]]; then
        [ ! -z "$main_choice" ] && echo -e " ${RED}[!] Masukkan angka!${NC}" && sleep 1
        continue
    fi

    case $((10#$main_choice)) in
        1) start_processing ;;
        2) menu_settings ;;
        3) run_api termux-open "https://github.com/mindsetmot" ;;
        4) run_api termux-open "https://mindsetmot.github.io/subtitle-editor-web/" ;;
        0) echo -e "${GREEN}Sampai jumpa!${NC}"; exit 0 ;;
        *) echo -e " ${RED}[!] Menu tidak ada!${NC}"; sleep 1 ;;
    esac
done