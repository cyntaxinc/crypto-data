pipeline {
    // testing jenkins pipeline
    agent any

    environment {
        DOCKER_IMAGE = 'api-b3po-io'
    }

    stages {        
        stage('Build Docker Image') {
            when {
                anyOf {
                    branch 'main'
                }
            }
            steps {
                script {
                    docker.build("$DOCKER_IMAGE:latest")
                }
            }
        }
        
    }
}
