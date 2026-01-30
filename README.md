# 🎬 V-Encode - Automated Video Processor

[![Build Status](https://img.shields.io/badge/Status-Beta--Release-blueviolet?style=for-the-badge)](https://github.com/Mindsetmot/Automated-Video-Processor)
[![Engine](https://img.shields.io/badge/Engine-FFmpeg-green?style=for-the-badge)](https://ffmpeg.org/)
[![Platform](https://img.shields.io/badge/Platform-Termux-orange?style=for-the-badge)](https://termux.dev/)

> [!IMPORTANT]
> **Status Proyek**: Ini adalah proyek pribadi yang dikembangkan untuk kebutuhan internal dan saat ini masih dalam **tahap uji coba (Beta)**. Penggunaan secara luas mungkin akan menemui beberapa bug.

**V-Encode** adalah solusi baris perintah (CLI) yang dirancang khusus untuk mengotomatisasi proses pengolahan video (Hardsub & Softsub) di lingkungan **Termux**. Alat ini menyederhanakan kompleksitas FFmpeg menjadi antarmuka yang ramah pengguna.

---

### 🚀 Key Features

* **Smart Automation**: Menggabungkan video dan subtitle secara otomatis tanpa perlu mengetik perintah manual yang panjang.
* **Dual-Core Mode**: Mendukung **Hardsub** (Burn-in) untuk kompatibilitas maksimal dan **Softsub** (Muxing) untuk kecepatan tinggi.
* **Manajemen Font:** Impor font kustom (`.ttf`/`.otf`) langsung dari folder Download/Unduhan Anda atau gunakan font sistem.
* **Secure Input System**: Dilengkapi proteksi input untuk mencegah *crash* akibat kesalahan pengetikan pengguna.
* **Dynamic Branding**: Fitur kustomisasi watermark/credits dengan pengaturan posisi, font, dan durasi yang fleksibel.
* **Dukungan Wake-Lock:** Menggunakan `termux-api` untuk mencegah proses encoding terhenti saat layar mati.

---

### 📥 Quick Installation

Jalankan perintah ini untuk menginstal `V-Encode` (versi Binary/Compiled) beserta semua dependencies secara otomatis:

```bash
curl -L https://github.com/Mindsetmot/Automated-Video-Processor/raw/main/v-encode-installer.sh | bash
