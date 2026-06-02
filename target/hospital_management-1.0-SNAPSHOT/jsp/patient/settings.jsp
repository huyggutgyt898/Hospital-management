<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hospital.model.Account" %>
<%@ include file="/jsp/common/patient_prefs.jsp" %>
<%
    Account account = (Account) session.getAttribute("account");
    if (account == null || !"patient".equalsIgnoreCase(account.getRole())) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }

    String language = patientLang;
    boolean isDark = patientIsDark;
    boolean isEn = patientIsEn;
%>
<!DOCTYPE html>
<html lang="<%= isEn ? "en" : "vi" %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= isEn ? "System Settings - HMS" : "Cài đặt hệ thống - HMS" %></title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <%@ include file="/jsp/common/patient_head.jsp" %>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            transition: background-color 0.35s ease, color 0.35s ease, border-color 0.35s ease, box-shadow 0.35s ease;
        }

        /* ====== CSS VARIABLES ====== */
        :root {
            --bg-page:      #eef2f7;
            --bg-card:      #ffffff;
            --bg-input:     #f8fafc;
            --text-primary: #0f172a;
            --text-secondary:#334155;
            --text-muted:   #64748b;
            --border:       #e2e8f0;
            --primary:      #2563eb;
            --primary-dark: #1d4ed8;
            --primary-glow: rgba(37,99,235,0.18);
            --success:      #10b981;
            --success-bg:   #dcfce7;
            --success-text: #166534;
            --danger:       #ef4444;
            --danger-bg:    #fee2e2;
            --danger-text:  #991b1b;
            --info-bg:      #dbeafe;
            --info-text:    #1e40af;
            --shadow-sm:    0 1px 3px rgba(0,0,0,0.07);
            --shadow-md:    0 4px 16px rgba(0,0,0,0.10);
            --shadow-lg:    0 10px 32px rgba(0,0,0,0.12);
            --radius:       14px;
            --radius-sm:    8px;
        }

        /* ====== DARK MODE ====== */
        body.patient-dark.settings-page {
            --bg-page:      #0b1120;
            --bg-card:      #161f2e;
            --bg-input:     #1e2d42;
            --text-primary: #f0f6ff;
            --text-secondary:#b8cce4;
            --text-muted:   #7a9abc;
            --border:       #243348;
            --primary:      #3b82f6;
            --primary-dark: #2563eb;
            --primary-glow: rgba(59,130,246,0.25);
            --success:      #34d399;
            --success-bg:   #064e3b;
            --success-text: #6ee7b7;
            --danger:       #f87171;
            --danger-bg:    #450a0a;
            --danger-text:  #fca5a5;
            --info-bg:      #1e3a5f;
            --info-text:    #93c5fd;
            --shadow-sm:    0 1px 3px rgba(0,0,0,0.4);
            --shadow-md:    0 4px 16px rgba(0,0,0,0.5);
            --shadow-lg:    0 10px 32px rgba(0,0,0,0.6);
        }

        body {
            font-family: 'Inter', system-ui, sans-serif;
            background: var(--bg-page);
            color: var(--text-primary);
            min-height: 100vh;
            padding: 28px 16px 48px;
        }

        /* ====== HEADER NAV ====== */
        .top-nav {
            max-width: 780px;
            margin: 0 auto 32px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            color: var(--text-secondary);
            text-decoration: none;
            font-weight: 500;
            font-size: 14px;
            padding: 8px 14px;
            border-radius: var(--radius-sm);
            border: 1px solid var(--border);
            background: var(--bg-card);
            box-shadow: var(--shadow-sm);
        }

        .back-link:hover {
            color: var(--primary);
            border-color: var(--primary);
            background: var(--bg-page);
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .user-avatar {
            width: 38px;
            height: 38px;
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-weight: 700;
            font-size: 15px;
            flex-shrink: 0;
        }

        .user-name {
            font-weight: 600;
            font-size: 14px;
            color: var(--text-primary);
        }

        .logout-btn {
            color: var(--danger);
            text-decoration: none;
            font-size: 13px;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 6px 12px;
            border-radius: var(--radius-sm);
            border: 1px solid var(--danger-bg);
            background: var(--danger-bg);
            transition: all 0.2s;
        }

        .logout-btn:hover {
            background: var(--danger);
            color: #fff;
            border-color: var(--danger);
        }

        /* ====== PAGE TITLE ====== */
        .page-title-wrap {
            max-width: 780px;
            margin: 0 auto 32px;
            text-align: center;
        }

        .page-icon {
            width: 68px;
            height: 68px;
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            border-radius: 20px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 28px;
            color: #fff;
            margin-bottom: 14px;
            box-shadow: 0 8px 20px var(--primary-glow);
        }

        .page-title-wrap h1 {
            font-size: 26px;
            font-weight: 800;
            color: var(--text-primary);
            margin-bottom: 6px;
        }

        .page-title-wrap p {
            color: var(--text-muted);
            font-size: 14px;
        }

        /* ====== ALERT ====== */
        #alertMessage {
            max-width: 780px;
            margin: 0 auto 20px;
            padding: 14px 18px;
            border-radius: var(--radius-sm);
            font-size: 14px;
            font-weight: 500;
            display: none;
            align-items: center;
            gap: 10px;
            border-left: 4px solid transparent;
        }

        #alertMessage.success {
            background: var(--success-bg);
            color: var(--success-text);
            border-left-color: var(--success);
            display: flex;
        }

        #alertMessage.danger {
            background: var(--danger-bg);
            color: var(--danger-text);
            border-left-color: var(--danger);
            display: flex;
        }

        #alertMessage.info {
            background: var(--info-bg);
            color: var(--info-text);
            border-left-color: var(--primary);
            display: flex;
        }

        /* ====== CARD ====== */
        .card {
            max-width: 780px;
            margin: 0 auto 24px;
            background: var(--bg-card);
            border-radius: var(--radius);
            border: 1px solid var(--border);
            box-shadow: var(--shadow-md);
            overflow: hidden;
        }

        .card-header {
            padding: 18px 28px;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 16px;
            font-weight: 700;
            color: var(--text-primary);
            background: var(--bg-card);
        }

        .card-header .header-icon {
            width: 36px;
            height: 36px;
            border-radius: 10px;
            background: var(--primary-glow);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary);
            font-size: 16px;
            flex-shrink: 0;
        }

        .card-body {
            padding: 24px 28px;
        }

        /* ====== SETTING ROW ====== */
        .setting-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
        }

        .setting-label h4 {
            font-size: 15px;
            font-weight: 600;
            color: var(--text-primary);
            margin-bottom: 4px;
        }

        .setting-label p {
            font-size: 13px;
            color: var(--text-muted);
        }

        /* ====== TOGGLE SWITCH ====== */
        .toggle-wrap {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-shrink: 0;
        }

        .toggle-icon {
            font-size: 16px;
            color: var(--text-muted);
        }

        .switch {
            position: relative;
            display: inline-block;
            width: 56px;
            height: 30px;
            flex-shrink: 0;
        }

        .switch input { opacity: 0; width: 0; height: 0; }

        .slider {
            position: absolute;
            cursor: pointer;
            inset: 0;
            background: var(--border);
            border-radius: 30px;
            transition: 0.3s;
        }

        .slider:before {
            content: "";
            position: absolute;
            height: 22px;
            width: 22px;
            left: 4px;
            bottom: 4px;
            background: #fff;
            border-radius: 50%;
            transition: 0.3s;
            box-shadow: 0 1px 4px rgba(0,0,0,0.2);
        }

        input:checked + .slider { background: var(--primary); }
        input:checked + .slider:before { transform: translateX(26px); }

        /* ====== LANGUAGE BUTTONS ====== */
        .lang-buttons {
            display: flex;
            gap: 10px;
            flex-shrink: 0;
        }

        .lang-btn {
            padding: 8px 22px;
            border: 2px solid var(--border);
            border-radius: 30px;
            background: var(--bg-page);
            color: var(--text-secondary);
            cursor: pointer;
            font-weight: 600;
            font-size: 13px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s;
        }

        .lang-btn.active {
            background: var(--primary);
            border-color: var(--primary);
            color: #fff;
            box-shadow: 0 2px 8px var(--primary-glow);
        }

        .lang-btn:hover:not(.active) {
            border-color: var(--primary);
            color: var(--primary);
            background: var(--bg-card);
        }

        /* ====== FORM ====== */
        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            font-size: 13px;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.05em;
        }

        .input-wrap {
            position: relative;
        }

        .input-wrap i {
            position: absolute;
            left: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
            font-size: 14px;
            pointer-events: none;
        }

        .form-control {
            width: 100%;
            padding: 12px 44px;
            border: 1.5px solid var(--border);
            border-radius: var(--radius-sm);
            background: var(--bg-input);
            color: var(--text-primary);
            font-size: 14px;
            font-family: inherit;
            transition: all 0.2s;
        }

        .form-control:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px var(--primary-glow);
            background: var(--bg-card);
        }

        .password-toggle {
            position: absolute;
            right: 14px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
            cursor: pointer;
            font-size: 14px;
            z-index: 2;
            background: none;
            border: none;
            padding: 4px;
        }

        .password-toggle:hover { color: var(--primary); }

        .hint-text {
            font-size: 12px;
            color: var(--text-muted);
            margin-top: 6px;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        /* Password strength */
        .strength-bar {
            height: 4px;
            border-radius: 4px;
            margin-top: 8px;
            background: var(--border);
            overflow: hidden;
        }

        .strength-fill {
            height: 100%;
            border-radius: 4px;
            transition: width 0.3s, background 0.3s;
            width: 0%;
        }

        .strength-text {
            font-size: 11px;
            margin-top: 4px;
            font-weight: 600;
        }

        /* ====== SUBMIT BUTTON ====== */
        .btn-submit {
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: #fff;
            border: none;
            padding: 13px 28px;
            border-radius: 10px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
            box-shadow: 0 4px 12px var(--primary-glow);
        }

        .btn-submit:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px var(--primary-glow);
        }

        .btn-submit:active { transform: translateY(0); }

        .btn-submit:disabled {
            opacity: 0.6;
            cursor: not-allowed;
            transform: none;
        }

        /* ====== FOOTER NOTE ====== */
        .footer-note {
            max-width: 780px;
            margin: 10px auto 0;
            text-align: center;
            font-size: 12px;
            color: var(--text-muted);
            padding: 12px;
        }

        /* ====== RESPONSIVE ====== */
        @media (max-width: 600px) {
            body { padding: 16px 10px 40px; }

            .top-nav { flex-direction: column; gap: 12px; align-items: flex-start; }

            .setting-row { flex-direction: column; align-items: flex-start; gap: 14px; }

            .lang-buttons { width: 100%; }
            .lang-btn { flex: 1; justify-content: center; }

            .card-header, .card-body { padding: 16px 18px; }
        }
    </style>
