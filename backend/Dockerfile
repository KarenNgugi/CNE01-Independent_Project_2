FROM node:24-slim

WORKDIR /src

COPY package.json package.json

RUN npm install

COPY . .

RUN addgroup --gid 1001 nodegroup && adduser --gid 1001 nodeuser && chown -R nodeuser:nodegroup /src

USER nodeuser

EXPOSE 3000

CMD ["npm", "start"]




