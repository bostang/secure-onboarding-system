#!/bin/bash

# ---
## Konfigurasi Komponen Proyek
# Sesuaikan jalur relatif dan perintah start untuk setiap komponen.
# Path harus relatif dari root repositori induk.

# --- Frontend (Vite/NPM) ---
FRONTEND_PATH="frontend-secure-onboarding-system"
FRONTEND_INSTALL_CMD="npm install"
FRONTEND_START_CMD="npm run dev"
FRONTEND_TAB_NAME="Frontend"
FRONTEND_PORT="5173"

# --- Backend (Spring Boot/Maven) ---
BACKEND_PATH="backend-secure-onboarding-system"
BACKEND_INSTALL_CMD="./setup.sh"
BACKEND_START_CMD="mvn spring-boot:run" # Atau "java -jar target/*.jar" jika sudah di-build
BACKEND_TAB_NAME="Backend"
BACKEND_PORT="8080" # Diperbarui ke 8080

# --- Verifikator (Spring Boot/Maven) ---
VERIFICATOR_PATH="verificator-secure-onboarding-system"
VERIFICATOR_INSTALL_CMD="./setup.sh"
VERIFICATOR_START_CMD="mvn spring-boot:run" # Atau "java -jar target/*.jar" jika sudah di-build
VERIFICATOR_TAB_NAME="Verifikator"
VERIFICATOR_PORT="8081" # Diperbarui ke 8081

# ---
## Fungsi untuk Menjalankan Komponen di Tab Baru
run_in_new_tab() {
    local path="$1"
    local install_cmd="$2"
    local start_cmd="$3"
    local tab_name="$4"
    local component_name="$5"
    local port="$6"

    echo "Memulai proses untuk: ${component_name}"
    echo "Direktori: ${path}"

    # Periksa apakah direktori komponen ada
    if [ ! -d "$path" ]; then
        echo "Error: Direktori '${path}' tidak ditemukan. Lewati ${component_name}."
        return 1
    fi

    # Cek apakah port sudah digunakan
    if lsof -i :$port -t >/dev/null; then
        echo "Peringatan: Port ${port} (${component_name}) sudah digunakan. Membunuh proses yang menggunakan port ini..."
        # Menggunakan `kill -9` untuk memastikan proses terbunuh
        kill -9 $(lsof -i :$port -t) >/dev/null 2>&1
        sleep 1 # Beri waktu sejenak agar port dilepaskan
    fi

    # Inisialisasi string perintah lengkap yang akan dieksekusi di tab baru
    local full_command=""

    # Perintah untuk berpindah ke direktori komponen
    full_command+="cd \"$path\" && "

    # Cek apakah dependensi sudah terinstal (menggunakan file flag)
    # Jika file flag tidak ditemukan, jalankan instalasi
    if [ ! -f "$path/.${component_name}_installed" ]; then
        echo "Menjalankan instalasi dependensi untuk ${component_name}..."
        # Memberikan izin eksekusi jika itu adalah skrip setup (misalnya setup.sh)
        if [[ "$install_cmd" == *"./setup.sh"* ]]; then
            echo "Memberikan izin eksekusi untuk setup.sh di ${component_name}..."
            full_command+="chmod +x setup.sh && "
        fi
        # Tambahkan perintah instalasi ke string perintah lengkap
        # Gunakan '&&' untuk memastikan perintah berikutnya hanya berjalan jika yang ini berhasil
        full_command+="$install_cmd && "
        
    else
        echo "Dependensi ${component_name} sudah terinstal (berdasarkan flag .${component_name}_installed)."
    fi

    # Tambahkan perintah start ke string perintah lengkap
    full_command+="$start_cmd"

    echo "Membuka tab baru untuk ${component_name}..."
    # Eksekusi perintah di tab terminal baru
    # 'gnome-terminal --tab --title="${tab_name}" -- bash -c "${full_command}; exec bash" &'
    # 'exec bash' di akhir akan menjaga tab tetap terbuka setelah aplikasi berhenti
    gnome-terminal --tab --title="${tab_name}" -- bash -c "${full_command}; exec bash" &
    echo "Selesai memproses: ${component_name}"
    return 0
}

# ---
## Eksekusi Script
echo "Memulai semua layanan proyek di tab terminal baru..."
echo "Pastikan Anda menjalankan script ini dari root repositori induk."
echo "Pastikan emulator terminal Anda mendukung pembukaan tab baru melalui 'gnome-terminal --tab' atau yang setara."
echo "Untuk menghentikan layanan, tutup saja tab terminal masing-masing."
echo ""

# Opsional: Hapus flag instalasi lama jika ingin force install setiap kali
# Uncomment baris di bawah ini jika Anda ingin memaksa instalasi setiap kali skrip dijalankan
# find . -name ".*_installed" -type f -delete

# Jalankan setiap komponen di tab baru
run_in_new_tab "$FRONTEND_PATH" "$FRONTEND_INSTALL_CMD" "$FRONTEND_START_CMD" "$FRONTEND_TAB_NAME" "Frontend" "$FRONTEND_PORT"
sleep 1 # Beri jeda agar tab terbuka sempurna sebelum yang berikutnya
run_in_new_tab "$BACKEND_PATH" "$BACKEND_INSTALL_CMD" "$BACKEND_START_CMD" "$BACKEND_TAB_NAME" "Backend" "$BACKEND_PORT"
sleep 1
run_in_new_tab "$VERIFICATOR_PATH" "$VERIFICATOR_INSTALL_CMD" "$VERIFICATOR_START_CMD" "$VERIFICATOR_TAB_NAME" "Verifikator" "$VERIFICATOR_PORT"

echo "---"
echo "Semua layanan telah dicoba untuk dimulai di tab terminal baru."
echo "Periksa tab-tab yang baru terbuka untuk melihat *output* dan status setiap layanan."
echo "Proses selesai."
