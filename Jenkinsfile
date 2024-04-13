pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'cyntaxinc/crypto-data'
        DOCKER_USERNAME = credentials('jenkins-dockerhub')
        DOCKER_PASSWORD = credentials('jenkins-dockerhub')
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
        
        stage('Deploy to Docker Hub') {
            when {
                anyOf {
                    branch 'main'
                }
            }
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_USERNAME, DOCKER_PASSWORD) {
                        docker.image("$DOCKER_IMAGE:latest").push()
                    }
                }
            }
        }
    }
}