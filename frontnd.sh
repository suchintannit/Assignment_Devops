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
