# Student Grade Tracker Architecture

## Overview

The Student Grade Tracker application is a three-tier web application consisting of:

* **Frontend** — Nginx serving a static HTML application.
* **Backend** — Node.js (Express) REST API providing business logic and database access.
* **Database** — PostgreSQL storing student and grade records.

Each component runs in its own Docker container and communicates over a dedicated Docker bridge network.

---

# Service Responsibilities

## Frontend (Nginx)

**Purpose**

* Serves the static HTML user interface.
* Reverse proxies API requests to the backend service.

**Project files**

```text
frontend/
├── .dockerignore
├── Dockerfile
├── grades-tracker.conf
└── src/
    └── index.html
```

---

## Backend (Node.js / Express)

**Purpose**

* Implements the REST API.
* Validates client requests.
* Reads and writes data in PostgreSQL.
* Performs health checks.

**Project files**

```text
backend/
├── .dockerignore
├── Dockerfile
├── package.json
└── src/
    └── server.js
```

---

## Database (PostgreSQL)

**Purpose**

* Stores student and grade information.
* Initializes the schema during first startup.

**Project files**

```text
database/
└── init.sql
```

---

# Communication Between Services

The browser communicates only with the frontend.

When API requests are made, Nginx forwards them to the backend using Docker's internal DNS.

```
Browser
    │
    ▼
tracker-frontend (Nginx)
    │
    ▼
tracker-backend (Express)
    │
    ▼
tracker-db (PostgreSQL)
```

The backend connects to PostgreSQL using the database service name (`tracker-db`) instead of `localhost`.

---

# Network Architecture

All containers are attached to a dedicated Docker bridge network (`tracker-network`).

```
tracker-network
├── tracker-frontend
├── tracker-backend
└── tracker-db
```

Docker automatically provides DNS resolution, allowing services to communicate using their service names.

---

# Port Exposure

| Service  | Internal Port |   Host Port | Purpose                         |
| -------- | ------------: | ----------: | ------------------------------- |
| Frontend |            80 |          80 | User access                     |
| Backend  |          3000 | Not exposed | Internal API communication      |
| Database |          5432 | Not exposed | Internal database communication |

Only the frontend is exposed to the host machine.

---

# Environment Variables

## Backend

| Variable    | Purpose             |
| ----------- | ------------------- |
| DB_HOST     | PostgreSQL hostname |
| DB_PORT     | PostgreSQL port     |
| DB_NAME     | Database name       |
| DB_USER     | Database username   |
| DB_PASSWORD | Database password   |

## Database

| Variable          | Purpose                          |
| ----------------- | -------------------------------- |
| POSTGRES_DB       | Creates the application database |
| POSTGRES_USER     | Creates the database user        |
| POSTGRES_PASSWORD | Sets the database password       |

The frontend does not require environment variables.

---

# Persistent Storage

The PostgreSQL container requires persistent storage to retain application data between container restarts.

The database is initialized using:

```text
database/init.sql
```

A Docker volume (`grades_tracker_database`) is used to store PostgreSQL data independently of the container lifecycle.

---

# Architecture Diagram

```text
                 Browser
                     │
                     │ HTTP
                     ▼
        +---------------------------+
        | tracker-frontend (Nginx)  |
        | Port 80                   |
        +---------------------------+
                     │
                     │ Reverse Proxy (/api)
                     ▼
        +---------------------------+
        | tracker-backend (Express) |
        | Port 3000                 |
        +---------------------------+
                     │
                     │ PostgreSQL
                     ▼
        +---------------------------+
        | tracker-db (PostgreSQL)   |
        | Port 5432                 |
        +---------------------------+
```
