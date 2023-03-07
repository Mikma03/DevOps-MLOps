pipeline {
    agent any
    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'stage', 'demo', 'prod'],
            description: 'Select environment for deployment'
        )
    }
    stages {
        stage('Deployment stage 1') {
            when {
                expression { params.ENVIRONMENT == 'demo' }
            }
            steps {
                echo "Deployment on ${params.ENVIRONMENT}"
                sh 'echo "Deploying..."'
            }
        }
        stage('Deployment stage 2') {
            steps {
                script {
                    if (params.ENVIRONMENT != 'prod') {
                        echo "Deployment on ${params.ENVIRONMENT}"
                        sh 'echo "Deploying..."'
                    } else {
                        echo "Deployment to production not allowed!"
                    }
                }
            }
        }
    }
}
