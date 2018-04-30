FROM node:carbon-alpine

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

# Install any needed packages specified in package.json
RUN npm install

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variables
# ENV NAME World

# Run app when the container launches
ENTRYPOINT [ "sh", "/app/test.sh" ]
