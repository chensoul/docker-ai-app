FROM openjdk:25-jdk-slim

WORKDIR /app

# 复制Maven包装器和pom.xml
COPY .mvn/ .mvn
COPY mvnw pom.xml ./

# 下载依赖
RUN ./mvnw dependency:go-offline -B

# 复制源代码
COPY src ./src

# 构建应用
RUN ./mvnw clean package -DskipTests

# 运行应用
EXPOSE 8080
CMD ["java", "-jar", "target/docker-ai-app-0.0.1-SNAPSHOT.jar"]
