package com.hospital.service;

import com.hospital.util.AiConfig;
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import org.json.JSONArray;
import org.json.JSONObject;

public class GroqChatClient {

    private static final String API_URL = "https://api.groq.com/openai/v1/chat/completions";

    public String chat(String systemPrompt, JSONArray messages) throws Exception {
        String apiKey = AiConfig.getGroqApiKey();
        if (apiKey.isEmpty()) {
            throw new IllegalStateException("Groq API key not configured");
        }

        JSONObject body = new JSONObject();
        body.put("model", AiConfig.getGroqModel());
        body.put("max_tokens", 1024);
        body.put("temperature", 0.6);

        JSONArray payloadMessages = new JSONArray();
        payloadMessages.put(new JSONObject().put("role", "system").put("content", systemPrompt));
        for (int i = 0; i < messages.length(); i++) {
            payloadMessages.put(messages.getJSONObject(i));
        }
        body.put("messages", payloadMessages);

        HttpURLConnection conn = (HttpURLConnection) new URL(API_URL).openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conn.setRequestProperty("Authorization", "Bearer " + apiKey);
        conn.setDoOutput(true);
        conn.setConnectTimeout(20000);
        conn.setReadTimeout(60000);

        byte[] bytes = body.toString().getBytes(StandardCharsets.UTF_8);
        try (OutputStream os = conn.getOutputStream()) {
            os.write(bytes);
        }

        int status = conn.getResponseCode();
        InputStream stream = status >= 200 && status < 300
                ? conn.getInputStream()
                : conn.getErrorStream();

        StringBuilder response = new StringBuilder();
        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(stream, StandardCharsets.UTF_8))) {
            String line;
            while ((line = reader.readLine()) != null) {
                response.append(line);
            }
        }

        if (status < 200 || status >= 300) {
            throw new RuntimeException("Groq API error " + status + ": " + response);
        }

        JSONObject json = new JSONObject(response.toString());
        JSONArray choices = json.getJSONArray("choices");
        if (choices.length() == 0) {
            throw new RuntimeException("Empty Groq response");
        }
        return choices.getJSONObject(0).getJSONObject("message").getString("content");
    }
}
