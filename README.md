
#WordPress Deployment and Testing with Kubernetes and Helm

This repository contains a Jenkins pipeline configuration to automate the deployment of a WordPress application. The pipeline includes the following stages:

1. **Code Checkout**: Clones the repository from the source control system.
2. **Unit Testing**: Runs PHPUnit tests for the WordPress plugin.
3. **Security Check**: Analyzes the code using SonarQube for security and quality assurance.
4. **Docker Image Build and Push**: Builds a Docker image and pushes it to AWS Elastic Container Registry (ECR).
5. **Helm Deployment**: Deploys the WordPress application to a K3s cluster using Helm.
6. **Application Verification**: Verifies that the application is accessible after deployment.
7. **Notifications**: Sends notifications via Slack on success or failure.

---

## Pipeline Details

### Kubernetes Pod Configuration
The pipeline runs on a Kubernetes pod with the following containers:
- **PHP**: For running PHPUnit tests (`jitesoft/phpunit:8.2`).
- **Helm**: For deploying the application using Helm (`alpine/helm:3.12.3`).
- **Kubectl**: For Kubernetes cluster operations (`bitnami/kubectl:latest`).
- **Docker**: For building and pushing Docker images (`docker:20.10`).

The pod also mounts the Docker socket for container builds.

### Environment Variables
- `ECR_REPO`: AWS ECR repository (`390844773286.dkr.ecr.eu-west-3.amazonaws.com/docker-repo`).
- `IMAGE_NAME`: The Docker image name (`wordpress`).
- `REGION`: AWS region (`eu-west-3`).

---

## Pipeline Stages

### 1. Checkout
Clones the repository using the Jenkins `checkout scm` command.

### 2. Run PHPUnit Tests
Runs PHPUnit tests within the `php` container:
```bash
phpunit --bootstrap plugin/wp-test-plugin/autoload.php --testdox plugin/tests
```

### 3. Security Check with SonarQube
Analyzes the code for quality and security using SonarQube:
```bash
sonar-scanner -Dsonar.sources=$WORKSPACE/plugin
```

### 4. Docker Image Build and Push
Builds the Docker image and pushes it to AWS ECR:
```groovy
app = docker.build("docker-repo")
docker.withRegistry('https://390844773286.dkr.ecr.eu-west-3.amazonaws.com', 'ecr:eu-west-3:aws') {
    app.push("${env.BUILD_NUMBER}")
    app.push("latest")
}
```

### 5. Deployment to K3s with Helm
Deploys the WordPress application using Helm:
```bash
helm upgrade --install wordpress ./wordpress
```

### 6. Application Verification
Verifies the application by checking its accessibility:
```bash
curl -LI http://wordpress.aws.alextonkovid.site/ --fail --silent --show-error || exit 1
```

### 7. Slack Notifications
Sends success or failure notifications to a Slack channel:
- **Success**: Job succeeded.
- **Failure**: Job failed.

---

## Prerequisites
- Jenkins with Kubernetes plugin configured.
- AWS credentials for accessing ECR.
- SonarQube configured with the required credentials.
- Slack integration set up in Jenkins.

---

## Notes
- Ensure that the Kubernetes cluster is properly configured for Jenkins to run the pipeline.
- Update the Helm chart path (`./wordpress`) and release name (`wordpress`) as necessary.
- Modify environment variables and Slack settings according to your setup.

---

## Submission

