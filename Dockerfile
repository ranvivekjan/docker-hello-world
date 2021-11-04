FROM anapsix/alpine-java
COPY *.jar /home/myjar.jar
CMD ["java","-jar","/home/myjar.jar"]
