pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Terraform Init') {
            steps {
                sh 'cd /path/to/your/terraform/project && terraform init'
            }
        }
        stage('Terraform Apply') {
            steps {
                sh 'cd /path/to/your/terraform/project && terraform apply -auto-approve'
            }
        }
    }
}
