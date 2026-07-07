pipeline {
    agent any

    triggers {
        cron('*/5 * * * *')
    }

    environment {
        EC2_USER = "ec2-user"
        EC2_HOST = "3.227.246.28 "
        PEM_FILE = "C:\\Program Files\\Jenkins\\keys\\KP-WINDOWS SERVER.pem" 
        REMOTE_DIR = "/home/ec2-user/self-healing-monitor" 
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Copy Project to EC2') {
            steps {
                bat """
                scp -i "%PEM_FILE%" -o StrictHostKeyChecking=no -r * %EC2_USER%@%EC2_HOST%:%REMOTE_DIR%
                """
            }
        }

        stage('Run Self-Healing Monitor') {
            steps {
                bat """
                ssh -i "%PEM_FILE%" -o StrictHostKeyChecking=no %EC2_USER%@%EC2_HOST% ^
                "cd %REMOTE_DIR% && \
                chmod +x scripts/process_check.sh && \
                chmod +x scripts/logger.sh && \
                chmod +x scripts/diagnostics.sh && \
                ./scripts/process_check.sh"
                """
            }
        }

    }

    post {

        success {
            echo 'Self-healing monitoring completed successfully.'
        }

        failure {
            echo 'Critical failure detected. Check the EC2 report logs.'
        }
    }
}