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
WORKDIR /app
COPY package*.json ./
RUN npm ci --omit=dev
COPY . .

# ---- runtime stage ----
FROM gcr.io/distroless/nodejs18-debian12
WORKDIR /app
COPY --from=builder /app /app
CMD ["index.js"]
