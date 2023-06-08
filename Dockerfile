FROM openjdk:11-jre
EXPOSE 8080
COPY target/my-app-*.jar /home/myjar.jar
CMD ["java","-jar","/home/myjar.jar"]
