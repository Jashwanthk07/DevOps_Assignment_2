pipeline {
  agent any

  environment {
    IMAGE = "jashwanth00/ticket-booking:latest"   // set your image
    DOCKER_CRED = "jashwanth00"            // your Jenkins credential id
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Docker login') {
      steps {
        // Perform docker login before any docker build/pull happens
        withCredentials([usernamePassword(credentialsId: env.DOCKER_CRED, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          // for Windows agents (bat)
          bat 'echo Logging into Docker...'
          bat 'echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin'
        }
      }
    }

    stage('Tool check') {
      steps {
        bat 'node -v'
        bat 'docker --version'
      }
    }

    stage('Build image') {
      steps {
        // Optionally disable BuildKit if you want classic build:
        // bat 'set DOCKER_BUILDKIT=0 && docker build -t %IMAGE% .'
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

    stage('Deploy') {
      steps {
        bat 'kubectl apply -f k8s/deployment.yaml'
      }
    }
  }

  post { always { echo 'Pipeline finished' } }
}
