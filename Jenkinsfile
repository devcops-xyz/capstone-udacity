pipeline {
    environment {
        eksClusterName = 'capstone-cluster'
        awsRegion = 'us-west-2'
        registry = "udacity1project/capstone"
        registryCredential = 'dockerhub'
        version = 'latest'
    }
    agent any
        stages {
        stage('Lint') {
            steps {
                sh 'tidy -q -e **/*.html'
                sh '''docker run --rm -i hadolint/hadolint < Dockerfile'''
                }
            }
        stage('Building Image') {
            steps {
                script {
                    dockerImage = docker.build registry + ":$version"
                }
            }
        }
        stage('Deploying Image to Docker Hub') {
            steps{
                script {
                    docker.withRegistry( '', registryCredential ) {
                    dockerImage.push()
                    }
                }
            }
        }
        stage('EKS Deploy')  {
            steps {
                withAWS(credentials: 'aws-static', region: awsRegion) {
                    sh 'aws eks --region=${awsRegion} update-kubeconfig --name ${eksClusterName}'
                    sh 'kubectl apply -f deploy/capstone-deployment.yml'
                    sh 'kubectl get service capstone'
                }
            }
        }
    }
}