pipeline {
    agent { label 'docker-node' }

    environment {
        def DATE_TIMESTAMP = sh returnStdout: true, script: 'date +%Y%m%d%H%M%S'
    }

    stages {
        stage('Run linters') {
            steps {
                sh 'make lint-dockerfile'
            }
        }
        stage('Build image') {
            steps {
                sh 'make login-source-ecr'
                sh 'make build-image BUILD_ID=$DATE_TIMESTAMP'
                sh 'make tag-image BUILD_ID=$DATE_TIMESTAMP'
            }
        }
        stage('Run unit tests') {
            steps {
                sh 'make test-image BUILD_ID=$DATE_TIMESTAMP'
            }
        }
        stage('Security scan image') {
            steps {
                sh 'make scan-image BUILD_ID=$DATE_TIMESTAMP'
            }
        }
        stage('Push image to ECR') {
            steps {
                sh 'make push-image BUILD_ID=$DATE_TIMESTAMP'
            }
        }
    }
    post {
        failure {
            emailext (
                recipientProviders: [requestor(),brokenBuildSuspects()],
		to: "daniel_roach@amp.com.au",
                subject: "BUILD FAILED: ${env.JOB_NAME} job for '${ENV_NAME}'",
                body: """BUILD FAILED: '${env.JOB_NAME} [${env.BUILD_NUMBER}]'
                      Please see URL : ${env.BUILD_URL}""",
                attachLog: false
            )
	}
        fixed {
            emailext (
                recipientProviders: [requestor()],
		to: "daniel_roach@amp.com.au",
                subject: "BUILD RECOVERED: ${env.JOB_NAME} job for '${ENV_NAME}'",
                body: """BUILD RECOVERED: '${env.JOB_NAME} [${env.BUILD_NUMBER}]'
                      Please see URL : ${env.BUILD_URL}""",
                attachLog: false
            )
	    }
    }
}