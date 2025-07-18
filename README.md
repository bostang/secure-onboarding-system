# secure-onboarding-system

## Cara Menjalankan Aplikasi (Local)

### Cara Otomatis

> dapat digunakan pada OS linux/ UNIX (MAC OS)

```bash
# pastikan bahwa setiap submodul (frontend, backend, verifikator) sudah terupdate
./update_submodules.sh

# jalankan masing-masing submodul
./run.sh
```

### CARA MANUAL Menjalankan (bila script gagal)

Untuk menjalankan setiap komponen proyek Anda secara manual, Anda perlu membuka terminal terpisah untuk masing-masing layanan. Pastikan Anda memulai dari direktori `secure-onboarding-system` (root repositori induk Anda).

#### **1. Menjalankan Frontend**

Frontend adalah aplikasi web yang akan berinteraksi dengan pengguna.

1. **Buka terminal baru.**
2. **Pindah ke direktori Frontend:**

    ```bash
    cd frontend-secure-onboarding-system
    ```

3. **Instal dependensi Node.js:**
    Jalankan perintah ini hanya jika Anda belum pernah menginstalnya sebelumnya, atau jika ada perubahan pada `package.json`.

    ```bash
    npm install
    ```

4. **Jalankan aplikasi Frontend:**
    Aplikasi akan mulai berjalan, biasanya di `http://localhost:5173/`. Anda akan melihat *output* Vite di terminal ini.

    ```bash
    npm run dev
    ```

#### **2. Menjalankan Backend**

Backend adalah layanan utama yang menyediakan API dan logika bisnis.

1. **Buka terminal baru yang berbeda dari Frontend.**
2. **Pindah ke direktori Backend:**

    ```bash
    cd backend-secure-onboarding-system
    ```

3. **Jalankan skrip *setup* Backend:**
    Skrip ini kemungkinan akan menginstal dependensi Maven, membangun proyek, dan mungkin memulai database atau konfigurasi awal lainnya. Biarkan proses ini selesai.

    ```bash
    ./setup.sh
    ```

    *Catatan: Pastikan `setup.sh` memiliki izin eksekusi (`chmod +x setup.sh`) jika Anda mendapatkan error "Permission denied".*

#### **3. Menjalankan Verifikator**

Verifikator adalah layanan terpisah yang mungkin bertanggung jawab untuk proses verifikasi atau otentikasi.

1. **Buka terminal baru yang berbeda dari Frontend dan Backend.**
2. **Pindah ke direktori Verifikator:**

    ```bash
    cd verificator-secure-onboarding-system
    ```

3. **Jalankan skrip *setup* Verifikator:**
    Sama seperti Backend, skrip ini akan menyiapkan lingkungan dan menjalankan aplikasi Verifikator.

    ```bash
    ./setup.sh
    ```

    *Catatan: Pastikan `setup.sh` memiliki izin eksekusi (`chmod +x setup.sh`) jika Anda mendapatkan error "Permission denied".*

## Desain Sistem

### High-level Architecture

![high-level-architecture](./img/high-level-architecture.png)

### Blok Diagram

#### Level 1

![block-diagram-level-1](./img/block-diagram-level-1.png)

#### Level 2

![block-diagram-level-2](./img/block-diagram-level-2.png)

#### Level 3

![block-diagram-level-3](./img/block-diagram-level-3.png)

#### Level 4

![block-diagram-level-4](./img/block-diagram-level-4.png)

### Entity Relationship Diagram (ERD)

![entity-relationship-diagram](./img/entity-relationship-diagram.png)

### Kubernetes Architecture Design

![k8s-architecture-design](./img/k8s-architecture-design.png)

### Tech Stack

![tech-stack](./img/tech-stack.png)

### Use Case Diagram

![use-case-diagram](./img/use-case-diagram.png)

### Desain Repositori

![repo-strategy](./img/repo-strategy.png)
