pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '058264559032' // Replace with your actual AWS account ID
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key-id')
        EKS_CLUSTER_NAME = 'my-cluster'
        DEPLOYMENT_FILE = 'deployment.yaml' // Ensure this file is in your repository
        ECR_REPO_NAME = "aws-html-app"
        IMAGE_TAG = "latest"
        APP_NAME = "aws-html-app"
        REPO_URL = "https://github.com/prayag-sangode/aws-html-app.git"
        BRANCH = "main"  // Replace with the desired branch
    }

    stages {
        stage('Clone Repository') {
            steps {
                script {
                    // Clone the Git repository using GitHub credentials
                    git credentialsId: 'github-pat', url: REPO_URL, branch: BRANCH
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
                    def loginCmd = sh(script: "aws ecr get-login-password --region ${AWS_REGION}", returnStdout: true).trim()
                    
                    // Login to ECR
                    sh "echo '${loginCmd}' | docker login --username AWS --password-stdin ${ecrRepoUri}"
                    
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
                    sed -i 's#image: .*#image: ${ecrRepoUri}:${IMAGE_TAG}#' ${DEPLOYMENT_FILE}
                    sed -i 's#APP_NAME: .*#APP_NAME: ${APP_NAME}#' ${DEPLOYMENT_FILE}
                    cat ${DEPLOYMENT_FILE} # For debugging, to see the updated file
                    """
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    // Fetch AWS credentials from Jenkins credentials store
                    def awsAccessKeyId = credentials('aws-access-key-id')
                    def awsSecretAccessKey = credentials('aws-secret-key-id')

                    // Use AWS credentials to authenticate
                    withAWS(credentials: "${awsAccessKeyId},${awsSecretAccessKey}", region: AWS_REGION) {
                        // Update Kubernetes deployment and service to use the new image
                        sh """
                        aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER_NAME}
                        kubectl apply -f ${DEPLOYMENT_FILE}
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
