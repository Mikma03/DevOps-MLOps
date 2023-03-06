pipeline {
    agent none
    stages {
        stage('STAGE-A') {
            input {
                message "Continue?"
                submitter "mikolaj_maslanka"
            }
            steps {
                echo "Continuing with pipeline..."
            }
        }
        stage('STAGE-B') {
            parallel {
                stage('STAGE-C') {
                    agent { label "agent1" }
                    steps {
                        echo "Running STAGE-C..."
                    }
                }
                stage('STAGE-D') {
                    agent { label "agent2" }
                    steps {
                        echo "Running STAGE-D..."
                        sh "exit 1"
                    }
                }
                stage('STAGE-E') {
                    agent { label "agent3" }
                    steps {
                        echo "Running STAGE-E..."
                    }
                }
            }
        }
    }
}
