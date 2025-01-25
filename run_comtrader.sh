#!/bin/bash

# Step 1: Build the Docker Image
echo "Building the Docker image..."
docker build -t comtrader-shiny .
if [ $? -ne 0 ]; then
  echo "Error: Failed to build the Docker image. Exiting."
  exit 1
fi

# Step 2: Run the Docker Container in Interactive Mode
echo "Starting the Docker container..."
CONTAINER_ID=$(docker run -it -d -p 3838:3838 comtrader-shiny)
if [ $? -ne 0 ]; then
  echo "Error: Failed to start the Docker container. Exiting."
  exit 1
fi

echo "Docker container started with ID: $CONTAINER_ID"

# Step 3: Launch the Browser Automatically
echo "Opening the app in the browser..."
sleep 5  # Allow time for the container to initialize
BROWSER_URL="http://localhost:3838"
xdg-open $BROWSER_URL || start $BROWSER_URL || open $BROWSER_URL

# Step 4: Follow the Container Logs
echo "Press Ctrl+C to stop the app..."
docker logs -f $CONTAINER_ID

# Step 5: Stop and Clean Up the Docker Container
echo "Stopping the Docker container..."
docker stop $CONTAINER_ID
docker rm $CONTAINER_ID

# Step 6: Optionally Remove the Docker Image
read -p "Do you want to delete the Docker image (comtrader-shiny)? [y/N]: " DELETE_IMAGE
if [[ $DELETE_IMAGE =~ ^[Yy]$ ]]; then
  echo "Removing the Docker image..."
  docker rmi comtrader-shiny
fi

echo "The comtrader app and Docker container have been cleaned up."
