
FROM eclipse-temurin:20-jdk AS build
WORKDIR /workspace
COPY . .
RUN chmod +x gradlew \
    && ./gradlew bootJar --no-daemon -x test
RUN JAR="$(ls build/libs/*-SNAPSHOT.jar | grep -v plain)" \
    && cp "$JAR" /workspace/app.jar

FROM eclipse-temurin:20-jre
WORKDIR /app
COPY --from=build /workspace/app.jar /app/app.jar
EXPOSE 8090
ENV SERVER_PORT=8090
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
