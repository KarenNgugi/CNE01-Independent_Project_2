# stage 1 - set up base
FROM node:24-slim AS base

# install security updates
RUN apt update && apt upgrade -y && \
	rm -rf /var/lib/apt/lists/*

# set working directory 
WORKDIR /backend

# stage 2 - install production dependencies
# pin specific node version
FROM base AS builder

# copy dependencies files
COPY package*.json ./

# install dependencies using clean install
RUN npm ci --omit=dev

# copy only the files the application needs
COPY /src ./src

# stage 3 - preparing for production
# pin specific node version
FROM node:lts-alpine3.23

# copy only build artifacts and runtime dependencies
COPY --from=builder /backend/src ./src/
COPY --from=builder /backend/node_modules ./node_modules
COPY --from=builder /backend/package.json ./

# create group & user 
RUN addgroup --gid 1001 nodegroup && \
	adduser -G nodegroup -u 1001 -D nodeuser

# switch to nonroot user
USER nodeuser

# expose port 3000
EXPOSE 3000

# set environment variables to connect to the database
ENV \
	DB_HOST=tracker-db \
	DB_PORT=5432 \
	DB_USER=postgres \
	DB_PASSWORD=password \
	DB_NAME=grades_db

# conduct healthcheck of database
HEALTHCHECK --interval=5s --timeout=10s --start-period=15s --retries=10 \
	CMD node -e "require('http').get('http://localhost:3000/health', (r) => process.exit(r.statusCode === 200 ? 0 : 1))"

# entrypoint command
CMD ["npm", "start"]



