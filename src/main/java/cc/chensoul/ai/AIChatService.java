package cc.chensoul.ai;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.ai.document.Document;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class AIChatService {
    
    private final ChatClient chatClient;
    private final VectorStore vectorStore;
    
    public AIChatService(ChatClient.Builder chatClientBuilder, 
                        VectorStore vectorStore) {
        this.chatClient = chatClientBuilder.build();
        this.vectorStore = vectorStore;
    }
    
    public String chat(String userMessage) {
        // 构建上下文
        String context = buildContext(userMessage);
        
        // 发送到AI模型
        return chatClient.prompt()
                .user(context + "\n\n用户问题: " + userMessage)
                .call()
                .content();
    }
    
    private String buildContext(String message) {
        // 从向量数据库检索相关文档
        List<Document> docs = vectorStore.similaritySearch(
            SearchRequest.builder().query(message).topK(3).build()
        );
        
        return docs.stream()
                .map(Document::getFormattedContent)
                .collect(Collectors.joining("\n"));
    }
    
    public void addDocument(String content) {
        // 将文档添加到向量数据库
        Document document = new Document(content);
        vectorStore.add(List.of(document));
    }
    
    public Flux<String> streamChat(String message) {
        // 构建上下文
        String context = buildContext(message);
        
        // 发送到AI模型并返回流式响应
        return chatClient.prompt()
                .user(context + "\n\n用户问题: " + message)
                .stream()
                .content();
    }
}