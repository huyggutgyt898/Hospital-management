<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hospital.model.Account" %>
<%
    Account account = (Account) session.getAttribute("account");
    if (account == null || !"admin".equals(account.getRole())) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tạo báo cáo - HMS Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', sans-serif; background: #f0f2f5; color: #1a2c3e; }
        
        .sidebar {
            position: fixed; left: 0; top: 0; width: 280px; height: 100%;
            background: linear-gradient(180deg, #0f2b3d 0%, #0a1e2c 100%);
            color: #e0edf5; z-index: 1000;
        }
        .sidebar-header { padding: 28px 24px; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .sidebar-header h3 { font-size: 1.5rem; font-weight: 700; color: white; }
        .sidebar-header h3 span { font-weight: 400; color: #5bc0ff; }
        .sidebar-header p { font-size: 0.8rem; opacity: 0.7; margin-top: 6px; }
        .sidebar-menu { padding: 20px 16px; display: flex; flex-direction: column; gap: 6px; }
        .menu-item {
            display: flex; align-items: center; gap: 14px; padding: 12px 18px;
            border-radius: 12px; font-weight: 500; font-size: 0.95rem;
            color: #cbdbe6; text-decoration: none; transition: all 0.2s;
        }
        .menu-item i { width: 24px; font-size: 1.1rem; }
        .menu-item.active { background: #2c4f6e; color: white; }
        .menu-item:hover:not(.active) { background: rgba(255,255,255,0.08); color: white; }
        .doctor-link { margin-top: 20px; padding-top: 16px; border-top: 1px solid rgba(255,255,255,0.1); }
        
        .main-content { margin-left: 280px; padding: 24px 32px; min-height: 100vh; }
        
        .top-bar {
            display: flex; justify-content: space-between; align-items: center;
            margin-bottom: 28px; flex-wrap: wrap; gap: 16px;
        }
        .page-title h1 { font-size: 1.8rem; font-weight: 700; color: #1f3b4c; }
        .page-title p { color: #5e7e93; font-size: 0.9rem; margin-top: 4px; }
        .admin-profile {
            display: flex; align-items: center; gap: 16px; background: white;
            padding: 8px 20px; border-radius: 40px; box-shadow: 0 2px 6px rgba(0,0,0,0.05);
        }
        .admin-profile span { font-weight: 600; color: #1f3b4c; }
        .logout-btn {
            background: #ef4444; color: white; border: none; padding: 8px 18px;
            border-radius: 8px; cursor: pointer; font-size: 0.85rem; font-weight: 500;
        }
        .logout-btn:hover { background: #dc2626; }
        
        .card { background: white; border-radius: 20px; border: 1px solid #eef2f8; overflow: hidden; }
        .card-header { padding: 18px 24px; border-bottom: 1px solid #edf2f7; font-weight: 600; font-size: 1.1rem; background: #fafdff; }
        .card-body { padding: 24px; }
        
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; font-size: 0.85rem; color: #475569; }
        .form-control {
            width: 100%; padding: 12px 16px; border: 1px solid #e2e8f0;
            border-radius: 10px; font-size: 0.9rem; transition: all 0.2s;
        }
        .form-control:focus { border-color: #2c7da0; outline: none; box-shadow: 0 0 0 3px rgba(44,125,160,0.1); }
        textarea.form-control { resize: vertical; min-height: 150px; }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        
        .btn-submit {
            background: #2c7da0; color: white; border: none; padding: 12px 24px;
            border-radius: 10px; font-weight: 600; cursor: pointer; font-size: 1rem;
            display: inline-flex; align-items: center; gap: 8px;
        }
        .btn-submit:hover { background: #1f5e7e; }
        .btn-back {
            background: #64748b; color: white; text-decoration: none; padding: 12px 24px;
            border-radius: 10px; font-weight: 600; margin-left: 12px;
            display: inline-flex; align-items: center; gap: 8px;
        }
        .btn-back:hover { background: #475569; }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="sidebar-header">
            <h3>HMS <span>| Admin</span></h3>
            <p>Admin Panel</p>
        </div>
        <div class="sidebar-menu">
            <a href="<%= request.getContextPath() %>/jsp/admin/overview.jsp" class="menu-item">
                <i class="fas fa-chart-line"></i> <span>Tổng quan</span>
            </a>
            <a href="#" class="menu-item" onclick="alert('Quản lý bác sĩ')"><i class="fas fa-user-md"></i> <span>Quản lý bác sĩ</span></a>
            <a href="#" class="menu-item" onclick="alert('Thêm tài khoản bác sĩ')"><i class="fas fa-user-plus"></i> <span>Thêm tài khoản bác sĩ</span></a>
            <a href="#" class="menu-item" onclick="alert('Quản lý bệnh nhân')"><i class="fas fa-user-injured"></i> <span>Quản lý bệnh nhân</span></a>
            <a href="<%= request.getContextPath() %>/admin/reports/list" class="menu-item active">
                <i class="fas fa-chart-bar"></i> <span>Báo cáo thống kê</span>
            </a>
            <div class="doctor-link">
                <a href="<%= request.getContextPath() %>/jsp/doctor/doctor_dashboard.jsp" class="menu-item">
                    <i class="fas fa-stethoscope"></i> <span>👨‍⚕️ Giao diện Bác sĩ</span>
                </a>
            </div>
        </div>
    </div>

    <div class="main-content">
        <div class="top-bar">
            <div class="page-title">
                <h1>Tạo báo cáo mới</h1>
                <p>Điền thông tin báo cáo thống kê</p>
            </div>
            <div style="display: flex; gap: 12px;">
                <div class="admin-profile"><i class="fas fa-user-shield"></i><span><%= account.getFullname() %></span></div>
                <button class="logout-btn" onclick="logout()"><i class="fas fa-sign-out-alt"></i> Đăng xuất</button>
            </div>
        </div>

        <div class="card">
            <div class="card-header"><i class="fas fa-file-alt"></i> Thông tin báo cáo</div>
            <div class="card-body">
                <form action="<%= request.getContextPath() %>/admin/reports/create" method="POST">
                    <div class="form-group">
                        <label>Tiêu đề báo cáo *</label>
                        <input type="text" name="title" class="form-control" required placeholder="VD: Báo cáo hoạt động tháng 3/2025">
                    </div>
                    
                    <div class="form-group">
                        <label>Loại báo cáo *</label>
                        <select name="reportType" class="form-control" required>
                            <option value="">Chọn loại báo cáo</option>
                            <option value="Doanh thu">💰 Doanh thu</option>
                            <option value="Lịch hẹn">📅 Lịch hẹn</option>
                            <option value="Bệnh nhân">🩺 Bệnh nhân</option>
                            <option value="Bác sĩ">👨‍⚕️ Bác sĩ</option>
                            <option value="Hoạt động chung">📊 Hoạt động chung</option>
                        </select>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label>Từ ngày *</label>
                            <input type="date" name="periodStart" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label>Đến ngày *</label>
                            <input type="date" name="periodEnd" class="form-control" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label>Nội dung báo cáo *</label>
                        <textarea name="content" class="form-control" required placeholder="Nhập nội dung báo cáo chi tiết..."></textarea>
                    </div>
                    
                    <div style="margin-top: 24px;">
                        <button type="submit" class="btn-submit"><i class="fas fa-save"></i> Lưu báo cáo</button>
                        <a href="<%= request.getContextPath() %>/admin/reports/list" class="btn-back"><i class="fas fa-arrow-left"></i> Quay lại</a>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <script>
        const contextPath = '<%= request.getContextPath() %>';
        function logout() { if (confirm('Đăng xuất?')) window.location.href = contextPath + '/logout'; }
    </script>
</body>
</html>