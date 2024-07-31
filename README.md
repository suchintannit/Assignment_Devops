<h1>A Two Tier Application Consisting of a PHP Frontend and a MYSQL Backend</h1>
<h3>Creating the backend.sh to automate the backend. The backend runs a mysql-server container and hosts the table that stores data from the frontend.The script installs docker in the backend instance and runs the mysql-server container from dockerhub.</h3>
```
#! /bin/bash
sudo apt-get update -y
```


<h3>Creating the frontend.sh to automate the frontend. The script installs docker and runs our frontend app from dockerhub.</h3>
```
#! /bin/bash
$ sudo apt-get update -y
```
<h3> How the Frontend Container is created.</h3>
