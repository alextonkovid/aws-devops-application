pipeline {
    agent {
        kubernetes {
            label 'helm-deploy'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: helm-deploy
spec:
  containers:
  - name: php
    image: jitesoft/phpunit:8.2
    command:
    - cat
    tty: true
  - name: helm
    image: alpine/helm:3.12.3
    command:
    - cat
    tty: true
  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
  - name: docker
    image: docker:20.10
    volumeMounts:
    - name: docker-sock
      mountPath: /var/run/docker.sock
    command:
    - cat
    tty: true
  volumes:
  - name: docker-sock
    hostPath:
      path: /var/run/docker.sock
      
"""
        }
    }
    environment {
        ECR_REPO = '390844773286.dkr.ecr.eu-west-3.amazonaws.com/docker-repo'
        IMAGE_NAME = 'wordpress'
        REGION = 'eu-west-3'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Run PHPUnit Tests') {
											steps {
															container('php') {
																			sh """
																			phpunit --bootstrap plugin/wp-test-plugin/autoload.php --testdox plugin/tests
																			"""
															}
											}
								}
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner';
                    withSonarQubeEnv() { 
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }
    


        // stage('Docker Build and Push to ECR') {
        //     steps {
        //         container('docker') {
        //             script {
        //                 sh """
        //                 sudo apt-get install -y unzip
        //                 curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        //                 unzip awscliv2.zip
        //                 sudo ./aws/install
        //                 sudo aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
        //                 sudo docker build -t ${IMAGE_NAME}:latest .
        //                 sudo docker tag ${IMAGE_NAME}:latest ${ECR_REPO}:latest
        //                 sudo docker push ${ECR_REPO}:latest
        //                 """
        //             }
        //         }
        //     }
        // }

        stage('Helm Install/Upgrade') {
            // when {
            //     expression {
            //         // Ensure that Docker push completed before proceeding
            //         return true // Add actual condition if necessary
            //     }
            // }
            steps {
                container('helm') {
                    script {
                        def releaseName = "wordpress"
                        def chartPath = "./wordpress" 

                        sh """
                        helm upgrade --install ${releaseName} ${chartPath}
                        """
                    }
                } 
            }
        }
    }
}
