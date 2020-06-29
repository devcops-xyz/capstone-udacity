List<String> CHOICES = [];
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
                        script {
                        CHOICES = ["blue", "green"];    
                        env.YourTag = input  message: 'What would you like to deploy?',ok : 'Deploy',id :'color',
                                        parameters:[choice(choices: CHOICES, description: 'Select a color for this build', name: 'CHOICES')]
                        }
        }
        }
        stage('Deploy blue Container')  {
                        when {expression { CHOICES == 'blue' }}
            steps {
                withAWS(credentials: 'aws-static', region: awsRegion) {
                    sh 'kubectl apply -f blue-green/deploy-blue.yaml'
                    sleep 20 //to have time getting service
                    sh 'kubectl get service capstoneLB'
                }
            }
        }
        stage('Deploy green Container')  {
                        when {expression { CHOICES == 'green' }}
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