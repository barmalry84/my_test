FROM node:20

# Set the working directory in the container
WORKDIR /usr/src/api

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./
COPY .env.example ./.env

# Install the application dependencies
RUN npm install

# Expose the application on port 3000
EXPOSE 3000

# Run the application
CMD ["npm", "run", "start"]