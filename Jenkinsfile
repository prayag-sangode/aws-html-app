def AWS_CREDENTIALS_ID = 'aws-id'

pipeline {
    agent any
    
    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '058264559032' // Replace with your actual AWS account ID
        ECR_REPO_NAME = 'myhtml-app'
        IMAGE_NAME = "${ECR_REPO_NAME}" // # Added this line to define IMAGE_NAME
        APP_NAME = 'myhtml-app'
        GIT_REPO_NAME = 'https://github.com/prayag-sangode/myhtml-app.git'
        IMAGE_TAG = 'latest'
        AWS_CREDENTIALS_ID = 'aws-id'
    }
    
    stages {
        stage('Clone Repository') {
            steps {
                script {
                    // Clone the Git repository using GitHub credentials
                    git credentialsId: 'github-pat', url: "${GIT_REPO_NAME}", branch: 'main'
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    def ecrRepoUri = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
                    
                    // Build Docker image
                    sh "docker build -t ${ECR_REPO_NAME}:${IMAGE_TAG} ."
                    
                    // Tag Docker image
                    sh "docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} ${ecrRepoUri}:${IMAGE_TAG}"
                }
            }
        }
        
        stage('Push Docker Image to ECR') {
            steps {
                script {
                    def ecrRepoUri = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
                    
                    // Get ECR login command using AWS CLI and credentials
                    def loginCmd = ""
                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: AWS_CREDENTIALS_ID,
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                        ]
                    ]) {
                        // Obtain the ECR login command
                        loginCmd = sh(script: "/usr/local/bin/aws ecr get-login-password --region ${AWS_REGION}", returnStdout: true).trim()
                    }

                    // Login to ECR with AWS credentials
                    sh "echo '${loginCmd}' | docker login --username AWS --password-stdin ${ecrRepoUri}"
                    
                    // Push Docker image to ECR
                    sh "docker push ${ecrRepoUri}:${IMAGE_TAG}"
                }
            }
        }
        
        stage('Update Deployment File') {
            steps {
                script {
                    def ecrRepoUri = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}" // # Moved ecrRepoUri here

                    // Update the deployment file with the new image tag
                    sh """
                    sed -i "s|{{IMAGE}}|${ecrRepoUri}:${IMAGE_TAG}|g" deployment.yaml  # Used ecrRepoUri instead of undefined ECR_REGISTRY
                    sed -i "s|{{APP_NAME}}|${APP_NAME}|g" deployment.yaml
                    cat deployment.yaml
                    """
                }
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                script {
                    // Update kubeconfig for your EKS cluster using stored AWS credentials
                    withCredentials([aws(credentialsId: AWS_CREDENTIALS_ID, region: 'us-east-1')]) {
                        sh 'aws eks update-kubeconfig --name my-cluster'
                        sh 'kubectl get nodes'
                        sh 'cat deployment.yaml'
                        sh 'kubectl apply -f deployment.yaml'
                        sh 'kubectl rollout restart deploy ${APP_NAME}'
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
