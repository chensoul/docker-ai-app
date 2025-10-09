package cc.chensoul.ai.dto;

public class DocumentResponse {
    private String message;
    
    public DocumentResponse() {}
    
    public DocumentResponse(String message) {
        this.message = message;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
}
