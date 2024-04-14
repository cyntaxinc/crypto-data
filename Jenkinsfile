pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'cyntaxinc/crypto-data'
        DOCKER_USERNAME = credentials('jenkins-dockerhub')
        DOCKER_PASSWORD = credentials('jenkins-dockerhub')
        PROD_SERVER = '104.131.0.135'
        PROD_USER = 'root'
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

         stage('Deploy to Server') {
            when {
                anyOf {
                    branch 'main'
                }
            }
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'jenkins-dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                        sshagent(credentials: ['jenkins-ssh-digitalocean']) {
                            sh "ssh -o StrictHostKeyChecking=no $PROD_USER@$PROD_SERVER 'sudo docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'"
                            sh "ssh -o StrictHostKeyChecking=no $PROD_USER@$PROD_SERVER 'sudo docker pull $DOCKER_IMAGE:latest'"
                            sh "ssh -o StrictHostKeyChecking=no $PROD_USER@$PROD_SERVER 'sudo docker restart api-b3po'"
                            sh "ssh -o StrictHostKeyChecking=no $PROD_USER@$PROD_SERVER 'sudo docker logout'"
                        }
                    }
                }
            }
        }
    }
}