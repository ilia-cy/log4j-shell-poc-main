pipeline {
    agent any

    tools {
        jdk 'Java17'
        maven 'Maven3'
    }

    environment {
        APP_NAME = "log4j-shell-poc"
        RELEASE = "1.0.0"
        DOCKER_USER = "dmancloud"
        DOCKER_PASS = 'dockerhub'
        IMAGE_NAME  = "${DOCKER_USER}" + "/" + "${APP_NAME}"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
        JENKINS_API_TOKEN = credentials('JENKINS_API_TOKEN')
    }

    stages {
        stage('Cleanup Workspace') {
            steps {
                cleanWs()
            }
        }
        
         stage('Print ENV') {
             steps {
                 sh 'id'
             }
         }
        
         stage('Install Cimon') {
            steps {
                sh 'curl -sSfL https://cimon-releases.s3.amazonaws.com/install.sh | sudo sh -s -- -b /usr/local/bin'
            }
         }

        stage('Run Cimon') {
            environment {
                CIMON_CLIENT_ID = credentials("CIMON_CLIENT_ID")
                CIMON_SECRET = credentials("CIMON_SECRET")
            }
            steps {
                sh 'sudo -E cimon agent start-background'
            }
        }
        
        stage('Checkout Code') {
            steps {
                git branch: 'main', credentialsId: 'github', url: 'https://github.com/dmancloud/log4j-shell-poc'
            }
        }  

        stage('Build Application') {
            steps {
                sh "mvn clean package"
            }
        }

        stage('Test Application') {
            steps {
                sh "mvn test"
            }
        }    
        
        stage('Sonarqube SAST') {
            steps {
                script {
                withSonarQubeEnv(credentialsId: 'jenkins-sonarqube-token') {
                    sh "mvn sonar:sonar"
                }
                }            
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'jenkins-sonarqube-token'
                }            
            }
        }        
        
        stage('Docker Build & Push') {
            steps {
                script {
                   // docker.withRegistry(' ',DOCKER_PASS) {
                    withDockerRegistry(credentialsId: 'dockerhub') {
                        docker_image = docker.build "${IMAGE_NAME}"
                    }

                   // docker.withRegistry(' ',DOCKER_PASS) {
                    withDockerRegistry(credentialsId: 'dockerhub') {
                        docker_image.push("${IMAGE_TAG}")
                        docker_image.push('latest')
                    }
                    
                }            
            }
        }


        stage('Deploy Application') {
            steps {
                script {
                    sh "curl -v -k --user dmistry:${JENKINS_API_TOKEN} -X POST -H 'cache-control: no-cache' -H 'content-type: application/x-www-form-urlencoded' --data 'IMAGE_TAG=${IMAGE_TAG}' 'https://jenkins.home.dman.cloud/job/deploy-log4j-shell-poc/buildWithParameters?token=gitops-token'"

                }            
            }
        }
        

        stage ('Cleanup Artifacts') {
            steps {
                script {
                    sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker rmi ${IMAGE_NAME}:latest"
                }
            }
        }      
    }
     post {
        always {
            sh 'sudo -E cimon agent stop'
        }
    }
    
}