</head>
<body class="settings-page <%= isDark ? "patient-dark" : "" %>">

<!-- ====== TOP NAV ====== -->
<div class="top-nav">
    <a href="${pageContext.request.contextPath}/index.jsp" class="back-link">
        <i class="fas fa-arrow-left"></i>
        <span id="txt-back"><%= isEn ? "Back to Home" : "Quay lại trang chủ" %></span>
    </a>
    <div class="user-info">
        <div class="user-avatar"><%= account.getFullname().trim().substring(0,1).toUpperCase() %></div>
        <span class="user-name"><%= account.getFullname() %></span>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn" id="txt-logout">
            <i class="fas fa-sign-out-alt"></i>
            <span><%= isEn ? "Logout" : "Đăng xuất" %></span>
        </a>
    </div>
</div>

<!-- ====== PAGE TITLE ====== -->
<div class="page-title-wrap">
    <div class="page-icon"><i class="fas fa-sliders-h"></i></div>
    <h1 id="txt-page-title"><%= isEn ? "System Settings" : "Cài đặt hệ thống" %></h1>
    <p id="txt-page-sub"><%= isEn ? "Customize your interface & account preferences" : "Tùy chỉnh giao diện và thông tin tài khoản" %></p>
</div>

<!-- ====== ALERT ====== -->
<div id="alertMessage" role="alert"></div>

