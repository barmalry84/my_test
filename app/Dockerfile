FROM node:20

# Copy needed things to the working directory
COPY . /usr/src/app
RUN cp .env.example .env

# Set the working directory in the container
WORKDIR /usr/src/app

# Install the application dependencies
RUN npm install

# Expose the application on port 3000
EXPOSE 3000

# Run the application
CMD ["npm", "run", "start"]