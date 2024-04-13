# Use official Node.js image as the base image
FROM node:latest

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy only the necessary application files to the working directory
COPY index.js ./
COPY marquee.json ./

# Expose port 6000
EXPOSE 6000

# Command to run the application
CMD ["node", "index.js"]
