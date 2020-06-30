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
    stage('Create EKS')  {
            //when {branch 'test'}
            steps {
                withAWS(credentials: 'aws-static', region: awsRegion) {
                    sh 'eksctl create cluster --name myeks --nodes 2'
                }
            }
        }
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
                    sh 'aws eks update-kubeconfig --name ${ClusterName}'
                    sh 'kubectl config use-context arn:aws:eks:us-west-2:543805437419:cluster/${ClusterName}'
                }
            }
        }
        stage('Deploy blue Container')  {
            steps {
                withAWS(credentials: 'aws-static', region: awsRegion) {
                    sh 'kubectl apply -f blue-green/deploy-blue.yaml'
                }
            }
        }
        stage('Deploy green Container')  {
            steps {
                withAWS(credentials: 'aws-static', region: awsRegion) {
                    sh 'kubectl apply -f blue-green/deploy-green.yaml'
                }
            }
        }
		stage('Create the blue service') {
			steps {
				withAWS(credentials: 'aws-static', region: awsRegion) {
					sh 'kubectl apply -f blue-green/blue-service.yaml'
                    sleep 10 //to have time getting service
                    sh 'kubectl get service capstone'
				}
			}
		}

		stage('User approval to deploy the green service') {
            steps {
                input "Reirect service to green?"
            }
        }

		stage('Create the green service') {
			steps {
				withAWS(credentials: 'aws-static', region: awsRegion) {
					sh 'kubectl apply -f blue-green/green-service.yaml'
                    sleep 10 //to have time getting service
                    sh 'kubectl get service capstone'
				}
			}
		}

    }
}