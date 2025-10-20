pipeline {
  agent any

  environment {
    IMAGE = "jashwanth00/ticket-booking:latest"   // <-- set your image
    DOCKER_CRED = "jashwanth00"            // <-- credential id in Jenkins
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Docker login (pre-build)') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.DOCKER_CRED, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          bat 'echo Logging into Docker before build...'
          bat 'echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin'
        }
      }
    }

    stage('Tool check') {
      steps {
        bat 'echo Node: && node -v'
        bat 'echo NPM: && npm -v'
        bat 'echo Docker: && docker --version'
        bat 'echo Kubectl: && kubectl version --client'
      }
    }

    stage('Install dependencies') {
      steps {
        bat 'npm install'
      }
    }

    stage('Build image') {
      steps {
        // If BuildKit causes auth problems, use DOCKER_BUILDKIT=0
        bat 'docker build -t %IMAGE% .'
      }
    }

    stage('Docker login (pre-push)') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.DOCKER_CRED, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          bat 'echo Logging into Docker before push...'
          bat 'echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin'
        }
      }
    }

    stage('Push image') {
      steps {
        bat 'docker push %IMAGE%'
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
    always { echo 'Pipeline finished' }
    success { echo 'Pipeline succeeded' }
    failure { echo 'Pipeline failed — check console output' }
  }
}
