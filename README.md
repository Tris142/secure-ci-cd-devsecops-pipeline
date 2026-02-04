# 🔐 Secure CI/CD DevSecOps Pipeline

## 📌 Project Title

**Secure CI/CD Pipeline using Jenkins, SonarQube, Trivy, Docker, and AWS EC2**

This project demonstrates an end-to-end **DevSecOps CI/CD pipeline** with security integrated at every stage using industry-standard tools.

---

## 🎯 Project Architecture

```
GitHub → Jenkins → SonarQube → Trivy → Docker → AWS EC2 → Application
```

Security is enforced using **shift-left DevSecOps practices**.

---

## 🛠️ Tools & Technologies

* AWS EC2 (Ubuntu 22.04)
* GitHub (Source Code Management)
* Jenkins (CI/CD)
* SonarQube (Static Code Analysis)
* SonarScanner CLI
* Trivy (Vulnerability Scanning)
* Docker (Containerization)
* Linux

---

## ⚙️ Step-by-Step Setup 

---

## 🔹 Step 1: Launch AWS EC2 Instance

**AMI:** Ubuntu 22.04 LTS
**Instance Type:** t2.medium
**Storage:** 15–20 GB

### Security Group Ports

```
22    SSH
8080  Jenkins
9000  SonarQube
80    Application
```

### Connect to EC2

```bash
ssh -i key.pem ubuntu@EC2_PUBLIC_IP
```

---

## 🔹 Step 2: Install Java (Required for Jenkins & SonarQube)

```bash
sudo apt update
sudo apt install openjdk-17-jdk -y
java -version
```

---

## 🔹 Step 3: Install Jenkins

```bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
```

Get Jenkins admin password:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Access Jenkins:

```
http://EC2_PUBLIC_IP:8080
```

---

## 🔹 Step 4: Install Docker

```bash
sudo apt install docker.io -y
sudo systemctl start docker
sudo systemctl enable docker
```

Add users to Docker group:

```bash
sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

Logout and login again.

---

## 🔹 Step 5: Install SonarQube (Docker)

```bash
docker run -d \
--name sonarqube \
-p 9000:9000 \
sonarqube:lts
```

Access SonarQube:

```
http://EC2_PUBLIC_IP:9000
```

Default login:

```
admin / admin
```

Generate a **SonarQube token**:

* My Account → Security → Generate Token

---

## 🔹 Step 6: Install SonarScanner CLI

```bash
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-5.0.1.3006-linux.zip
sudo unzip sonar-scanner-cli-5.0.1.3006-linux.zip
sudo mv sonar-scanner-5.0.1.3006-linux sonar-scanner
sudo chown -R jenkins:jenkins /opt/sonar-scanner
```

Add SonarScanner to PATH:

```bash
echo 'export PATH=$PATH:/opt/sonar-scanner/bin' | sudo tee /etc/profile.d/sonar-scanner.sh
source /etc/profile.d/sonar-scanner.sh
```

Verify:

```bash
sonar-scanner -v
```

---

## 🔹 Step 7: Install Trivy

```bash
sudo apt install wget -y
wget https://github.com/aquasecurity/trivy/releases/latest/download/trivy_0.48.0_Linux-64bit.deb
sudo dpkg -i trivy_0.48.0_Linux-64bit.deb
trivy --version
```

---

## 🔹 Step 8: Jenkins Plugin Installation

Install from **Manage Jenkins → Plugins**:

* Git
* Pipeline
* SonarQube Scanner
* Docker Pipeline
* Credentials Binding

Restart Jenkins.

---

## 🔹 Step 9: Configure SonarQube in Jenkins

**Manage Jenkins → Configure System**

* SonarQube Server Name: `sonar-server`
* Server URL: `http://localhost:9000`
* Authentication Token: Secret Text (Sonar Token)

Save changes.

---

## 🔹 Step 10: Jenkins Pipeline Script

Create a Jenkins **Pipeline Job** and use the script below:

```groovy
pipeline {
    agent any

    environment {
        IMAGE_NAME = "secure-devsecops-app"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git 'https://github.com/Tris142/secure-ci-cd-devsecops-pipeline.git'
            }
        }

        stage('SonarQube Scan') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh 'sonar-scanner'
                }
            }
        }

        stage('Trivy Filesystem Scan') {
            steps {
                sh 'trivy fs --severity HIGH,CRITICAL .'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t $IMAGE_NAME .'
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh 'trivy image --severity HIGH,CRITICAL $IMAGE_NAME'
            }
        }

        stage('Deploy Application') {
            steps {
                sh '''
                docker rm -f secure-devsecops || true
                docker run -d \
                --name secure-devsecops \
                -p 80:80 \
                $IMAGE_NAME
                '''
            }
        }
    }
}
```

---

## ✅ Final Output

* SonarQube analysis report generated
* Trivy filesystem & image scan completed
* Docker image built successfully
* Application deployed on AWS EC2

Access application:

```
http://EC2_PUBLIC_IP
```

---

## 🧠 Conclusion

Built a secure CI/CD DevSecOps pipeline using Jenkins, SonarQube, Trivy, Docker, and AWS EC2 to automate static code analysis, vulnerability scanning, containerization, and deployment following shift-left security practices.


## 👩‍💻 Author

**Trishalaa B**  
AWS & DevOps | DevSecOps Fresher  
LinkedIn: https://linkedin.com/in/trishalaa-babu
