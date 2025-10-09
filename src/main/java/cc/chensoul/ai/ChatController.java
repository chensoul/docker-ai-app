package cc.chensoul.ai;

import cc.chensoul.ai.dto.ChatRequest;
import cc.chensoul.ai.dto.ChatResponse;
import cc.chensoul.ai.dto.DocumentRequest;
import cc.chensoul.ai.dto.DocumentResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Flux;
import org.springframework.http.MediaType;
import org.springframework.http.codec.ServerSentEvent;

@RestController
@RequestMapping("/api/chat")
public class ChatController {
    
    @Autowired
    private AIChatService chatService;
    
    @PostMapping
    public ResponseEntity<ChatResponse> chat(@RequestBody ChatRequest request) {
        try {
            String response = chatService.chat(request.getMessage());
            return ResponseEntity.ok(new ChatResponse(response));
        } catch (Exception e) {
            return ResponseEntity.status(500)
                    .body(new ChatResponse("AI服务暂时不可用: " + e.getMessage()));
        }
    }
    
    @GetMapping(value = "/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<ServerSentEvent<String>> streamChat(@RequestParam String message) {
        try {
            return chatService.streamChat(message)
                    .map(content -> ServerSentEvent.builder(content).build())
                    .onErrorResume(throwable -> {
                        return Flux.just(ServerSentEvent.builder("AI服务暂时不可用: " + throwable.getMessage()).build());
                    });
        } catch (Exception e) {
            return Flux.just(ServerSentEvent.builder("AI服务暂时不可用: " + e.getMessage()).build());
        }
    }
    
    @PostMapping("/document")
    public ResponseEntity<DocumentResponse> addDocument(@RequestBody DocumentRequest request) {
        try {
            chatService.addDocument(request.getContent());
            return ResponseEntity.ok(new DocumentResponse("文档添加成功"));
        } catch (Exception e) {
            return ResponseEntity.status(500)
                    .body(new DocumentResponse("文档添加失败: " + e.getMessage()));
        }
    }
}
