# Docker AI应用

[![GitHub release](https://img.shields.io/github/v/release/chensoul/docker-ai-app)](https://github.com/chensoul/docker-ai-app/releases)
[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/chensoul/docker-ai-app/ci.yml?branch=main)](https://github.com/chensoul/docker-ai-app/actions/workflows/test.yml)
[![License](https://img.shields.io/github/license/chensoul/docker-ai-app)](LICENSE)
[![GitHub stars](https://img.shields.io/github/stars/chensoul/docker-ai-app)](https://github.com/chensoul/docker-ai-app/stargazers)


基于Docker Model Runner和Spring AI构建的AI应用，支持文本生成、向量搜索和RAG功能。

## 功能特性

- 🤖 **Docker AI模型**: 使用Docker Model Runner运行ai/gemma3模型
- 🔍 **向量搜索**: 基于pgvector的语义搜索，使用ai/embeddinggemma嵌入模型
- 📚 **RAG支持**: 检索增强生成，自动从向量存储检索相关文档
- 🌊 **流式响应**: 实时流式输出
- 🐳 **Docker支持**: 容器化部署
- 📊 **健康监控**: 完整的健康检查
- ⚡ **零配置**: 无需API密钥，开箱即用

## 快速开始

### 1. 环境要求

- Docker Desktop 4.40+ (macOS) 或 4.41+ (Windows) (支持Docker Model Runner)
- Java 25
- Maven 3.9+
- 内存: 至少16GB（推荐32GB）
- 系统: macOS (Apple Silicon), Windows (Intel/AMD), 或 Linux (NVIDIA GPU)

### 2. 启用Docker Model Runner

1. 打开Docker Desktop
2. 进入 Settings → AI
3. 启用 "Docker Model Runner"
4. 启用 "Enable host-side TCP support" (默认端口12434)
5. 应用设置并重启Docker Desktop

### 3. 启动服务

```bash
# 一键启动所有服务（包含PostgreSQL、Docker Model Runner、AI模型和Spring Boot应用）
./start.sh
```

`start.sh` 脚本会自动完成以下操作：
- 启动PostgreSQL数据库服务
- 检查Docker Desktop和Docker Model Runner可用性
- 拉取ai/gemma3模型并启动AI模型服务
- 构建并启动Spring Boot应用
- 验证所有服务状态

### 4. 测试功能

```bash
# 运行测试脚本
./test.sh

# 或者手动测试
curl -X POST http://localhost:8080/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "你好"}'
```

## API接口

### 聊天接口

```bash
POST /api/chat
Content-Type: application/json

{
  "message": "你的问题"
}
```

### 流式聊天

```bash
GET /api/chat/stream?message=你的问题
Accept: text/event-stream

# 注意：URL 中的中文字符需要进行编码
# 例如：message=Hello%20AI 而不是 message=Hello AI
```

### 文档管理

```bash
POST /api/chat/document
Content-Type: application/json

{
  "content": "要添加的文档内容"
}
```
## 配置说明

### 应用配置 (application.yml)

- **聊天模型**: ai/gemma3 (文本生成)
- **嵌入模型**: ai/embeddinggemma (768维度向量嵌入)
- **API端点**: http://localhost:12434/engines/llama.cpp
- **数据库**: PostgreSQL 16 + pgvector 0.8.1
- **向量存储**: PgVectorStore with EUCLIDEAN_DISTANCE
- **端口**: 8080 (Spring应用), 12434 (Docker Model Runner), 5432 (PostgreSQL)

### Docker配置

- **Docker Model Runner**: 运行AI模型 (无需额外容器)
- **PostgreSQL**: 存储向量数据
- **零配置**: 无需API密钥或复杂设置

## 开发指南

### 项目结构

```
docker-ai-app/
├── src/main/java/cc/chensoul/ai/
│   ├── Application.java              # 主应用类
│   ├── AIChatService.java           # AI聊天服务
│   ├── ChatController.java          # REST控制器
│   └── dto/                         # 数据传输对象
│       ├── ChatRequest.java
│       ├── ChatResponse.java
│       ├── DocumentRequest.java
│       └── DocumentResponse.java
├── src/main/resources/
│   └── application.yml              # 应用配置
├── start.sh                         # 一键启动脚本（包含所有服务）
├── test.sh                          # 测试脚本
├── docker-compose.yml               # PostgreSQL服务配置
├── Dockerfile                       # 应用容器化配置（JDK 25）
└── pom.xml                          # Maven配置（JDK 25）
```

### 添加新功能

1. 在`AIChatService`中添加业务逻辑
2. 在`ChatController`中添加API端点
3. 创建相应的DTO类
4. 更新测试脚本

## 故障排除

### 常见问题

1. **内存不足**: 增加Docker内存限制
2. **模型加载失败**: 检查网络连接和磁盘空间
3. **数据库连接失败**: 确认PostgreSQL服务状态
4. **pgvector SQL语法错误**: 已解决，使用EUCLIDEAN_DISTANCE替代COSINE_DISTANCE

### 已解决的问题

#### pgvector SQL语法兼容性问题
**问题**: `PreparedStatementCallback; bad SQL grammar [SELECT *, embedding <=> ? AS distance FROM public.vector_store WHERE embedding <=> ? < ? ORDER BY distance LIMIT ? ]`

**原因**: Spring AI 1.0.3 与 pgvector 0.8.1 在使用 COSINE_DISTANCE 时存在 SQL 语法不兼容

**解决方案**: 
- 使用 `EUCLIDEAN_DISTANCE` 替代 `COSINE_DISTANCE`
- 保持 pgvector 0.8.1 版本 (PostgreSQL 16)
- 配置正确的向量维度 (768) 匹配 ai/embeddinggemma 模型

#### 向量存储配置
```yaml
spring:
  ai:
    vectorstore:
      pgvector:
        index-type: HNSW
        distance-type: EUCLIDEAN_DISTANCE  # 关键配置
        dimensions: 768
        initialize-schema: true
        remove-existing-vector-store-table: false
```

### 日志查看

```bash
# 查看应用日志
tail -f logs/ai-app.log

# 查看Docker日志
docker-compose logs -f
```

## 性能优化

- 使用GPU加速（如果可用）
- 调整模型参数
- 启用响应缓存
- 使用模型量化

## 相关资源

- [Docker Model Runner官方文档](https://docs.docker.com/ai/model-runner/)
- [Spring AI官方文档](https://docs.spring.io/spring-ai/reference/)
- [Docker官方文档](https://docs.docker.com/)
- [Hugging Face模型库](https://huggingface.co/models)