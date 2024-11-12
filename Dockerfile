# Use an official Maven runtime as a parent image
FROM maven:3.8.4-openjdk-17 AS build

# Set the working directory in the container
WORKDIR /app

# Copy the Maven project file(s) and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the application source code
COPY src ./src

# Package the application
RUN mvn package

# Use a lightweight JDK base image to run the application
FROM tomcat:10.1.20

# Create a non-root user and group
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Set the working directory in the container
WORKDIR /app

# Copy the application JAR file from the build stage
COPY --from=build /app/target/log4j-exploit-demo-1.1.jar ./app.jar

# Change ownership of the application JAR file
RUN chown appuser:appuser /app/app.jar

# Expose the default Tomcat port
EXPOSE 8080

# Set the user to run the container
USER appuser

# Start Tomcat when the container launches
CMD ["catalina.sh", "run"]



