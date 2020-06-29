pipeline {
    environment {
        ClusterName = 'capstone-cluster'
        awsRegion = 'us-west-2'
        registry = "udacity1project/capstone"
        registryCredential = 'dockerhub'
        version = 'latest'
        imageName = "capstone"
    }
    agent any
        stages {
        stage('Lint') {
            steps {
                sh 'tidy -q -e **/*.html'
                sh '''docker run --rm -i hadolint/hadolint < Dockerfile'''
                }
            }
        stage('Build Image') {
            steps {
                script {
                    dockerImage = docker.build registry + ":$version"
                }
            }
        }
        stage('Push Image to Docker Hub') {
            steps{
                script {
                    docker.withRegistry( '', registryCredential ) {
                    dockerImage.push()
                    }
                }
            }
        }
        stage('Deploy to EKS')  {
            steps {
                withAWS(credentials: 'aws-static', region: awsRegion) {
                    sh 'aws eks --region=${awsRegion} update-kubeconfig --name ${ClusterName}'
                }
            }
        }
        stage('Blue/Green?') {
            steps {
                input(message: 'Blue/Green?', id: 'deploy', ok: 'deploy?', parameters: [choice(choices: 'blue\ngreen', description: 'Select an environment', name: 'PROD_ENV')])
        }
        }
        stage('Deploy blue Container')  {
                        when {expression { deploy == 'blue' }}
            steps {
                withAWS(credentials: 'aws-static', region: awsRegion) {
                    sh 'kubectl apply -f blue-green/deploy-blue.yaml'
                    sleep 20 //to have time getting service
                    sh 'kubectl get service capstoneLB'
                }
            }
        }
        stage('Deploy green Container')  {
                        when {expression { deploy == 'green' }}
            steps {
                withAWS(credentials: 'aws-static', region: awsRegion) {
                    sh 'kubectl apply -f blue-green/deploy-green.yaml'
                    sleep 20 //to have time getting service
                    sh 'kubectl get service capstoneLB'
                }
            }
        }
    }
}