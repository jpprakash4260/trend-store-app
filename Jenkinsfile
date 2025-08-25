pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('jprakash2306-DockerHub-credentials')
        IMAGE_NAME = "jprakash2306/trend_store_app"
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/jpprakash4260/trend-store-app.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'docker --version'
                sh 'docker build -f Dockerfile -t $IMAGE_NAME:latest .'
            }
        }
        stage('Push to DockerHub') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
                sh 'docker push $IMAGE_NAME:latest'
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh 'kubectl get nodes'
                sh 'kubectl apply -f k8s/deployment.yml'
                sh 'kubectl apply -f k8s/service.yml'
            }
        }
        stage('Kubernetes Rollback') {
            steps {
                sh 'kubectl rollout restart deployment/trend-app'
                sh 'kubectl get pods'
            }
        }
    }
}
