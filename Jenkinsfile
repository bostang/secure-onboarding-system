pipeline {
    agent any
    tools {
        maven 'Maven 3.9.10'
        jdk 'Temurin JDK 21'
    }

    environment {
        FRONTEND_IMAGE_NAME = 'frontend-secure-onboarding-system'
        GCR_HOSTNAME = 'gcr.io' 
        GCP_PROJECT_ID = 'model-parsec-465503-p3'
        TF_BACKEND_BUCKET = 'terraform-state-secure-onboarding'
        TF_DIR = 'terraform' 
        TF_APP_IMAGE = ""
        IAM_SCOPE = 'https://www.googleapis.com/auth/cloud-platform'
    }

    stages {
        stage('Checkout Frontend') {
            steps {
                echo "Getting frontend code from GitHub..."
                    git url: 'https://github.com/alvarolt17/frontend-secure-onboarding-system', branch: 'feature/docker-support'
            }
        }

        stage('Build Frontend (React)') {
            steps {
                script {
                    sh "npm install"
                    sh "npm run build"
                }
            }
        }

        // stage('Build Backend (Spring Boot)'){
        //     steps {
        //         script {
        //             sh "mvn clean package -DskipTests"
        //         }
        //     }
        // }

        // stage('Unit Test & Coverage'){
        //     steps {
        //         sh "mvn package -DskipTests"
        //     }
        // }

        // stage('Static Code Analysis (SAST) via Sonar') {
        //     steps {
        //         sh """
        //             mvn clean compile sonar:sonar \
        //                 -Dsonar.projectKey=backend-finalized \
        //                 -Dsonar.projectName='backend-finalized' \
        //                 -Dsonar.host.url=http://sonarqube:9000 \
        //                 -Dsonar.token=sqp_26ce111b44fa70b8e4b44e94ff975a5d7b246408    
        //         """
        //     }
        // }
        

        stage('Docker Build and Push Frontend') {
            steps {
                script {
                    def imageTag = "${env.BUILD_NUMBER}" 
                    def fullImageName = "${GCR_HOSTNAME}/${GCP_PROJECT_ID}/${FRONTEND_IMAGE_NAME}:${imageTag}"
                    
                    sh "pwd && ls -la"
                    
                    echo "Build Frontend Docker Image: ${fullImageName}"
                        withCredentials([file(credentialsId: 'gcr-credential-id', variable: 'GCR_KEY_FILE_PATH')]) {
                            sh "docker login -u _json_key --password-stdin https://${GCR_HOSTNAME} < ${GCR_KEY_FILE_PATH}"
                            sh "docker build -t ${fullImageName} -f Dockerfile ."
                            sh "docker push ${fullImageName}"
                            echo "Docker image Frontend ${fullImageName} berhasil dibangun dan didorong ke GCR."
                        }

                    env.TF_APP_IMAGE = fullImageName
                    echo "Nilai TF_APP_IMAGE disetel ke: ${env.TF_APP_IMAGE}"
                }
            }
        }

        stage('Checkout Terraform Configuration') {
            steps {
                echo "Getting Terraform Code from GitHub"
                    git url: 'https://github.com/qanitasyaf/ops-secure-onboarding-system', branch: 'master'
            }
        }

        stage('Terraform Apply GKE Deployment') {
            steps {
                script {
                    withCredentials([file(credentialsId: 'gcp-terraform-credential', variable: 'TF_GCP_KEY_FILE_PATH')]) {
                        dir("${env.TF_DIR}") { 
                            echo "Authenticating gcloud CLI with Service Account Terraform"
                            sh "gcloud auth activate-service-account --key-file=${TF_GCP_KEY_FILE_PATH}"
                            sh "gcloud config set project ${env.GCP_PROJECT_ID}"
                            sh "gcloud auth list"
                            sh "gcloud config get-value account"
                            sh "export GOOGLE_APPLICATION_CREDENTIALS=${TF_GCP_KEY_FILE_PATH}"

                            echo "Terraform Initialization..."
                            sh "terraform init -backend-config=bucket=${TF_BACKEND_BUCKET}"
                            
                            sh "pwd && ls -la"

                            echo "Planning Terraform for GKE Deployment..."
                            sh "terraform plan -var='app_image=${env.TF_APP_IMAGE}' -out=tfplan"

                            echo "Applying Terraform to GKE..."
                            sh "terraform apply -auto-approve tfplan"

                            echo "GKE Deployment using Terraform Success!"
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline success!🚀"
        }
        failure {
            echo "Pipeline failed!💥"
        }
        always {
            cleanWs() 
        }
    }
}
