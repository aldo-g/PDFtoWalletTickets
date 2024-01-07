# Use an official Python runtime as a parent image
FROM python:3.8-slim-buster

# Set the working directory in the container to /app
WORKDIR /app

# Add the current directory contents into the container at /app
ADD . /app

# Install the project dependencies
RUN apt-get update && apt-get install -y build-essential libssl-dev
RUN apt-get update && apt-get install -y swig
RUN apt-get update && apt-get install -y libzbar0
RUN apt-get update && apt-get install -y poppler-utils
RUN pip install poetry
RUN poetry config virtualenvs.create false
RUN poetry install --no-root

# Make port 80 available to the world outside this container
EXPOSE 80

# Run main.py when the container launches
CMD ["poetry", "run", "python", "main.py"]