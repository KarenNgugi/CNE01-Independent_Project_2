 # CNE Independent Project 2 - Containerization

## Project Overview
The project sets up a Student Grade Tracker — a 3-tier web application that allows students to be added, grades to be recorded, and results to be viewed.


This project demonstrates how to:
* Design a multi-container application architecture
* Write production-grade Dockerfiles for multiple services
* Build, tag, and push Docker images to a registry
* Define and manage a multi-container stack using Docker Compose
* Configure container networking and persistent storage
* Apply Docker image optimisation and security best practices
* Troubleshoot and debug container issues independently
* Document your work professionally on GitHub

## Quick Start
```
git clone git@github.com:KarenNgugi/CNE01-Independent_Project_2.git # SSH
# git clone https://github.com/KarenNgugi/CNE01-Independent_Project_2.git # HTTPS

cd CNE01-Independent_Project_2

docker compose up -d
```

Open `http://localhost` on your browser

## Stack
* **Frontend:** Nginx (port 80)
* **Backend:** Node.js API (port 3000)
* **Database:** PostgreSQL (port 5432)

## System Architecture
![Student Grade Tracker Application Architecture](https://github.com/KarenNgugi/CNE01-Independent_Project_2/blob/main/docs/ip2%20architecture.png)

Full details of the architecture can be found [here](https://github.com/KarenNgugi/CNE01-Independent_Project_2/blob/main/docs/architecture.md).

## Project Structure
* **`backend/:`** the Express.js backend application. database
* **`database/:`** contains `init.sql` which initializes the PostgreSQL database
* **`docs/:`** contains architecture-related infomation
* **`frontend/:`** contains the frontend assets served by Nginx
* **`scripts/:`** contains helper scripts for image building and health checks

## Setup & Installation
### 1. Prerequisites
Make sure you have installed the following:
- Node.js (best done with [NVM](https://www.nvmnode.com/guide/download.html))
- [Docker](https://docs.docker.com/engine/install/)
- [Nginx](https://github.com/nginx/nginx#downloading-and-installing)
- [PostgreSQL](https://www.postgresql.org/download/)

To clone this repository, carry out the following:
```
# create project directory and move into it
mkdir grades_tracker_app; cd $_

# clone the project files
git clone git@github.com:KarenNgugi/CNE01-Independent_Project_2.git .

# if using HTTPS instead of SSH, use this instead
# https://github.com/KarenNgugi/CNE01-Independent_Project_2.git
```

### 2. Local Installation
#### 2.1. PostgreSQL (database)
Install and start PostgreSQL locally (Ubuntu/Debian):

```
# change working directory
cd database

# enable postgresql
sudo systemctl enable postgresql

# change password
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'password';"

# create database
sudo -u postgres psql -c "CREATE DATABASE grades_db OWNER postgres;"

# create table & data for database
psql -h localhost -U postgres -d grades_db -f init.sql 
```

When prompted for the password, type `password` and press enter. If successful, you will get the following output:
```
Password for user postgres: 
CREATE TABLE
CREATE TABLE
INSERT 0 5
INSERT 0 10
```

#### 2.2. Node.js API (backend)
```
# install and switch to node version 24
nvm install 24
nvm use 24

# change working directory
cd backend

# install dependencies
npm install

# kill any existing processes on port 3000
sudo lsof -t -i :3000 | xargs -r sudo kill

# confirm there are no processes on port 3000
sudo lsof -i :3000

# start the application
npm start
```

When successful, you will see this output:
```
> grade-tracker-api@1.0.0 start
> node src/server.js

Database connection established
Grade Tracker API running on port 3000
```
Don't stop the service or close the current terminal.

The following endpoints can be accessed:
* **`/api/students:`** returns JSON data of current students in the database
* **`/api/grades:`** returns JSON data of grades per students
* **`/health:`** returns JSON data of the health endpoint

#### 2.3. Nginx (frontend)
Open a new terminal. Before starting on Nginx, first confirm the initial set up is ok:
```
sudo nginx -t
```
If it is correct, you will see the following output:
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

Next, set Nginx up to serve your file
```
# create a new directory for your project
mkdir /var/www/grades-tracker

# copy the index.html file to the new directory
sudo cp frontend/src/index.html /var/www/grades-tracker/

# create configuration file for your project
touch /etc/nginx/sites-available/grades-tracker

# create a symbolic link to your configuration to enable your site to be served
sudo ln -s /etc/nginx/sites-available/grades-tracker /etc/nginx/sites-enabled/
```

Add the following to `/etc/nginx/sites-available/grades-tracker`:
```
server {
    listen 80;
    server_name localhost;

    location / {
        root /var/www/grades-tracker;
        index index.html;
    }

    location /api/ {
        proxy_pass http://localhost:3000;
    }
}
```

Run `sudo nginx -t` again to confirm configuration test is OK then run `sudo systemctl reload nginx` to reload the Nginx server.

Confirm your site is up and running on `http://localhost:80`.

### 3. Docker Installation
Install the Docker engine as per the instructions in [the official documentstion](https://docs.docker.com/engine/install/).

#### 3.1. Running the database container
```
# create dedicated network
docker network create tracker-network

# navigate to the database directory
cd database

# run docker command to create container using existing postgres:17 image
docker run \
    --name tracker-db \
    -e POSTGRES_USER=postgres \
    -e POSTGRES_PASSWORD=password \
    -e POSTGRES_DB=grades_db \
    --network tracker-network \
    -v ./init.sql:/docker-entrypoint-initdb.d/init.sql \
    -d postgres:17
```

#### 3.2. Running the backend container
```
# navigate to the backend directory
cd ../backend

# build image from Dockerfile
docker build -t tracker-backend:v1 .

# create container using image
docker run \
    --name tracker-backend \
    --network tracker-network \
    -e DB_HOST=tracker-db \
    -e DB_PORT=5432 \
    -e DB_USER=postgres \
    -e DB_PASSWORD=password \
    -e DB_NAME=grades_db \
    -d tracker-backend:v1
```

#### 3.3. Running the frontend container
```
# navigate to the frontend directory
cd ../frontend

# build image from Dockerfile
docker build -t tracker-frontend:v1 .

# create container using image
docker run \
    -p 80:80 \
    --name tracker-frontend \
    --network tracker-network \
    -d tracker-frontend:v1
```

You can now access the site on your browser via **`http://localhost`**
#### 3.4. Running with Docker Compose
```
# install docker compose (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install docker-compose-plugin -y

# start all services
docker compose up -d
```

Give the app time to start up, then access it through **`http://localhost`**

When you are ready to take the app down, run the following:
```
docker compose down
```

**Note:** because of data persistence, any changes made to the database will persist when you restart the application. If you wish to completely wipe out the changes you made, run `docker compose down -v`.

## Troubleshooting Guide
### Connection to port refused
This often happens when the port you wish to use (80 for Nginx or 3000 for NodeJS) is already occupied. Run one or both of the following commands:
```
# stop nginx
sudo systemctl stop nginx

# stop postgresql
sudo systemctl stop postgresql
```
Confirm the ports are free with `sudo lsof -i :<port_number>`. It should return no output.

### Container name already exists
There are 2 ways to deal with this:
1. Use a new name. This is not recommended as you will need to update the new name in other containers and configurations, and you can miss.
2. Stop, remove, and recreate the container with the same name (recommended). The container can be stopped with `docker stop <container_name>` and removed with `docker rm <container_name>`.

### Other issues
In case of other issues, check the container's logs to find out more information. They can be obtained with the command `docker logs <container_name>`.

## Lessons Learned
- Custom built images should be scanned with Trivy or Docker Scout prior to use to check for security vulnerabilities.
- Containers should communicate using Docker network hostnames, not localhost.
- Port mappings expose services to the host; they are not used for communication between containers.
- Nginx reverse proxy should forward requests to the backend service name.
- The trailing slash in proxy_pass affects how request URIs are forwarded.
- Health checks provide an application-level indication of service readiness beyond simply checking whether a container is running.

## Author Information
Author: [Karen Ngugi](https://github.com/KarenNgugi)
