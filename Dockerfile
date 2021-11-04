FROM anapsix/alpine-java
ARG workspace
COPY ${workspace}/*.jar /home/myjar.jar
CMD ["java","-jar","/home/myjar.jar"]
