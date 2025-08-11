# Use the official Node.js runtime as the base image
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json (if available)
COPY package*.json ./

# Install dependencies (even though there are none in this case)
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port the app runs on
EXPOSE 3000

# Create a non-root user to run the application
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001 -G nodejs
RUN chown -R nodejs:nodejs /app
USER nodejs

# Define the command to run the application
CMD ["npm", "start"]
