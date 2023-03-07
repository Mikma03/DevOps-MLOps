pipeline {
    agent any
    stages {
        stage('Git checkout') {
            steps {
                script {
                    gitCheckout([
                        revision: 'main',
                        url: 'https://github.com/username/repository.git',
                        credentialsId: 'my-git-credentials'
                    ])
                }
            }
        }
        stage('Set Git user info') {
            steps {
                script {
                    setGitUserInfo([
                        username: 'myusername',
                        email: 'myemail@example.com',
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
                    gitCommit([
                        commitMessage: 'Updated myfile.txt'
                    ], 'myfile.txt')
                }
            }
        }
        stage('Push changes') {
            steps {
                script {
                    gitPush('my-git-credentials', 'https://github.com/username/repository.git')
                }
            }
        }
    }
}

// develop changes