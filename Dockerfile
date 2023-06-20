FROM openjdk:11-jre
EXPOSE 8080
COPY target/my-app-*.jar /home/myjar.jar
RUN htop
CMD ["java","-jar","/home/myjar.jar"]
