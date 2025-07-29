# Deliverables W3 (X-men)

> Kelompok : 2

**Daftar Deliverables**:

```tree
.
├── Deployment & Service
│   ├── application
│   │   ├── backend-deployment.yaml
│   │   ├── frontend-deployment.yaml
│   │   ├── frontend-service.yaml
│   │   ├── postgresql-deployment.yaml
│   │   └── postgresql-service.yaml
│   ├── jenkins
│   │   ├── jenkins-master-deployment.yaml
│   │   └── jenkins-master-service.yaml
│   └── sonarqube
│       ├── configmap.yaml
│       ├── postgres-statefulset.yaml
│       └── sonarqube-statefulset.yaml
├── Dockerfile
│   ├── Dockerfile.backend
│   ├── Dockerfile.frontend
│   └── Dockerfile.verify-dukcapil
├── prometheus.yaml
└── README.md
```

## Langkah-langkah Deplyment

### **1. Langkah-langkah Deployment**

Ikuti langkah-langkah berikut untuk melakukan deployment komponen aplikasi Anda ke kluster Kubernetes. Pastikan Anda memiliki `kubectl` yang terkonfigurasi dan terhubung ke kluster target Anda.

#### **1.1. Buat Namespace**

Pertama, buat namespace yang diperlukan untuk mengatur deployment Anda:

```bash
kubectl create namespace jenkins
kubectl create namespace sonarqube
kubectl create namespace backend
kubectl create namespace frontend
```

#### **1.2. Deployment PostgreSQL untuk SonarQube**

Database PostgreSQL untuk SonarQube memerlukan secret untuk kredensial database dan configmap untuk konfigurasi.

1. **Buat Secret Database SonarQube:**
    Buat secret bernama `sonarqube-db-secret` di namespace `sonarqube`. Ganti `your_db_name`, `your_username`, dan `your_password` dengan nilai yang Anda inginkan.

    ```bash
    kubectl create secret generic sonarqube-db-secret \
      --namespace=sonarqube \
      --from-literal=database=your_db_name \
      --from-literal=username=your_username \
      --from-literal=password=your_password
    ```

2. **Buat ConfigMap PostgreSQL untuk SonarQube:**
    Buat ConfigMap bernama `postgres-config` di namespace `sonarqube`, berisi konfigurasi PostgreSQL (misalnya, `postgresql.conf`).

    ```bash
    # Contoh isi postgresql.conf (simpan ini ke file, misal, postgresql.conf)
    # max_connections = 100
    # shared_buffers = 256MB
    # ...

    kubectl create configmap postgres-config \
      --namespace=sonarqube \
      --from-file=postgresql.conf=<path/to/your/postgresql.conf>
    ```

3. **Deployment PostgreSQL StatefulSet dan Service untuk SonarQube:**
    Terapkan `postgres-statefulset.yaml` yang mencakup StatefulSet untuk database PostgreSQL dan Service ClusterIP terkait untuk SonarQube.

    ```bash
    kubectl apply -f postgres-statefulset.yaml
    ```

#### **1.3. Deployment SonarQube**

SonarQube memerlukan ConfigMap untuk file `sonar.properties` miliknya.

1. **Buat ConfigMap SonarQube:**
    Buat ConfigMap bernama `sonarqube-config` di namespace `sonarqube`, berisi konfigurasi `sonar.properties` SonarQube.

    ```bash
    # Contoh isi sonar.properties (simpan ini ke file, misal, sonar.properties)
    # sonar.jdbc.url=jdbc:postgresql://postgresql:5432/sonarqube
    # sonar.jdbc.username=sonarqube
    # sonar.jdbc.password=sonarqube
    # ...

    kubectl create configmap sonarqube-config \
      --namespace=sonarqube \
      --from-file=sonar.properties=<path/to/your/sonar.properties>
    ```

2. **Deployment SonarQube StatefulSet dan Service:**
    Terapkan `sonarqube-statefulset.yaml` yang mencakup StatefulSet untuk SonarQube dan Service ClusterIP terkait.

    ```bash
    kubectl apply -f sonarqube-statefulset.yaml
    ```

