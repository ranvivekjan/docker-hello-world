FROM anapsix/alpine-java
ADD target/my-app-1.0.1-shaded.jar myjar.jar
CMD ["java","-jar","/home/myjar.jar"]
