# Dockerfile - lightweight Node app
FROM node:18-alpine

WORKDIR /app

# copy package files first to take advantage of layer caching
COPY package*.json ./
RUN npm install --production

# copy app source
COPY . .

ENV PORT=3000
EXPOSE 3000

CMD ["node", "index.js"]
