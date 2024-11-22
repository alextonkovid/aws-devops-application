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

        stage('Security check with SonarQube') {
            environment {
                scannerHome = tool 'SonarQube';
            }
            steps {
                withSonarQubeEnv(credentialsId: 'SonarQube', installationName: 'SonarQube') {
                    sh """
                    ${scannerHome}/bin/sonar-scanner \
                    -Dsonar.sources=$WORKSPACE/plugin 
                    """
                }
            }
        }

        stage('Docker image building and pushing to ECR') {
            steps {
                container('docker') {
                    script {
                        app = docker.build("docker-repo")
                        docker.withRegistry('https://390844773286.dkr.ecr.eu-west-3.amazonaws.com', 'ecr:eu-west-3:aws') {
                            app.push("${env.BUILD_NUMBER}")
                            app.push("latest")
                        }
                    }
                }
            }
        }

        stage('Deployment to K3s with Helm') {
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

        stage('Application Verification') {
            steps {
                script {
                    echo 'Waiting 30 seconds for the application ...'
                    sleep 30
                    echo 'Verifying application accessibility...'
                    sh """
                    curl -LI http://wordpress.aws.alextonkovid.site/ --fail --silent --show-error || exit 1
                    """
                }
            }
        }
    }
				post {
    success {
        slackSend channel: 'jenkins-notifications',
                  message: "SUCCESS: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' succeeded. ${env.BUILD_URL}"
    }
    failure {
        slackSend channel: 'jenkins-notifications',
                  message: "FAILURE: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' failed. ${env.BUILD_URL}"
    }
}

}
