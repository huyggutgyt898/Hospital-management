<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hospital System – Đăng Nhập</title>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --primary:        #2563eb;
      --primary-dark:   #1d4ed8;
      --primary-soft:   #dbeafe;
      --bg:             #f0f6ff;
      --card:           #ffffff;
      --border:         #e2e8f0;
      --text-primary:   #1e293b;
      --text-muted:     #94a3b8;
      --radius:         10px;
      --radius-xl:      20px;
      --shadow-lg:      0 20px 60px rgba(37,99,235,0.13);
      --font-display:   'Sora', sans-serif;
    }

    body {
      font-family: var(--font-display);
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      background: var(--bg);
    }

    /* ── Wrapper ── */
    .login-wrapper {
      display: flex;
      width: 100%;
      max-width: 860px;
      min-height: 500px;
      border-radius: var(--radius-xl);
      overflow: hidden;
      box-shadow: var(--shadow-lg);
    }

    /* ── Left panel ── */
    .login-left {
      flex: 1;
      background: linear-gradient(145deg, #bfdbfe 0%, #93c5fd 50%, #60a5fa 100%);
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 48px 32px;
      text-align: center;
    }

    .brand-icon {
      width: 88px;
      height: 88px;
      background: rgba(255,255,255,0.35);
      border-radius: var(--radius-xl);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 42px;
      margin-bottom: 20px;
      box-shadow: 0 8px 24px rgba(37,99,235,0.2);
    }

    .login-left h1 {
      font-size: 24px;
      font-weight: 800;
      color: #1d4ed8;
      margin-bottom: 6px;
    }

    .login-left p {
      font-size: 11px;
      font-weight: 700;
      letter-spacing: 0.12em;
      color: #3b82f6;
      text-transform: uppercase;
    }

    /* ── Right panel ── */
    .login-right {
      flex: 1;
      background: var(--card);
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 48px 40px;
    }

    .login-logo-small {
      width: 52px;
      height: 52px;
      background: var(--primary-soft);
      border-radius: var(--radius);
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 24px;
      margin-bottom: 14px;
    }

    .login-right h2 {
      font-size: 19px;
      font-weight: 700;
      margin-bottom: 4px;
      color: var(--text-primary);
    }

    .welcome {
      font-size: 13px;
      color: var(--text-muted);
      margin-bottom: 26px;
    }

    /* ── Form ── */
    .login-form {
      width: 100%;
      max-width: 320px;
    }

    .error-message {
      width: 100%;
      margin-bottom: 14px;
      padding: 11px 14px;
      border-radius: var(--radius);
      background: #fee2e2;
      color: #dc2626;
      font-size: 13px;
      text-align: center;
    }

    .input-wrap {
      position: relative;
      margin-bottom: 13px;
    }

    .input-wrap .icon {
      position: absolute;
      left: 12px;
      top: 50%;
      transform: translateY(-50%);
      color: var(--text-muted);
      pointer-events: none;
    }

    .input-wrap input {
      width: 100%;
      padding: 11px 42px 11px 40px;
      border: 1.5px solid var(--border);
      border-radius: var(--radius);
      background: var(--bg);
      color: var(--text-primary);
      font-family: var(--font-display);
      font-size: 14px;
      transition: border-color 0.2s, background 0.2s;
    }

    .input-wrap input:focus {
      border-color: var(--primary);
      outline: none;
      background: var(--card);
    }

    .input-wrap input::placeholder { color: var(--text-muted); }

    .toggle-pw {
      position: absolute;
      right: 12px;
      top: 50%;
      transform: translateY(-50%);
      cursor: pointer;
      color: var(--text-muted);
      font-size: 16px;
      user-select: none;
      line-height: 1;
    }

    .forgot-link {
      text-align: right;
      margin-bottom: 18px;
    }

    .forgot-link a {
      font-size: 12px;
      color: var(--primary);
      text-decoration: none;
    }

    .forgot-link a:hover { text-decoration: underline; }

    .btn-login {
      width: 100%;
      padding: 12px;
      background: var(--primary);
      color: #fff;
      border: none;
      border-radius: var(--radius);
      font-family: var(--font-display);
      font-size: 14px;
      font-weight: 700;
      letter-spacing: 0.06em;
      cursor: pointer;
      box-shadow: 0 4px 14px rgba(37,99,235,0.3);
      transition: background 0.2s, transform 0.15s;
    }

    .btn-login:hover {
      background: var(--primary-dark);
      transform: translateY(-1px);
    }

    .support-text {
      font-size: 12px;
      color: var(--text-muted);
      margin-top: 20px;
      text-align: center;
    }

    /* ── Responsive ── */
    @media (max-width: 600px) {
      .login-left { display: none; }
      .login-right { padding: 32px 24px; }
    }
    
    .register-text {
      font-size: 12px;
      color: var(--text-muted);
      margin-top: 14px;
      text-align: center;
    }

    .register-text a {
      color: var(--primary);
      font-weight: 600;
      text-decoration: none;
    }

    .register-text a:hover {
      text-decoration: underline;
    }
  </style>
</head>

<body>

  <div class="login-wrapper">

    <!-- Left branding -->
    <div class="login-left">
      <div class="brand-icon">🏥</div>
      <h1>HOSPITAL SYSTEM</h1>
      <p>Quản lý bệnh viện hiện đại</p>
    </div>

    <!-- Right form -->
    <div class="login-right">

      <div class="login-logo-small">🏥</div>
      <h2>ĐĂNG NHẬP</h2>
      <p class="welcome">Chào mừng quay trở lại!</p>
      
      <%-- Hiển thị thông báo đăng ký thành công --%>
    <%
      String successMsg = (String) session.getAttribute("successMsg");
      if (successMsg != null) {
        session.removeAttribute("successMsg");
    %>
      <div style="
        width: 100%;
        margin-bottom: 14px;
        padding: 11px 14px;
        border-radius: var(--radius);
        background: #dcfce7;
        color: #16a34a;
        font-size: 13px;
        text-align: center;
        display: flex;
        align-items: center;
        gap: 8px;
      ">
        <i class="fas fa-check-circle"></i>
        <span><%= successMsg %></span>
      </div>
    <% } %>
      
      <div class="login-form">

        <%-- Hiển thị lỗi từ server nếu có --%>
        <% String error = (String) request.getAttribute("error");
           if (error != null && !error.isEmpty()) { %>
          <div class="error-message"><%= error %></div>
        <% } %>

        <form id="loginForm"
              action="${pageContext.request.contextPath}/login"
              method="post">

          <%-- Username --%>
          <div class="input-wrap">
            <span class="icon">
              <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
              </svg>
            </span>
            <input type="text"
                   id="username"
                   name="username"
                   placeholder="Tên đăng nhập"
                   value=""
                   autocomplete="username"
                   required>
          </div>

          <%-- Password --%>
          <div class="input-wrap">
            <span class="icon">
              <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round"
                      d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
              </svg>
            </span>
            <input type="password"
                   id="password"
                   name="password"
                   placeholder="Mật khẩu"
                   autocomplete="current-password"
                   required>
            <span class="toggle-pw" onclick="togglePw()" title="Hiện/ẩn mật khẩu">👁</span>
          </div>

          <div class="forgot-link">
            <a href="#">Quên mật khẩu?</a>
          </div>

          <button type="submit" class="btn-login">ĐĂNG NHẬP</button>

        </form>
          
        <p class="register-text">
            Chưa có tài khoản? 
            <a href="${pageContext.request.contextPath}/register">Tạo tài khoản</a>
        </p>

        <p class="support-text">Hỗ trợ kỹ thuật: support@hms.com</p>

      </div>
    </div>
  </div>

  <script>
    function togglePw() {
      var pw = document.getElementById('password');
      pw.type = pw.type === 'password' ? 'text' : 'password';
    }

    document.getElementById('loginForm').addEventListener('submit', function (e) {
      var u = document.getElementById('username').value.trim();
      var p = document.getElementById('password').value.trim();
      if (!u || !p) {
        e.preventDefault();
        alert('Vui lòng nhập tên đăng nhập và mật khẩu');
      }
    });
  </script>

</body>
</html>
