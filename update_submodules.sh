#!/bin/bash

# ---
## Konfigurasi Submodule
# Sesuaikan array di bawah dengan jalur submodule dan branch yang diinginkan.
# Format: "path/to/submodule:nama-branch"
# Contoh: "verificator-secure-onboarding-system:main"

SUBMODULES=(
    "verificator-secure-onboarding-system:main"
    "backend-secure-onboarding-system:develop"
    "frontend-secure-onboarding-system:feature/login"
)

# ---
## Fungsi untuk Memperbarui Submodule
update_submodule() {
    local submodule_path="$1"
    local target_branch="$2"

    echo "---"
    echo "Memproses submodule: ${submodule_path}"
    echo "Branch yang ditargetkan: ${target_branch}"

    # Cek apakah direktori submodule ada
    if [ ! -d "$submodule_path" ]; then
        echo "Error: Direktori submodule '${submodule_path}' tidak ditemukan."
        echo "Pastikan submodule sudah ditambahkan dengan 'git submodule add' terlebih dahulu."
        return 1
    fi

    # Masuk ke direktori submodule
    if ! cd "$submodule_path"; then
        echo "Error: Gagal masuk ke direktori '${submodule_path}'."
        return 1
    fi

    # --- MEMAKSA AMBIL TERBARU ---
    # Reset keras untuk membuang perubahan lokal dan staged
    echo "Melakukan reset keras untuk menimpa perubahan lokal di '${submodule_path}'..."
    if ! git reset --hard HEAD; then
        echo "Peringatan: Gagal melakukan git reset --hard di '${submodule_path}'. Mungkin ada masalah dengan HEAD."
    fi

    # Membersihkan file yang tidak terlacak (untracked files)
    echo "Membersihkan file yang tidak terlacak di '${submodule_path}'..."
    if ! git clean -df; then
        echo "Peringatan: Gagal membersihkan file yang tidak terlacak di '${submodule_path}'."
    fi
    # --- AKHIR MEMAKSA AMBIL TERBARU ---


    # Fetch semua branch terbaru
    echo "Fetching branch terbaru di '${submodule_path}'..."
    if ! git fetch origin; then
        echo "Error: Gagal melakukan git fetch di '${submodule_path}'."
        cd - > /dev/null
        return 1
    fi

    # Checkout ke branch yang ditargetkan
    echo "Checkout ke branch '${target_branch}' di '${submodule_path}'..."
    # Gunakan -f (force) untuk checkout, jika ada masalah Git akan tetap mencobanya
    if ! git checkout -f "$target_branch"; then
        echo "Error: Gagal checkout ke branch '${target_branch}' di '${submodule_path}'."
        echo "Pastikan branch '${target_branch}' ada di repositori remote."
        cd - > /dev/null
        return 1
    fi

    # Pull perubahan terbaru dari branch
    echo "Melakukan pull perubahan terbaru untuk branch '${target_branch}' di '${submodule_path}'..."
    # Gunakan --force untuk pull, ini akan menimpa histori lokal jika perlu
    if ! git pull --force origin "$target_branch"; then
        echo "Error: Gagal melakukan git pull --force di '${submodule_path}'. Mungkin ada konflik yang parah."
        cd - > /dev/null
        return 1
    fi

    # Kembali ke direktori induk
    cd - > /dev/null # Menggunakan > /dev/null agar tidak mencetak direktori
    echo "Selesai memproses '${submodule_path}'."
    return 0
}

# ---
## Eksekusi Script
echo "Memulai proses pembaruan submodule..."
echo "PERINGATAN: Script ini akan secara paksa menimpa perubahan lokal di submodule."
echo "Pastikan Anda menjalankan script ini dari root repositori induk."
echo ""

ALL_SUCCESS=true

for entry in "${SUBMODULES[@]}"; do
    IFS=':' read -r path branch <<< "$entry"
    update_submodule "$path" "$branch"
    if [ $? -ne 0 ]; then
        ALL_SUCCESS=false
    fi
done

echo "---"
if [ "$ALL_SUCCESS" = true ]; then
    echo "Semua submodule berhasil diperbarui ke branch yang ditentukan dan versi terbaru."
    echo "Jangan lupa untuk 'git add .' dan 'git commit -m \"Update submodules\"' di repositori induk jika ada perubahan."
else
    echo "Ada beberapa masalah saat memperbarui submodule. Harap periksa log di atas."
fi

echo "Proses selesai."