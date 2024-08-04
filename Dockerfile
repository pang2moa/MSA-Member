# Use Amazon Corretto 11 as base image
FROM amazoncorretto:11-alpine-jdk

# Set the working directory in the container
WORKDIR /app

# Copy the jar file into the container
COPY target/*.jar app.jar

# Expose the port the app runs on
EXPOSE 8080

# Run the jar file 
ENTRYPOINT ["java","-jar","/app/app.jar"]