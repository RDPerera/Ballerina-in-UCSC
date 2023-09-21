import ballerina/http;
import ballerinax/openai.chat;

configurable int port = 3000;
configurable string OPEN_AI_KEY = ?;

chat:Client chatClient = check new ({
    auth: {
    token: OPEN_AI_KEY
    }
});

public function rewrite(string inputText) returns string|error? {
    chat:CreateChatCompletionRequest req = {
    model: "gpt-3.5-turbo",
    messages: [{"role": "user", "content": "Rewrite the following text in academic writing:"+inputText}]
    };
    chat:CreateChatCompletionResponse res = check chatClient->/chat/completions.post(req);
    return res.choices[0].message?.content;
}
service / on new http:Listener(port) {
    resource function post write(@http:Payload string inputText) returns string {
        string|error? ouputText = rewrite(inputText);
        if (ouputText is string) {
            return ouputText;
        } else if (ouputText is error) {
            return "Error: "+ouputText.message();
        }
        else {
            return "Error while rewriting the text !";
        }
    }
}