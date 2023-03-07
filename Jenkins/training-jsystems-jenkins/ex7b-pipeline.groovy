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
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh 'docker pull non-existing-image:latest'
                }
            }
        }
    }
}
