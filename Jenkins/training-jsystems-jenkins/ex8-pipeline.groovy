@Library('my-folder-shared-lib-mikolaj-lib') _

pipeline {
    agent any
    stages {
        stage('Git checkout') {
            steps {
                script {
                    scmUtils.gitCheckout([
                        revision: 'main',
                        url: 'https://github.com/Mikma03/DevOps-MLOps',
                        credentialsId: 'my-git-credentials'
                    ])
                }
            }
        }
        stage('Set git user info') {
            steps {
                script {
                    scmUtils.setGitUserInfo([
                        username: 'my-git-username',
                        email: 'my-git-email@example.com',
                        credentialsId: 'my-git-credentials'
                    ])
                }
            }
        }
        stage('Edit file') {
            steps {
                sh 'echo "Hello, world!" > myfile.txt'
            }
        }
        stage('Commit changes') {
            steps {
                script {
                    scmUtils.gitCommit([
                        commitMessage: 'Updated myfile.txt'
                    ], 'myfile.txt')
                }
            }
        }
        stage('Push changes') {
            steps {
                script {
                    scmUtils.gitPush('my-git-credentials', 'https://github.com/Mikma03/DevOps-MLOps')
                }
            }
        }
    }
}
