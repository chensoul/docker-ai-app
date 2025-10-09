#!/bin/bash

echo "开始启动Docker AI应用..."

# 启动PostgreSQL服务
echo "启动PostgreSQL服务..."
docker-compose up -d

# 等待服务启动
echo "等待PostgreSQL服务启动..."
sleep 10

# 检查服务状态
echo "检查服务状态..."
docker-compose ps

# 设置Docker Model Runner
echo "设置Docker Model Runner for Docker AI应用..."

# 检查Docker Desktop是否运行
if ! docker info > /dev/null 2>&1; then
    echo "错误: Docker Desktop未运行，请先启动Docker Desktop"
    exit 1
fi

# 检查Docker Model Runner是否可用
if ! docker model --help > /dev/null 2>&1; then
    echo "错误: Docker Model Runner不可用"
    echo "请确保："
    echo "1. Docker Desktop 4.40+ (macOS) 或 4.41+ (Windows) 已安装"
    echo "2. 在Docker Desktop设置中启用了'Docker Model Runner'"
    echo "3. 在Docker Desktop设置中启用了'Enable host-side TCP support' (端口12434)"
    echo ""
    echo "如果仍然遇到问题，请尝试创建符号链接："
    echo "ln -s /Applications/Docker.app/Contents/Resources/cli-plugins/docker-model ~/.docker/cli-plugins/docker-model"
    exit 1
fi

echo "拉取ai/gemma3模型..."
docker model pull ai/gemma3

echo "拉取ai/embeddinggemma模型..."
docker model pull ai/embeddinggemma

echo "验证模型安装..."
docker model list

echo "启动模型服务..."
docker model run ai/gemma3 &
docker model run ai/embeddinggemma &

echo "等待模型启动..."
sleep 10

echo "测试模型连接..."
curl -s http://localhost:12434/engines/llama.cpp/v1/models

echo ""
echo "Docker Model Runner设置完成！"
echo "模型API端点: http://localhost:12434/engines/llama.cpp"

echo "启动Spring Boot应用..."
echo "正在构建和启动应用，请稍候..."

# 启动Spring Boot应用
./mvnw spring-boot:run &

# 等待Spring Boot应用启动
echo "等待Spring Boot应用启动..."
sleep 15

# 检查Spring Boot应用是否启动成功
echo "检查Spring Boot应用状态..."
if curl -s http://localhost:8080/actuator/health > /dev/null 2>&1; then
    echo "✅ Spring Boot应用启动成功！"
else
    echo "⚠️  Spring Boot应用可能还在启动中，请稍等片刻..."
fi

echo ""
echo "🎉 所有服务启动完成！"
echo "📱 Spring应用: http://localhost:8080"
echo "🤖 Docker Model Runner: http://localhost:12434"
echo "🗄️  PostgreSQL: localhost:5432"
echo ""
echo "💡 提示: 使用 Ctrl+C 停止所有服务"
