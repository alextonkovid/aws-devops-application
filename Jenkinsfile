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
"""
        }
    }


    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

      stage('Helm Install/Upgrade') {
          steps {
              container('helm') {
                  script {
                      def releaseName = "wordpress"
                      def chartPath = "./wordpress" 
                      def namespace = "wordpress"

                      sh """
                      helm list -A
                      helm install ${releaseName} ${chartPath} -n ${namespace}
                      echo Username: user Password: $(kubectl get secret --namespace jenkins wordpress -o jsonpath="{.data.wordpress-password}" | base64 -d)
                      """
                  }
              }
          }
      }
    }
}
