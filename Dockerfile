FROM maven:3-eclipse-temurin-17-alpine AS build

ARG SERVICE_VERSION=4560c68d89b733f217dcdc8b442880fc2be02949

RUN apk add --no-cache git maven &&\
    git clone -b $SERVICE_VERSION --depth=1 https://gitlab.eclipse.org/eclipse/xfsc/cat/fc-service.git &&\
    cd /fc-service &&\
    mvn clean package -pl fc-service-server -am -Dmaven.test.skip=true

FROM eclipse-temurin:17-jre-alpine
COPY --from=build /fc-service/fc-service-server/target/fc-service-server-*.jar /opt/fc-service-server.jar
ENTRYPOINT ["java", "-jar","/opt/fc-service-server.jar"]
