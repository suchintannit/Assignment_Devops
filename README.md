<h1>A Two Tier Application Consisting of a PHP Frontend and a MYSQL Backend Running on Individual Containers</h1>

<h4>Step:1 Creating the backend.sh to automate the backend. The backend runs a mysql-server container and hosts the Table that stores data from the frontend.The script installs docker in the backend instance and runs the mysql-server container fromdockerhub. Then, running the mysql script using docker exec creates the backend.[MYSQL Script] (https://github.com/suchintannit/Assignment_Devops/blob/main/db-sql.sql)</h4>

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

<h4>Step:2 Creating the frontend.sh to automate the frontend. The script installs docker and runs our frontend app from dockerhub.</h4>

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
sudo docker run --name mydb -e MYSQL_ROOT_PASSWORD=1234 -p 3306:3306 -d mysql:5.7
```

<h3> How the Frontend Container is created.</h3>
The Frontend Container is a simple PHP application that takes user input using HTML forms and stores the data in the container running the backend. The frontend container is created using the 3 files 
  
1. index.html - 
2. contact.php
3. db-sql.sql

Once these file are written in any directory, a Dockerfile can be created as shown below
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
The Dockerfile copies the ubuntu image and makes the frontend noninteractive. It then updates the container and installs apache, php and its modules. It copies the folder containing the 3 files mentioned above to the containers /var/www/html. It exposes port 80 of the container and as entrypoint adds a command to run apache in the forground.
After writing the Dockerfile the image can be build and pushed to dockerhub using the following command:
```
sudo docker build -t frontend
sudo docker tag frontend suchintantraining/frontend
sudo docker push suchintantraining/frontend
```
