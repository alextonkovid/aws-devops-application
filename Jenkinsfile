pipeline {
    agent any
    environment {
        KUBECONFIG = credentials('1d3e81b5-bfcc-4f36-bc43-45ce76c9148c') 
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Helm Deploy') {
            steps {
                script {
                    // Update Helm dependencies if required
                    sh "helm repo update"

                    // Deploy using Helm
                    sh "helm upgrade --install my-wordpress ./wordpress --namespace wordpress"
                }
            }
        }
    }
}
