FROM node:20

# Copy needed things to the working directory
COPY . /usr/src/api

# Set the working directory in the container
WORKDIR /usr/src/api
RUN ls -la
COPY .env.example .env

# Install the application dependencies
RUN npm install

# Expose the application on port 3000
EXPOSE 3000

# Run the application
CMD ["npm", "run", "start"]