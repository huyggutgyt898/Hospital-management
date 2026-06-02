<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hospital.model.Account" %>
<%@ include file="/jsp/common/patient_prefs.jsp" %>
<%
    Account account = (Account) session.getAttribute("account");
    if (account == null || !"patient".equalsIgnoreCase(account.getRole())) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="<%= patientIsEn ? "en" : "vi" %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Chatbox - HMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <%@ include file="/jsp/common/patient_head.jsp" %>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container-custom {
            max-width: 1000px;
            margin: 0 auto;
        }

        /* Top bar */
        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            color: white;
        }
        .top-bar a { color: white; text-decoration: none; font-size: 14px; }
        .top-bar a:hover { opacity: 0.8; }

        /* Chat container */
        .chat-container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15);
            overflow: hidden;
            height: calc(100vh - 120px);
            display: flex;
            flex-direction: column;
        }

        /* Chat header */
        .chat-header {
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            color: white;
            padding: 20px 24px;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        .chat-header .ai-avatar {
            width: 50px;
            height: 50px;
            background: rgba(255,255,255,0.2);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
        }
        .chat-header h3 {
            margin: 0;
            font-size: 18px;
            font-weight: 700;
        }
        .chat-header p {
            margin: 0;
            font-size: 12px;
            opacity: 0.8;
        }

        /* Chat messages */
        .chat-messages {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            background: #f8fafc;
        }

        .message {
            display: flex;
            margin-bottom: 20px;
            animation: fadeIn 0.3s ease;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .message.user {
            justify-content: flex-end;
        }
        .message.bot {
            justify-content: flex-start;
        }

        .message-bubble {
            max-width: 70%;
            padding: 12px 16px;
            border-radius: 18px;
            font-size: 14px;
            line-height: 1.5;
        }
        .message.user .message-bubble {
            background: #2563eb;
            color: white;
            border-bottom-right-radius: 4px;
        }
        .message.bot .message-bubble {
            background: white;
            color: #1e293b;
            border-bottom-left-radius: 4px;
            box-shadow: 0 1px 2px rgba(0,0,0,0.1);
        }

        .message-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 10px;
            flex-shrink: 0;
        }
        .message.user .message-avatar {
            margin-left: 10px;
            margin-right: 0;
            background: #2563eb;
            color: white;
        }
        .message.bot .message-avatar {
            background: #10b981;
            color: white;
        }

        /* Search / chat input */
        .chat-input-area {
            padding: 16px 20px;
            background: white;
            border-top: 1px solid #e2e8f0;
        }
        .search-hint {
            font-size: 11px;
            color: #64748b;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 6px;
        }
        .search-row {
            display: flex;
            gap: 12px;
            align-items: center;
        }
        .search-wrap {
            flex: 1;
            position: relative;
        }
        .search-wrap .search-icon {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            pointer-events: none;
        }
        .chat-input-area input[type="search"],
        .chat-input-area input#messageInput {
            width: 100%;
            padding: 14px 16px 14px 44px;
            border: 2px solid #e2e8f0;
            border-radius: 30px;
            font-size: 15px;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .chat-input-area input:focus {
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
        }
        .ai-status {
            font-size: 11px;
            color: #64748b;
            margin-top: 8px;
        }
        .ai-status.online { color: #059669; }
        .chat-input-area button {
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            color: white;
            border: none;
            padding: 0 24px;
            border-radius: 30px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
        }
        .chat-input-area button:hover {
            transform: translateY(-1px);
        }
        .chat-input-area button:disabled {
            opacity: 0.6;
            cursor: not-allowed;
        }

        /* Suggestion chips */
        .suggestion-section {
            padding: 12px 20px;
            background: #f1f5f9;
            border-top: 1px solid #e2e8f0;
        }
        .suggestion-title {
            font-size: 12px;
            color: #64748b;
            margin-bottom: 8px;
        }
        .suggestion-chips {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }
        .chip {
            background: white;
            border: 1px solid #e2e8f0;
            border-radius: 20px;
            padding: 6px 14px;
            font-size: 12px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .chip:hover {
            background: #2563eb;
            color: white;
            border-color: #2563eb;
        }

        /* Typing indicator */
        .typing-indicator {
            display: flex;
            align-items: center;
            gap: 4px;
            padding: 10px 16px;
        }
        .typing-indicator span {
            width: 8px;
            height: 8px;
            background: #94a3b8;
            border-radius: 50%;
            animation: typing 1.4s infinite ease-in-out;
        }
        .typing-indicator span:nth-child(1) { animation-delay: 0s; }
        .typing-indicator span:nth-child(2) { animation-delay: 0.2s; }
        .typing-indicator span:nth-child(3) { animation-delay: 0.4s; }
        @keyframes typing {
            0%, 60%, 100% { transform: translateY(0); opacity: 0.4; }
            30% { transform: translateY(-10px); opacity: 1; }
        }
    </style>
</head>

<body class="<%= patientIsDark ? "patient-dark" : "" %>">
<div class="container-custom">
    <!-- Top bar -->
    <div class="top-bar">
        <a href="${pageContext.request.contextPath}/index.jsp">
            <i class="fas fa-arrow-left me-2"></i><%= pt(patientIsEn, "Quay lại trang chủ", "Back to home") %>
        </a>
        <div style="display:flex; align-items:center; gap:16px;">
            <span><i class="fas fa-user-circle me-1"></i><%= account.getFullname() %></span>
            <a href="${pageContext.request.contextPath}/logout">
                <i class="fas fa-sign-out-alt me-1"></i><%= pt(patientIsEn, "Đăng xuất", "Logout") %>
            </a>
        </div>
    </div>

    <!-- Chat container -->
    <div class="chat-container">
        <div class="chat-header">
            <div class="ai-avatar">
                <i class="fas fa-robot"></i>
            </div>
            <div>
                <h3><i class="fas fa-brain me-1"></i> <%= pt(patientIsEn, "AI Trợ lý y tế", "AI Health Assistant") %></h3>
                <p><%= pt(patientIsEn, "Hỗ trợ tư vấn sức khỏe thông minh 24/7", "Smart health support 24/7") %></p>
            </div>
        </div>

        <!-- Chat messages -->
        <div class="chat-messages" id="chatMessages">
            <div class="message bot">
                <div class="message-avatar">
                    <i class="fas fa-robot"></i>
                </div>
                <div class="message-bubble">
                    <% if (patientIsEn) { %>
                    Hello! I am the HMS medical AI assistant.<br>
                    I can help you with:<br>
                    • Symptom advice<br>
                    • Medicine questions<br>
                    • Health care tips<br>
                    • Hospital information<br><br>
                    Type your question below!
                    <% } else { %>
                    Xin chào! Tôi là AI trợ lý y tế của bệnh viện HMS. <br>
                    Tôi có thể giúp bạn:<br>
                    • Tư vấn về triệu chứng bệnh<br>
                    • Giải đáp thắc mắc về thuốc<br>
                    • Hướng dẫn chăm sóc sức khỏe<br>
                    • Trả lời câu hỏi về bệnh viện<br><br>
                    Hãy nhập câu hỏi của bạn bên dưới nhé!
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Suggestion chips -->
        <div class="suggestion-section">
            <div class="suggestion-title"><%= pt(patientIsEn, "Câu hỏi gợi ý:", "Suggested questions:") %></div>
            <div class="suggestion-chips">
                <div class="chip" onclick="sendSuggestion('Tôi bị đau đầu, sốt nhẹ nên làm gì?')">🤒 Đau đầu, sốt nhẹ</div>
                <div class="chip" onclick="sendSuggestion('Cách đặt lịch khám bệnh?')">📅 Đặt lịch khám</div>
                <div class="chip" onclick="sendSuggestion('Thuốc Paracetamol uống thế nào?')">💊 Thuốc Paracetamol</div>
                <div class="chip" onclick="sendSuggestion('Dấu hiệu sốt xuất huyết?')">🦟 Sốt xuất huyết</div>
                <div class="chip" onclick="sendSuggestion('Giờ làm việc của bệnh viện?')">⏰ Giờ làm việc</div>
            </div>
        </div>

        <!-- Search / ask bar -->
        <div class="chat-input-area">
            <div class="search-hint">
                <i class="fas fa-search"></i>
                <%= pt(patientIsEn, "Nhập câu hỏi và nhấn Enter hoặc Gửi — AI trả lời ngay tại đây", "Type a question and press Enter or Send — AI replies here") %>
            </div>
            <div class="search-row">
                <div class="search-wrap">
                    <i class="fas fa-search search-icon"></i>
                    <input type="search" id="messageInput" autocomplete="off"
                           placeholder="<%= pt(patientIsEn, "Tìm kiếm / hỏi về sức khỏe, thuốc, đặt lịch...", "Search / ask about health, medicine, booking...") %>"
                           enterkeyhint="search">
                </div>
                <button type="button" id="sendBtn" onclick="sendMessage()">
                    <i class="fas fa-paper-plane"></i> <%= pt(patientIsEn, "Gửi", "Send") %>
                </button>
            </div>
            <div class="ai-status" id="aiStatus">
                <i class="fas fa-circle-notch fa-spin"></i> <%= pt(patientIsEn, "Đang kết nối AI...", "Connecting to AI...") %>
            </div>
        </div>
    </div>
</div>

<script>
    const contextPath = '<%= request.getContextPath() %>';
    const patientLang = '<%= patientLang %>';
    let isTyping = false;
    let conversationHistory = [];

    function t(vi, en) {
        return patientLang === 'en' ? en : vi;
    }

    function addMessage(text, isUser) {
        const messagesDiv = document.getElementById('chatMessages');
        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${isUser ? 'user' : 'bot'}`;

        if (isUser) {
            messageDiv.innerHTML =
                '<div class="message-bubble">' + escapeHtml(text) + '</div>' +
                '<div class="message-avatar"><i class="fas fa-user"></i></div>';
        } else {
            messageDiv.innerHTML =
                '<div class="message-avatar"><i class="fas fa-robot"></i></div>' +
                '<div class="message-bubble">' + formatText(text) + '</div>';
        }

        messagesDiv.appendChild(messageDiv);
        messagesDiv.scrollTop = messagesDiv.scrollHeight;
    }

    function showTypingIndicator() {
        if (isTyping) return;
        isTyping = true;
        const messagesDiv = document.getElementById('chatMessages');
        const typingDiv = document.createElement('div');
        typingDiv.id = 'typingIndicator';
        typingDiv.className = 'message bot';
        typingDiv.innerHTML =
            '<div class="message-avatar"><i class="fas fa-robot"></i></div>' +
            '<div class="typing-indicator"><span></span><span></span><span></span></div>';
        messagesDiv.appendChild(typingDiv);
        messagesDiv.scrollTop = messagesDiv.scrollHeight;
    }

    function hideTypingIndicator() {
        const typingDiv = document.getElementById('typingIndicator');
        if (typingDiv) typingDiv.remove();
        isTyping = false;
    }

    async function callHealthAI(userMessage) {
        const response = await fetch(contextPath + '/ai/chat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json;charset=UTF-8' },
            body: JSON.stringify({
                message: userMessage,
                lang: patientLang,
                history: conversationHistory
            })
        });

        if (!response.ok) {
            throw new Error('HTTP ' + response.status);
        }

        const data = await response.json();
        if (!data.success) {
            const msg = patientLang === 'en' && data.messageEn ? data.messageEn : data.message;
            throw new Error(msg || 'AI error');
        }

        updateAiStatus(data);
        conversationHistory.push({ role: 'user', content: userMessage });
        conversationHistory.push({ role: 'assistant', content: data.reply });
        if (conversationHistory.length > 20) {
            conversationHistory = conversationHistory.slice(-20);
        }
        return data.reply;
    }

    function updateAiStatus(data) {
        const el = document.getElementById('aiStatus');
        if (!el) return;
        el.classList.add('online');
        if (data.source === 'groq') {
            el.innerHTML = '<i class="fas fa-bolt"></i> ' + t('AI Groq (miễn phí) — đang hoạt động', 'Groq AI (free tier) — active');
        } else {
            el.innerHTML = '<i class="fas fa-robot"></i> ' + t('Trợ lý nội bộ — thêm API Groq miễn phí trong ai.properties để dùng AI mạnh hơn',
                'Built-in assistant — add free Groq API key in ai.properties for smarter replies');
        }
    }

    async function loadAiStatus() {
        try {
            const res = await fetch(contextPath + '/ai/chat');
            const data = await res.json();
            const el = document.getElementById('aiStatus');
            if (!el) return;
            el.classList.add('online');
            if (data.groqConfigured) {
                el.innerHTML = '<i class="fas fa-bolt"></i> ' + t('Sẵn sàng — AI Groq miễn phí', 'Ready — Groq free AI');
            } else {
                el.innerHTML = '<i class="fas fa-info-circle"></i> ' + t('Chế độ trợ lý nội bộ (không cần API). Cấu hình Groq trong ai.properties để bật AI đầy đủ.',
                    'Built-in mode (no API). Configure Groq in ai.properties for full AI.');
            }
        } catch (e) {
            console.warn('AI status check failed', e);
        }
    }

    async function sendMessage() {
        const input = document.getElementById('messageInput');
        const sendBtn = document.getElementById('sendBtn');
        const message = input.value.trim();
        if (!message || isTyping) return;

        addMessage(message, true);
        input.value = '';
        sendBtn.disabled = true;
        showTypingIndicator();

        try {
            const reply = await callHealthAI(message);
            hideTypingIndicator();
            addMessage(reply, false);
        } catch (e) {
            hideTypingIndicator();
            addMessage('⚠️ ' + t(
                'Không gửi được câu hỏi. Vui lòng thử lại hoặc gọi hotline 1900 xxxx.',
                'Could not send your question. Please try again or call hotline 1900 xxxx.'
            ) + '\n\n(' + e.message + ')', false);
            console.error('AI Error:', e);
        } finally {
            sendBtn.disabled = false;
            input.focus();
        }
    }

    function sendSuggestion(text) {
        document.getElementById('messageInput').value = text;
        sendMessage();
    }

    // Format text — chuyển **bold** và xuống dòng
    function formatText(text) {
        return text
            .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
            .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
            .replace(/\n/g, '<br>');
    }

    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML.replace(/\n/g, '<br>');
    }

    const messageInput = document.getElementById('messageInput');
    messageInput.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            sendMessage();
        }
    });

    document.addEventListener('DOMContentLoaded', function () {
        loadAiStatus();
        messageInput.focus();
    });
</script>
<script src="${pageContext.request.contextPath}/js/patient-preferences.js"></script>
</body>
</html>