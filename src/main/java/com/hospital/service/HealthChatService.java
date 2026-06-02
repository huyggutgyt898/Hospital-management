package com.hospital.service;

import com.hospital.util.AiConfig;
import org.json.JSONArray;
import org.json.JSONObject;

public class HealthChatService {

    private final GroqChatClient groqClient = new GroqChatClient();
    private final LocalHealthAssistant localAssistant = new LocalHealthAssistant();

    public JSONObject chat(String message, JSONArray history, String lang) {
        JSONObject result = new JSONObject();
        String safeLang = "en".equalsIgnoreCase(lang) ? "en" : "vi";

        try {
            if (shouldUseGroq()) {
                String systemPrompt = buildSystemPrompt(safeLang);
                JSONArray messages = buildMessages(history, message);
                String reply = groqClient.chat(systemPrompt, messages);
                result.put("success", true);
                result.put("reply", reply);
                result.put("source", "groq");
                return result;
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.put("groqError", e.getMessage());
        }

        String localReply = localAssistant.reply(message, safeLang);
        result.put("success", true);
        result.put("reply", localReply);
        result.put("source", "local");
        return result;
    }

    private boolean shouldUseGroq() {
        if ("local".equals(AiConfig.getProvider())) {
            return false;
        }
        return AiConfig.isGroqConfigured();
    }

    private JSONArray buildMessages(JSONArray history, String latestMessage) {
        JSONArray messages = new JSONArray();
        if (history != null) {
            int start = Math.max(0, history.length() - 10);
            for (int i = start; i < history.length(); i++) {
                JSONObject item = history.getJSONObject(i);
                String role = item.optString("role", "user");
                if (!"user".equals(role) && !"assistant".equals(role)) {
                    continue;
                }
                messages.put(new JSONObject()
                        .put("role", role)
                        .put("content", item.optString("content", "")));
            }
        }
        messages.put(new JSONObject().put("role", "user").put("content", latestMessage));
        return messages;
    }

    private String buildSystemPrompt(String lang) {
        if ("en".equals(lang)) {
            return "You are the HMS hospital virtual health assistant. "
                    + "Answer clearly in English about symptoms, general medicine info, "
                    + "appointments, hospital services. "
                    + "Always add: this is not a medical diagnosis; see a doctor for serious symptoms. "
                    + "Be concise, use bullet points when helpful.";
        }
        return "Bạn là trợ lý sức khỏe ảo của bệnh viện HMS. "
                + "Trả lời bằng tiếng Việt, rõ ràng về triệu chứng, thuốc (thông tin chung), "
                + "đặt lịch khám, dịch vụ bệnh viện. "
                + "Luôn nhắc: đây không phải chẩn đoán y khoa; triệu chứng nặng cần gặp bác sĩ. "
                + "Trả lời ngắn gọn, có thể dùng gạch đầu dòng.";
    }
}
