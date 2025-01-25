#!/bin/bash

# Trap signals to clean up properly
cleanup() {
  echo "Stopping the Docker container..."
  docker stop "$CONTAINER_ID" > /dev/null
  docker rm "$CONTAINER_ID" > /dev/null
  echo "Container stopped and removed."
  exit 0
}
trap cleanup SIGINT SIGTERM

# Step 1: Build the Docker Image
echo "Building the Docker image..."
docker build -t comtrader-shiny .
if [ $? -ne 0 ]; then
  echo "Error: Failed to build the Docker image. Exiting."
  exit 1
fi

# Step 2: Run the Docker Container
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
xdg-open "$BROWSER_URL" || start "$BROWSER_URL" || open "$BROWSER_URL"

# Step 4: Monitor and Wait for User Action
echo "The app is running. Press Ctrl+C to stop the app, or close the browser to disconnect."

# Loop to keep the script running and detect browser closure
while docker ps --format "{{.ID}}" | grep -q "$CONTAINER_ID"; do
  sleep 2
done

# Clean up if the container stops
cleanup

