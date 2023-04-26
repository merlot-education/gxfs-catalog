FROM maven:3-eclipse-temurin-17-alpine AS build

ARG SERVICE_VERSION=1.0.1

RUN apk add --no-cache git maven &&\
    git clone -b $SERVICE_VERSION --depth=1 https://gitlab.com/gaia-x/data-infrastructure-federation-services/cat/fc-service.git &&\
    cd /fc-service &&\
    mvn clean package -pl fc-service-server -am -Dmaven.test.skip=true

FROM eclipse-temurin:17-jre-alpine
COPY --from=build /fc-service/fc-service-server/target/fc-service-server-*.jar /opt/fc-service-server.jar
ENTRYPOINT ["java", "-jar","/opt/fc-service-server.jar"]
