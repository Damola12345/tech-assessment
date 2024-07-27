# Stage 1: Build
FROM node:18-alpine AS builder

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .

# Stage 2: Run
FROM node:18-alpine

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy only the necessary files from the build stage
COPY --from=builder /usr/src/app /usr/src/app

# Expose the application port
EXPOSE 3000

# Define the command to run the application
CMD [ "node", "app.mjs" ]



