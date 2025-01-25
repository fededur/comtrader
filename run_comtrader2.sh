#!/bin/bash

set -e  # Exit immediately if any command exits with a non-zero status

# Step 1: Build the Docker Image
echo "Building the Docker image..."
docker build -t comtrader-shiny .
if [ $? -ne 0 ]; then
  echo "Error: Failed to build the Docker image. Exiting."
  exit 1
fi

# Step 2: Run the Docker Container in Detached Mode
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
if command -v xdg-open &>/dev/null; then
  xdg-open "$BROWSER_URL"
elif command -v start &>/dev/null; then
  start "$BROWSER_URL"
elif command -v open &>/dev/null; then
  open "$BROWSER_URL"
else
  echo "Warning: Could not automatically open the browser. Please navigate to $BROWSER_URL manually."
fi

# Step 4: Clean Up on Interrupt (Ctrl+C)
trap "echo 'Stopping the Docker container...'; docker stop $CONTAINER_ID; docker rm $CONTAINER_ID; exit 0" SIGINT

# Step 5: Follow the Container Logs
echo "Press Ctrl+C to stop the app or close the browser window..."
docker logs -f "$CONTAINER_ID"

# Step 6: Clean Up the Docker Container
echo "Stopping the Docker container..."
docker stop "$CONTAINER_ID"
docker rm "$CONTAINER_ID"

# Step 7: Optionally Remove the Docker Image
read -p "Do you want to delete the Docker image (comtrader-shiny)? [y/N]: " DELETE_IMAGE
if [[ "$DELETE_IMAGE" =~ ^[Yy]$ ]]; then
  echo "Removing the Docker image..."
  docker rmi comtrader-shiny
fi

echo "The comtrader app and Docker container have been cleaned up."

