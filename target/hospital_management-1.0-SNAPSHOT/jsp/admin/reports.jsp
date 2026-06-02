<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hospital.model.Account" %>
<%@ page import="com.hospital.model.Report" %>
<%@ page import="java.util.*" %>
<%
    Account account = (Account) session.getAttribute("account");
    if (account == null || !"admin".equals(account.getRole())) {
        response.sendRedirect(request.getContextPath() + "/index.html");
        return;
    }
    List<Report> reports = (List<Report>) request.getAttribute("reports");
    if (reports == null) reports = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo cáo thống kê - HMS Admin</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:opsz,wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', system-ui, sans-serif;
            background: #f0f2f5;
        }

        /* Sidebar */
        .sidebar {
            position: fixed;
            left: 0;
            top: 0;
            width: 260px;
            height: 100%;
            background: linear-gradient(145deg, #1e3a5f 0%, #0f2b45 100%);
            color: #fff;
            transition: all 0.3s;
            z-index: 1000;
        }

        .sidebar-header {
            padding: 24px 20px;
            border-bottom: 1px solid rgba(255,255,255,0.1);
        }

        .sidebar-header h3 {
            font-size: 20px;
            font-weight: 700;
            margin: 0;
        }

        .sidebar-header p {
            font-size: 12px;
            color: rgba(255,255,255,0.6);
            margin: 5px 0 0;
        }

        .sidebar-menu {
            padding: 20px 0;
        }

        .menu-item {
            padding: 12px 24px;
            display: flex;
            align-items: center;
            gap: 12px;
            color: rgba(255,255,255,0.8);
            text-decoration: none;
            transition: all 0.3s;
            cursor: pointer;
        }

        .menu-item:hover {
            background: rgba(255,255,255,0.1);
            color: #fff;
        }

        .menu-item.active {
            background: rgba(255,255,255,0.15);
            border-left: 3px solid #60a5fa;
            color: #fff;
        }

        .menu-item i {
            width: 20px;
            font-size: 16px;
        }

        /* Main Content */
        .main-content {
            margin-left: 260px;
            padding: 20px 30px;
        }

        /* Top Bar */
        .top-bar {
            background: #fff;
            border-radius: 12px;
            padding: 15px 25px;
            margin-bottom: 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .page-title {
            font-size: 24px;
            font-weight: 700;
            color: #1e293b;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .user-name {
            font-weight: 600;
            color: #1e293b;
        }

        .logout-btn {
            background: #ef4444;
            color: #fff;
            border: none;
            padding: 8px 16px;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s;
        }

        .logout-btn:hover {
            background: #dc2626;
        }

        /* Buttons */
        .btn-primary {
            background: #10b981;
            color: #fff;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            margin-bottom: 20px;
        }

        .btn-primary:hover {
            background: #059669;
        }

        .btn-edit {
            background: #3b82f6;
            color: #fff;
            border: none;
            padding: 6px 12px;
            border-radius: 6px;
            cursor: pointer;
            margin: 0 4px;
        }

        .btn-delete {
            background: #ef4444;
            color: #fff;
            border: none;
            padding: 6px 12px;
            border-radius: 6px;
            cursor: pointer;
        }

        .btn-view {
            background: #10b981;
            color: #fff;
            border: none;
            padding: 6px 12px;
            border-radius: 6px;
            cursor: pointer;
        }

        /* Card & Table */
        .card {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            margin-bottom: 25px;
        }

        .card-header {
            padding: 18px 24px;
            border-bottom: 1px solid #e2e8f0;
            font-weight: 600;
            font-size: 18px;
        }

        .card-body {
            padding: 20px 24px;
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #e2e8f0;
        }

        th {
            background: #f8fafc;
            font-weight: 600;
            color: #1e293b;
        }

        .badge {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            background: #dbeafe;
            color: #1e40af;
        }

        .alert {
            padding: 12px 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
        }

        .alert-success {
            background: #dcfce7;
            color: #16a34a;
            border: 1px solid #bbf7d0;
        }

        .alert-danger {
            background: #fee2e2;
            color: #dc2626;
            border: 1px solid #fecaca;
        }

        @media (max-width: 768px) {
            .sidebar {
                width: 70px;
            }
            .sidebar-header h3, .sidebar-header p, .menu-item span {
                display: none;
            }
            .main-content {
                margin-left: 70px;
            }
        }
    </style>
</head>
<body>
    <!-- Sidebar -->
    <div class="sidebar">
        <div class="sidebar-header">
            <h3>HMS <span>| Admin</span></h3>
            <p>Admin Panel</p>
        </div>
        <div class="sidebar-menu">
            <a href="<%= request.getContextPath() %>/jsp/admin/overview.jsp" class="menu-item">
                <i class="fas fa-chart-line"></i> <span>Tổng quan</span>
            </a>
            <a href="#" class="menu-item" onclick="alert('Quản lý bác sĩ')">
                <i class="fas fa-user-md"></i> <span>Quản lý bác sĩ</span>
            </a>
            <a href="#" class="menu-item" onclick="alert('Thêm tài khoản bác sĩ')">
                <i class="fas fa-user-plus"></i> <span>Thêm tài khoản bác sĩ</span>
            </a>
            <a href="#" class="menu-item" onclick="alert('Quản lý bệnh nhân')">
                <i class="fas fa-user-injured"></i> <span>Quản lý bệnh nhân</span>
            </a>
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

    <!-- Main Content -->
    <div class="main-content">
        <div class="top-bar">
            <div class="page-title">
                <h1>Báo cáo thống kê</h1>
                <p>Quản lý và tạo báo cáo hệ thống</p>
            </div>
            <div style="display: flex; gap: 12px; align-items: center;">
                <div class="admin-profile">
                    <i class="fas fa-user-shield"></i>
                    <span><%= account.getFullname() %></span>
                </div>
                <button class="logout-btn" onclick="logout()"><i class="fas fa-sign-out-alt"></i> Đăng xuất</button>
            </div>
        </div>

        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success"><%= request.getAttribute("success") %></div>
        <% } %>
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger"><%= request.getAttribute("error") %></div>
        <% } %>

        <a href="<%= request.getContextPath() %>/admin/reports/create" class="btn-primary">
            <i class="fas fa-plus-circle"></i> Tạo báo cáo mới
        </a>

        <div class="card">
            <div class="card-header">Danh sách báo cáo</div>
            <div class="card-body">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th><th>Tiêu đề</th><th>Loại báo cáo</th>
                            <th>Kỳ báo cáo</th><th>Người tạo</th><th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (reports.isEmpty()) { %>
                            <tr><td colspan="6" style="text-align: center;">Chưa có báo cáo nào</td></tr>
                        <% } else {
                            for (Report r : reports) { %>
                            <tr>
                                <td><%= r.getReportId() %></td>
                                <td><strong><%= r.getTitle() %></strong></td>
                                <td><span class="badge"><%= r.getReportType() %></span></td>
                                <td><%= r.getPeriodStart() %> → <%= r.getPeriodEnd() %></td>
                                <td><%= r.getCreatedBy() %></td>
                                <td>
                                    <button class="btn-view" onclick="viewReport(<%= r.getReportId() %>)"><i class="fas fa-eye"></i> Xem</button>
                                    <button class="btn-edit" onclick="editReport(<%= r.getReportId() %>)"><i class="fas fa-edit"></i> Sửa</button>
                                    <button class="btn-delete" onclick="deleteReport(<%= r.getReportId() %>)"><i class="fas fa-trash"></i> Xóa</button>
                                </td>
                            </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        const contextPath = '<%= request.getContextPath() %>';
        
        function viewReport(id) {
            alert('Xem chi tiết báo cáo ID: ' + id);
        }
        
        function editReport(id) {
            window.location.href = contextPath + '/admin/reports/edit/' + id;
        }
        
        function deleteReport(id) {
            if (confirm('Bạn có chắc muốn xóa báo cáo này không?')) {
                window.location.href = contextPath + '/admin/reports/delete/' + id;
            }
        }
        
        function logout() {
            if (confirm('Đăng xuất?')) window.location.href = contextPath + '/logout';
        }
    </script>
</body>
</html>