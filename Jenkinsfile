pipeline {
  agent any

  environment {
    IMAGE = "jashwanth00/ticket-booking:latest"
    DOCKER_CRED = "jashwanth00"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Tool check') {
      steps {
        bat 'echo Node version && node -v'
        bat 'echo NPM version && npm -v'
        bat 'echo Docker version && docker --version'
        bat 'echo Kubectl client version && kubectl version --client'
      }
    }

    stage('Build image') {
      steps {
        bat 'docker build -t %IMAGE% .'
      }
    }

    stage('Push image') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.DOCKER_CRED, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          bat 'echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin'
          bat 'docker push %IMAGE%'
        }
      }
    }

    stage('Deploy to k8s') {
      steps {
        bat 'kubectl apply -f k8s/deployment.yaml'
        bat 'kubectl apply -f k8s/service.yaml'
      }
    }
  }

  post {
    always {
      echo 'Pipeline finished'
    }
  }
}
