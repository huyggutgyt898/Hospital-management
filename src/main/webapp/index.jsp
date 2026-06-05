<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hospital.model.Account" %>
<%@ include file="/jsp/common/patient_prefs.jsp" %>
<%
    Account account = (Account) session.getAttribute("account");
    String fullname = (account != null) ? account.getFullname() : "Khách";
    String role = (account != null) ? account.getRole() : "guest";
    boolean isPatientUser = account != null && "patient".equalsIgnoreCase(account.getRole());
    boolean homeIsEn = isPatientUser && patientIsEn;
    boolean homeIsDark = isPatientUser && patientIsDark;
%>
<!DOCTYPE html>
<html lang="<%= homeIsEn ? "en" : "vi" %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HMS - Trang chủ</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <% if (isPatientUser) { %><%@ include file="/jsp/common/patient_head.jsp" %><% } %>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        :root {
            --primary: #2563eb;
            --primary-dark: #1d4ed8;
            --primary-light: #dbeafe;
            --bg: #f0f2f5;
            --card: #ffffff;
            --text-primary: #1e293b;
            --text-muted: #64748b;
            --border: #e2e8f0;
            --shadow: 0 1px 3px rgba(0,0,0,0.1);
            --shadow-lg: 0 10px 25px -5px rgba(0,0,0,0.1);
            --radius: 12px;
            --radius-lg: 16px;
            --radius-xl: 24px;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #bfdbfe 0%, #93c5fd 50%, #60a5fa 100%);
            min-height: 100vh;
        }

        /* Navbar */
        .navbar {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            padding: 16px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: var(--shadow-lg);
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            z-index: 1000;
        }

        .logo {
            display: flex;
            align-items: center;
            gap: 12px;
            font-size: 24px;
            font-weight: 800;
            color: var(--primary);
        }

        .logo i {
            font-size: 28px;
        }

        .nav-links {
            display: flex;
            gap: 24px;
            align-items: center;
        }

        .nav-links a {
            text-decoration: none;
            color: var(--text-primary);
            font-weight: 500;
            transition: color 0.2s;
        }

        .nav-links a:hover {
            color: var(--primary);
        }

        .btn-login-nav {
            background: var(--primary);
            color: #fff !important;
            padding: 8px 20px;
            border-radius: 30px;
            transition: all 0.2s;
        }

        .btn-login-nav:hover {
            background: var(--primary-dark);
            transform: translateY(-2px);
        }

        .user-name-nav {
            font-weight: 600;
            color: var(--text-primary);
        }

        /* Notification Bell */
        .notification-bell {
            position: relative;
            cursor: pointer;
            font-size: 20px;
            color: var(--text-muted);
            transition: color 0.2s;
        }

        .notification-bell:hover {
            color: var(--primary);
        }

        .notification-badge {
            position: absolute;
            top: -8px;
            right: -8px;
            background: #ef4444;
            color: #fff;
            font-size: 10px;
            font-weight: 600;
            padding: 2px 6px;
            border-radius: 20px;
            min-width: 18px;
            text-align: center;
        }

        /* Notification Dropdown */
        .notification-dropdown {
            border: 1px solid #ddd;
            position: absolute;
            top: 50px;
            right: 20px;
            width: 320px;
            background: var(--card);
            border-radius: 12px;
            box-shadow: var(--shadow-lg);
            z-index: 1000;
            display: none;
            max-height: 400px;
            overflow-y: auto;
        }

        .notification-dropdown.show {
            display: block;
        }

        .notification-header {
            padding: 12px 16px;
            border-bottom: 1px solid var(--border);
            font-weight: 600;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .mark-all-read {
            font-size: 12px;
            color: var(--primary);
            cursor: pointer;
        }

        .notification-item {
            padding: 12px 16px;
            border-bottom: 1px solid var(--border);
            display: flex;
            gap: 12px;
            cursor: pointer;
            transition: background 0.2s;
        }

        .notification-item:hover {
            background: var(--bg);
        }

        .notification-item.unread {
            background: var(--primary-light);
        }

        .notification-icon {
            width: 36px;
            height: 36px;
            background: var(--primary-light);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary);
        }

        .notification-content {
            flex: 1;
        }

        .notification-title {
            font-weight: 600;
            font-size: 14px;
            margin-bottom: 4px;
        }

        .notification-time {
            font-size: 11px;
            color: var(--text-muted);
        }

        /* Hero Section */
        .hero {
            padding: 120px 40px 80px;
            text-align: center;
            color: #1e3a5f;
        }

        .hero h1 {
            font-size: 48px;
            font-weight: 800;
            margin-bottom: 20px;
            color: #1d4ed8;
        }

        .hero p {
            font-size: 18px;
            max-width: 600px;
            margin: 0 auto 30px;
            color: #1e3a5f;
            opacity: 0.9;
        }

        .hero-buttons {
            display: flex;
            gap: 16px;
            justify-content: center;
        }

        .btn-primary {
            background: #1d4ed8;
            color: #fff;
            padding: 12px 30px;
            border-radius: 40px;
            text-decoration: none;
            font-weight: 700;
            transition: all 0.2s;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.2);
            background: #1e40af;
        }

        .btn-outline {
            border: 2px solid #1d4ed8;
            color: #1d4ed8;
            background: #fff;
            padding: 12px 30px;
            border-radius: 40px;
            text-decoration: none;
            font-weight: 700;
            transition: all 0.2s;
        }

        .btn-outline:hover {
            background: #1d4ed8;
            color: #fff;
        }

        /* Features Section */
        .features {
            background: #fff;
            padding: 80px 40px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .section-title {
            text-align: center;
            font-size: 32px;
            font-weight: 800;
            color: var(--text-primary);
            margin-bottom: 16px;
        }

        .section-subtitle {
            text-align: center;
            color: var(--text-muted);
            margin-bottom: 48px;
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 30px;
        }

        .feature-card {
            text-align: center;
            padding: 30px 20px;
            background: #f8fafc;
            border-radius: var(--radius-lg);
            transition: all 0.3s;
            text-decoration: none;
            display: block;
            cursor: pointer;
        }

        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: var(--shadow-lg);
        }

        .feature-icon {
            width: 70px;
            height: 70px;
            background: var(--primary-light);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 30px;
            color: var(--primary);
        }

        .feature-card h3 {
            font-size: 18px;
            margin-bottom: 10px;
            color: var(--text-primary);
        }

        .feature-card p {
            font-size: 14px;
            color: var(--text-muted);
        }

        /* Introduction Section */
        .intro-section {
            background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
            padding: 60px 40px;
            margin-bottom: 0;
        }

        .intro-container {
            max-width: 1200px;
            margin: 0 auto;
        }

        .intro-title {
            text-align: center;
            font-size: 32px;
            font-weight: 800;
            color: var(--text-primary);
            margin-bottom: 50px;
        }

        .intro-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 40px;
            margin-bottom: 40px;
        }

        .intro-card {
            background: #fff;
            border-radius: var(--radius-lg);
            overflow: hidden;
            box-shadow: var(--shadow-lg);
            transition: all 0.3s;
            text-align: center;
        }

        .intro-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 40px -10px rgba(0,0,0,0.15);
        }

        .intro-card-image {
            width: 100%;
            height: 250px;
            object-fit: cover;
            display: block;
        }

        .intro-card-content {
            padding: 30px 25px;
        }

        .intro-card h3 {
            font-size: 20px;
            font-weight: 700;
            color: var(--text-primary);
            margin-bottom: 12px;
        }

        .intro-card p {
            font-size: 14px;
            color: var(--text-muted);
            line-height: 1.6;
        }

        /* Contact Section */
        .contact-section {
            background: #fff;
            padding: 60px 40px;
            border-top: 1px solid var(--border);
        }

        .contact-container {
            max-width: 1200px;
            margin: 0 auto;
            text-align: center;
        }

        .contact-title {
            font-size: 32px;
            font-weight: 800;
            color: var(--text-primary);
            margin-bottom: 15px;
        }

        .contact-subtitle {
            font-size: 16px;
            color: var(--text-muted);
            margin-bottom: 40px;
        }

        .social-grid {
            display: flex;
            justify-content: center;
            gap: 30px;
            flex-wrap: wrap;
        }

        .social-icon {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: var(--primary-light);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            color: var(--primary);
            transition: all 0.3s;
            text-decoration: none;
            cursor: pointer;
        }

        .social-icon:hover {
            background: var(--primary);
            color: #fff;
            transform: scale(1.1);
        }

        .social-icon i {
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Footer */
        .footer {
            background: #1e293b;
            color: #fff;
            text-align: center;
            padding: 30px;
            font-size: 14px;
        }

        @media (max-width: 900px) {
            .features-grid {
                grid-template-columns: repeat(2, 1fr);
            }
            .hero h1 {
                font-size: 36px;
            }
            .intro-grid {
                grid-template-columns: repeat(2, 1fr);
                gap: 30px;
            }
        }

        @media (max-width: 600px) {
            .features-grid {
                grid-template-columns: 1fr;
            }
            .navbar {
                padding: 16px 20px;
            }
            .hero {
                padding: 100px 20px 60px;
            }
            .intro-grid {
                grid-template-columns: 1fr;
                gap: 20px;
            }
            .intro-section {
                padding: 40px 20px;
            }
            .intro-title {
                font-size: 24px;
            }
            .contact-section {
                padding: 40px 20px;
            }
            .contact-title {
                font-size: 24px;
            }
            .social-grid {
                gap: 20px;
            }
        }
        
        .btn-outline-nav {
            border: 1px solid var(--primary);
            color: var(--primary);
            padding: 8px 20px;
            border-radius: 30px;
            background: transparent;
            transition: all 0.2s;
        }

        .btn-outline-nav:hover {
            background: var(--primary);
            color: #fff;
        }
        
        /* Achievement Section */
        .achievements {
            background: #fff;
            padding: 60px 40px;
        }
    </style>
</head>
<body class="<%= homeIsDark ? "patient-dark" : "" %>">
    <!-- Navbar -->
    <nav class="navbar">
        <div class="logo">
            <i class="fas fa-hospital-user"></i>
            <span>HMS</span>
        </div>
        <div class="nav-links">
            <a href="#"><%= isPatientUser ? pt(patientIsEn, "Trang chủ", "Home") : "Trang chủ" %></a>
            <a href="#intro-section"><%= isPatientUser ? pt(patientIsEn, "Giới thiệu", "About") : "Giới thiệu" %></a>
            <a href="#contact-section"><%= isPatientUser ? pt(patientIsEn, "Liên hệ", "Contact") : "Liên hệ" %></a>
            
            <% if (account != null) { %>
                <span class="user-name-nav"><i class="fas fa-user"></i> <%= fullname %></span>
                <!-- Chuông thông báo -->
                <div class="notification-bell" onclick="toggleNotification(event)">
                    <i class="fas fa-bell"></i>
                    <span class="notification-badge" id="notiBadge"></span>
                </div>
                <a href="${pageContext.request.contextPath}/logout" class="btn-login-nav" style="background: #ef4444;"><%= isPatientUser ? pt(patientIsEn, "Đăng xuất", "Logout") : "Đăng xuất" %></a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/jsp/auth/login.jsp" class="btn-login-nav">Đăng nhập</a>
                <a href="${pageContext.request.contextPath}/jsp/auth/register.jsp" class="btn-outline-nav">Đăng ký</a>
            <% } %>
        </div>
    </nav>

    <!-- Notification Dropdown -->
    <div class="notification-dropdown" id="notificationDropdown">
        <div class="notification-header">
            <span>Thông báo</span>
            <span class="mark-all-read" onclick="markAllRead()">Đánh dấu đã đọc</span>
        </div>
        <div id="notificationList">
            <!-- Nội dung thông báo sẽ được load từ API -->
            <div class="loading-noti" style="text-align: center; padding: 20px; color: #94a3b8;">
                <i class="fas fa-spinner fa-spin"></i> Đang tải...
            </div>
        </div>
    </div>

    <!-- Hero Section -->
    <section class="hero">
        <h1><%= isPatientUser ? pt(patientIsEn, "Chào mừng bạn đến với HMS", "Welcome to HMS") : "Chào mừng bạn đến với HMS" %></h1>
        <p><%= isPatientUser ? pt(patientIsEn, "Đặt lịch khám nhanh chóng - Chăm sóc tận tâm", "Fast booking — caring service") : "Đặt lịch khám nhanh chóng - Chăm sóc tận tâm" %></p>
        <div class="hero-buttons">
            <% if (account != null) { %>
                <a href="${pageContext.request.contextPath}/jsp/patient/book_appointment.jsp" class="btn-primary"><%= isPatientUser ? pt(patientIsEn, "Đặt lịch ngay", "Book now") : "Đặt lịch ngay" %></a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/jsp/auth/login.jsp" class="btn-primary">Đăng nhập ngay</a>
                <a href="${pageContext.request.contextPath}/jsp/auth/register.jsp" class="btn-outline">Đăng ký</a>
            <% } %>
        </div>
    </section>

    <!-- Achievement Section -->
    <section class="achievements">
        <div class="container">
            <div class="stats-grid" style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 30px; text-align: center; margin-bottom: 50px;">
                <div class="stat-item">
                    <div class="stat-number" data-target="50" data-suffix="+" style="font-size: 42px; font-weight: 800; color: #2563eb;">0+</div>
                    <div class="stat-label" style="font-size: 14px; color: #64748b; margin-top: 8px;">Bác sĩ chuyên khoa</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number" data-target="10000" data-suffix="+" style="font-size: 42px; font-weight: 800; color: #2563eb;">0+</div>
                    <div class="stat-label" style="font-size: 14px; color: #64748b; margin-top: 8px;">Bệnh nhân mỗi năm</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number" data-target="98" data-suffix="%" style="font-size: 42px; font-weight: 800; color: #2563eb;">0%</div>
                    <div class="stat-label" style="font-size: 14px; color: #64748b; margin-top: 8px;">Hài lòng của bệnh nhân</div>
                </div>
                <div class="stat-item">
                    <div class="stat-number" data-target="24" data-suffix="/7" style="font-size: 42px; font-weight: 800; color: #2563eb;">0/7</div>
                    <div class="stat-label" style="font-size: 14px; color: #64748b; margin-top: 8px;">Dịch vụ cấp cứu</div>
                </div>
            </div>

            <div class="about-text" style="text-align: center; max-width: 800px; margin: 0 auto;">
                <h3 style="font-size: 24px; font-weight: 700; color: #1e293b; margin-bottom: 20px;">Về Bệnh viện HMS</h3>
                <p style="font-size: 16px; color: #475569; line-height: 1.6;">
                    Bệnh viện HMS là một trong những bệnh viện hàng đầu trong khu vực, 
                    với đội ngũ bác sĩ giàu kinh nghiệm và trang thiết bị y tế hiện đại. 
                    Chúng tôi cam kết mang đến dịch vụ chăm sóc sức khỏe tốt nhất cho cộng đồng.
                </p>
            </div>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features">
        <div class="container">
            <h2 class="section-title"><%= isPatientUser ? pt(patientIsEn, "Tiện ích dành cho bạn", "Your utilities") : "Tiện ích dành cho bạn" %></h2>
            <p class="section-subtitle"><%= isPatientUser ? pt(patientIsEn, "Đồng hành cùng bạn trên mọi hành trình sức khỏe", "With you on every health journey") : "Đồng hành cùng bạn trên mọi hành trình sức khỏe" %></p>
            <div class="features-grid">
                <!-- AI Chatbox (thay thế Quản lý bệnh nhân) -->
                <div class="feature-card" onclick="window.location.href='${pageContext.request.contextPath}/jsp/patient/ai_chatbox.jsp'">
                    <div class="feature-icon"><i class="fas fa-robot"></i></div>
                    <h3>AI Chatbox</h3>
                    <p><%= isPatientUser ? pt(patientIsEn, "Hỗ trợ tư vấn sức khỏe thông minh 24/7", "Smart health advice 24/7") : "Hỗ trợ tư vấn sức khỏe thông minh 24/7" %></p>
                </div>
                
                <!-- Thanh toán (thay thế Quản lý bác sĩ) -->
                <div class="feature-card" onclick="window.location.href='${pageContext.request.contextPath}/jsp/patient/payment.jsp'">
                    <div class="feature-icon"><i class="fas fa-credit-card"></i></div>
                    <h3><%= isPatientUser ? pt(patientIsEn, "Thanh toán", "Payment") : "Thanh toán" %></h3>
                    <p><%= isPatientUser ? pt(patientIsEn, "Thanh toán hóa đơn trực tuyến nhanh chóng", "Pay bills online quickly") : "Thanh toán hóa đơn trực tuyến nhanh chóng" %></p>
                </div>
                
                <!-- Đặt lịch hẹn (giữ nguyên) -->
                <div class="feature-card" onclick="window.location.href='${pageContext.request.contextPath}/jsp/patient/book_appointment.jsp'">
                    <div class="feature-icon"><i class="fas fa-calendar-check"></i></div>
                    <h3><%= isPatientUser ? pt(patientIsEn, "Đặt lịch hẹn", "Book appointment") : "Đặt lịch hẹn" %></h3>
                    <p><%= isPatientUser ? pt(patientIsEn, "Đặt lịch khám trực tuyến dễ dàng", "Easy online scheduling") : "Đặt lịch khám trực tuyến dễ dàng" %></p>
                </div>
                
                <!-- Cài đặt hệ thống (thay thế Kê đơn thuốc) -->
                <div class="feature-card" onclick="window.location.href='${pageContext.request.contextPath}/jsp/patient/settings.jsp'">
                    <div class="feature-icon"><i class="fas fa-cog"></i></div>
                    <h3><%= isPatientUser ? pt(patientIsEn, "Cài đặt hệ thống", "System settings") : "Cài đặt hệ thống" %></h3>
                    <p><%= isPatientUser ? pt(patientIsEn, "Tùy chỉnh thông tin cá nhân và cài đặt", "Customize profile and preferences") : "Tùy chỉnh thông tin cá nhân và cài đặt" %></p>
                </div>
            </div>
        </div>
    </section>

    <!-- Introduction Section -->
    <section class="intro-section" id="intro-section">
        <div class="intro-container">
            <h2 class="intro-title"><%= isPatientUser ? pt(patientIsEn, "Tại sao chọn HMS?", "Why choose HMS?") : "Tại sao chọn HMS?" %></h2>
            <div class="intro-grid">
                <div class="intro-card">
                    <img src="${pageContext.request.contextPath}/assets/img/intro-facility.jpg" alt="Cơ sở vật chất" class="intro-card-image">
                    <div class="intro-card-content">
                        <h3><%= isPatientUser ? pt(patientIsEn, "Cơ sở vật chất hiện đại", "Modern Facilities") : "Cơ sở vật chất hiện đại" %></h3>
                        <p><%= isPatientUser ? pt(patientIsEn, "Trang thiết bị y tế tiên tiến, phòng mổ với công nghệ mới nhất để đảm bảo an toàn và hiệu quả cao", "Advanced medical equipment with latest technology") : "Trang thiết bị y tế tiên tiến, phòng mổ với công nghệ mới nhất để đảm bảo an toàn và hiệu quả cao" %></p>
                    </div>
                </div>
                <div class="intro-card">
                    <img src="${pageContext.request.contextPath}/assets/img/intro-team.jpg" alt="Đội ngũ y tế" class="intro-card-image">
                    <div class="intro-card-content">
                        <h3><%= isPatientUser ? pt(patientIsEn, "Đội ngũ y tế chuyên nghiệp", "Professional Medical Team") : "Đội ngũ y tế chuyên nghiệp" %></h3>
                        <p><%= isPatientUser ? pt(patientIsEn, "Bác sĩ giàu kinh nghiệm, lương y có chuyên môn cao, cam kết mang lại dịch vụ y tế tốt nhất", "Expert doctors and experienced professionals") : "Bác sĩ giàu kinh nghiệm, lương y có chuyên môn cao, cam kết mang lại dịch vụ y tế tốt nhất" %></p>
                    </div>
                </div>
                <div class="intro-card">
                    <img src="${pageContext.request.contextPath}/assets/img/intro-satisfaction.jpg" alt="Sự hài lòng bệnh nhân" class="intro-card-image">
                    <div class="intro-card-content">
                        <h3><%= isPatientUser ? pt(patientIsEn, "Sự hài lòng của bệnh nhân", "Patient Satisfaction") : "Sự hài lòng của bệnh nhân" %></h3>
                        <p><%= isPatientUser ? pt(patientIsEn, "Hơn 98% bệnh nhân hài lòng với dịch vụ, chất lượng chăm sóc và sự thân thiện của nhân viên", "Over 98% patient satisfaction rate") : "Hơn 98% bệnh nhân hài lòng với dịch vụ, chất lượng chăm sóc và sự thân thiện của nhân viên" %></p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Contact Section -->
    <section class="contact-section" id="contact-section">
        <div class="contact-container">
            <h2 class="contact-title"><%= isPatientUser ? pt(patientIsEn, "Liên hệ với chúng tôi", "Contact Us") : "Liên hệ với chúng tôi" %></h2>
            <p class="contact-subtitle"><%= isPatientUser ? pt(patientIsEn, "Theo dõi chúng tôi trên các nền tảng xã hội", "Follow us on social media") : "Theo dõi chúng tôi trên các nền tảng xã hội" %></p>
            <div class="social-grid">
                <a href="https://zalo.me/hms" class="social-icon" title="Zalo">
                    <i class="fas fa-comment-dots"></i>
                </a>
                <a href="mailto:contact@hms.com" class="social-icon" title="Email">
                    <i class="fas fa-envelope"></i>
                </a>
                <a href="https://facebook.com/hms" class="social-icon" title="Facebook">
                    <i class="fab fa-facebook-f"></i>
                </a>
                <a href="https://www.tiktok.com/@to.nguyn074?is_from_webapp=1&sender_device=pc" class="social-icon" title="TikTok">
                    <i class="fab fa-tiktok"></i>
                </a>
                <a href="https://www.youtube.com/@123hp6" class="social-icon" title="YouTube">
                    <i class="fab fa-youtube"></i>
                </a>
                <a href="https://maps.google.com" class="social-icon" title="Google Maps">
                    <i class="fas fa-map-marker-alt"></i>
                </a>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <p>&copy; 2026 Hospital Management System. All rights reserved.</p>
        <p>Hỗ trợ: support@hms.com | Hotline: 1900 xxxx</p>
    </footer>

    <script>
        // Thêm biến ctx (context path) sớm để các hàm JS sử dụng
        const ctx = '<%= request.getContextPath() %>';

        // ===== KIỂM TRA TRẠNG THÁI LỊCH HẸN ĐỊNH KỲ =====
        let lastCheckedStatus = {};
        let readNotifications = [];

        async function checkAppointmentStatus() {
            try {
                const response = await fetch(ctx + '/patient/my-appointments');
                const appointments = await response.json();

                if (!appointments || appointments.length === 0) return;

                // Kiểm tra từng lịch hẹn xem có thay đổi trạng thái không
                appointments.forEach(apt => {
                    const key = apt.appointmentId;
                    const oldStatus = lastCheckedStatus[key];
                    const newStatus = apt.status;

                    // Nếu trạng thái thay đổi (từ pending sang confirmed)
                    if (oldStatus && oldStatus !== newStatus && newStatus === 'confirmed') {
                        // Hiển thị thông báo trình duyệt
                        showBrowserNotification('✅ Lịch hẹn đã được xác nhận!', 
                            `Bác sĩ ${apt.doctorName} đã xác nhận lịch hẹn ngày ${apt.date} lúc ${apt.time}`);

                        // Cập nhật lại dropdown nếu đang mở
                        const dropdown = document.getElementById('notificationDropdown');
                        if (dropdown.classList.contains('show')) {
                            loadAppointmentNotifications();
                        }
                    }

                    // Cập nhật trạng thái đã lưu
                    lastCheckedStatus[key] = newStatus;
                });

                // Cập nhật badge và dropdown nếu cần
                updateBadgeOnly(appointments);

            } catch (error) {
                console.error('Lỗi kiểm tra trạng thái:', error);
            }
        }

        // Chỉ cập nhật badge (không reload toàn bộ)
        function updateBadgeOnly(appointments) {
            const pendingCount = appointments.filter(apt => apt.status === 'pending').length;
            const badge = document.getElementById('notiBadge');
            if (pendingCount > 0) {
                badge.textContent = pendingCount;
                badge.style.display = 'inline-block';
            } else {
                badge.style.display = 'none';
            }
        }

        // Hiển thị thông báo trình duyệt (yêu cầu quyền)
        function showBrowserNotification(title, body) {
            if ('Notification' in window) {
                if (Notification.permission === 'granted') {
                    new Notification(title, { body: body, icon: '/favicon.ico' });
                } else if (Notification.permission !== 'denied') {
                    Notification.requestPermission().then(permission => {
                        if (permission === 'granted') {
                            new Notification(title, { body: body });
                        }
                    });
                }
            }

            // Hiển thị alert fallback
            alert(title + '\n' + body);
        }

        // Bắt đầu kiểm tra định kỳ mỗi 15 giây
        let intervalId = null;

        function startPolling() {
            if (intervalId) clearInterval(intervalId);
            intervalId = setInterval(checkAppointmentStatus, 15000); // 15 giây
        }

        function stopPolling() {
            if (intervalId) {
                clearInterval(intervalId);
                intervalId = null;
            }
        }

        // Xin phép thông báo trình duyệt
        if ('Notification' in window && Notification.permission !== 'granted') {
            Notification.requestPermission();
        }

        // Khởi động polling khi trang load
        startPolling();

        // Dừng polling khi rời trang (tùy chọn)
        window.addEventListener('beforeunload', function() {
            stopPolling();
        });
        
        
        // ===== LẤY THÔNG BÁO LỊCH HẸN TỪ DATABASE =====
        async function loadAppointmentNotifications() {
            const container = document.getElementById('notificationList');

            try {
                const response = await fetch(ctx + '/patient/notifications');
                const notis = await response.json();

                if (!response.ok) throw new Error('HTTP ' + response.status);

                if (!notis || notis.length === 0) {
                    container.innerHTML = '<div style="text-align: center; padding: 30px; color: #94a3b8;"><i class="fas fa-bell-slash"></i> Chưa có thông báo mới</div>';
                    document.getElementById('notiBadge').style.display = 'none';
                    return;
                }

                let html = '';
                let unreadCount = 0;

                notis.forEach(n => {
                    const type = n.type || '';
                    let icon = 'fa-bell';
                    let color = '#2563eb';
                    let isUnread = (type === 'booking' || type === 'invoice');

                    if (type === 'booking' || type === 'booking_confirmed') { icon = 'fa-calendar-check'; color = type === 'booking_confirmed' ? '#10b981' : '#2563eb'; }
                    else if (type === 'invoice') { icon = 'fa-file-invoice-dollar'; color = '#f59e0b'; }
                    else if (type === 'payment_success') { icon = 'fa-money-bill-wave'; color = '#10b981'; }

                    if (isUnread) unreadCount++;

                    html += '<div class="notification-item ' + (isUnread ? 'unread' : '') + '" onclick="markAsRead(this)">' +
                            '<div class="notification-icon" style="background: ' + (isUnread ? '#fef3c7' : '#dbeafe') + '">' +
                                '<i class="fas ' + icon + '" style="color: ' + color + ';"></i>' +
                            '</div>' +
                            '<div class="notification-content">' +
                                '<div class="notification-title">' + escapeHtml(n.title) + '</div>' +
                                '<div>' + escapeHtml(n.message) + '</div>' +
                                '<div class="notification-time" style="color: ' + color + ';">' + escapeHtml(n.time || '') + '</div>' +
                            '</div>' +
                        '</div>';
                });

                container.innerHTML = html;

                const badge = document.getElementById('notiBadge');
                if (unreadCount > 0) { badge.textContent = unreadCount; badge.style.display = 'inline-block'; }
                else { badge.style.display = 'none'; }

            } catch (error) {
                console.error('Lỗi tải thông báo:', error);
                container.innerHTML = '<div style="text-align: center; padding: 30px; color: #ef4444;"><i class="fas fa-exclamation-circle"></i> Lỗi tải thông báo</div>';
            }
        }

        // Escape HTML helper to avoid XSS when inserting server-provided text
        function escapeHtml(str) {
            if (!str) return '';
            return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#039;');
        }

        // Toggle notification dropdown
        function toggleNotification(event) {
            event.stopPropagation();
            const dropdown = document.getElementById('notificationDropdown');
            dropdown.classList.toggle('show');
            // Load lại thông báo mỗi khi mở dropdown
            if (dropdown.classList.contains('show')) {
                loadAppointmentNotifications();
            }
        }

        // Mark as read
        function markAsRead(element, appointmentId) {
            if (!readNotifications.includes(appointmentId)) {
                readNotifications.push(appointmentId);
            }

            element.classList.remove('unread');

            const unreadCount = document.querySelectorAll('.notification-item.unread').length;

            const badge = document.getElementById('notiBadge');

            if (unreadCount > 0) {
                badge.textContent = unreadCount;
            } else {
                badge.style.display = 'none';
            }
        }

        // Mark all as read
        function markAllRead() {
            document.querySelectorAll('.notification-item').forEach(item => {
                item.classList.remove('unread');
            });
            document.getElementById('notiBadge').style.display = 'none';
        }

        // Close dropdown when clicking outside
        document.addEventListener('click', function(event) {
            const dropdown = document.getElementById('notificationDropdown');
            const bell = document.querySelector('.notification-bell');
            if (!bell.contains(event.target) && !dropdown.contains(event.target)) {
                dropdown.classList.remove('show');
            }
        });

        function animateStatNumbers() {
            document.querySelectorAll('.stat-number[data-target]').forEach(el => {
                const target = parseInt(el.dataset.target, 10) || 0;
                const suffix = el.dataset.suffix || '';
                const duration = 1200;
                const fps = 60;
                const steps = Math.max(Math.round((duration / 1000) * fps), 1);
                const increment = target / steps;
                let current = 0;

                const update = () => {
                    current += increment;
                    if (current >= target) {
                        el.textContent = target + suffix;
                        return;
                    }
                    el.textContent = Math.floor(current) + suffix;
                    requestAnimationFrame(update);
                };

                requestAnimationFrame(update);
            });
        }

        // Load thông báo lần đầu khi trang load
        document.addEventListener('DOMContentLoaded', function() {
            loadAppointmentNotifications();
            animateStatNumbers();
        });
    </script>
    <% if (isPatientUser) { %>
    <script src="${pageContext.request.contextPath}/js/patient-preferences.js"></script>
    <% } %>
</body>
</html>