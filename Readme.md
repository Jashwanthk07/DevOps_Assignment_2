# DevOps CI/CD Pipeline — Jenkins + Docker + GitHub + ngrok

This repository demonstrates a complete end-to-end DevOps workflow where Jenkins builds, tests, and pushes a Dockerized application automatically when code is pushed to GitHub. It uses **ngrok** to expose a local Jenkins instance so GitHub webhooks can reach it during development.

---

## Table of Contents
- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Setup Instructions](#setup-instructions)
  - [Prerequisites](#prerequisites)
  - [Clone Repository](#clone-repository)
  - [Configure Docker](#configure-docker)
  - [Configure Jenkins](#configure-jenkins)
  - [Add Jenkins Credentials](#add-jenkins-credentials)
  - [Expose Jenkins with ngrok](#expose-jenkins-with-ngrok)
  - [Add GitHub Webhook](#add-github-webhook)
- [Pipeline Stages Explained](#pipeline-stages-explained)
- [Example Jenkinsfile](#example-jenkinsfile)
- [Example Dockerfile](#example-dockerfile)
- [Common Errors & Fixes](#common-errors--fixes)
- [Troubleshooting](#troubleshooting)
- [Future Improvements](#future-improvements)
- [License](#license)

---

## Overview

This pipeline automates:
1. GitHub webhook → triggers Jenkins on push  
2. Jenkins pipeline → builds Docker image and pushes to Docker Hub  
3. ngrok → exposes Jenkins to the internet (for webhooks during local development)

---

## Tech Stack

- Jenkins (Pipeline)
- Docker (build & push)
- GitHub (source + webhooks)
- ngrok (tunnel for local dev)
- Windows PowerShell / Linux Shell

---

## Architecture

Developer → GitHub (push) → GitHub Webhook → ngrok Tunnel → Jenkins → Docker Hub


---

## Setup Instructions

### Prerequisites
- Docker Desktop installed and running
- Jenkins installed (or run as Docker container)
- Git installed
- ngrok installed
- GitHub account and Docker Hub account

### Clone Repository
```bash
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>
```

### Configure Docker

Login to verify Docker setup:
```
docker login
```

This ensures your Docker Hub credentials or PAT (Personal Access Token) work correctly.

### Configure Jenkins

#### Open Jenkins: http://localhost:8080

#### Install plugins:

1. Git

2. Pipeline

3. Docker Pipeline

4. Credentials Binding

5. GitHub Integration

#### Create a Pipeline Job.

#### Under Build Triggers, enable:

✅ “GitHub hook trigger for GITScm polling”

### Add Jenkins Credentials

Go to:
Manage Jenkins → Credentials → (global) → Add Credentials

Fill:

Username: your Docker Hub username

Password: your Docker Hub PAT

ID: dockerhub-cred-id

Description: Docker Hub Login Credentials

💡 If you prefer, store only your PAT as Secret text and hardcode username in Jenkinsfile.

### Expose Jenkins with ngrok

Run ngrok to expose Jenkins (running on port 8080):
```
ngrok http 8080

```
You’ll get output like:
```
Forwarding  https://abc123.ngrok-free.app → http://localhost:8080
```

Copy this public HTTPS URL.

If you see:
```
ERR_NGROK_15013


→ open C:\Users\<you>\AppData\Local\ngrok\ngrok.yml and remove any hostname: or dev_domain: lines.
```
### Add GitHub Webhook

In your GitHub repository:

Go to Settings → Webhooks → Add Webhook

Enter:
Payload URL: https://abc123.ngrok-free.app/github-webhook/

Content type: application/json

Event: Just the push event

Save.

Then in Jenkins:

Job → Configure → Build Triggers → ✅ “GitHub hook trigger for GITScm polling”

## Pipeline Stages Explained
Stages
Checkout Code	: Pulls the latest code from GitHub
Build Docker Image	: Builds Docker image using Dockerfile
Login to Docker Hub	: Authenticates Jenkins to Docker Hub
Push Image	: Pushes the image to your Docker repository
Cleanup	: Optionally removes local Docker images
## Example Jenkinsfile (Windows PowerShell)
```
pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/<your-username>/<your-repo>.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t myapp:latest .'
            }
        }

        stage('Login & Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-cred-id', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        bat 'echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin'
                        bat 'docker tag myapp:latest %DOCKER_USER%/myapp:latest'
                        bat 'docker push %DOCKER_USER%/myapp:latest'
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                bat 'docker rmi myapp:latest || exit 0'
            }
        }
    }

    post {
        always {
            echo "Pipeline completed successfully."
        }
    }
}
```
## Example Dockerfile

Here’s a simple example for a Node.js app:
```
# Base image
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy dependencies
COPY package*.json ./

# Install production dependencies
RUN npm ci --only=production

# Copy source code
COPY . .

# Expose port
EXPOSE 8080

# Start application
CMD ["node", "server.js"]
```
## Common Errors & Fixes
Error	Cause	Fix
ERR_NGROK_15013	ngrok config uses an unassigned dev domain	Remove hostname or dev_domain in ngrok.yml
Selected Git installation does not exist	Jenkins Git path missing	Install Git & configure global tools
docker: not found	Docker CLI missing on agent	Install Docker Desktop / add to PATH
unauthorized: authentication required	Wrong Docker credentials	Re-add correct Docker Hub PAT in Jenkins credentials
Webhook not triggering	Jenkins URL unreachable	Ensure ngrok tunnel is active and correct URL is in GitHub webhook
## Troubleshooting

Run:
``
ngrok http 8080 --log=stdout
``

to view tunnel logs.

Open ngrok dashboard:

http://127.0.0.1:4040


to inspect requests.

Check GitHub webhook logs under:

GitHub → Repo → Settings → Webhooks → Recent Deliveries


Check Jenkins console output for pipeline failure details.

## Future Improvements

Multi-branch pipeline setup for different environments

Auto-deploy Docker image to AWS ECS or Kubernetes

Integrate Trivy/Grype for image vulnerability scanning

Add Slack or Teams notifications for build results
