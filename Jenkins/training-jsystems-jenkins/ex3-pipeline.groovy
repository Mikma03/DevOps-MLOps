pipeline {
    agent { label "slave01" }
    options {
        buildDiscarder(logRotator(numToKeepStr: '3', daysToKeepStr: '7'))
        timeout(time: 5, unit: 'MINUTES')
        timestamps()
    }
    environment {
        ENV_VAR1 = "some_value"
        ENV_VAR2 = "another_value"
    }
    stages {
        stage('Display environment variables') {
            steps {
                sh 'echo "Environment variable 1: $ENV_VAR1"'
                sh 'echo "Environment variable 2: $ENV_VAR2"'
            }
        }
        stage('Testing timeout') {
            options {
                timeout(time: 30, unit: 'SECONDS')
            }
            steps {
                sh 'echo "Starting sleep..."'
                sh 'sleep 15'
                sh 'echo "Sleep completed."'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}