FROM maven:3-eclipse-temurin-17-alpine AS build

ARG SERVICE_VERSION=1.0.1

RUN apk add --no-cache git maven

# Clone fc-service repository
RUN git clone -b $SERVICE_VERSION --depth=1 https://gitlab.eclipse.org/eclipse/xfsc/cat/fc-service.git

# Remove default schema files in fc-service
RUN rm -rf /fc-service/fc-service-core/src/main/resources/defaultschema/shacl/* &&\
	rm -rf /fc-service/fc-service-core/src/main/resources/defaultschema/ontology/*

# Clone catalog-shapes repository
RUN git clone https://github.com/merlot-education/catalog-shapes.git 

RUN apk add --no-cache python3

# Run merge-shapes.py, copy default schema files from catalog-shapes into fc-service
RUN python3 /catalog-shapes/merge-shapes.py &&\
    cp /catalog-shapes/shacl/shapes/mergedShapes.ttl fc-service/fc-service-core/src/main/resources/defaultschema/shacl/ &&\
	cp /catalog-shapes/shacl/ontology/* /fc-service/fc-service-core/src/main/resources/defaultschema/ontology/ &&\
    rm -rf /catalog-shapes

# Change to fc-service directory
WORKDIR /fc-service

# Perform Maven build
RUN mvn clean package -pl fc-service-server -am -Dmaven.test.skip=true

FROM eclipse-temurin:17-jre-alpine
COPY --from=build /fc-service/fc-service-server/target/fc-service-server-*.jar /opt/fc-service-server.jar
ENTRYPOINT ["java", "-jar", "/opt/fc-service-server.jar"]
