<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Đăng ký tài khoản - Hệ thống quản lý bệnh viện</title>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Sora:wght@400;600;700;800&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">

  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --primary:      #2563eb;
      --primary-dark: #1d4ed8;
      --primary-soft: #dbeafe;
      --bg:           #f0f6ff;
      --card:         #ffffff;
      --border:       #e2e8f0;
      --text-primary: #1e293b;
      --text-muted:   #94a3b8;
      --radius:       10px;
      --radius-xl:    20px;
      --shadow-lg:    0 20px 60px rgba(37,99,235,0.13);
      --font-display: 'Sora', sans-serif;
    }

    body {
      font-family: var(--font-display);
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      background: var(--bg);
      padding: 40px 20px;
    }

    /* ── Wrapper ── */
    .login-wrapper {
      display: flex;
      width: 100%;
      max-width: 860px;
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
      padding: 40px 40px;
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
      margin-bottom: 22px;
    }

    .register-form {
      width: 100%;
      max-width: 340px;
    }

    /* Bootstrap overrides để khớp tông màu login */
    .form-label {
      font-size: 13px;
      font-weight: 600;
      color: var(--text-primary);
      margin-bottom: 5px;
    }

    .form-control {
      font-family: var(--font-display);
      font-size: 14px;
      border: 1.5px solid var(--border);
      border-radius: var(--radius) !important;
      padding: 11px 14px;
      background: var(--bg);
      color: var(--text-primary);
      transition: border-color 0.2s, background 0.2s;
    }

    .form-control:focus {
      border-color: var(--primary);
      background: var(--card);
      box-shadow: none;
      outline: none;
    }

    .form-control::placeholder { color: var(--text-muted); }

    small.text-muted {
      font-size: 11px;
      color: var(--text-muted) !important;
    }

    /* Alert */
    .alert {
      width: 100%;
      max-width: 340px;
      padding: 11px 14px;
      border-radius: var(--radius);
      margin-bottom: 14px;
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 13px;
    }

    .alert-danger  { background: #fee2e2; border: none; color: #dc2626; }
    .alert-success { background: #dcfce7; border: none; color: #16a34a; }

    /* Button */
    .btn-register {
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
      margin-top: 6px;
    }

    .btn-register:hover {
      background: var(--primary-dark);
      transform: translateY(-1px);
    }

    .btn-link-custom {
      display: block;
      text-align: center;
      margin-top: 16px;
      font-size: 12px;
      color: var(--text-muted);
      text-decoration: none;
    }

    .btn-link-custom a {
      color: var(--primary);
      font-weight: 600;
      text-decoration: none;
    }

    .btn-link-custom a:hover { text-decoration: underline; }

    @media (max-width: 600px) {
      .login-left  { display: none; }
      .login-right { padding: 32px 24px; }
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
      <h2>ĐĂNG KÝ</h2>
      <p class="welcome">Tạo tài khoản bệnh nhân mới</p>

      <%-- Hiển thị thông báo lỗi --%>
    <% if (request.getAttribute("success") == null && request.getAttribute("error") != null) { %>
      <div class="alert alert-danger">
        <i class="fas fa-exclamation-circle"></i>
        <span><%= request.getAttribute("error") %></span>
      </div>
    <% } %>

      <%-- Hiển thị thông báo thành công --%>
    <% if (request.getAttribute("success") != null) { %>
      <div class="alert alert-success" style="flex-direction: column; align-items: flex-start; gap: 12px;">
        <div style="display:flex; align-items:center; gap:8px;">
          <i class="fas fa-check-circle"></i>
          <span><%= request.getAttribute("success") %></span>
        </div>
        <a href="${pageContext.request.contextPath}/index.jsp"
           style="
             display: inline-block;
             width: 100%;
             padding: 10px;
             background: var(--primary);
             color: #fff;
             border-radius: var(--radius);
             font-family: var(--font-display);
             font-size: 13px;
             font-weight: 700;
             letter-spacing: 0.06em;
             text-align: center;
             text-decoration: none;
             box-shadow: 0 4px 14px rgba(37,99,235,0.3);
             transition: background 0.2s;
           "
           onmouseover="this.style.background='var(--primary-dark)'"
           onmouseout="this.style.background='var(--primary)'">
          ← VỀ TRANG ĐĂNG NHẬP
        </a>
      </div>
    <% } %>
      
      <% if (request.getAttribute("success") == null) { %>
      <div class="register-form">
        <%-- GIỮ NGUYÊN action, method, onsubmit --%>
        <form action="${pageContext.request.contextPath}/register" method="post" onsubmit="return validateRegisterForm()">

          <div class="mb-3">
            <label for="username" class="form-label">Tên đăng nhập *</label>
            <input type="text" class="form-control" id="username" name="username" required>
            <small class="text-muted">3-50 ký tự, chỉ chữ cái, số và dấu gạch dưới</small>
          </div>

          <div class="mb-3">
            <label for="fullname" class="form-label">Họ và tên *</label>
            <input type="text" class="form-control" id="fullname" name="fullname" required>
          </div>

          <div class="mb-3">
            <label for="password" class="form-label">Mật khẩu *</label>
            <input type="password" class="form-control" id="password" name="password" required>
            <small class="text-muted">Tối thiểu 6 ký tự</small>
          </div>

          <div class="mb-3">
            <label for="confirmPassword" class="form-label">Xác nhận mật khẩu *</label>
            <input type="password" class="form-control" id="confirmPassword" name="confirmPassword" required>
          </div>

          <div class="mb-3">
            <label for="email" class="form-label">Email</label>
            <input type="email" class="form-control" id="email" name="email">
          </div>

          <div class="mb-3">
            <label for="phone" class="form-label">Số điện thoại</label>
            <input type="tel" class="form-control" id="phone" name="phone">
          </div>

          <button type="submit" class="btn-register">ĐĂNG KÝ</button>

          <div class="btn-link-custom">
            <a href="${pageContext.request.contextPath}/login">Đã có tài khoản? Đăng nhập</a>
          </div>

        </form>
      </div>
      <% } %>
    </div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>