<!-- ====== CARD: APPEARANCE ====== -->
<div class="card">
    <div class="card-header">
        <div class="header-icon"><i class="fas fa-palette"></i></div>
        <span id="txt-appearance"><%= isEn ? "Appearance" : "Giao diện" %></span>
    </div>
    <div class="card-body">
        <div class="setting-row">
            <div class="setting-label">
                <h4 id="txt-theme-title"><%= isEn ? "Dark / Light Mode" : "Chế độ tối / Sáng" %></h4>
                <p id="txt-theme-desc"><%= isEn ? "Switch between light and dark interface" : "Chuyển đổi giữa giao diện sáng và tối" %></p>
            </div>
            <div class="toggle-wrap">
                <i class="fas fa-sun toggle-icon" id="iconSun"></i>
                <label class="switch">
                    <input type="checkbox" id="themeToggle" <%= isDark ? "checked" : "" %>>
                    <span class="slider"></span>
                </label>
                <i class="fas fa-moon toggle-icon" id="iconMoon"></i>
            </div>
        </div>
    </div>
</div>

<!-- ====== CARD: LANGUAGE ====== -->
<div class="card">
    <div class="card-header">
        <div class="header-icon"><i class="fas fa-language"></i></div>
        <span id="txt-lang-header"><%= isEn ? "Language" : "Ngôn ngữ" %></span>
    </div>
    <div class="card-body">
        <div class="setting-row">
            <div class="setting-label">
                <h4 id="txt-lang-title"><%= isEn ? "Display Language" : "Ngôn ngữ hiển thị" %></h4>
                <p id="txt-lang-desc"><%= isEn ? "Changes will apply across all patient pages" : "Thay đổi sẽ áp dụng cho tất cả trang bệnh nhân" %></p>
            </div>
            <div class="lang-buttons">
                <button class="lang-btn <%= !isEn ? "active" : "" %>" id="btnVi" onclick="setLanguage('vi')">
                    🇻🇳 Tiếng Việt
                </button>
                <button class="lang-btn <%= isEn ? "active" : "" %>" id="btnEn" onclick="setLanguage('en')">
                    🇬🇧 English
                </button>
            </div>
        </div>
    </div>
