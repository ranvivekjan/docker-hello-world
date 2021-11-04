FROM anapsix/alpine-java
ADD target/my-app-*.jar myjar.jar
CMD ["java","-jar","/home/myjar.jar"]
