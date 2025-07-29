# Deliverables Backend W3
> Kelompok : 2

- [X] `DockerFile`
- [X] `deployment.yaml`
- [X] `service.yaml`
- [X] `hpa.yaml`
- [X] `values.yaml`
- [X] `grafana-dashboard.png`   
- [X] `README.md`
- [X] `prometheus-config.yaml`
- [X] `link-repo.txt`

## DockerFile
`DockerFile` merupakan File konfigurasi Docker untuk membangun image aplikasi Spring Boot

### `Dockerfile BE`
```docker
# Multi-stage build untuk Secure Onboarding
# Stage 1: Build stage
FROM maven:3.9.8-eclipse-temurin-21 AS build
WORKDIR /app

# Copy pom.xml dan download dependencies
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn
RUN ./mvnw dependency:go-offline

# Copy source code
COPY src ./src

# Copy environment files dengan default fallback
COPY .env* ./
COPY src/main/resources/model-parsec-465503-p3-firebase-adminsdk-fbsvc-1e9901efad.json* ./src/main/resources/

# Build aplikasi
RUN ./mvnw clean package -DskipTests

# Stage 2: Runtime stage
FROM eclipse-temurin:21-jre
WORKDIR /app

# Copy JAR dari build stage
COPY --from=build /app/target/*.jar app.jar

# Copy .env file ke runtime (jika ada)
COPY --from=build /app/.env* ./

# Environment variables (match dengan application.properties)
ENV DB_URL=jdbc:postgresql://postgres-db:5432/customer_registration
ENV DB_USERNAME=postgres
ENV DB_PASSWORD=postgres123
ENV JWT_SECRET=aB3dF6gH9jK2mN5pQ8rS1tU4vW7xY0zA3bC6dE9fG2hJ5kL8mO1pR4sT7uV0wX3y
ENV JWT_EXPIRATION=86400000
ENV SERVER_PORT=8080
ENV FIREBASE_CONFIG_PATH=model-parsec-465503-p3-firebase-adminsdk-fbsvc-1e9901efad.json
ENV DUKCAPIL_SERVICE_URL=http://dukcapil-dummy:8081

# Expose port
EXPOSE 8080

# Run aplikasi dengan nama JAR yang fixed
CMD ["java", "-jar", "app.jar"]
 
 ```

 ### `Dockerfile FE`

 ```docker
 # Stage 1: Build aplikasi
FROM node:18-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Stage 2: Serve via Nginx
FROM nginx:stable-alpine AS production
COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]

```

### `Dockerfile Ops`

```docker
FROM maven:3.8.7-openjdk-17 AS builder

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src

RUN mvn clean install -DskipTests

FROM openjdk:17-jdk-slim


WORKDIR /app

ARG JAR_FILE=target/ops-secure-onboarding-system-0.0.1-SNAPSHOT.jar
COPY --from=builder /app/${JAR_FILE} app.jar

EXPOSE 8080

# Command to run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
 ```

 ### `Dockerfile Verificator`
```docker
 # Stage 1: Build aplikasi menggunakan Maven
# Gunakan image Maven + Java 21
FROM maven:3.9.6-eclipse-temurin-21 AS build

# Set working directory di dalam container build stage
WORKDIR /app

# Copy pom.xml dan mvnw (Maven Wrapper) terlebih dahulu untuk memanfaatkan Docker layer caching.
# Karena Dockerfile ini berada di dalam folder verificator-secure-onboarding-system,
# jalur COPY sekarang relatif terhadap folder tersebut.
COPY pom.xml ./
COPY mvnw ./
COPY .mvn ./.mvn

# Beri izin eksekusi pada mvnw
RUN chmod +x mvnw

# Copy seluruh source code verifikator
# Ini akan menyalin semua file dari folder src ke /app/src di dalam container.
COPY src ./src

# Build aplikasi Spring Boot
# Perintah ini akan mengkompilasi kode dan membuat file JAR yang dapat dieksekusi.
# -DskipTests digunakan untuk melewati pengujian selama proses build Docker.
RUN ./mvnw clean package -DskipTests

# Stage 2: Jalankan jar dengan OpenJDK
# Gunakan image OpenJDK yang ringan untuk menjalankan aplikasi.
FROM eclipse-temurin:21-jdk-alpine 
    # Menggunakan alpine untuk ukuran image yang lebih kecil

# Set working directory di dalam container runtime stage
WORKDIR /app

# Copy hasil build (file JAR) dari stage 'build' ke direktori /app di stage ini.
# File JAR yang dihasilkan akan memiliki nama seperti 'verificator-secure-onboarding-system-0.0.1-SNAPSHOT.jar'
# atau nama lain sesuai konfigurasi di pom.xml Anda.
# Kita menyalinnya sebagai 'app.jar' untuk konsistensi.
COPY --from=build /app/target/*.jar app.jar

# --- Opsional: Tambahkan baris ini untuk debugging (misalnya, untuk netcat) ---
# eclipse-temurin:21-jdk-alpine adalah berbasis Alpine, jadi gunakan apk
# RUN apk update && apk add netcat-traditional && rm -rf /var/cache/apk/*
# Baris di atas akan menginstal netcat untuk debugging jika diperlukan.
# 'rm -rf /var/cache/apk/*' membersihkan cache apk untuk menjaga ukuran image tetap kecil.
# ----------------------------------------------------------------------

# Tentukan perintah yang akan dijalankan saat container dimulai.
# Ini akan menjalankan aplikasi Spring Boot Anda.
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

 ## deployment.yaml
`deployment.yaml` berisikan File konfigurasi untuk mendefinisikan Deployment di Kubernetes/OpenShift.
>tungguin fiqa

## service.yaml
`service.yaml` berisikan Konfigurasi Service (ClusterIP/NodePort/LoadBalancer) untuk akses aplikasi
>tungguin fiqa

## hpa.yaml
`hpa.yaml` berisikan Konfigurasi Horizontal Pod Autoscaler (HPA) berbasis resource (misalnya CPU)
>tungguin fiqa

## values.yaml
`values.yaml` berisikan File konfigurasi Helm chart (jika menggunakan Helm untuk deployment)
>tungguin fiqa

## grafana-dashboard.png
`grafana-dashboard.png` berisikan Screenshot dashboard performa aplikasi dari Grafana
>tungguin fiqa

## prometheus-config.yaml
`prometheus-config.yaml` berisikan File konfigurasi Prometheus jika dilakukan kustomisasi 
>tungguin fiqa

## link-repo.txt
`link-repo.txt` berisikan File berisi tautan ke GitHub/GitLab repo utama
>tungguin fiqa