</div>

<!-- ====== CARD: CHANGE PASSWORD ====== -->
<div class="card">
    <div class="card-header">
        <div class="header-icon"><i class="fas fa-key"></i></div>
        <span id="txt-pwd-header"><%= isEn ? "Change Password" : "Đổi mật khẩu" %></span>
    </div>
    <div class="card-body">
        <form id="changePasswordForm" novalidate>
            <!-- Current Password -->
            <div class="form-group">
                <label id="lbl-cur"><%= isEn ? "Current Password" : "Mật khẩu hiện tại" %></label>
                <div class="input-wrap">
                    <i class="fas fa-lock"></i>
                    <input type="password" id="currentPassword" class="form-control"
                           placeholder="<%= isEn ? "Enter current password" : "Nhập mật khẩu hiện tại" %>" required>
                    <button type="button" class="password-toggle" onclick="togglePwd('currentPassword', this)">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
            </div>

            <!-- New Password -->
            <div class="form-group">
                <label id="lbl-new"><%= isEn ? "New Password" : "Mật khẩu mới" %></label>
                <div class="input-wrap">
                    <i class="fas fa-lock-open"></i>
                    <input type="password" id="newPassword" class="form-control"
                           placeholder="<%= isEn ? "Enter new password" : "Nhập mật khẩu mới" %>" required
                           oninput="checkStrength(this.value)">
                    <button type="button" class="password-toggle" onclick="togglePwd('newPassword', this)">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
                <div class="strength-bar"><div class="strength-fill" id="strengthFill"></div></div>
                <div class="strength-text" id="strengthText"></div>
                <div class="hint-text">
                    <i class="fas fa-info-circle"></i>
                    <span id="lbl-hint"><%= isEn ? "Minimum 6 characters" : "Tối thiểu 6 ký tự" %></span>
                </div>
            </div>

            <!-- Confirm Password -->
            <div class="form-group">
                <label id="lbl-confirm"><%= isEn ? "Confirm New Password" : "Xác nhận mật khẩu mới" %></label>
                <div class="input-wrap">
                    <i class="fas fa-shield-alt"></i>
                    <input type="password" id="confirmPassword" class="form-control"
                           placeholder="<%= isEn ? "Re-enter new password" : "Nhập lại mật khẩu mới" %>" required>
                    <button type="button" class="password-toggle" onclick="togglePwd('confirmPassword', this)">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
            </div>

            <button type="submit" class="btn-submit" id="submitBtn">
                <i class="fas fa-save"></i>
                <span id="txt-btn-submit"><%= isEn ? "Update Password" : "Cập nhật mật khẩu" %></span>
            </button>
        </form>
    </div>
