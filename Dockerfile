###############################
# 1. BUILD STAGE
###############################
FROM node:20 AS build

WORKDIR /app

# Accept PUBLIC_URL at build time
ARG PUBLIC_URL
ENV PUBLIC_URL=$PUBLIC_URL

# Copy only package files first (better Docker caching)
COPY package.json package-lock.json* ./

# Install required Linux esbuild binary BEFORE full install
RUN npm install esbuild --platform=linux --force

# Install dependencies
RUN npm ci

# Copy full project (includes .env)
COPY . .

# Ensure Strapi CLI is executable
RUN chmod +x node_modules/.bin/strapi

# Build Strapi Admin Panel using PUBLIC_URL
RUN npm run build


###############################
# 2. RUNTIME STAGE
###############################
FROM node:20-alpine

WORKDIR /app

ENV NODE_ENV=production

# Copy everything from the build stage
COPY --from=build /app /app

# Expose Strapi port
EXPOSE 1337

# Start Strapi
CMD ["npm", "start"]
