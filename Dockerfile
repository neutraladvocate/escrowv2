FROM ethereum/client-go

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
ADD . /app

# Install any needed packages specified in package.json
RUN npm install

# Make port 80 available to the world outside this container
EXPOSE 80 22

# Define environment variable
# ENV NAME World

# Run app.py when the container launches
CMD ["./app/test.sh"]
