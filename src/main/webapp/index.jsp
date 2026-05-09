<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hospital.model.Account" %>
<%
    Account account = (Account) session.getAttribute("account");
    String fullname = (account != null) ? account.getFullname() : "Khách";
    String role = (account != null) ? account.getRole() : "guest";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HMS - Hệ thống quản lý bệnh viện</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
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
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
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

        /* Hero Section */
        .hero {
            padding: 120px 40px 80px;
            text-align: center;
            color: #fff;
        }

        .hero h1 {
            font-size: 48px;
            font-weight: 800;
            margin-bottom: 20px;
        }

        .hero p {
            font-size: 18px;
            max-width: 600px;
            margin: 0 auto 30px;
            opacity: 0.9;
        }

        .hero-buttons {
            display: flex;
            gap: 16px;
            justify-content: center;
        }

        .btn-primary {
            background: #fff;
            color: var(--primary);
            padding: 12px 30px;
            border-radius: 40px;
            text-decoration: none;
            font-weight: 700;
            transition: all 0.2s;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(0,0,0,0.2);
        }

        .btn-outline {
            border: 2px solid #fff;
            color: #fff;
            padding: 12px 30px;
            border-radius: 40px;
            text-decoration: none;
            font-weight: 700;
            transition: all 0.2s;
        }

        .btn-outline:hover {
            background: #fff;
            color: var(--primary);
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
        }
    </style>
</head>
<body>
    <!-- Navbar -->
    <nav class="navbar">
        <div class="logo">
            <i class="fas fa-hospital-user"></i>
            <span>HMS</span>
        </div>
        <div class="nav-links">
            <a href="#">Trang chủ</a>
            <a href="#">Giới thiệu</a>
            <a href="#">Liên hệ</a>
            
            <% if (account != null) { %>
                <span class="user-name-nav"><i class="fas fa-user"></i> <%= fullname %></span>
                <% if ("patient".equals(role)) { %>
                    <a href="${pageContext.request.contextPath}/jsp/patient/book_appointment.jsp" class="btn-login-nav" style="background: #10b981;">
                        <i class="fas fa-calendar-plus"></i> Đặt lịch
                    </a>
                <% } %>
                <a href="${pageContext.request.contextPath}/logout" class="btn-login-nav" style="background: #ef4444;">Đăng xuất</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/jsp/auth/login.jsp" class="btn-login-nav">Đăng nhập</a>
                <a href="${pageContext.request.contextPath}/jsp/auth/register.jsp" class="btn-outline-nav" style="border: 1px solid var(--primary); color: var(--primary); padding: 8px 20px; border-radius: 30px;">Đăng ký</a>
            <% } %>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero">
        <h1>Hệ thống quản lý bệnh viện</h1>
        <p>Giải pháp toàn diện cho quản lý bệnh nhân, bác sĩ, lịch hẹn và đơn thuốc</p>
        <div class="hero-buttons">
            <% if (account != null && "patient".equals(role)) { %>
                <a href="${pageContext.request.contextPath}/jsp/patient/book_appointment.jsp" class="btn-primary">Đặt lịch ngay</a>
            <% } else { %>
                <a href="${pageContext.request.contextPath}/jsp/auth/login.jsp" class="btn-primary">Đăng nhập ngay</a>
                <a href="${pageContext.request.contextPath}/jsp/auth/register.jsp" class="btn-outline">Đăng ký tài khoản</a>
            <% } %>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features">
        <div class="container">
            <h2 class="section-title">Tính năng nổi bật</h2>
            <p class="section-subtitle">Hệ thống được thiết kế để đáp ứng mọi nhu cầu quản lý bệnh viện</p>
            <div class="features-grid">
                <div class="feature-card">
                    <div class="feature-icon"><i class="fas fa-users"></i></div>
                    <h3>Quản lý bệnh nhân</h3>
                    <p>Lưu trữ hồ sơ, lịch sử khám bệnh chi tiết</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon"><i class="fas fa-user-md"></i></div>
                    <h3>Quản lý bác sĩ</h3>
                    <p>Theo dõi lịch làm việc, chuyên khoa</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon"><i class="fas fa-calendar-check"></i></div>
                    <h3>Đặt lịch hẹn</h3>
                    <p>Đặt lịch khám trực tuyến dễ dàng</p>
                </div>
                <div class="feature-card">
                    <div class="feature-icon"><i class="fas fa-prescription-bottle"></i></div>
                    <h3>Kê đơn thuốc</h3>
                    <p>Quản lý đơn thuốc điện tử</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="footer">
        <p>&copy; 2026 Hospital Management System. All rights reserved.</p>
        <p>Hỗ trợ: support@hms.com | Hotline: 1900 xxxx</p>
    </footer>
</body>
</html>