#### **1.4. Deployment PostgreSQL untuk Backend**

Database PostgreSQL untuk backend juga memerlukan secret untuk kredensial.

1. **Buat Secret Database Backend:**
    Buat secret bernama `postgres-credentials` di namespace `backend`. Ganti `your_backend_db_name`, `your_backend_username`, dan `your_backend_password` dengan nilai yang Anda inginkan.

    ```bash
    kubectl create secret generic postgres-credentials \
      --namespace=backend \
      --from-literal=database=your_backend_db_name \
      --from-literal=username=your_backend_username \
      --from-literal=password=your_backend_password
    ```

2. **Deployment PostgreSQL StatefulSet untuk Backend:**
    Terapkan `postgresql-deployment.yaml` yang mendefinisikan StatefulSet untuk PostgreSQL backend.

    ```bash
    kubectl apply -f postgresql-deployment.yaml
    ```

3. **Deployment PostgreSQL Service untuk Backend:**
    Terapkan `postgresql-service.yaml` yang mendefinisikan Service ClusterIP untuk PostgreSQL backend.

    ```bash
    kubectl apply -f postgresql-service.yaml
    ```

#### **1.5. Deployment Aplikasi Backend**

Aplikasi backend memerlukan deployment dan service.

1. **Deployment Backend Deployment dan Service:**
    Terapkan `backend-deployment.yaml` yang mencakup Deployment untuk aplikasi backend dan Service LoadBalancer terkait.

    ```bash
    kubectl apply -f backend-deployment.yaml
    ```

#### **1.6. Deployment Aplikasi Frontend**

Aplikasi frontend memerlukan deployment dan service.

1. **Deployment Frontend Deployment:**
    Terapkan `frontend-deployment.yaml` yang mendefinisikan Deployment untuk aplikasi frontend.

    ```bash
    kubectl apply -f frontend-deployment.yaml
    ```

2. **Deployment Frontend Service:**
    Terapkan `frontend-service.yaml` yang mendefinisikan Service LoadBalancer untuk aplikasi frontend.

    ```bash
    kubectl apply -f frontend-service.yaml
    ```

#### **1.7. Deployment Jenkins**

Jenkins memerlukan PersistentVolumeClaim, Service Account, Deployment, dan Service.

1. **Buat PersistentVolumeClaim (PVC) Jenkins:**
    Anda perlu mendefinisikan PVC untuk Jenkins. Buat file bernama `jenkins-pvc.yaml` (contoh di bawah) dan terapkan.

    ```yaml
    # jenkins-pvc.yaml
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: jenkins-pv-claim
      namespace: jenkins
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 10Gi # Sesuaikan penyimpanan sesuai kebutuhan
    ```

    ```bash
    kubectl apply -f jenkins-pvc.yaml
    ```

2. **Buat Service Account Jenkins:**
    Buat service account untuk Jenkins. Anda mungkin perlu mendefinisikan role dan role binding untuknya nanti, tergantung pada interaksi Jenkins dengan API Kubernetes.

    ```yaml
    # jenkins-sa.yaml
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: jenkins-sa
      namespace: jenkins
    ```

    ```bash
    kubectl apply -f jenkins-sa.yaml
    ```

3. **Deployment Jenkins Master Deployment:**
    Terapkan `jenkins-master-deployment.yaml` yang mendefinisikan Deployment untuk master Jenkins.

    ```bash
    kubectl apply -f jenkins-master-deployment.yaml
    ```

4. **Deployment Jenkins Master Service:**
    Terapkan `jenkins-master-service.yaml` yang mendefinisikan Service LoadBalancer untuk master Jenkins.

    ```bash
    kubectl apply -f jenkins-master-service.yaml
    ```

-----

### **2. Konfigurasi**

Bagian ini merinci konfigurasi spesifik untuk setiap komponen yang di-deploy.

#### **2.1. PostgreSQL untuk SonarQube**

- **Kredensial Database:** Dikonfigurasi melalui `sonarqube-db-secret` (nama database, username, password).
- **Konfigurasi PostgreSQL:** Dikonfigurasi melalui `postgres-config` (misalnya, `max_connections`, `shared_buffers`).
- **Persistensi Data:** Data dipertahankan menggunakan PersistentVolumeClaim bernama `postgres-data` dengan permintaan penyimpanan 2Gi.

