FROM maven:3.9-eclipse-temurin-21 AS build

WORKDIR /app

COPY pom.xml .
COPY src ./src
RUN mvn -q package -DskipTests

FROM eclipse-temurin:21-jre-jammy

WORKDIR /app

COPY --from=build /app/target/dockerfile-demo-1.0.0.jar app.jar

EXPOSE 8000

CMD ["java", "-jar", "app.jar"]
