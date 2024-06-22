pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCESS_KEY_ID = credentials('your-aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('your-aws-secret-access-key')
        ECR_REPO_NAME = 'aws-html-app'
        EKS_CLUSTER_NAME = 'my-cluster'
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://https://github.com/prayag-sangode/aws-html-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = "latest"
                    def ecrRepoUri = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
                    
                    // Build Docker image
                    sh "docker build -t ${ECR_REPO_NAME}:${imageTag} ."
                    
                    // Tag Docker image
                    sh "docker tag ${ECR_REPO_NAME}:${imageTag} ${ecrRepoUri}:${imageTag}"
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    def ecrRepoUri = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
                    
                    // Login to ECR
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ecrRepoUri}"
                    
                    // Push Docker image to ECR
                    sh "docker push ${ecrRepoUri}:${imageTag}"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    withAWS(credentials: "${AWS_ACCESS_KEY_ID},${AWS_SECRET_ACCESS_KEY}", region: AWS_REGION) {
                        // Update Kubernetes deployment to use the new image
                        sh """
                        kubectl set image deployment/${EKS_DEPLOYMENT_NAME} ${EKS_CONTAINER_NAME}=${ecrRepoUri}:${imageTag} --namespace=default
                        """
                    }
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
