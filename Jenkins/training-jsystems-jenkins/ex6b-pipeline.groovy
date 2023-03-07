pipeline {
    agent any
    parameters {
        string(name: 'EXAMPLE_VAR', description: 'Example variable from upstream pipeline')
    }
    stages {
        stage('Example downstream stage') {
            steps {
                echo "The EXAMPLE_VAR value is: ${params.EXAMPLE_VAR}"
            }
        }
    }
}