#### **2.2. SonarQube**

- **Koneksi Database:** SonarQube terhubung ke database PostgreSQL menggunakan variabel lingkungan `SONAR_JDBC_URL`, `SONAR_JDBC_USERNAME`, dan `SONAR_JDBC_PASSWORD`, yang mengambil nilai dari `sonarqube-db-secret`.
- **Konfigurasi Aplikasi:** Pengaturan umum SonarQube dikelola melalui ConfigMap `sonarqube-config` yang memetakan ke `sonar.properties`.
- **Persistensi Data:** Data, log, dan ekstensi SonarQube dipertahankan menggunakan PersistentVolumeClaims bernama `sonarqube-data` (2Gi), `sonarqube-logs` (1Gi), dan `sonarqube-extensions` (1Gi) secara berturut-turut.
- **Sumber Daya:** Meminta 4Gi memori dan 1 CPU, batas 6Gi memori dan 2 CPU.

#### **2.3. PostgreSQL untuk Backend**

- **Kredensial Database:** Dikonfigurasi melalui secret `postgres-credentials` (nama database, username, password).
- **Persistensi Data:** Data dipertahankan menggunakan PersistentVolumeClaim bernama `postgres-data` dengan permintaan penyimpanan 5Gi.
- **Sumber Daya:** Meminta 2Gi memori dan 500m CPU, batas 4Gi memori dan 1.5 CPU.

#### **2.4. Aplikasi Backend**

- **Host Database:** Variabel lingkungan `DB_HOST` diatur ke `postgresql-service.backend` untuk terhubung ke layanan PostgreSQL backend di namespace `backend`.
- **Kredensial Database:** `DB_USERNAME` dan `DB_PASSWORD` diambil dari secret `postgres-credentials`.
- **Port:** Aplikasi mendengarkan di port 8080.
- **Sumber Daya:** Meminta 512Mi memori dan 250m CPU, batas 1Gi memori dan 1 CPU.

#### **2.5. Aplikasi Frontend**

- **Port:** Aplikasi mendengarkan di port 8080.
- **Sumber Daya:** Meminta 64Mi memori dan 50m CPU, batas 128Mi memori dan 100m CPU.

#### **2.6. Jenkins**

- **Kredensial Admin:** ID admin awal adalah `admin` dan kata sandi adalah `supersecurepassword` yang diatur melalui variabel lingkungan `JENKINS_ADMIN_ID` dan `JENKINS_ADMIN_PASSWORD`. **Catatan: Sangat disarankan untuk segera mengubah kata sandi ini setelah login pertama dan menggunakan manajemen secret yang tepat.**
- **Opsi Java:** Dikonfigurasi melalui `JAVA_OPTS` untuk mengatur memori JVM (`-Xmx2048m -Xms512m`).
- **Persistensi Data:** Direktori home Jenkins (`/var/jenkins_home`) dipasang ke PersistentVolumeClaim bernama `jenkins-pv-claim`.
- **Sumber Daya:** Meminta 3Gi memori dan 1000m CPU, batas 4Gi memori dan 1500m CPU.
- **Service Account:** Menggunakan `jenkins-sa` untuk interaksi API Kubernetes.

#### **2.7. Prometheus (File Konfigurasi)**

- `prometheus.yaml` yang disediakan adalah file konfigurasi untuk Prometheus, bukan sumber daya Kubernetes. Ini mendefinisikan `scrape_config` untuk job bernama `registration-customer-spring-boot-app` untuk mengambil metrik dari `host.docker.internal:8080` pada endpoint `/api/actuator/prometheus` setiap 15 detik. Konfigurasi ini akan digunakan saat menyiapkan instans Prometheus *di luar* Kubernetes atau dalam deployment Prometheus yang mengonsumsi konfigurasi ini. Jika Prometheus di-deploy di dalam Kubernetes, `targets` biasanya akan menjadi konfigurasi penemuan layanan Kubernetes.

