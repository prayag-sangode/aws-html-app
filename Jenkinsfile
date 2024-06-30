pipeline {
    agent any
    
    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '058264559032' // Replace with your actual AWS account ID
        ECR_REPO_NAME = 'aws-html-app'
        IMAGE_TAG = 'latest'
        AWS_CREDENTIALS_ID = 'aws-access-key-id' // Replace with your Jenkins credentials ID
    }
    
    stages {
        stage('Clone Repository') {
            steps {
                script {
                    // Clone the Git repository using GitHub credentials
                    git credentialsId: 'github-pat', url: 'https://github.com/prayag-sangode/aws-html-app.git', branch: 'main'
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
                    def loginCmd = sh(script: "/usr/local/bin/aws ecr get-login-password --region ${AWS_REGION}", returnStdout: true).trim()

                    // Login to ECR
                    withCredentials([
                        [
                            $class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: AWS_CREDENTIALS_ID,
                            accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                            secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                        ]
                    ]) {
                        sh "echo '${loginCmd}' | docker login --username AWS --password-stdin ${ecrRepoUri}"
                    }
                    
                    // Push Docker image to ECR
                    sh "docker push ${ecrRepoUri}:${IMAGE_TAG}"
                }
            }
        }
        
        stage('Update Deployment File') {
            steps {
                script {
                    def ecrRepoUri = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"

                    // Update the deployment file with the new image tag
                    sh """
                    sed -i 's#image: .*#image: ${ecrRepoUri}:${IMAGE_TAG}#' deployment.yaml
                    """
                }
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                script {
                    def ecrRepoUri = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
                    
                    // Assuming you have configured kubeconfig and kubectl on Jenkins
                    sh """
                    aws eks update-kubeconfig --region ${AWS_REGION} --name my-cluster
                    kubectl apply -f deployment.yaml
                    """
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
