#!/bin/bash

echo "开始测试Docker AI应用..."

# 检查服务状态
echo "检查服务状态..."
echo "PostgreSQL状态:"
docker-compose ps

echo "Docker Model Runner状态:"
curl -s http://localhost:12434/engines/llama.cpp/v1/models | jq .

echo "Spring Boot应用状态:"
curl -s http://localhost:8080/actuator/health | jq .

# 测试基础聊天功能
echo ""
echo "测试基础聊天功能..."
curl -s -X POST http://localhost:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, how are you?"}' | jq .

# 测试文档添加功能
echo ""
echo "测试文档添加功能..."
curl -s -X POST http://localhost:8080/api/chat/document \
  -H "Content-Type: application/json" \
  -d '{"content": "Spring AI是Spring生态系统中的新项目，专门用于简化AI应用的开发。它支持多种AI模型和向量存储。"}' | jq .

# 测试向量搜索功能
echo ""
echo "测试向量搜索功能..."
curl -s -X POST http://localhost:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "什么是Spring AI？"}' | jq .

# 测试流式聊天功能
echo ""
echo "测试流式聊天功能..."
curl -s -X GET "http://localhost:8080/api/chat/stream?message=Hello%20AI" | head -5

echo ""
echo "✅ 所有测试完成！"
echo "📱 Spring应用: http://localhost:8080"
echo "🤖 Docker Model Runner: http://localhost:12434"
echo "🗄️  PostgreSQL: localhost:5432"
