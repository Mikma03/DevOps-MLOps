@Library('my-folder-shared-lib-mikolaj-lib') _

pipeline {
    agent any
    parameters {
        credentials(name: 'myCredentials', defaultValue: 'example_1')
    }
    stages {
        stage('Git checkout') {
            steps {
                script {
                    gitCheckout([
                        revision: 'main',
                        url: 'https://github.com/username/repository.git',
                        credentialsId: "${params.myCredentials}"
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
                        redentialsId: "${params.myCredentials}"
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
