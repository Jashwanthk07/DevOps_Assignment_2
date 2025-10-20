DevOps CI/CD Pipeline — Jenkins + Docker + GitHub + ngrok

This project demonstrates a complete end-to-end DevOps workflow where Jenkins automatically builds, tests, and deploys a Dockerized application whenever code is pushed to GitHub.
It uses ngrok to expose your local Jenkins server to the internet securely, enabling real-time GitHub webhook triggers.

Table of Contents

Overview

Tech Stack

Architecture

Setup Instructions

1. Prerequisites

2. Clone Repository

3. Configure Docker

4. Configure Jenkins

5. Add Jenkins Credentials

6. Expose Jenkins with ngrok

7. Add GitHub Webhook

Pipeline Stages Explained

Example Jenkinsfile

Common Errors & Fixes

Troubleshooting

Future Improvements

License

Overview

This pipeline automates the build and deployment process using:

GitHub Webhook → triggers Jenkins on every push

Jenkins Pipeline → pulls source code, builds Docker image, and pushes it to Docker Hub

ngrok → provides a secure public URL for Jenkins (required for GitHub webhooks when Jenkins runs locally)

Tech Stack
Component	Purpose
Jenkins	Continuous Integration server
Docker	Containerization platform
GitHub	Source code hosting & webhook trigger
ngrok	Expose localhost to the internet
Windows PowerShell / Linux Shell	Command execution environment
Architecture
┌──────────┐       Push code        ┌────────────┐
│ Developer│ ─────────────────────▶ │ GitHub Repo│
└──────────┘                        └─────┬──────┘
                                          │ (Webhook)
                                          ▼
                                  ┌────────────────┐
                                  │  ngrok Tunnel  │
                                  │(public URL →   │
                                  │ localhost:8080)│
                                  └─────┬──────────┘
                                        │
                                        ▼
                                ┌─────────────┐
                                │   Jenkins   │
                                │Build, Test, │
                                │ Docker Push │
                                └────┬────────┘
                                     │
                                     ▼
                                ┌────────────┐
                                │ Docker Hub │
                                │ (Registry) │
                                └────────────┘

Setup Instructions
1Prerequisites

Install the following tools:

Docker Desktop

Jenkins

Git

ngrok

A GitHub
 and Docker Hub
 account

2️ Clone Repository
git clone https://github.com/<your-username>/<your-repo>.git
cd <your-repo>

3️ Configure Docker

Log in to Docker Hub locally to verify credentials:

docker login

4️ Configure Jenkins

Open Jenkins at http://localhost:8080

Install recommended plugins

Create a Freestyle or Pipeline job

Select:

Source Code Management: Git

Repository URL: your GitHub repo link

Build Triggers: ✅ GitHub hook trigger for GITScm polling

5️ Add Jenkins Credentials

Go to:

Manage Jenkins → Credentials → (global) → Add Credentials


Kind: Username with password

Username: your Docker ID

Password: your Docker Personal Access Token (PAT)

ID: dockerhub-cred-id

Description: Docker Hub Login

6️ Expose Jenkins with ngrok

Run Jenkins on port 8080, then open a terminal and run:

ngrok http 8080


ngrok will generate a public URL, e.g.:

https://randomstring.ngrok-free.app

7️ Add GitHub Webhook

In your GitHub repo:

Settings → Webhooks → Add Webhook


Fill these:

Payload URL:
https://randomstring.ngrok-free.app/github-webhook/

Content type: application/json

Event: “Just the push event”

Secret (optional): your secret token

Click Add webhook ✅

Pipeline Stages Explained
Stage	Purpose
Checkout	Clones the GitHub repo into Jenkins workspace
Build Image	Builds a Docker image from the Dockerfile
Login	Authenticates to Docker Hub using Jenkins credentials
Push Image	Pushes the built image to your Docker Hub repository
Cleanup	Optionally removes local Docker images to free space
Example Jenkinsfile
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
                script {
                    docker.build('myapp:latest')
                }
            }
        }

        stage('Push to Docker Hub') {
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
    }
}

Common Errors & Fixes
Error	Cause	Solution
ERR_NGROK_15013	ngrok requested an unassigned dev domain	Remove hostname: or claim domain in dashboard
Selected Git installation does not exist	Jenkins missing Git path	Install Git and configure path in Jenkins
docker: not found	Docker not installed on Jenkins agent	Install Docker & add to PATH
unauthorized: authentication required	Invalid Docker credentials	Re-add Docker Hub PAT in Jenkins credentials
Troubleshooting

Run ngrok http 8080 --log=stdout to see tunnel logs

Open http://127.0.0.1:4040 to inspect ngrok traffic

Verify GitHub webhook deliveries under Repo → Webhooks → Recent Deliveries

Check Jenkins console logs for detailed build status

Future Improvements

Deploy automatically to a cloud provider (AWS ECS / Azure Container Apps)

Add email or Slack notifications after successful builds

Integrate vulnerability scanning (Trivy, Grype) before pushing images

Add multi-branch pipeline with different environments (dev/stage/prod)