</div>

<div class="footer-note">
    <i class="fas fa-cookie-bite"></i>
    <span id="txt-footer"><%= isEn ? "Settings are saved in your browser cookies" : "Cài đặt được lưu trong cookie trình duyệt của bạn" %></span>
</div>

<!-- ====== SCRIPTS ====== -->
<script>
    const contextPath = '<%= request.getContextPath() %>';
    let currentLang = '<%= language %>';

    /* ==================== THEME TOGGLE ==================== */
    const themeToggle = document.getElementById('themeToggle');

    themeToggle.addEventListener('change', function () {
        const dark = this.checked;
        document.body.classList.toggle('patient-dark', dark);
        document.documentElement.classList.toggle('patient-dark', dark);
        if (window.PatientPrefs && PatientPrefs.saveTheme) {
            PatientPrefs.saveTheme(dark).catch(function () {});
        }
        showAlert(
            dark
                ? (currentLang === 'vi' ? '🌙 Đã bật chế độ tối' : '🌙 Dark mode enabled')
                : (currentLang === 'vi' ? '☀️ Đã bật chế độ sáng' : '☀️ Light mode enabled'),
            'info'
        );
    });

    /* ==================== LANGUAGE ==================== */
    function setLanguage(lang) {
        if (lang === currentLang) return;
        if (window.PatientPrefs && PatientPrefs.saveLanguage) {
            PatientPrefs.saveLanguage(lang);
        } else {
            window.location.href = contextPath + '/patient/preferences?lang=' + lang
                + '&redirect=' + encodeURIComponent(window.location.href);
        }
    }

    /* ==================== PASSWORD VISIBILITY ==================== */
    function togglePwd(fieldId, btn) {
        const input = document.getElementById(fieldId);
        const icon = btn.querySelector('i');
        if (input.type === 'password') {
            input.type = 'text';
            icon.className = 'fas fa-eye-slash';
        } else {
            input.type = 'password';
            icon.className = 'fas fa-eye';
        }
    }

    /* ==================== PASSWORD STRENGTH ==================== */
    function checkStrength(val) {
        const fill = document.getElementById('strengthFill');
        const text = document.getElementById('strengthText');
        let score = 0;
        if (val.length >= 6) score++;
        if (val.length >= 10) score++;
        if (/[A-Z]/.test(val)) score++;
        if (/[0-9]/.test(val)) score++;
        if (/[^A-Za-z0-9]/.test(val)) score++;

        const levels = [
            { pct: '0%',   color: 'transparent', label: '' },
            { pct: '25%',  color: '#ef4444',     label: currentLang === 'vi' ? '😟 Rất yếu' : '😟 Very weak' },
            { pct: '50%',  color: '#f59e0b',     label: currentLang === 'vi' ? '😐 Trung bình' : '😐 Fair' },
            { pct: '75%',  color: '#3b82f6',     label: currentLang === 'vi' ? '🙂 Khá mạnh' : '🙂 Good' },
            { pct: '90%',  color: '#10b981',     label: currentLang === 'vi' ? '💪 Mạnh' : '💪 Strong' },
            { pct: '100%', color: '#059669',     label: currentLang === 'vi' ? '🔒 Rất mạnh' : '🔒 Very strong' },
        ];

        const lv = levels[Math.min(score, 5)];
        fill.style.width = val.length === 0 ? '0%' : lv.pct;
        fill.style.background = lv.color;
        text.textContent = val.length === 0 ? '' : lv.label;
        text.style.color = lv.color;
    }

    /* ==================== CHANGE PASSWORD FORM ==================== */
    document.getElementById('changePasswordForm').addEventListener('submit', async function (e) {
        e.preventDefault();

        const curPwd   = document.getElementById('currentPassword').value.trim();
        const newPwd   = document.getElementById('newPassword').value.trim();
        const confPwd  = document.getElementById('confirmPassword').value.trim();
        const btn      = document.getElementById('submitBtn');

        const t = (vi, en) => currentLang === 'vi' ? vi : en;

        if (!curPwd || !newPwd || !confPwd) {
            showAlert(t('Vui lòng nhập đầy đủ thông tin!', 'Please fill in all fields!'), 'danger'); return;
        }
        if (newPwd.length < 6) {
            showAlert(t('Mật khẩu mới phải có ít nhất 6 ký tự!', 'New password must be at least 6 characters!'), 'danger'); return;
        }
        if (newPwd !== confPwd) {
            showAlert(t('Mật khẩu xác nhận không khớp!', 'Passwords do not match!'), 'danger'); return;
        }

        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> ' + t('Đang xử lý...', 'Processing...');

        try {
            const resp = await fetch(contextPath + '/user/change-password', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: new URLSearchParams({
                    currentPassword: curPwd,
                    newPassword: newPwd,
                    lang: currentLang
                })
            });

            const result = await resp.json();

            if (result.success) {
                showAlert('✅ ' + t('Đổi mật khẩu thành công! Đang đăng xuất...', 'Password changed! Logging out...'), 'success');
                document.getElementById('changePasswordForm').reset();
                document.getElementById('strengthFill').style.width = '0%';
                document.getElementById('strengthText').textContent = '';
                setTimeout(() => window.location.href = contextPath + '/logout', 2500);
            } else {
                showAlert('❌ ' + (result.message || t('Đổi mật khẩu thất bại!', 'Failed to change password!')), 'danger');
                btn.disabled = false;
                btn.innerHTML = '<i class="fas fa-save"></i> <span>' + t('Cập nhật mật khẩu', 'Update Password') + '</span>';
            }
        } catch (err) {
            console.error('Password change error:', err);
            showAlert(t('Lỗi kết nối máy chủ. Vui lòng thử lại!', 'Server connection error. Please try again!'), 'danger');
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-save"></i> <span>' + t('Cập nhật mật khẩu', 'Update Password') + '</span>';
        }
    });

    /* ==================== HELPERS ==================== */
    let alertTimer;
    function showAlert(msg, type) {
        const el = document.getElementById('alertMessage');
        el.className = type;
        el.innerHTML = '<i class="fas ' + (type === 'success' ? 'fa-check-circle' : (type === 'danger' ? 'fa-exclamation-circle' : 'fa-info-circle')) + '"></i> ' + msg;
        el.style.display = 'flex';
        clearTimeout(alertTimer);
        alertTimer = setTimeout(() => { el.style.display = 'none'; }, 4000);
    }
</script>
<script src="<%= request.getContextPath() %>/js/patient-preferences.js"></script>
</body>
</html>