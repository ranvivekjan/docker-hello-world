FROM anapsix/alpine-java
ARG workspace
RUN echo "$workspace"
COPY $workspace/my-app/target/*.jar /home/myjar.jar
CMD ["java","-jar","/home/myjar.jar"]
