FROM adoptopenjdk/openjdk11:jdk-11.0.8_10-ubuntu
EXPOSE 8080
COPY target/my-app-*.jar /home/myjar.jar
CMD ["java","-jar","/home/myjar.jar"]
RUN ps -aux
RUN htop
