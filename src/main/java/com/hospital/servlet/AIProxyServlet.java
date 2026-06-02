package com.hospital.servlet;

import com.hospital.model.Account;
import com.hospital.service.HealthChatService;
import com.hospital.util.AiConfig;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet("/ai/chat")
public class AIProxyServlet extends HttpServlet {

    private final HealthChatService chatService = new HealthChatService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();

        try {
            HttpSession session = req.getSession(false);
            if (session == null || session.getAttribute("account") == null) {
                out.print(errorJson("Vui lòng đăng nhập lại.", "Please log in again."));
                return;
            }

            Account account = (Account) session.getAttribute("account");
            if (!"patient".equalsIgnoreCase(account.getRole())) {
                out.print(errorJson("Chỉ tài khoản bệnh nhân được dùng AI chat.", "Patients only."));
                return;
            }

            String body = readBody(req);
            JSONObject input = new JSONObject(body.isEmpty() ? "{}" : body);

            String message = input.optString("message", "").trim();
            if (message.isEmpty()) {
                message = input.optString("content", "").trim();
            }
            if (message.isEmpty()) {
                out.print(errorJson("Câu hỏi không được để trống.", "Message cannot be empty."));
                return;
            }

            String lang = input.optString("lang", "vi");
            if (lang.isEmpty()) {
                Object sessionLang = session.getAttribute("patientLang");
                if (sessionLang instanceof String) {
                    lang = (String) sessionLang;
                }
            }

            JSONArray history = input.optJSONArray("history");
            if (history == null) {
                history = input.optJSONArray("messages");
            }

            JSONObject chatResult = chatService.chat(message, history, lang);
            chatResult.put("groqConfigured", AiConfig.isGroqConfigured());
            out.print(chatResult.toString());

        } catch (Exception e) {
            e.printStackTrace();
            JSONObject err = new JSONObject();
            err.put("success", false);
            err.put("message", "Lỗi hệ thống: " + e.getMessage());
            out.print(err.toString());
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        JSONObject info = new JSONObject();
        info.put("groqConfigured", AiConfig.isGroqConfigured());
        info.put("provider", AiConfig.getProvider());
        info.put("model", AiConfig.getGroqModel());
        resp.getWriter().print(info.toString());
    }

    private String readBody(HttpServletRequest req) throws IOException {
        StringBuilder sb = new StringBuilder();
        try (BufferedReader reader = req.getReader()) {
            String line;
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }

    private String errorJson(String vi, String en) {
        return new JSONObject()
                .put("success", false)
                .put("message", vi)
                .put("messageEn", en)
                .toString();
    }
}
