# GitHub Action for building Maven proj with Docker and push it Docker Hub

### My Workflow
The project is simple "Hello world" Maven project that I created 2 Dockerfiles for him.

One simple Dockerfile that copies the artifacts to the image and run the `.jar` file:

```Docker
FROM anapsix/alpine-java
ADD target/my-app-*.jar /home/myjar.jar
CMD ["java","-jar","/home/myjar.jar"]
```

And second Multi Stage Dockerfile that build the project as well:

```Docker
FROM maven:3 as BUILD_IMAGE
ENV APP_HOME=/root/dev/myapp/
RUN mkdir -p $APP_HOME/src/main/java
WORKDIR $APP_HOME
COPY . .
RUN mvn -B package -e -X --file my-app/pom.xml

FROM openjdk:8-jre
WORKDIR /root/
COPY --from=BUILD_IMAGE /root/dev/myapp/my-app/target/my-app*.jar .
CMD java -jar my-app*.jar
```

So, I created 2 GitHub workflows for the project:

1. Build maven project with standard Dockerfile. this wokrflow contains 3 jobs: **1.** Bump the `.jar` version and building the maven project. **2.** Building the docker image and push it Docker Hub. **3.** Pull the image and run it.

```yaml
name: Maven Package

on:
  [push]

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    outputs:
      jar_version: ${{ steps.bump.outputs.jar_version }}

    steps:
    - uses: actions/checkout@v2
    - name: Set up JDK 8
      uses: actions/setup-java@v2
      with:
        java-version: '8'
        distribution: 'adopt'
        server-id: github # Value of the distributionManagement/repository/id field of the pom.xml
        settings-path: ${{ github.workspace }} # location for the settings.xml file
        
    - name: Bump jar version
      id: bump
      run: |
        POMPATH=my-app
        OLD_VERSION=$(cd $POMPATH && mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
        BUMP_MODE="none"
        old="$OLD_VERSION"
        parts=( ${old//./ } )
        bv=$((parts[2] + 1))
        NEW_VERSION="${parts[0]}.${parts[1]}.${bv}"
        echo "pom.xml at" $POMPATH "will be bumped from" $OLD_VERSION "to" $NEW_VERSION
        mvn -q versions:set -DnewVersion="${NEW_VERSION}" --file $POMPATH/pom.xml
        echo ::set-output name=jar_version::${NEW_VERSION}
            
    - name: Compile
      run: mvn -B compile --file my-app/pom.xml
      
    - name: Build a package
      run: mvn -B package --file my-app/pom.xml
      
    - name: Temporarily save jar artifact
      uses: actions/upload-artifact@v2
      with:
        name: jar-artifact
        path: ${{ github.workspace }}/my-app/target/*.jar
        retention-days: 1
        
  deploy:
    runs-on: ubuntu-18.04
    needs: build
    
    steps:
    - uses: actions/checkout@v2
    - uses: actions/download-artifact@v1
      with:
          name: jar-artifact
          path: target/
    - name: Docker build
      run: |
        docker build . -t shayki/shayki-maven:${{needs.build.outputs.jar_version}}
    - name: Login to DockerHub
      uses: docker/login-action@v1
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Docker push
      run: |
        docker push shayki/shayki-maven:${{needs.build.outputs.jar_version}}
  run:
    runs-on: ubuntu-18.04
    needs: [build, deploy]
    
    steps:
    - name: Run container
      run: |
        docker run shayki/shayki-maven:${{needs.build.outputs.jar_version}}
```

2. Build the maven project with Multi Stage Dockerfile. in this workflow the building step is inside the docker and not like above. so the build & deploy it's in one job, and running the image it's in a second job.

```yaml
name: Maven Package - Multi stage docker

on:
  [push]

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    outputs:
      jar_version: ${{ steps.bump.outputs.jar_version }}

    steps:
    - uses: actions/checkout@v2

    - name: Bump jar version
      id: bump
      run: |
        POMPATH=my-app
        OLD_VERSION=$(cd $POMPATH && mvn help:evaluate -Dexpression=project.version -q -DforceStdout)
        BUMP_MODE="none"
        old="$OLD_VERSION"
        parts=( ${old//./ } )
        bv=$((parts[2] + 1))
        NEW_VERSION="${parts[0]}.${parts[1]}.${bv}"
        echo "pom.xml at" $POMPATH "will be bumped from" $OLD_VERSION "to" $NEW_VERSION
        mvn -q versions:set -DnewVersion="${NEW_VERSION}" --file $POMPATH/pom.xml
        echo ::set-output name=jar_version::${NEW_VERSION}
            
    - name: Docker build
      run: |
        docker build . -t shayki/shayki-maven:${{ steps.bump.outputs.jar_version }} -f DockerfileMultiStage
    - name: Login to DockerHub
      uses: docker/login-action@v1
      with:
        username: ${{ secrets.DOCKER_USERNAME }}
        password: ${{ secrets.DOCKER_PASSWORD }}

    - name: Docker push
      run: |
        docker push shayki/shayki-maven:${{ steps.bump.outputs.jar_version }}
  run:
    runs-on: ubuntu-18.04
    needs: [build]
    
    steps:
    - name: Run container
      run: |
        docker run shayki/shayki-maven:${{needs.build.outputs.jar_version}}
```

I used several workflows in my project:

- checkout@v2
- setup-java@v2
- upload-artifact@v2
- download-artifact@v1
- docker/login-action@v1

### Submission Category: 

Maintainer Must-Haves

