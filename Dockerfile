FROM maven:3-eclipse-temurin-17-alpine AS build

ARG SERVICE_VERSION=b6939bd8
COPY add_merlot_pubkey.patch /add_merlot_pubkey.patch
RUN apk add --no-cache git maven &&\
    git clone -b main https://gitlab.eclipse.org/eclipse/xfsc/cat/fc-service.git &&\
    cd /fc-service &&\
	git apply /add_merlot_pubkey.patch &&\
	git checkout $SERVICE_VERSION &&\
    mvn clean package -pl fc-service-server -am -Dmaven.test.skip=true

FROM eclipse-temurin:17-jre-alpine
COPY --from=build /fc-service/fc-service-server/target/fc-service-server-*.jar /opt/fc-service-server.jar
ENTRYPOINT ["java", "-jar","/opt/fc-service-server.jar"]
