<h1>A Two Tier Application Consisting of a PHP Frontend and a MYSQL Backend Running on Individual Containers</h1>
<h3>Creating the backend.sh to automate the backend. The backend runs a mysql-server container and hosts the Table that stores data from the frontend.The script installs docker in the backend instance and runs the mysql-server container from dockerhub.</h3>
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
```

<h3>Creating the frontend.sh to automate the frontend. The script installs docker and runs our frontend app from dockerhub.</h3>

```#! /bin/bash
$ sudo apt-get update -y
```

<h3> How the Frontend Container is created.</h3>
