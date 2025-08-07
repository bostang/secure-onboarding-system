# Operational Report 

- Kubernetes (k8s) is an open-source platform for managing containerized workloads and services.
- Makes it easy to orchestrate many containers on many hosts, scale them as microservices, and deploy rollout.
- A set of APIs to deploy containers on a set of nodes called a cluster.
- Divided into a set of primary components that run as a control plane and a set of nodes that run containers.

Google Kubernetes Engines (GKE) can deploy, manage, and scale Kubernetes. Here's some GKE features: Fully managed, OS are optimazed to scale up quickly, GKE autopilot manages cluster configuration, auto upgrade so ensures that clusters have the latest stable versions of Kubernetes, auto repair healthy nodes, scales the cluster itself, and integrated cloud build, Google Cloud Observability, and Virtual Private Clouds (VPC).

Our deployment is divided by 3 part
1. Infrastructure Deployment
2. Mockup Deployment
3. Automated CI/CD 


## 1 Infrastructure Deployment
We're using GKE as our Infrastructure. Here's step-by-step our Infrastructure Deployment:
1. Login 
2. Applying main.tf, provider.tf, and variables.tf using this command to deploy GKE.
```bash 
terrafom init
terraform apply 
terrafom plan
```




