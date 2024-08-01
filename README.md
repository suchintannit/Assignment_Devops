<h1>A Two Tier Application Consisting of a PHP Frontend and a MYSQL Backend Running on Individual Containers.</h1>

<h4>1. Creating the backend.sh to automate the backend. The backend runs a mysql-server container and hosts the Table that stores data from the frontend.The script installs docker in the backend instance and runs the mysql-server container from dockerhub. Then, running the mysql script using docker exec creates the backend.</h4>
  <h5>MYSQL Script - https://github.com/suchintannit/Assignment_Devops/blob/main/db-sql.sql</h5>

```
#Install Docker in the Backend
#! /bin/bash
sudo apt-get update -y
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
#Pull and Run the Mysql-server conatiner and change the root user password to 1234
docker run — name mydb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=1234 -d mysql:5.7
#Once the container executes, we run the Mysql script in backend to create the database without logging into the mysql prompt.
sudo docker exec -i mydb mysql -u root -p1234 < path to/db-sql.sql

```

<h4>2. Creating the frontend.sh to automate the frontend. The script installs docker and runs our frontend app from dockerhub.</h4>

```
#Install Docker in the Frontend
#! /bin/bash
sudo apt-get update -y
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
#Pull and Run the Frontend PHP Container
sudo docker pull suchintantraining/frontend
#Link the frontend container with the 'mydb' mysql-server container run in the previous step
sudo docker run -dp 80:80 --link mydb:mydb 4bda355c9da1
```

<h3> How the Frontend Container is created.</h3>
The Frontend Container is a simple PHP application that takes user input using HTML forms and stores the data in the container running the backend. The frontend container is created using the 3 files.
  
1. index.html - https://github.com/suchintannit/Assignment_Devops/blob/main/contact.php 
2. contact.php - https://github.com/suchintannit/Assignment_Devops/blob/main/index.html
3. db-sql.sql - https://github.com/suchintannit/Assignment_Devops/blob/main/db-sql.sql

Once these file are written in any directory, a Dockerfile can be created as shown below,
```
FROM ubuntu
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y
RUN apt-get install apache2 -y
RUN apt-get install php -y
RUN apt-get install php-mysql -y
ADD . /var/www/html
EXPOSE 80
CMD [“apache2ctl”, “-D”, “FOREGROUND”]
```
The Dockerfile (when build as an image) copies the ubuntu image and makes the frontend non-interactive. It then updates the image and installs apache, php and its modules. It copies the folder containing the 3 files mentioned above to the containers /var/www/html. It exposes port 80 of the container and as entrypoint adds a command to run apache in the foreground.

After writing the Dockerfile the image can be build and pushed to dockerhub using the following command:
```
sudo docker build -t frontend
sudo docker tag frontend suchintantraining/frontend
sudo docker push suchintantraining/frontend
```
<h4>Creating the AWS Infrastructure to run both the Containers in the Same Instance</h4>

AWS infrastructure can be created using an IAAC tool such as Terraform. Below is a Terraform file that creates an ubuntu EC2 instance and provisons the instance with both frontend and backend bash sricpts. Then it uses remote-exec provisioner to run them on the system.
```
resource "aws_instance" "Application" {
  ami           = "ami-03f0544597f43a91d"
  instance_type = "t2.micro"
  key_name = "Desktop-key"
  tags = {
    Name = "master"
  }
  provisioner "file" {
    source      = "./frontend.sh"
    destination = "/home/ubuntu/frontend.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./Desktop-key.pem")}"
      host        = "${self.public_dns}"
    }
  }
  provisioner "file" {
    source      = "./backend.sh"
    destination = "/home/ubuntu/backend.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./Desktop-key.pem")}"
      host        = "${self.public_dns}"
    }
  }
provisioner "file" {
    source      = "./db-sql.sql"
    destination = "/home/ubuntu/db-sql.sql"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./Desktop-key.pem")}"
      host        = "${self.public_dns}"
    }
  }
provisioner "remote-exec" {
   connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("./Desktop-key.pem")}"
      host        = "${self.public_dns}"
    }
    inline = [
      "./backend.sh",
      "./frontend.sh",
    ]
  }  

  }
```
<h4>Building a CI/CD Pipeline</h4>
Further this can be automated through a Jenkins CI/CD Pipeline as stages. The following Jenkinsfile can create the infrastructure and deploy the application.

```
pipeline {
    agent any
  parameters {
    password (name: 'your-aws-access-id')
    password (name: 'your-aws-access-key')
  }
  environment {
    TF_WORKSPACE = 'dev' //Sets the Terraform Workspace
    TF_IN_AUTOMATION = 'true'
    AWS_ACCESS_KEY_ID = "your-aws-access-id"
    AWS_SECRET_ACCESS_KEY = "your-aws-access-key"
  }
stages {
    stage('Terraform init') {
      steps {
        sh "cd /path_to_your_main.tf && terraform init -input=false"
      }
    }
    stage('Terraform plan') {
      steps {
        sh "cd /path_to_your_main.tf && terraform plan -out=tfplan -input=false "
      }
    }
    stage('Terraform apply') {
      steps {
        sh "cd /path_to_your_main.tf && terraform apply -input=false -out=tfplan"
      }
    }
}
}
```
<h2>Additional Steps to Run the Containers on 2 different Instances.</h2>
The instances are supposed to execute in the same AWS VPC but Frontend instance runs on the Public subnet while the the Backend instance runs on the private subnet. Using docker swarm, 2 contaners running on host1 and host2 can communicate. Using the following additional changes to the frontend and backend script.

```
#On Backend Run the following command
sudo docker swarm init --advertise-addr 10.0.2.232

#On Frontend Run the following for it to join the Backend
docker swarm join --token SWMTKN-1-33whghul7v7923zmcq5lxhj4b50d6an12ljorohzpwwlu1qfqf-8z66lgpxuvf1cd6ctajkxhnb9 10.0.2.232:2377
```
By adding these lines to frontend.sh and backend.sh (after installing docker) and (before running contaners) can allow the systems to communicate with each other.

updated Backend.sh
```
#! /bin/bash
sudo apt-get update -y
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo docker swarm init --advertise-addr 10.0.2.232
#Pull and Run the Mysql-server conatiner and change the root user password to 1234
docker run — name mydb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=1234 -d mysql:5.7
#Once the container executes, we run the Mysql script in backend to create the database without logging into the mysql prompt.
sudo docker exec -i mydb mysql -u root -p1234 < path to/db-sql.sql
```

Updated Frontend.sh:

```
#! /bin/bash
sudo apt-get update -y
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
#Pull and Run the Mysql-server conatiner and change the root user password to 1234
docker swarm join --token SWMTKN-1-33whghul7v7923zmcq5lxhj4b50d6an12ljorohzpwwlu1qfqf-8z66lgpxuvf1cd6ctajkxhnb9 10.0.2.232:2377
sudo docker run -dp 80:80 --link mydb:mydb 4bda355c9da1
```
