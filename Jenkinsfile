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
    image: alpine/helm:3.5.4
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

    environment {
        KUBECONFIG = credentials('kubeconfig-credential-id') // Jenkins credential with kubeconfig
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
                        def releaseName = "my-release"
                        def chartPath = "./wordpress" // or chart repo URL
                        def namespace = "default" // Namespace to deploy

                        sh """
                        helm upgrade --install ${releaseName} ${chartPath} --namespace ${namespace} --kubeconfig $KUBECONFIG
                        """
                    }
                }
            }
        }
    }
}
