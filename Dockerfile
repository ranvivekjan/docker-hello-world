FROM adoptopenjdk/openjdk11:jdk-11.0.11_9-alpine-slim
EXPOSE 8080
COPY target/my-app-*.jar /home/myjar.jar
RUN htop
CMD ["java","-jar","/home/myjar.jar"]