<details>
  <summary>Click to view full console output of the Pipeline</summary>

  ### console output
  ```
		Started by GitHub push by alextonkovid
Started by GitHub push by alextonkovid
Obtained Jenkinsfile from git https://github.com/alextonkovid/aws-devops-application
[Pipeline] Start of Pipeline
[Pipeline] echo
[WARNING] label option is deprecated. To use a static pod template, use the 'inheritFrom' option.
[Pipeline] podTemplate
[Pipeline] {
[Pipeline] node
Created Pod: kubernetes jenkins/helm-deploy-jnq5s-zm3cn
Agent helm-deploy-jnq5s-zm3cn is provisioned from template helm-deploy-jnq5s
---
apiVersion: "v1"
kind: "Pod"
metadata:
  annotations:
    kubernetes.jenkins.io/last-refresh: "1732299474508"
    buildUrl: "http://jenkins.jenkins.svc.cluster.local:8080/job/wordpress/17/"
    runUrl: "job/wordpress/17/"
  labels:
    some-label: "helm-deploy"
    jenkins/jenkins-jenkins-agent: "true"
    jenkins/label-digest: "34fb528bbdbd3d1aef2e51dd8cd631009e8075b0"
    jenkins/label: "helm-deploy"
    kubernetes.jenkins.io/controller: "http___jenkins_jenkins_svc_cluster_local_8080x"
  name: "helm-deploy-jnq5s-zm3cn"
  namespace: "jenkins"
spec:
  containers:
  - command:
    - "cat"
    image: "jitesoft/phpunit:8.2"
    name: "php"
    tty: true
    volumeMounts:
    - mountPath: "/home/jenkins/agent"
      name: "workspace-volume"
      readOnly: false
  - command:
    - "cat"
    image: "alpine/helm:3.12.3"
    name: "helm"
    tty: true
    volumeMounts:
    - mountPath: "/home/jenkins/agent"
      name: "workspace-volume"
      readOnly: false
  - command:
    - "cat"
    image: "bitnami/kubectl:latest"
    name: "kubectl"
    tty: true
    volumeMounts:
    - mountPath: "/home/jenkins/agent"
      name: "workspace-volume"
      readOnly: false
  - command:
    - "cat"
    image: "docker:20.10"
    name: "docker"
    tty: true
    volumeMounts:
    - mountPath: "/var/run/docker.sock"
      name: "docker-sock"
    - mountPath: "/home/jenkins/agent"
      name: "workspace-volume"
      readOnly: false
  - env:
    - name: "JENKINS_SECRET"
      value: "********"
    - name: "JENKINS_TUNNEL"
      value: "jenkins-agent.jenkins.svc.cluster.local:50000"
    - name: "JENKINS_AGENT_NAME"
      value: "helm-deploy-jnq5s-zm3cn"
    - name: "REMOTING_OPTS"
      value: "-noReconnectAfter 1d"
    - name: "JENKINS_NAME"
      value: "helm-deploy-jnq5s-zm3cn"
    - name: "JENKINS_AGENT_WORKDIR"
      value: "/home/jenkins/agent"
    - name: "JENKINS_URL"
      value: "http://jenkins.jenkins.svc.cluster.local:8080/"
    image: "jenkins/inbound-agent:3261.v9c670a_4748a_9-2"
    name: "jnlp"
    resources:
      requests:
        memory: "256Mi"
        cpu: "100m"
    volumeMounts:
    - mountPath: "/home/jenkins/agent"
      name: "workspace-volume"
      readOnly: false
  nodeSelector:
    kubernetes.io/os: "linux"
  restartPolicy: "Never"
  volumes:
  - hostPath:
      path: "/var/run/docker.sock"
    name: "docker-sock"
  - emptyDir:
      medium: ""
    name: "workspace-volume"

Running on helm-deploy-jnq5s-zm3cn in /home/jenkins/agent/workspace/wordpress
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Declarative: Checkout SCM)
[Pipeline] checkout
Selected Git installation does not exist. Using Default
The recommended git tool is: NONE
using credential github
Cloning the remote Git repository
Cloning repository https://github.com/alextonkovid/aws-devops-application
 > git init /home/jenkins/agent/workspace/wordpress # timeout=10
Fetching upstream changes from https://github.com/alextonkovid/aws-devops-application
 > git --version # timeout=10
 > git --version # 'git version 2.39.2'
using GIT_SSH to set credentials 
Verifying host key using known hosts file
You're using 'Known hosts file' strategy to verify ssh host keys, but your known_hosts file does not exist, please go to 'Manage Jenkins' -> 'Security' -> 'Git Host Key Verification Configuration' and configure host key verification.
 > git fetch --tags --force --progress -- https://github.com/alextonkovid/aws-devops-application +refs/heads/*:refs/remotes/origin/* # timeout=10
Avoid second fetch
Checking out Revision 93d980419656a89e8a0ada63b21a19fcd3c03a21 (refs/remotes/origin/task_6)
Commit message: "added persistentVolumeReclaimPolicy: Delete"
 > git config remote.origin.url https://github.com/alextonkovid/aws-devops-application # timeout=10
 > git config --add remote.origin.fetch +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git rev-parse refs/remotes/origin/task_6^{commit} # timeout=10
 > git config core.sparsecheckout # timeout=10
 > git checkout -f 93d980419656a89e8a0ada63b21a19fcd3c03a21 # timeout=10
 > git rev-list --no-walk 92f70e4dc5797a9ad905470780b3196eae088e77 # timeout=10
[Pipeline] }
[Pipeline] // stage
[Pipeline] withEnv
[Pipeline] {
[Pipeline] withEnv
[Pipeline] {
[Pipeline] stage
[Pipeline] { (Checkout)
[Pipeline] checkout
Selected Git installation does not exist. Using Default
The recommended git tool is: NONE
using credential github
Fetching changes from the remote Git repository
Checking out Revision 93d980419656a89e8a0ada63b21a19fcd3c03a21 (refs/remotes/origin/task_6)
Commit message: "added persistentVolumeReclaimPolicy: Delete"
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Run PHPUnit Tests)
[Pipeline] container
[Pipeline] {
[Pipeline] sh
 > git rev-parse --resolve-git-dir /home/jenkins/agent/workspace/wordpress/.git # timeout=10
 > git config remote.origin.url https://github.com/alextonkovid/aws-devops-application # timeout=10
Fetching upstream changes from https://github.com/alextonkovid/aws-devops-application
 > git --version # timeout=10
 > git --version # 'git version 2.39.2'
using GIT_SSH to set credentials 
Verifying host key using known hosts file
You're using 'Known hosts file' strategy to verify ssh host keys, but your known_hosts file does not exist, please go to 'Manage Jenkins' -> 'Security' -> 'Git Host Key Verification Configuration' and configure host key verification.
 > git fetch --tags --force --progress -- https://github.com/alextonkovid/aws-devops-application +refs/heads/*:refs/remotes/origin/* # timeout=10
 > git rev-parse refs/remotes/origin/task_6^{commit} # timeout=10
 > git config core.sparsecheckout # timeout=10
 > git checkout -f 93d980419656a89e8a0ada63b21a19fcd3c03a21 # timeout=10
+ phpunit --bootstrap plugin/wp-test-plugin/autoload.php --testdox plugin/tests
PHPUnit 10.5.1 by Sebastian Bergmann and contributors.

Runtime:       PHP 8.2.13

..                                                                  2 / 2 (100%)

Time: 00:00.005, Memory: 24.58 MB

Email
 ✔ Can be created from valid email
 ✔ Cannot be created from invalid email

OK (2 tests, 2 assertions)
[Pipeline] }
[Pipeline] // container
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Security check with SonarQube)
[Pipeline] tool
Unpacking https://repo1.maven.org/maven2/org/sonarsource/scanner/cli/sonar-scanner-cli/6.2.1.4610/sonar-scanner-cli-6.2.1.4610.zip to /home/jenkins/agent/tools/hudson.plugins.sonar.SonarRunnerInstallation/SonarQube on helm-deploy-jnq5s-zm3cn
[Pipeline] withEnv
[Pipeline] {
[Pipeline] withSonarQubeEnv
Injecting SonarQube environment variables using the configuration: SonarQube
[Pipeline] {
[Pipeline] sh
+ /home/jenkins/agent/tools/hudson.plugins.sonar.SonarRunnerInstallation/SonarQube/bin/sonar-scanner -Dsonar.sources=/home/jenkins/agent/workspace/wordpress/plugin
18:18:14.260 INFO  Scanner configuration file: /home/jenkins/agent/tools/hudson.plugins.sonar.SonarRunnerInstallation/SonarQube/conf/sonar-scanner.properties
18:18:14.266 INFO  Project root configuration file: /home/jenkins/agent/workspace/wordpress/sonar-project.properties
18:18:14.305 INFO  SonarScanner CLI 6.2.1.4610
18:18:14.307 INFO  Java 17.0.12 Eclipse Adoptium (64-bit)
18:18:14.310 INFO  Linux 5.15.0-1072-aws amd64
18:18:14.378 INFO  User cache: /home/jenkins/.sonar/cache
18:18:15.707 INFO  JRE provisioning: os[linux], arch[x86_64]
18:18:42.818 INFO  Communicating with SonarQube Server 10.7.0.96327
18:18:43.276 INFO  Starting SonarScanner Engine...
18:18:43.277 INFO  Java 17.0.11 Eclipse Adoptium (64-bit)
18:18:44.605 INFO  Load global settings
18:18:44.807 INFO  Load global settings (done) | time=202ms
18:18:44.812 INFO  Server id: EA8D9556-AZNPxftLYXT0TTm-T5f9
18:18:44.832 INFO  Loading required plugins
18:18:44.836 INFO  Load plugins index
18:18:44.899 INFO  Load plugins index (done) | time=72ms
18:18:44.899 INFO  Load/download plugins
18:18:53.142 INFO  Load/download plugins (done) | time=8238ms
18:18:53.787 INFO  Process project properties
18:18:53.801 INFO  Process project properties (done) | time=13ms
18:18:53.821 INFO  Project key: wordpress
18:18:53.822 INFO  Base dir: /home/jenkins/agent/workspace/wordpress
18:18:53.825 INFO  Working dir: /home/jenkins/agent/workspace/wordpress/.scannerwork
18:18:53.846 INFO  Load project settings for component key: 'wordpress'
18:18:53.917 INFO  Load project settings for component key: 'wordpress' (done) | time=72ms
18:18:53.980 INFO  Load quality profiles
18:18:54.097 INFO  Load quality profiles (done) | time=116ms
18:18:54.139 INFO  Auto-configuring with CI 'Jenkins'
18:18:54.195 INFO  Load active rules
18:18:57.619 INFO  Load active rules (done) | time=3424ms
18:18:57.628 INFO  Load analysis cache
18:18:57.702 INFO  Load analysis cache (2.0 kB) | time=71ms
18:18:57.871 INFO  Preprocessing files...
18:18:58.016 INFO  1 language detected in 3 preprocessed files
18:18:58.017 INFO  0 files ignored because of scm ignore settings
18:18:58.021 INFO  Loading plugins for detected languages
18:18:58.022 INFO  Load/download plugins
18:19:00.098 INFO  Load/download plugins (done) | time=2076ms
18:19:00.178 INFO  Load project repositories
18:19:00.250 INFO  Load project repositories (done) | time=70ms
18:19:00.273 INFO  Indexing files...
18:19:00.274 INFO  Project configuration:
18:19:00.330 INFO  3 files indexed
18:19:00.337 INFO  Quality profile for php: Sonar way
18:19:00.338 INFO  ------------- Run sensors on module wordpress
18:19:00.434 INFO  Load metrics repository
18:19:00.533 INFO  Load metrics repository (done) | time=98ms
18:19:01.812 INFO  Sensor HTML [web]
18:19:01.860 INFO  Sensor HTML [web] (done) | time=48ms
18:19:01.860 INFO  Sensor JaCoCo XML Report Importer [jacoco]
18:19:01.865 INFO  'sonar.coverage.jacoco.xmlReportPaths' is not defined. Using default locations: target/site/jacoco/jacoco.xml,target/site/jacoco-it/jacoco.xml,build/reports/jacoco/test/jacocoTestReport.xml
18:19:01.867 INFO  No report imported, no coverage information will be imported by JaCoCo XML Report Importer
18:19:01.868 INFO  Sensor JaCoCo XML Report Importer [jacoco] (done) | time=8ms
18:19:01.870 INFO  Sensor PHP sensor [php]
18:19:02.007 INFO  Starting PHP symbol indexer
18:19:02.036 INFO  3 source files to be analyzed
18:19:02.362 INFO  3/3 source files have been analyzed
18:19:02.364 INFO  Cached information of global symbols will be used for 0 out of 3 files. Global symbols were recomputed for the remaining files.
18:19:02.437 INFO  Starting PHP rules
18:19:02.452 INFO  3 source files to be analyzed
18:19:02.927 INFO  3/3 source files have been analyzed
18:19:02.928 INFO  The PHP analyzer was able to leverage cached data from previous analyses for 0 out of 3 files. These files were not parsed.
18:19:02.929 INFO  Sensor PHP sensor [php] (done) | time=1057ms
18:19:02.929 INFO  Sensor Analyzer for "php.ini" files [php]
18:19:02.935 INFO  Sensor Analyzer for "php.ini" files [php] (done) | time=7ms
18:19:02.936 INFO  Sensor PHPUnit report sensor [php]
18:19:02.939 INFO  No PHPUnit tests reports provided (see 'sonar.php.tests.reportPath' property)
18:19:02.941 INFO  No PHPUnit coverage reports provided (see 'sonar.php.coverage.reportPaths' property)
18:19:02.945 WARN  PHPUnit test cases are detected. Make sure to specify test sources via `sonar.test` to get more precise analysis results.
18:19:02.947 INFO  Sensor PHPUnit report sensor [php] (done) | time=11ms
18:19:02.948 INFO  Sensor Java Config Sensor [iac]
18:19:02.972 INFO  0 source files to be analyzed
18:19:02.973 INFO  0/0 source files have been analyzed
18:19:02.977 INFO  Sensor Java Config Sensor [iac] (done) | time=27ms
18:19:02.977 INFO  Sensor IaC Docker Sensor [iac]
18:19:03.114 INFO  0 source files to be analyzed
18:19:03.115 INFO  0/0 source files have been analyzed
18:19:03.118 INFO  Sensor IaC Docker Sensor [iac] (done) | time=140ms
18:19:03.118 INFO  Sensor TextAndSecretsSensor [text]
18:19:03.118 INFO  Available processors: 2
18:19:03.118 INFO  Using 2 threads for analysis.
18:19:03.987 INFO  The property "sonar.tests" is not set. To improve the analysis accuracy, we categorize a file as a test file if any of the following is true:
  * The filename starts with "test"
  * The filename contains "test." or "tests."
  * Any directory in the file path is named: "doc", "docs", "test" or "tests"
  * Any directory in the file path has a name ending in "test" or "tests"

18:19:04.026 INFO  Using git CLI to retrieve untracked files
18:19:04.036 INFO  Analyzing language associated files and files included via "sonar.text.inclusions" that are tracked by git
18:19:04.068 INFO  3 source files to be analyzed
18:19:04.113 INFO  3/3 source files have been analyzed
18:19:04.116 INFO  Sensor TextAndSecretsSensor [text] (done) | time=999ms
18:19:04.128 INFO  ------------- Run sensors on project
18:19:04.384 INFO  Sensor Zero Coverage Sensor
18:19:04.397 INFO  Sensor Zero Coverage Sensor (done) | time=14ms
18:19:04.411 INFO  CPD Executor Calculating CPD for 3 files
18:19:04.422 INFO  CPD Executor CPD calculation finished (done) | time=9ms
18:19:04.429 INFO  SCM revision ID '93d980419656a89e8a0ada63b21a19fcd3c03a21'
18:19:04.573 INFO  Analysis report generated in 140ms, dir size=226.7 kB
18:19:04.601 INFO  Analysis report compressed in 25ms, zip size=28.4 kB
18:19:04.733 INFO  Analysis report uploaded in 127ms
18:19:04.735 INFO  ANALYSIS SUCCESSFUL, you can find the results at: http://84.10.161.53:9000/dashboard?id=wordpress
18:19:04.735 INFO  Note that you will be able to access the updated dashboard once the server has processed the submitted analysis report
18:19:04.735 INFO  More about the report processing at http://84.10.161.53:9000/api/ce/task?id=c235b185-9e34-41b1-ba7d-2bcfe5ccc030
18:19:04.747 INFO  Analysis total time: 11.478 s
18:19:04.748 INFO  SonarScanner Engine completed successfully
18:19:04.805 INFO  EXECUTION SUCCESS
18:19:04.808 INFO  Total time: 50.602s
[Pipeline] }
[Pipeline] // withSonarQubeEnv
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Docker image building and pushing to ECR)
[Pipeline] container
[Pipeline] {
[Pipeline] script
[Pipeline] {
[Pipeline] isUnix
[Pipeline] withEnv
[Pipeline] {
[Pipeline] sh
+ docker build -t docker-repo .
Sending build context to Docker daemon  3.334MB

Step 1/3 : FROM bitnami/wordpress
 ---> 7dabc9f533ce
Step 2/3 : COPY ./plugin/wp-test-plugin/ /bitnami/wordpress/wp-content/plugins
 ---> Using cache
 ---> b80a6e521f5d
Step 3/3 : ENV PHP_MEMORY_LIMIT=512m
 ---> Using cache
 ---> d457be4ef91c
Successfully built d457be4ef91c
Successfully tagged docker-repo:latest
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] withEnv
[Pipeline] {
[Pipeline] withDockerRegistry
Executing sh script inside container docker of pod helm-deploy-jnq5s-zm3cn
Executing command: "docker" "login" "-u" "AWS" "-p" ******** "https://390844773286.dkr.ecr.eu-west-3.amazonaws.com" 
exit
WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /home/jenkins/agent/workspace/wordpress@tmp/e65b86c0-7bc5-4f84-9d74-c7065b7b8d24/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
[Pipeline] {
[Pipeline] isUnix
[Pipeline] withEnv
[Pipeline] {
[Pipeline] sh
+ docker tag docker-repo 390844773286.dkr.ecr.eu-west-3.amazonaws.com/docker-repo:17
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] isUnix
[Pipeline] withEnv
[Pipeline] {
[Pipeline] sh
+ docker push 390844773286.dkr.ecr.eu-west-3.amazonaws.com/docker-repo:17
The push refers to repository [390844773286.dkr.ecr.eu-west-3.amazonaws.com/docker-repo]
db35af977b85: Preparing
45a94d00d95c: Preparing
45a94d00d95c: Layer already exists
db35af977b85: Layer already exists
17: digest: sha256:c4a686441184b0865f6953ebe5ef5923418f91416b4d848454a378b892636c6f size: 738
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] isUnix
[Pipeline] withEnv
[Pipeline] {
[Pipeline] sh
+ docker tag docker-repo 390844773286.dkr.ecr.eu-west-3.amazonaws.com/docker-repo:latest
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] isUnix
[Pipeline] withEnv
[Pipeline] {
[Pipeline] sh
+ docker push 390844773286.dkr.ecr.eu-west-3.amazonaws.com/docker-repo:latest
The push refers to repository [390844773286.dkr.ecr.eu-west-3.amazonaws.com/docker-repo]
db35af977b85: Preparing
45a94d00d95c: Preparing
45a94d00d95c: Layer already exists
db35af977b85: Layer already exists
latest: digest: sha256:c4a686441184b0865f6953ebe5ef5923418f91416b4d848454a378b892636c6f size: 738
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // withDockerRegistry
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // container
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Deployment to K3s with Helm)
[Pipeline] container
[Pipeline] {
[Pipeline] script
[Pipeline] {
[Pipeline] sh
+ helm upgrade --install wordpress ./wordpress
Release "wordpress" does not exist. Installing it now.
NAME: wordpress
LAST DEPLOYED: Fri Nov 22 18:19:11 2024
NAMESPACE: jenkins
STATUS: deployed
REVISION: 1
TEST SUITE: None
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // container
[Pipeline] }
[Pipeline] // stage
[Pipeline] stage
[Pipeline] { (Application Verification)
[Pipeline] script
[Pipeline] {
[Pipeline] echo
Waiting 30 seconds for the application ...
[Pipeline] sleep
Sleeping for 30 sec
[Pipeline] echo
Verifying application accessibility...
[Pipeline] sh
+ curl -LI http://wordpress.aws.alextonkovid.site/ --fail --silent --show-error
HTTP/1.1 200 OK
Server: nginx/1.18.0
Date: Fri, 22 Nov 2024 18:19:43 GMT
Content-Type: text/html; charset=UTF-8
Connection: keep-alive
Link: <http://wordpress.aws.alextonkovid.site/wp-json/>; rel="https://api.w.org/"

[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // withEnv
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

- Provide a PR with the application, Helm chart, and Jenkinsfile in a repository.
- Ensure that the pipeline runs successfully and deploys the application to the K8s cluster.
![alt text](img/333.png)
![alt text](img/image.png)
- Provide a README file documenting the pipeline setup and deployment process.

## Evaluation Criteria (100 points for covering all criteria)

1. **Pipeline Configuration (40 points)**

   - A Jenkins pipeline is configured and stored as a Jenkinsfile in the main git repository.
   - The pipeline includes the following steps:
     - Application build (not nessesary wiSth wordpress)
     - Unit test execution
					![alt text](img/ima33ge.png)
     - Security check with SonarQube
					![alt text](<img/image copy.png>)
     - Docker image building and pushing to ECR (manual trigger)
					![alt text](img/imag44e.png)
     - Deployment to K8s cluster with Helm (dependent on the previous step)
					![alt text](img/ima55ge.png)
2. **Artifact Storage (20 points)**

   - Built artifacts (Dockerfile, Helm chart) are stored in git and ECR (Docker image). 
![alt text](<img/image copy 2.png>)
[link to chart](https://github.com/alextonkovid/aws-devops-application/blob/task_6/wordpress/Chart.yaml)
3. **Repository Submission (5 points)**

   - A repository is created with the application, 
		 [Helm chart](https://github.com/alextonkovid/aws-devops-application/blob/task_6/wordpress/Chart.yaml), and
			[Jenkinsfile](https://github.com/alextonkovid/aws-devops-application/blob/task_6/Jenkinsfile) .

4. **Verification (5 points)**

   - The pipeline runs successfully and deploys the application to the K8s cluster.
![alt text](<img/image copy 4.png>)

5. **Additional Tasks (30 points)**
   - **Application Verification (10 points)**
     - Application verification is performed (e.g., curl main page, send requests to API, smoke test).
					![alt text](<img/image copy 5.png>)
   - **Notification System (10 points)**
     - A notification system is set up to alert on pipeline failures or successes.
					![alt text](img/image-22.png)
   - **Documentation (10 points)**
     - The pipeline setup and deployment process, are documented in a README file.