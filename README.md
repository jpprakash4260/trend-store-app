# Brain Tasks App

This project is a React application. I deployed it on **AWS EKS** using Docker and CodeBuild. The app runs on **port 3000**.
---

## Steps I did

Deployed url is:
```bash
http://a202c1c06868a40d28e596b4e00538cb-1698366720.ap-south-1.elb.amazonaws.com:3000/
```

### 1. Clone repo
```bash
git clone https://github.com/Vennilavan12/Trend.git
cd trend_store_app
```

### 2. Docker
- Created Dockerfile with nginx:alpine
- Copied dist/ files and nginx.conf
- Expose port 3000

```bash
docker build -t <my-ecr-repo>:latest .
docker push <my-ecr-repo>:latest
```

### 3. Terraform
- Defined VPC, Subnets, Internet Gateway, Security Groups
- Created EC2 Jenkins server using user_data for installing Jenkins, Docker, and kubectl
- Applied configuration:

```bash
terraform init
terraform apply -auto-approve
```

### 4. Jenkins Setup
- Installed required plugins: Docker, Kubernetes, Pipeline, Git, Amazon EKS
- Configured GitHub Webhook for automatic builds
- Created Declarative Pipeline (Jenkinsfile) for:
    - Build Docker image
    - Push to DockerHub
    - Deploy to Kubernetes cluster using kubectl

### 5. Kubernetes Deployment
- Created deployment.yaml for the application with 2 replicas
- Created service.yaml with LoadBalancer to expose port 3000

```bash
kubectl apply -f k8s/deployment.yml
kubectl apply -f k8s/service.yml
```
- Check service:
```bash
kubectl get svc -n default
```

### 7. Monitoring
- Installed Prometheus + Grafana via kube-prometheus-stack Helm chart:
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
```
- Configured Alertmanager for email notifications when pods/nodes fail.

### 8. Architecture Flow
```GitHub Repo --> Jenkins Pipeline --> DockerHub --> AWS EKS Cluster --> LoadBalancer Service --> Browser```

### Notes
- App runs on port 3000 inside container and service.
- Kubernetes Service type: LoadBalancer.
- Jenkins pipeline automates CI/CD process.
- Monitoring with Prometheus & Grafana for real-time metrics and alerting.
- Infrastructure as Code with Terraform

### Access Application

- Copy the EXTERNAL-IP of the LoadBalancer:
```bash
kubectl get svc
```
- Open in browser:
```bash
http://<EXTERNAL-IP>:3000/
```


