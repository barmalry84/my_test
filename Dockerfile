FROM node:20

# Copy needed artifacts
COPY . app

# Set the working directory in the container
WORKDIR app

# Install the application dependencies
RUN npm install

# Expose the application on port 3000
EXPOSE 3000

# Run the application
CMD ["npm", "run", "start"]