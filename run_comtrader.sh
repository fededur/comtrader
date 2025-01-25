#!/bin/bash

# Step 1: Build the Docker Image
echo "Building the Docker image..."
docker build -t comtrader-shiny .
if [ $? -ne 0 ]; then
  echo "Error: Failed to build the Docker image. Exiting."
  exit 1
fi

# Step 2: Run the Docker Container in Detached Mode
echo "Starting the Docker container..."
CONTAINER_ID=$(docker run -d -p 3838:3838 comtrader-shiny)
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

# Step 4: Provide User Instructions
echo "************************************************************"
echo "************************************************************"
echo "************************************************************"
echo "                                                            "
echo " The app is now running. You can access it at: $BROWSER_URL"
echo " To stop the app, press Ctrl+C in this terminal."
echo "                                                            "
echo "************************************************************"
echo "************************************************************"
echo "************************************************************"

# Step 5: Graceful App Shutdown on Ctrl+C
cleanup() {
  echo "Stopping the Docker container..."
  docker stop $CONTAINER_ID > /dev/null
  docker rm $CONTAINER_ID > /dev/null
  echo "Docker container stopped and removed."

  # Ask to remove the Docker image
  read -p "Do you want to delete the Docker image (comtrader-shiny)? [y/N]: " DELETE_IMAGE
  if [[ $DELETE_IMAGE =~ ^[Yy]$ ]]; then
    echo "Removing the Docker image..."
    docker rmi comtrader-shiny > /dev/null
  fi

  echo "The comtrader app and Docker container have been cleaned up."
  exit 0
}

# Set trap to execute cleanup on Ctrl+C
trap cleanup SIGINT

# Monitor logs and wait for user to stop
docker logs -f $CONTAINER_ID
cleanup
