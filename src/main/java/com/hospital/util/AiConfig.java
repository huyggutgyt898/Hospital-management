package com.hospital.util;

import java.io.InputStream;
import java.util.Properties;

public final class AiConfig {

    private static final Properties PROPS = new Properties();

    static {
        try (InputStream in = AiConfig.class.getClassLoader().getResourceAsStream("ai.properties")) {
            if (in != null) {
                PROPS.load(in);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private AiConfig() {
    }

    public static String getGroqApiKey() {
        String env = System.getenv("GROQ_API_KEY");
        if (env != null && !env.trim().isEmpty()) {
            return env.trim();
        }
        return PROPS.getProperty("groq.api.key", "").trim();
    }

    public static String getGroqModel() {
        return PROPS.getProperty("groq.model", "llama-3.1-8b-instant").trim();
    }

    public static String getProvider() {
        String env = System.getenv("AI_PROVIDER");
        if (env != null && !env.trim().isEmpty()) {
            return env.trim().toLowerCase();
        }
        return PROPS.getProperty("ai.provider", "groq").trim().toLowerCase();
    }

    public static boolean isGroqConfigured() {
        return !getGroqApiKey().isEmpty();
    }
}
