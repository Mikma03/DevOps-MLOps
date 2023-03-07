pipeline {
    agent { label 'slave01' }
    stages {
        stage('Pull image 1') {
            steps {
                sh 'docker pull alpine:latest'
            }
        }
        stage('Pull image 2') {
            steps {
                try {
                    sh 'docker pull non-existing-image:latest'
                } catch (Exception e) {
                    echo "Exception caught: ${e.getMessage()}"
                    currentBuild.result = 'UNSTABLE'
                }
            }
        }
    }
}
