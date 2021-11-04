FROM anapsix/alpine-java
ARG workspace
RUN echo "$workspace"
COPY /home/runner/work/maven-hello-world/maven-hello-world/my-app/target/my-app-1.0.1-shaded.jar /home/myjar.jar
CMD ["java","-jar","/home/myjar.jar"]
