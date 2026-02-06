# FROM node:18-alpine

# # Create app directory
# WORKDIR /usr/src/app

# # Install app dependencies
# COPY package*.json ./

# RUN npm install

# # Bundle app source
# COPY . .

# EXPOSE 3000

# CMD [ "node", "index.js" ]

# ---- build stage ----
FROM node:18-alpine AS builder
RUN apk update && apk upgrade --no-cache
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .

# ---- runtime stage ----
FROM node:18-alpine
RUN apk update && apk upgrade --no-cache
WORKDIR /app
COPY --from=builder /app /app
CMD ["node", "index.js"]