-----

### **3. Hasil Verifikasi**

Setelah deployment, verifikasi status sumber daya Kubernetes Anda.

#### **3.1. Periksa Status Namespace**

```bash
kubectl get namespaces
```

Output yang diharapkan harus menunjukkan namespace `jenkins`, `sonarqube`, `backend`, dan `frontend` dalam status `Active`.

#### **3.2. Periksa Status Pod**

```bash
kubectl get pods -n jenkins
kubectl get pods -n sonarqube
kubectl get pods -n backend
kubectl get pods -n frontend
```

Output yang diharapkan: Semua pod harus dalam status `Running` atau `Completed`, dan kolom `READY` mereka harus menunjukkan semua kontainer sudah siap (misalnya, `1/1`).

#### **3.3. Periksa Status Service**

```bash
kubectl get services -n jenkins
kubectl get services -n sonarqube
kubectl get services -n backend
kubectl get services -n frontend
```

Output yang diharapkan:

- `jenkins-service`, `backend-service`, dan `frontend-service` harus memiliki `EXTERNAL-IP` eksternal jika kluster Kubernetes Anda mendukung layanan LoadBalancer dan penyedia cloud dikonfigurasi.
- `postgresql` (di namespace `sonarqube`), `postgresql-service` (di namespace `backend`), dan `sonarqube` harus memiliki `ClusterIP`.

#### **3.4. Periksa Status Deployment/StatefulSet**

```bash
kubectl get deployments -n backend
kubectl get deployments -n frontend
kubectl get deployments -n jenkins
kubectl get statefulsets -n sonarqube
kubectl get statefulsets -n backend
```

Output yang diharapkan: Semua deployment dan statefulset harus menunjukkan replika `READY` yang cocok dengan replika `DESIRED` (misalnya, `1/1`).

#### **3.5. Mengakses Aplikasi**

- **Jenkins:** Akses Jenkins menggunakan `EXTERNAL-IP` dari `jenkins-service` di port 8080 (misalnya, `http://<jenkins-service-external-ip>:8080`).
- **SonarQube:** Akses SonarQube menggunakan `EXTERNAL-IP` dari layanan LoadBalancer jika Anda mengeksposnya (tidak langsung dalam `sonarqube-statefulset.yaml` yang disediakan, yang hanya membuat layanan ClusterIP). Jika Anda ingin akses eksternal, Anda perlu membuat Ingress atau layanan LoadBalancer untuk SonarQube. Untuk akses internal, Anda dapat menggunakan `http://sonarqube.sonarqube:9000`.
- **Backend:** Akses aplikasi backend menggunakan `EXTERNAL-IP` dari `backend-service` di port 8080 (misalnya, `http://<backend-service-external-ip>:8080`).
- **Frontend:** Akses aplikasi frontend menggunakan `EXTERNAL-IP` dari `frontend-service` di port 8080 (misalnya, `http://<frontend-service-external-ip>:8080`).

#### **3.6. Periksa Log untuk Kesalahan**

```bash
kubectl logs <nama-pod> -n <nama-namespace>
```

Periksa log untuk pesan `Error` atau `Failed` untuk semua pod.

-----

### **4. Kendala (Issues) dan Troubleshooting**

Bagian ini menguraikan masalah umum dan langkah-langkah pemecahannya.

#### **4.1. Pod Tetap dalam Status Pending**

- **Penyebab:** Sumber daya yang tidak mencukupi (CPU, memori) di kluster, atau tidak ada node yang tersedia dengan pemilih node/toleransi yang cocok. Selain itu, PersistentVolumeClaims (PVC) mungkin tidak terikat jika tidak ada PersistentVolume (PV) yang cocok yang tersedia atau disediakan oleh StorageClass.
- **Troubleshooting:**
  - Periksa events: `kubectl describe pod <nama-pod> -n <nama-namespace>` untuk melihat mengapa pod tertunda.
  - Periksa sumber daya kluster: `kubectl top nodes` untuk melihat CPU/memori yang tersedia.
  - Periksa status PVC: `kubectl get pvc -n <nama-namespace>`. Jika PVC berstatus `Pending`, pastikan Anda memiliki StorageClass yang terkonfigurasi atau buat PV secara manual.
  - Tingkatkan ukuran kluster atau sesuaikan permintaan/batas sumber daya di file YAML Anda.

