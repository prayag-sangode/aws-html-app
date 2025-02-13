# Jenkins Pipeline for Deploying a Dockerized Application to AWS EKS

This Jenkins pipeline automates the process of building, pushing, and deploying a Docker image to AWS Elastic Kubernetes Service (EKS) using AWS Elastic Container Registry (ECR).

## **Pipeline Overview**

This pipeline consists of the following stages:
1. **Clone Repository**: Clones the Git repository.
2. **Build Docker Image**: Builds the Docker image.
3. **Push Docker Image to ECR**: Pushes the image to AWS ECR.
4. **Update Deployment File**: Updates the Kubernetes deployment file.
5. **Deploy to EKS**: Applies the deployment to the EKS cluster.

---

## **Pipeline Breakdown**

### **1. Global Variables & Environment Setup**
```groovy
def AWS_CREDENTIALS_ID = 'aws-id'
```
Defines the Jenkins credential ID used for AWS authentication.

```groovy
environment {
    AWS_REGION = 'us-east-1'
    AWS_ACCOUNT_ID = '058264559032' // Replace with your actual AWS account ID
    ECR_REPO_NAME = 'myhtml-app'
    IMAGE_NAME = "${ECR_REPO_NAME}" // Image name derived from repo name
    APP_NAME = 'myhtml-app'
    GIT_REPO_NAME = 'https://github.com/prayag-sangode/myhtml-app.git'
    IMAGE_TAG = 'latest'
    AWS_CREDENTIALS_ID = 'aws-id'
}
```
This block defines environment variables required for AWS, ECR, and Git repository details.

---

### **2. Stages in the Pipeline**

#### **Stage: Clone Repository**
```groovy
stage('Clone Repository') {
    steps {
        script {
            git credentialsId: 'github-pat', url: "${GIT_REPO_NAME}", branch: 'main'
        }
    }
}
```
This stage clones the GitHub repository using the provided credentials.

---

#### **Stage: Build Docker Image**
```groovy
stage('Build Docker Image') {
    steps {
        script {
            def ecrRepoUri = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
            
            sh "docker build -t ${ECR_REPO_NAME}:${IMAGE_TAG} ."
            sh "docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} ${ecrRepoUri}:${IMAGE_TAG}"
        }
    }
}
```
This stage builds the Docker image and tags it with the ECR repository URI.

---

#### **Stage: Push Docker Image to ECR**
```groovy
stage('Push Docker Image to ECR') {
    steps {
        script {
            def ecrRepoUri = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
            
            def loginCmd = ""
            withCredentials([
                [
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: AWS_CREDENTIALS_ID,
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]
            ]) {
                loginCmd = sh(script: "/usr/local/bin/aws ecr get-login-password --region ${AWS_REGION}", returnStdout: true).trim()
            }

            sh "echo '${loginCmd}' | docker login --username AWS --password-stdin ${ecrRepoUri}"
            sh "docker push ${ecrRepoUri}:${IMAGE_TAG}"
        }
    }
}
```
This stage authenticates with AWS ECR, logs in using stored credentials, and pushes the Docker image to ECR.

---

#### **Stage: Update Deployment File**
```groovy
stage('Update Deployment File') {
    steps {
        script {
            def ecrRepoUri = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"
            
            sh """
            sed -i "s|{{IMAGE}}|${ecrRepoUri}:${IMAGE_TAG}|g" deployment.yaml
            sed -i "s|{{APP_NAME}}|${APP_NAME}|g" deployment.yaml
            cat deployment.yaml
            """
        }
    }
}
```
This stage updates the Kubernetes deployment YAML file to use the newly built image.

---

#### **Stage: Deploy to EKS**
```groovy
stage('Deploy to EKS') {
    steps {
        script {
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
```
This stage updates the Kubernetes configuration for EKS, applies the deployment file, and restarts the application deployment.

---

### **3. Post Actions**
```groovy
post {
    always {
        cleanWs()
    }
}
```
This block ensures that workspace cleanup happens after the pipeline execution, preventing leftover files.

---

## **How to Use This Pipeline**
### **1. Configure Jenkins Credentials**
- **AWS Credentials**: Add an AWS credential in Jenkins with the ID `'aws-id'`.
- **GitHub Credentials**: Add a GitHub Personal Access Token (PAT) in Jenkins with the ID `'github-pat'`.

### **2. Set Up EKS and ECR**
- Ensure AWS ECR is created: `aws ecr create-repository --repository-name myhtml-app`
- Ensure an AWS EKS cluster (`my-cluster`) is set up.

### **3. Run the Pipeline**
- Add the Jenkinsfile to your repository.
- Run the pipeline from Jenkins.

### **4. Verify Deployment**
- Check Kubernetes pods: `kubectl get pods`
- Verify deployment logs: `kubectl logs -f deploy/myhtml-app`

---

## **Conclusion**
This pipeline automates the entire CI/CD process for deploying a Dockerized application to AWS EKS using Jenkins. It ensures a streamlined workflow by:
- Cloning the repository
- Building and pushing a Docker image
- Updating the deployment file
- Deploying to an AWS EKS cluster



