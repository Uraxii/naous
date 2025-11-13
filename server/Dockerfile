# Use an official Python runtime as a parent image
FROM python:3.13.9-alpine3.22

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY server .

# Install any needed packages specified in requirements.txt 
RUN pip install --no-cache-dir -r requirements.txt

# Make port 8080 available to the world outside this container (Optional, only for web apps)
EXPOSE 8080

# Define environment variable (optional)
ENV NAME DV

# Run app.py when the container launches
CMD ["python", "app.py"]
