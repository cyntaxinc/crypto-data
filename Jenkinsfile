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
                    withCredentials([usernamePassword(credentialsId: 'jenkins-dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sh "docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD"
                        sh "docker tag $DOCKER_IMAGE:latest $DOCKER_IMAGE:latest"
                        sh "docker push $DOCKER_IMAGE:latest"
                        sh "docker logout"
                    }
                }
            }
        }
    }
}