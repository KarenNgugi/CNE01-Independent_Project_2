# CNE Independent Project 2 - Containerization

## Project Overview
The project sets up a Student Grade Tracker — a 3-tier web application that allows students to be added, grades to be recorded, and results to be viewed.


After completing this project, I will be able to demonstrate how to:
* Design a multi-container application architecture
* Write production-grade Dockerfiles for multiple services
* Build, tag, and push Docker images to a registry
* Define and manage a multi-container stack using Docker Compose
* Configure container networking and persistent storage
* Apply Docker image optimisation and security best practices
* Troubleshoot and debug container issues independently
* Document your work professionally on GitHub

## Stack
* **Frontend:** Nginx (port 80)
* **Backend:** Node.js API (port 3000)
* **Database:** PostgreSQL (port 5432)

## System Architecture*

## Project Structure*
* **`backend/:`**
* **`database/:`**
* **`docs/:`**
* **`frontend/:`**
* **`scripts/:`**

## Setup & Installation*
### 1. Prerequisites
Make sure you have installed the following:
- Node.js (best done with NVM)
- Docker
- Nginx


### 2. Local Installation
#### 2.1. PostgreSQL (database)
Install and start PostgreSQL locally (Ubuntu/Debian):

```
# change working directory
cd database

# update package manager
sudo apt update

# install postgresql & dependencies
sudo apt install -y postgresql postgresql-contrib

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
# change working directory
cd backend

# install dependencies
npm install

# kill any existing processes on port 3000
sudo kill $(sudo lsof -t -i :3000)

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

#### 2.3. Nginx (frontend)
Before starting on Nginx, first confirm the initial set up is ok:
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
}
```

Run `sudo nginx -t` again to confirm configuration test is OK then run `sudo systemctl reload nginx` to reload the Nginx server.

Confirm your site is up and running on `http://localhost:80`.

### 3. Docker Installation