#### **4.2. Pod dalam CrashLoopBackOff**

- **Penyebab:** Kesalahan aplikasi, konfigurasi yang salah, variabel lingkungan yang hilang, atau masalah koneksi ke dependensi (misalnya, database).
- **Troubleshooting:**
  - Periksa log: `kubectl logs <nama-pod> -n <nama-namespace>` untuk mengidentifikasi kesalahan spesifik.
  - Verifikasi ConfigMaps dan Secrets: Pastikan keduanya ada dan berisi nilai yang benar.
  - Periksa konektivitas ke dependensi:
    - Untuk backend, pastikan `postgresql-service` berjalan dan dapat diakses dari pod backend.
    - Untuk SonarQube, pastikan layanan `postgresql` berjalan di namespace `sonarqube` dan dapat diakses.
  - Periksa pull gambar: Pastikan gambar Docker ada dan dapat diakses. `kubectl describe pod <nama-pod> -n <nama-namespace>` mungkin menunjukkan `ImagePullBackOff` jika ada masalah saat menarik gambar.

#### **4.3. Service Tidak Mendapatkan IP Eksternal (Tipe LoadBalancer)**

- **Penyebab:** Lingkungan kluster Kubernetes Anda mungkin tidak mendukung layanan tipe `LoadBalancer` (misalnya, kluster on-premises tanpa integrasi penyedia cloud) atau ada masalah dengan pengontrol LoadBalancer penyedia cloud.
- **Troubleshooting:**
  - Periksa dokumentasi kluster untuk dukungan LoadBalancer.
  - Pertimbangkan untuk menggunakan tipe layanan `NodePort` dan mengakses melalui IP node dan port, atau menyiapkan pengontrol Ingress (misalnya, Nginx Ingress Controller) untuk akses eksternal.
  - Verifikasi kuota layanan LoadBalancer penyedia cloud atau batas sumber daya.

#### **4.4. Aplikasi Tidak Dapat Terhubung ke Database**

- **Penyebab:** Kredensial database yang salah, host/port database yang salah, kebijakan jaringan yang mencegah komunikasi, atau database belum sepenuhnya siap.
- **Troubleshooting:**
  - Verifikasi `DB_HOST`, `DB_USERNAME`, `DB_PASSWORD` di deployment aplikasi (misalnya, `backend-deployment.yaml`) dan pastikan secret `postgres-credentials` dibuat dengan benar.
  - Verifikasi `SONAR_JDBC_URL`, `SONAR_JDBC_USERNAME`, `SONAR_JDBC_PASSWORD` untuk SonarQube dan `sonarqube-db-secret`.
  - Pastikan layanan database (misalnya, `postgresql-service.backend` atau `postgresql.sonarqube`) `Running` dan dapat diakses.
  - Dari dalam pod aplikasi, coba ping layanan database: `kubectl exec -it <nama-pod-aplikasi> -n <nama-namespace> -- ping <nama-layanan-db>`.
  - Periksa log pod database untuk kesalahan.

#### **4.5. Persistent Volumes Tidak Disediakan**

- **Penyebab:** Tidak ada StorageClass yang didefinisikan, atau StorageClass default tidak berfungsi dengan lingkungan Anda, atau tidak ada PersistentVolume yang tersedia untuk memenuhi permintaan PVC.
- **Troubleshooting:**
  - Periksa StorageClass: `kubectl get storageclass`.
  - Periksa status PVC: `kubectl get pvc -n <nama-namespace>`. Jika statusnya `Pending`, jelaskan untuk melihat alasannya.
  - Jika Anda menggunakan penyedia cloud, pastikan penyedia cloud tersebut dikonfigurasi dengan benar untuk menyediakan volume persisten.
  - Untuk kluster on-premises, pertimbangkan untuk menggunakan penyedia volume lokal atau solusi penyimpanan eksternal seperti Rook, Longhorn, atau NFS.
