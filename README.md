
# Helm chart from Bitnami package of WordPress


## Introduction

This repo contains modified Helm Chart of Wordpress CMS

It bootstraps a [WordPress](https://github.com/bitnami/containers/tree/main/bitnami/wordpress) deployment on a [Kubernetes](https://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

It also packages the [Bitnami MariaDB chart](https://github.com/bitnami/charts/tree/main/bitnami/mariadb) which is required for bootstrapping a MariaDB deployment for the database requirements of the WordPress application, and the [Bitnami Memcached chart](https://github.com/bitnami/charts/tree/main/bitnami/memcached) that can be used to cache database queries.

Bitnami charts can be used with [Kubeapps](https://kubeapps.dev/) for deployment and management of Helm Charts in clusters.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.8.0+
- PV provisioner support in the underlying infrastructure
- Jenkins

## Installing the Chart

This repo contains [Jenkins Piopeline](../Jenkinsfile) and configured webhook which triggers pipeline build on Jenkins server.

To install the chart with the release name `my-release`:

```console
helm install my-release ./wordpress
```


[Chart values](values.yaml) were configured to use nodePort on `http port 30080` and `https 30443`

Domain name of website is `wordpress.aws.alextonkovid.com` which was set by terraform in [this repo](https://github.com/alextonkovid/aws-devops-provision/blob/main/data/nginx/conf.d/wordpress.conf)

# Evaluation

1. **Helm Chart Creation (40 points)**

   - A Helm chart for the WordPress application is created.

   [LINK TO HELM CHART](https://github.com/alextonkovid/aws-devops-application/tree/main/wordpress)

2. **Application Deployment (30 points)**

   - The application is deployed using the Helm chart.

<details>
  <summary>**Click to view Jenkins Log**</summary>

  ### Jenkins pipeline log
  ```code
   > git rev-parse --resolve-git-dir /home/jenkins/agent/workspace/wordpress/.git # timeout=10
 > git config remote.origin.url https://github.com/alextonkovid/aws-devops-application.git # timeout=10
Fetching upstream changes from https://github.com/alextonkovid/aws-devops-application.git
 > git --version # timeout=10
 > git --version # 'git version 2.39.2'
using GIT_SSH to set credentials 
 > git fetch --tags --force --progress -- https://github.com/alextonkovid/aws-devops-application.git +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git rev-parse refs/remotes/origin/main^{commit} # timeout=10
 > git config core.sparsecheckout # timeout=10
 > git checkout -f 89ea2ed097f557c126ab2bebc12148a2ff446b74 # timeout=10
+ helm list -A
NAME       	NAMESPACE  	REVISION	UPDATED                                	STATUS  	CHART                        	APP VERSION
jenkins    	jenkins    	1       	2024-11-09 11:12:43.016884167 +0000 UTC	deployed	jenkins-5.7.12               	2.479.1    
traefik    	kube-system	1       	2024-11-09 11:13:13.34548714 +0000 UTC 	deployed	traefik-27.0.201+up27.0.2    	v2.11.10   
traefik-crd	kube-system	1       	2024-11-09 11:13:10.703793095 +0000 UTC	deployed	traefik-crd-27.0.201+up27.0.2	v2.11.10   
+ helm install wordpress ./wordpress
NAME: wordpress
LAST DEPLOYED: Sat Nov  9 16:22:22 2024
NAMESPACE: jenkins
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: wordpress
CHART VERSION: 23.1.26
APP VERSION: 6.6.2

** Please be patient while the chart is being deployed **

Your WordPress site can be accessed through the following DNS name from within your cluster:

    wordpress.jenkins.svc.cluster.local (port 80)

To access your WordPress site from outside the cluster follow the steps below:

1. Get the WordPress URL by running these commands:

   export NODE_PORT=$(kubectl get --namespace jenkins -o jsonpath="{.spec.ports[0].nodePort}" services wordpress)
   export NODE_IP=$(kubectl get nodes --namespace jenkins -o jsonpath="{.items[0].status.addresses[0].address}")
   echo "WordPress URL: http://$NODE_IP:$NODE_PORT/"
   echo "WordPress Admin URL: http://$NODE_IP:$NODE_PORT/admin"

2. Open a browser and access WordPress using the obtained URL.

3. Login with the following credentials below to see your blog:

  echo Username: user
  echo Password: $(kubectl get secret --namespace jenkins wordpress -o jsonpath="{.data.wordpress-password}" | base64 -d)

WARNING: There are "resources" sections in the chart not set. Using "resourcesPreset" is not recommended for production. For production installations, please set the following values according to your workload needs:
  - resources
+info https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // container
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // node
[Pipeline] }
[Pipeline] // podTemplate
[Pipeline] End of Pipeline
Finished: SUCCESS
  ```
</details>

   - The application is accessible from the internet.

   ![alt text](img/image.png)

3. **Repository Submission (5 points)**

   - A new repository is created with the WordPress and Helm chart.
   [LINK TO HELM CHART](https://github.com/alextonkovid/aws-devops-application/tree/main/wordpress)

4. **Verification (5 points)**

   - The application is verified to be running and accessible.
      ![alt text](img/image.png)

5. **Additional Tasks (20 points)**
   - **CI/CD Pipeline (10 points)**
     - A CI/CD pipeline is set up to automate the deployment of the application.
     ![alt text](img/image-2.png)

     ![alt text](img/image-1.png)
   - **Documentation (10 points)**
     - The application setup and deployment process are documented in a README file.