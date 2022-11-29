ARG JAVA_VERSION="17"

FROM docker.io/library/eclipse-temurin:${JAVA_VERSION}-jdk-alpine AS builder

ARG MAVEN_CLI_OPTS="--batch-mode --errors --fail-at-end --show-version"
ENV MAVEN_OPTS="-Dhttps.protocols=TLSv1.2 -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=WARN -Dorg.slf4j.simpleLogger.showDateTime=true -Djava.awt.headless=true"

WORKDIR /src/sitodo
COPY . .
RUN ./mvnw ${MAVEN_CLI_OPTS} -DskipTests clean package

FROM docker.io/library/eclipse-temurin:${JAVA_VERSION}-jre-alpine AS runner

WORKDIR /opt/sitodo
COPY --from=builder /src/sitodo/target/*.jar app.jar

ENTRYPOINT ["java"]
CMD ["-jar", "app.jar"]
