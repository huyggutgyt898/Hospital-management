<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="com.hospital.model.Account" %>
        <%@ page import="java.util.*" %>
            <% Account account=(Account) session.getAttribute("account"); if (account==null ||
                !"admin".equals(account.getRole())) { response.sendRedirect(request.getContextPath() + "/login" );
                return; } if (request.getAttribute("totalUsers")==null) { response.sendRedirect(request.getContextPath()
                + "/dashboard_admin" ); return; } %>
                <%@ page import="com.hospital.model.Doctor" %>
                    <%@ page import="java.util.List" %>
                        <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
                            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
                                <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
                                    <!DOCTYPE html>
                                    <html lang="vi">

                                    <head>
                                        <meta charset="UTF-8">
                                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                                        <title>Admin Dashboard - HMS</title>
                                        <link
                                            href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css"
                                            rel="stylesheet">
                                        <link rel="stylesheet"
                                            href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
                                                border-bottom: 1px solid rgba(255, 255, 255, 0.1);
                                            }

                                            .sidebar-header h3 {
                                                font-size: 20px;
                                                font-weight: 700;
                                                margin: 0;
                                            }

                                            .sidebar-header p {
                                                font-size: 12px;
                                                color: rgba(255, 255, 255, 0.6);
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
                                                color: rgba(255, 255, 255, 0.8);
                                                text-decoration: none;
                                                transition: all 0.3s;
                                                cursor: pointer;
                                            }

                                            .menu-item:hover {
                                                background: rgba(255, 255, 255, 0.1);
                                                color: #fff;
                                            }

                                            .menu-item.active {
                                                background: rgba(255, 255, 255, 0.15);
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
                                                box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
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

                                            /* Stats Cards */
                                            .stats-grid {
                                                display: grid;
                                                grid-template-columns: repeat(4, 1fr);
                                                gap: 20px;
                                                margin-bottom: 30px;
                                            }

                                            .stat-card {
                                                background: #fff;
                                                border-radius: 12px;
                                                padding: 20px;
                                                display: flex;
                                                align-items: center;
                                                justify-content: space-between;
                                                box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
                                            }

                                            .stat-info h3 {
                                                font-size: 28px;
                                                font-weight: 700;
                                                color: #1e293b;
                                                margin: 0;
                                            }

                                            .stat-info p {
                                                color: #64748b;
                                                margin: 5px 0 0;
                                                font-size: 14px;
                                            }

                                            .stat-icon {
                                                width: 50px;
                                                height: 50px;
                                                background: #dbeafe;
                                                border-radius: 12px;
                                                display: flex;
                                                align-items: center;
                                                justify-content: center;
                                                font-size: 24px;
                                                color: #2563eb;
                                            }

                                            /* Tables */
                                            .card {
                                                background: #fff;
                                                border-radius: 12px;
                                                box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
                                                margin-bottom: 25px;
                                            }

                                            .card-header {
                                                padding: 18px 24px;
                                                border-bottom: 1px solid #e2e8f0;
                                                font-weight: 600;
                                                font-size: 18px;
                                                background: #fff;
                                            }

                                            .card-body {
                                                padding: 20px 24px;
                                                overflow-x: auto;
                                            }

                                            table {
                                                width: 100%;
                                                border-collapse: collapse;
                                            }

                                            th,
                                            td {
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

                                            .badge-active {
                                                background: #dcfce7;
                                                color: #16a34a;
                                            }

                                            .badge-inactive {
                                                background: #fee2e2;
                                                color: #dc2626;
                                            }

                                            .btn-sm {
                                                padding: 4px 12px;
                                                border-radius: 6px;
                                                font-size: 12px;
                                                cursor: pointer;
                                                border: none;
                                            }

                                            .btn-edit {
                                                background: #3b82f6;
                                                color: #fff;
                                            }

                                            .btn-delete {
                                                background: #ef4444;
                                                color: #fff;
                                            }

                                            .btn-view {
                                                background: #10b981;
                                                color: #fff;
                                            }

                                            .btn-add {
                                                background: #10b981;
                                                color: #fff;
                                                border: none;
                                                padding: 10px 20px;
                                                border-radius: 8px;
                                                cursor: pointer;
                                                font-weight: 600;
                                                transition: all 0.2s;
                                            }

                                            .btn-add:hover {
                                                background: #059669;
                                            }

                                            /* Form styles */
                                            .form-group {
                                                margin-bottom: 15px;
                                            }

                                            .form-group label {
                                                display: block;
                                                margin-bottom: 5px;
                                                font-weight: 600;
                                                font-size: 13px;
                                                color: #475569;
                                            }

                                            .form-control {
                                                width: 100%;
                                                padding: 10px 12px;
                                                border: 1px solid #e2e8f0;
                                                border-radius: 8px;
                                                font-size: 14px;
                                                transition: all 0.2s;
                                            }

                                            .form-control:focus {
                                                border-color: #3b82f6;
                                                outline: none;
                                                box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
                                            }

                                            .form-grid {
                                                display: grid;
                                                grid-template-columns: repeat(2, 1fr);
                                                gap: 20px;
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

                                                .sidebar-header h3,
                                                .sidebar-header p,
                                                .menu-item span {
                                                    display: none;
                                                }

                                                .main-content {
                                                    margin-left: 70px;
                                                }

                                                .stats-grid {
                                                    grid-template-columns: repeat(2, 1fr);
                                                }

                                                .form-grid {
                                                    grid-template-columns: 1fr;
                                                }
                                            }

                                            #reportsTable {
                                                width: 100%;
                                                border-collapse: collapse;
                                            }

                                            #reportsTable th,
                                            #reportsTable td {
                                                padding: 12px;
                                                text-align: left;
                                                border-bottom: 1px solid #e2e8f0;
                                            }

                                            #reportsTable th {
                                                background: #f8fafc;
                                                font-weight: 600;
                                                color: #1e293b;
                                            }

                                            #reportsTable tr:hover {
                                                background: #f8fafc;
                                            }

                                            /* ===== Modal Sửa Bác Sĩ ===== */
                                            .modal-overlay {
                                                display: none;
                                                position: fixed;
                                                top: 0; left: 0;
                                                width: 100%; height: 100%;
                                                background: rgba(0,0,0,0.5);
                                                z-index: 9999;
                                                justify-content: center;
                                                align-items: center;
                                                backdrop-filter: blur(4px);
                                            }
                                            .modal-overlay.active {
                                                display: flex;
                                            }
                                            .modal-box {
                                                background: #fff;
                                                border-radius: 16px;
                                                width: 540px;
                                                max-width: 95%;
                                                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                                                animation: modalSlideIn 0.3s ease;
                                                overflow: hidden;
                                            }
                                            @keyframes modalSlideIn {
                                                from { transform: translateY(-30px); opacity: 0; }
                                                to   { transform: translateY(0);      opacity: 1; }
                                            }
                                            .modal-header {
                                                padding: 20px 24px;
                                                background: linear-gradient(135deg, #1e3a5f 0%, #2563eb 100%);
                                                color: #fff;
                                                display: flex;
                                                justify-content: space-between;
                                                align-items: center;
                                            }
                                            .modal-header h3 {
                                                margin: 0;
                                                font-size: 18px;
                                                font-weight: 700;
                                            }
                                            .modal-close {
                                                background: none;
                                                border: none;
                                                color: #fff;
                                                font-size: 22px;
                                                cursor: pointer;
                                                padding: 4px 8px;
                                                border-radius: 6px;
                                                transition: background 0.2s;
                                            }
                                            .modal-close:hover {
                                                background: rgba(255,255,255,0.2);
                                            }
                                            .modal-body {
                                                padding: 24px;
                                            }
                                            .modal-body .form-group {
                                                margin-bottom: 16px;
                                            }
                                            .modal-body .form-group label {
                                                display: block;
                                                margin-bottom: 6px;
                                                font-weight: 600;
                                                font-size: 13px;
                                                color: #475569;
                                            }
                                            .modal-body .form-control {
                                                width: 100%;
                                                padding: 10px 14px;
                                                border: 2px solid #e2e8f0;
                                                border-radius: 10px;
                                                font-size: 14px;
                                                transition: border-color 0.2s, box-shadow 0.2s;
                                            }
                                            .modal-body .form-control:focus {
                                                border-color: #2563eb;
                                                box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
                                                outline: none;
                                            }
                                            .modal-footer {
                                                padding: 16px 24px;
                                                background: #f8fafc;
                                                border-top: 1px solid #e2e8f0;
                                                display: flex;
                                                justify-content: flex-end;
                                                gap: 10px;
                                            }
                                            .btn-modal-cancel {
                                                padding: 10px 20px;
                                                border: 2px solid #e2e8f0;
                                                background: #fff;
                                                border-radius: 10px;
                                                cursor: pointer;
                                                font-weight: 600;
                                                color: #64748b;
                                                transition: all 0.2s;
                                            }
                                            .btn-modal-cancel:hover {
                                                background: #f1f5f9;
                                                border-color: #cbd5e1;
                                            }
                                            .btn-modal-save {
                                                padding: 10px 24px;
                                                background: linear-gradient(135deg, #2563eb, #1d4ed8);
                                                color: #fff;
                                                border: none;
                                                border-radius: 10px;
                                                cursor: pointer;
                                                font-weight: 600;
                                                transition: all 0.2s;
                                            }
                                            .btn-modal-save:hover {
                                                background: linear-gradient(135deg, #1d4ed8, #1e40af);
                                                box-shadow: 0 4px 12px rgba(37, 99, 235, 0.4);
                                            }
                                            .btn-modal-save:disabled {
                                                opacity: 0.6;
                                                cursor: not-allowed;
                                            }

                                            /* ===== Export Button ===== */
                                            .btn-export {
                                                background: linear-gradient(135deg, #059669, #047857);
                                                color: #fff;
                                                border: none;
                                                padding: 10px 20px;
                                                border-radius: 10px;
                                                cursor: pointer;
                                                font-weight: 600;
                                                font-size: 14px;
                                                transition: all 0.2s;
                                                display: inline-flex;
                                                align-items: center;
                                                gap: 8px;
                                            }
                                            .btn-export:hover {
                                                background: linear-gradient(135deg, #047857, #065f46);
                                                box-shadow: 0 4px 12px rgba(5, 150, 105, 0.4);
                                                transform: translateY(-1px);
                                            }
                                            .doctors-toolbar {
                                                display: flex;
                                                justify-content: flex-end;
                                                gap: 10px;
                                                margin-bottom: 16px;
                                            }
                                        </style>
                                    </head>

                                    <body>
                                        <!-- Sidebar -->
                                        <div class="sidebar">
                                            <div class="sidebar-header">
                                                <h3>🏥 HMS</h3>
                                                <p>Admin Panel</p>
                                            </div>
                                            <div class="sidebar-menu">
                                                <a href="#" class="menu-item"
                                                    onclick="showSection('dashboardSection', event)">
                                                    <i class="fas fa-tachometer-alt"></i> <span>Tổng quan</span>
                                                </a>
                                                <a href="#" class="menu-item"
                                                    onclick="showSection('doctorsSection', event)">
                                                    <i class="fas fa-user-md"></i> <span>Quản lý bác sĩ</span>
                                                </a>
                                                <a href="#" class="menu-item"
                                                    onclick="showSection('addDoctorSection', event)">
                                                    <i class="fas fa-plus-circle"></i> <span>Thêm tài khoản bác
                                                        sĩ</span>
                                                </a>
                                                <a href="#" class="menu-item"
                                                    onclick="showSection('patientsSection', event)">
                                                    <i class="fas fa-user-injured"></i> <span>Quản lý bệnh nhân</span>
                                                </a>
                                                <a href="#" class="menu-item"
                                                    onclick="showSection('reportsSection', event)">
                                                    <i class="fas fa-chart-bar"></i> <span>Báo cáo thống kê</span>
                                                </a>
                                                <a href="#" class="menu-item"
                                                    onclick="showSection('paymentsSection', event)">
                                                    <i class="fas fa-money-check-alt"></i> <span>Xác nhận thanh toán</span>
                                                </a>
                                            </div>
                                        </div>

                                        <!-- Main Content -->
                                        <div class="main-content">
                                            <div class="top-bar">
                                                <div class="page-title" id="pageTitle">Tổng quan</div>
                                                <div class="user-info">
                                                    <span class="user-name"><i class="fas fa-user-shield"></i>
                                                        <%= account.getFullname() %>
                                                    </span>
                                                    <button class="logout-btn" onclick="logout()"><i
                                                            class="fas fa-sign-out-alt"></i> Đăng xuất</button>
                                                </div>
                                            </div>

                                            <!-- Dashboard Section -->
                                            <div id="dashboardSection">
                                                <div class="stats-grid">
                                                    <div class="stat-card">
                                                        <div class="stat-info">
                                                            <h3 id="totalUsers">${totalUsers}</h3>
                                                            <p>Tổng người dùng</p>
                                                        </div>
                                                        <div class="stat-icon"><i class="fas fa-users"></i></div>
                                                    </div>
                                                    <div class="stat-card">
                                                        <div class="stat-info">
                                                            <h3 id="totalDoctors">${totalDoctors}</h3>
                                                            <p>Bác sĩ</p>
                                                        </div>
                                                        <div class="stat-icon"><i class="fas fa-user-md"></i></div>
                                                    </div>
                                                    <div class="stat-card">
                                                        <div class="stat-info">
                                                            <h3 id="totalPatients">${totalPatients}</h3>
                                                            <p>Bệnh nhân</p>
                                                        </div>
                                                        <div class="stat-icon"><i class="fas fa-user-injured"></i></div>
                                                    </div>
                                                    <div class="stat-card">
                                                        <div class="stat-info">
                                                            <h3 id="totalAppointments">${totalAppointments}</h3>
                                                            <p>Lịch hẹn</p>
                                                        </div>
                                                        <div class="stat-icon"><i class="fas fa-calendar-check"></i>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="card" style="margin-bottom: 24px;">
                                                    <div class="card-header"><i class="fas fa-chart-line me-2"></i>Doanh thu (30 ngày gần nhất)</div>
                                                    <div class="card-body">
                                                        <div style="display:flex;align-items:center;gap:20px;flex-wrap:wrap;margin-bottom:16px;">
                                                            <div><span style="color:#64748b;font-size:13px;">Tổng doanh thu đã thu</span>
                                                            <h3 id="totalRevenueDisplay" style="color:#059669;margin:4px 0 0;">0đ</h3></div>
                                                        </div>
                                                        <canvas id="revenueChart" height="100"></canvas>
                                                    </div>
                                                </div>

                                                <div class="card">
                                                    <div class="card-header">Bác sĩ mới nhất</div>
                                                    <div class="card-body">
                                                        <table id="recentDoctorsTable">
                                                            <thead>
                                                                <tr>
                                                                    <th>ID</th>
                                                                    <th>Tên bác sĩ</th>
                                                                    <th>Chuyên khoa</th>
                                                                    <th>SĐT</th>
                                                                    <th>Ngày tạo</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                                <c:choose>
                                                                    <c:when test="${not empty recentDoctors}">
                                                                        <c:forEach var="doc" items="${recentDoctors}">
                                                                            <tr>
                                                                                <td>${doc.doctorId}</td>
                                                                                <td>${doc.fullname}</td>
                                                                                <td>${doc.specialty != null ?
                                                                                    doc.specialty : '—'}</td>
                                                                                <td>${doc.phone != null ? doc.phone :
                                                                                    '—'}</td>
                                                                                <td>
                                                                                    <fmt:formatDate
                                                                                        value="${doc.createdAt}"
                                                                                        pattern="dd/MM/yyyy" />
                                                                                </td>
                                                                            </tr>
                                                                        </c:forEach>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <tr>
                                                                            <td colspan="5"
                                                                                style="text-align:center; color:#64748b;">
                                                                                Chưa có dữ liệu bác sĩ
                                                                            </td>
                                                                        </tr>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Doctors Section -->
                                            <div id="doctorsSection" style="display:none;">
                                                <div class="card">
                                                    <div class="card-header">Danh sách bác sĩ</div>
                                                    <div class="card-body">
                                                        <div class="doctors-toolbar">
                                                            <button class="btn-export" onclick="exportDoctorsToExcel()">
                                                                <i class="fas fa-file-excel"></i> Xuất Excel
                                                            </button>
                                                        </div>
                                                        <div style="overflow-x: auto;">
                                                            <table id="doctorsTable">
                                                                <thead>
                                                                    <tr>
                                                                        <th>ID</th>
                                                                        <th>Tên bác sĩ</th>
                                                                        <th>Kinh nghiệm</th>
                                                                        <th>Chuyên khoa</th>
                                                                        <th>Email</th>
                                                                        <th>SĐT</th>
                                                                        <th>Trạng thái</th>
                                                                        <th>Thao tác</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody>

                                                                </tbody>
                                                            </table>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Modal Sửa Bác Sĩ -->
                                            <div id="editDoctorModal" class="modal-overlay">
                                                <div class="modal-box">
                                                    <div class="modal-header">
                                                        <h3><i class="fas fa-user-edit"></i> Sửa thông tin bác sĩ</h3>
                                                        <button class="modal-close" onclick="closeEditModal()">&times;</button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div id="editDoctorMessage"></div>
                                                        <input type="hidden" id="editDoctorId">
                                                        <div class="form-group">
                                                            <label><i class="fas fa-user"></i> Họ và tên</label>
                                                            <input type="text" id="editFullname" class="form-control" required>
                                                        </div>
                                                        <div class="form-group">
                                                            <label><i class="fas fa-briefcase-medical"></i> Số năm kinh nghiệm</label>
                                                            <input type="number" id="editExperience" class="form-control" min="0" max="50">
                                                        </div>
                                                        <div class="form-group">
                                                            <label><i class="fas fa-stethoscope"></i> Chuyên khoa</label>
                                                            <input type="text" id="editSpecialty" class="form-control">
                                                        </div>
                                                        <div class="form-group">
                                                            <label><i class="fas fa-envelope"></i> Email</label>
                                                            <input type="email" id="editEmail" class="form-control">
                                                        </div>
                                                        <div class="form-group">
                                                            <label><i class="fas fa-phone"></i> Số điện thoại</label>
                                                            <input type="tel" id="editPhone" class="form-control">
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button class="btn-modal-cancel" onclick="closeEditModal()">Hủy</button>
                                                        <button class="btn-modal-save" id="btnSaveDoctor" onclick="saveDoctor()"><i class="fas fa-save"></i> Lưu thay đổi</button>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Add Doctor Section -->
                                            <div id="addDoctorSection" style="display:none;">
                                                <div class="card">
                                                    <div class="card-header"><i class="fas fa-user-md"></i> Thêm tài
                                                        khoản bác sĩ mới</div>
                                                    <div class="card-body">
                                                        <div id="addDoctorMessage"></div>
                                                        <form id="addDoctorForm" class="form-grid">
                                                            <div class="form-group">
                                                                <label>Tên đăng nhập *</label>
                                                                <input type="text" id="username" name="username"
                                                                    class="form-control" required>
                                                                <small class="text-muted">3-50 ký tự, chữ cái, số, gạch
                                                                    dưới</small>
                                                            </div>
                                                            <div class="form-group">
                                                                <label>Mật khẩu *</label>
                                                                <input type="password" id="password" name="password"
                                                                    class="form-control" required>
                                                                <small class="text-muted">Tối thiểu 6 ký tự</small>
                                                            </div>
                                                            <div class="form-group">
                                                                <label>Họ và tên *</label>
                                                                <input type="text" id="fullname" name="fullname"
                                                                    class="form-control" required>
                                                            </div>
                                                            <div class="form-group">
                                                                <label>Chuyên khoa</label>
                                                                <input type="text" id="specialty" name="specialty"
                                                                    class="form-control"
                                                                    placeholder="VD: Tim mạch, Nhi khoa...">
                                                            </div>
                                                            <div class="form-group">
                                                                <label>Email</label>
                                                                <input type="email" id="email" name="email"
                                                                    class="form-control">
                                                            </div>
                                                            <div class="form-group">
                                                                <label>Số điện thoại</label>
                                                                <input type="tel" id="phone" name="phone"
                                                                    class="form-control">
                                                            </div>
                                                            <div class="form-group" style="grid-column: span 2;">
                                                                <label>Ảnh đại diện (URL)</label>
                                                                <input type="text" id="avatar" name="avatar"
                                                                    class="form-control"
                                                                    placeholder="Nhập URL ảnh hoặc để trống để tự động sinh avatar đẹp...">
                                                            </div>
                                                            <div class="form-group">
                                                                <label>Số năm kinh nghiệm</label>
                                                                <input type="number" id="experienceYears"
                                                                    name="experienceYears" class="form-control" min="0"
                                                                    max="50" value="0">
                                                            </div>
                                                            <div class="form-group">
                                                                <label>&nbsp;</label>
                                                                <button type="submit" class="btn-add"
                                                                    style="width: 100%;"><i class="fas fa-save"></i> Tạo
                                                                    tài khoản bác sĩ</button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Patients Section -->
                                            <div id="patientsSection" style="display:none;">
                                                <div class="card">
                                                    <div class="card-header">Danh sách bệnh nhân</div>
                                                    <div class="card-body">
                                                        <div class="doctors-toolbar">
                                                            <button class="btn-export" onclick="exportPatientsToExcel()">
                                                                <i class="fas fa-file-excel"></i> Xuất Excel
                                                            </button>
                                                        </div>
                                                        <div style="overflow-x: auto;">
                                                            <table id="patientsTable">
                                                                <thead>
                                                                    <tr>
                                                                        <th>ID</th>
                                                                        <th>Tên bệnh nhân</th>
                                                                        <th>Tên đăng nhập</th>
                                                                        <th>Email</th>
                                                                        <th>SĐT</th>
                                                                        <th>Địa chỉ</th>
                                                                        <th>Trạng thái</th>
                                                                        <th>Thao tác</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody>
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Modal Sửa Bệnh Nhân -->
                                            <div id="editPatientModal" class="modal-overlay">
                                                <div class="modal-box">
                                                    <div class="modal-header" style="background: linear-gradient(135deg, #059669 0%, #047857 100%);">
                                                        <h3><i class="fas fa-user-edit"></i> Sửa thông tin bệnh nhân</h3>
                                                        <button class="modal-close" onclick="closeEditPatientModal()">&times;</button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div id="editPatientMessage"></div>
                                                        <input type="hidden" id="editPatientId">
                                                        <div class="form-group">
                                                            <label><i class="fas fa-user"></i> Họ và tên</label>
                                                            <input type="text" id="editPatientFullname" class="form-control" required>
                                                        </div>
                                                        <div class="form-group">
                                                            <label><i class="fas fa-envelope"></i> Email</label>
                                                            <input type="email" id="editPatientEmail" class="form-control">
                                                        </div>
                                                        <div class="form-group">
                                                            <label><i class="fas fa-phone"></i> Số điện thoại</label>
                                                            <input type="tel" id="editPatientPhone" class="form-control">
                                                        </div>
                                                        <div class="form-group">
                                                            <label><i class="fas fa-map-marker-alt"></i> Địa chỉ</label>
                                                            <input type="text" id="editPatientAddress" class="form-control">
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button class="btn-modal-cancel" onclick="closeEditPatientModal()">Hủy</button>
                                                        <button class="btn-modal-save" id="btnSavePatient" onclick="savePatient()" style="background: linear-gradient(135deg, #059669, #047857);"><i class="fas fa-save"></i> Lưu thay đổi</button>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Modal Xem Chi Tiết Báo Cáo -->
                                            <div id="viewReportModal" class="modal-overlay">
                                                <div class="modal-box" style="width: 700px; max-width: 95%;">
                                                    <div class="modal-header" style="background: linear-gradient(135deg, #1e3a5f 0%, #2563eb 100%);">
                                                        <h3><i class="fas fa-file-alt"></i> Chi tiết báo cáo</h3>
                                                        <button class="modal-close" onclick="closeViewReportModal()">&times;</button>
                                                    </div>
                                                    <div class="modal-body" style="max-height: 450px; overflow-y: auto;">
                                                        <h4 id="viewReportTitle" style="font-weight: 700; color: #1e293b; margin-bottom: 15px;"></h4>
                                                        <div class="form-grid" style="grid-template-columns: repeat(2, 1fr); gap: 15px; margin-bottom: 20px;">
                                                            <div><strong>Loại báo cáo:</strong> <span id="viewReportType"></span></div>
                                                            <div><strong>Người tạo:</strong> <span id="viewCreatedBy"></span></div>
                                                            <div><strong>Kỳ báo cáo:</strong> <span id="viewPeriod"></span></div>
                                                            <div><strong>Thời gian tạo:</strong> <span id="viewCreatedAt"></span></div>
                                                        </div>
                                                        <hr>
                                                        <div style="margin-top: 15px;">
                                                            <strong style="display: block; margin-bottom: 8px;">Nội dung:</strong>
                                                            <div id="viewReportContent" style="white-space: pre-wrap; background: #f8fafc; padding: 15px; border-radius: 8px; border: 1px solid #e2e8f0; line-height: 1.6; color: #334155;"></div>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button class="btn-modal-cancel" onclick="closeViewReportModal()">Đóng</button>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Modal Sửa Báo Cáo -->
                                            <div id="editReportModal" class="modal-overlay">
                                                <div class="modal-box" style="width: 600px; max-width: 95%;">
                                                    <div class="modal-header" style="background: linear-gradient(135deg, #2563eb 0%, #1d4ed8 100%);">
                                                        <h3><i class="fas fa-edit"></i> Chỉnh sửa báo cáo</h3>
                                                        <button class="modal-close" onclick="closeEditReportModal()">&times;</button>
                                                    </div>
                                                    <div class="modal-body">
                                                        <div id="editReportMessage"></div>
                                                        <input type="hidden" id="editReportId">
                                                        <div class="form-group">
                                                            <label>Tiêu đề báo cáo *</label>
                                                            <input type="text" id="editReportTitleField" class="form-control" required>
                                                        </div>
                                                        <div class="form-group">
                                                            <label>Loại báo cáo *</label>
                                                            <select id="editReportTypeField" class="form-control" required>
                                                                <option value="Doanh thu">💰 Doanh thu</option>
                                                                <option value="Lịch hẹn">📅 Lịch hẹn</option>
                                                                <option value="Bệnh nhân">🩺 Bệnh nhân</option>
                                                                <option value="Bác sĩ">👨‍⚕️ Bác sĩ</option>
                                                                <option value="Hoạt động chung">📊 Hoạt động chung</option>
                                                            </select>
                                                        </div>
                                                        <div class="form-grid" style="grid-template-columns: repeat(2, 1fr); gap: 15px; margin-bottom: 15px;">
                                                            <div class="form-group">
                                                                <label>Từ ngày *</label>
                                                                <input type="date" id="editPeriodStart" class="form-control" required>
                                                            </div>
                                                            <div class="form-group">
                                                                <label>Đến ngày *</label>
                                                                <input type="date" id="editPeriodEnd" class="form-control" required>
                                                            </div>
                                                        </div>
                                                        <div class="form-group">
                                                            <label>Nội dung báo cáo *</label>
                                                            <textarea id="editReportContent" class="form-control" rows="5" required></textarea>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button class="btn-modal-cancel" onclick="closeEditReportModal()">Hủy</button>
                                                        <button class="btn-modal-save" id="btnSaveReport" onclick="saveReport()"><i class="fas fa-save"></i> Lưu thay đổi</button>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Reports Section -->
                                            <div id="reportsSection" style="display:none;">
                                                <!-- Nút tạo báo cáo mới -->
                                                <div style="margin-bottom: 20px;">
                                                    <button class="btn-add" onclick="showCreateReportForm()">
                                                        <i class="fas fa-plus-circle"></i> Tạo báo cáo mới
                                                    </button>
                                                </div>

                                                <!-- Form tạo báo cáo (ẩn ban đầu) -->
                                                <div id="createReportForm" class="card"
                                                    style="display:none; margin-bottom: 25px;">
                                                    <div class="card-header">
                                                        <i class="fas fa-file-alt"></i> Tạo báo cáo mới
                                                        <button class="btn-sm btn-edit"
                                                            style="float: right; background: #64748b;"
                                                            onclick="hideCreateReportForm()">Đóng</button>
                                                    </div>
                                                    <div class="card-body">
                                                        <div id="reportMessage"></div>
                                                        <form id="reportForm" class="form-grid">
                                                            <div class="form-group">
                                                                <label>Tiêu đề báo cáo *</label>
                                                                <input type="text" id="reportTitle" class="form-control"
                                                                    required placeholder="VD: Báo cáo tháng 3/2025">
                                                            </div>
                                                            <div class="form-group">
                                                                <label>Loại báo cáo *</label>
                                                                <select id="reportType" class="form-control" required>
                                                                    <option value="">Chọn loại báo cáo</option>
                                                                    <option value="Doanh thu">💰 Doanh thu</option>
                                                                    <option value="Lịch hẹn">📅 Lịch hẹn</option>
                                                                    <option value="Bệnh nhân">🩺 Bệnh nhân</option>
                                                                    <option value="Bác sĩ">👨‍⚕️ Bác sĩ</option>
                                                                    <option value="Hoạt động chung">📊 Hoạt động chung
                                                                    </option>
                                                                </select>
                                                            </div>
                                                            <div class="form-group">
                                                                <label>Từ ngày *</label>
                                                                <input type="date" id="periodStart" class="form-control"
                                                                    required>
                                                            </div>
                                                            <div class="form-group">
                                                                <label>Đến ngày *</label>
                                                                <input type="date" id="periodEnd" class="form-control"
                                                                    required>
                                                            </div>
                                                            <div class="form-group" style="grid-column: span 2;">
                                                                <label>Nội dung báo cáo *</label>
                                                                <textarea id="reportContent" class="form-control"
                                                                    rows="5" required
                                                                    placeholder="Nhập nội dung báo cáo chi tiết..."></textarea>
                                                            </div>
                                                            <div class="form-group" style="grid-column: span 2;">
                                                                <button type="submit" class="btn-add"
                                                                    style="background: #10b981;"><i
                                                                        class="fas fa-save"></i> Lưu báo cáo</button>
                                                                <button type="button" class="btn-add"
                                                                    style="background: #64748b;"
                                                                    onclick="hideCreateReportForm()">Hủy</button>
                                                            </div>
                                                        </form>
                                                    </div>
                                                </div>

                                                <!-- Danh sách báo cáo -->
                                                <div class="card">
                                                    <div class="card-header">
                                                        <i class="fas fa-chart-bar"></i> Danh sách báo cáo
                                                    </div>
                                                    <div class="card-body">
                                                        <div>
                                                            <table id="reportsTable">
                                                                <thead>
                                                                    <tr>
                                                                        <th>ID</th>
                                                                        <th>Tiêu đề</th>
                                                                        <th>Loại báo cáo</th>
                                                                        <th>Kỳ báo cáo</th>
                                                                        <th>Thời gian</th>
                                                                        <th>Người tạo</th>
                                                                        <th>Thao tác</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody id="reportsTableBody">
                                                                    <!-- Dữ liệu báo cáo sẽ được load từ JavaScript -->
                                                                </tbody>
                                                            </table>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Payments Section -->
                                            <div id="paymentsSection" style="display:none;">
                                                <div class="filter-tabs" style="margin-bottom:16px;display:flex;gap:8px;">
                                                    <button class="btn-sm btn-edit" onclick="loadPayments('pending')">Chờ xác nhận (tiền mặt)</button>
                                                    <button class="btn-sm btn-view" onclick="loadPayments('unpaid')">Chưa thanh toán</button>
                                                    <button class="btn-sm btn-add" onclick="loadPayments('paid')">Đã thanh toán</button>
                                                    <button class="btn-sm" style="background:#64748b;color:#fff;" onclick="loadPayments('all')">Tất cả</button>
                                                </div>
                                                <div class="card">
                                                    <div class="card-header"><i class="fas fa-money-check-alt me-2"></i>Hóa đơn &amp; thanh toán</div>
                                                    <div class="card-body">
                                                        <table>
                                                            <thead>
                                                                <tr>
                                                                    <th>ID</th>
                                                                    <th>Lịch hẹn</th>
                                                                    <th>Bệnh nhân</th>
                                                                    <th>Bác sĩ</th>
                                                                    <th>Ngày khám</th>
                                                                    <th>Tổng tiền</th>
                                                                    <th>PTTT</th>
                                                                    <th>Trạng thái</th>
                                                                    <th>Thao tác</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody id="paymentsTableBody">
                                                                <tr><td colspan="9" class="text-center text-muted">Đang tải...</td></tr>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>

                                        <script
                                            src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
                                        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
                                        <script src="https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js"></script>
                                        <script>
                                            const contextPath = '<%= request.getContextPath() %>';

                                            // ==================== CÁC HÀM CHÍNH ====================

                                             // Biến lưu danh sách bác sĩ cho export
                                             var doctorsCache = [];
                                             var patientsCache = [];

                                            // Tải danh sách bác sĩ
                                            async function loadDoctors() {
                                                try {
                                                    const res = await fetch(contextPath + '/admin/doctors');
                                                    if (!res.ok) {
                                                        console.error('Lỗi API:', res.status);
                                                        return;
                                                    }
                                                    const data = await res.json();
                                                    doctorsCache = data || [];
                                                    const tbody = document.querySelector('#doctorsTable tbody');
                                                    if (!tbody) return;

                                                    tbody.innerHTML = '';
                                                    if (data && data.length > 0) {
                                                        data.forEach(doc => {
                                                            const doctorCode = 'BS' + String(doc.doctorId).padStart(3, '0');
                                                            const statusBadge = (doc.isActive === true) ?
                                                                '<span class="badge-active">Hoạt động</span>' :
                                                                '<span class="badge-inactive">Khóa</span>';

                                                            tbody.innerHTML += `<tr>
                                <td>\${doctorCode}</td>
                                <td>\${escapeXml(doc.fullname)}</td>
                                <td>\${escapeXml(String(doc.experienceYears || ''))}</td>
                                <td>\${escapeXml(doc.specialty || '')}</td>
                                <td>\${escapeXml(doc.email || '')}</td>
                                <td>\${escapeXml(doc.phone || '')}</td>
                                <td>\${statusBadge}</td>
                                <td>
                                    <button class="btn-sm btn-edit" onclick="editDoctor(\${doc.doctorId})">Sửa</button>
                                    <button class="btn-sm btn-delete" onclick="deleteDoctor(\${doc.doctorId})">Xóa</button>
                                </td>
                            </tr>`;
                        });
                } else {
                    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;">Không có dữ liệu bác sĩ</td></tr>';
                }
            } catch(e) { 
                console.error('Lỗi tải danh sách bác sĩ:', e);
                const tbody = document.querySelector('#doctorsTable tbody');
                if (tbody) {
                    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center; color:red;">Lỗi tải dữ liệu</td></tr>';
                }
            }
        }

        // Helper function escape HTML
        function escapeXml(str) {
            if (!str) return '';
            return str.replace(/[&<>]/g, function(m) {
                if (m === '&') return '&amp;';
                if (m === '<') return '&lt;';
                if (m === '>') return '&gt;';
                return m;
            });
        }

        // Hàm xóa bác sĩ
        function deleteDoctor(doctorId) {
            if (confirm('Bạn có chắc chắn muốn xóa bác sĩ này?')) {
                fetch(contextPath + '/admin/doctors/' + doctorId, { method: 'DELETE' })
                    .then(response => response.json())
                    .then(result => {
                        if (result.success) {
                            alert('Xóa thành công!');
                            loadDoctors(); // Tải lại danh sách
                            if (typeof loadDashboard === 'function') loadDashboard();
                        } else {
                            alert('Xóa thất bại: ' + result.message);
                        }
                    })
                    .catch(error => {
                        console.error('Lỗi:', error);
                        alert('Có lỗi xảy ra!');
                    });
            }
        }

        // Hàm sửa bác sĩ - mở modal
        function editDoctor(doctorId) {
            const doc = doctorsCache.find(d => d.doctorId === doctorId);
            if (!doc) {
                alert('Không tìm thấy thông tin bác sĩ!');
                return;
            }
            document.getElementById('editDoctorId').value = doc.doctorId;
            document.getElementById('editFullname').value = doc.fullname || '';
            document.getElementById('editExperience').value = doc.experienceYears || 0;
            document.getElementById('editSpecialty').value = doc.specialty || '';
            document.getElementById('editEmail').value = doc.email || '';
            document.getElementById('editPhone').value = doc.phone || '';
            document.getElementById('editDoctorMessage').innerHTML = '';
            document.getElementById('editDoctorModal').classList.add('active');
        }

        // Đóng modal sửa
        function closeEditModal() {
            document.getElementById('editDoctorModal').classList.remove('active');
        }

        // Lưu thông tin bác sĩ
        async function saveDoctor() {
            const doctorId = document.getElementById('editDoctorId').value;
            const fullname = document.getElementById('editFullname').value.trim();
            const experienceYears = parseInt(document.getElementById('editExperience').value) || 0;
            const specialty = document.getElementById('editSpecialty').value.trim();
            const email = document.getElementById('editEmail').value.trim();
            const phone = document.getElementById('editPhone').value.trim();
            const messageDiv = document.getElementById('editDoctorMessage');

            if (!fullname) {
                messageDiv.innerHTML = '<div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> Họ tên không được để trống!</div>';
                return;
            }

            const btnSave = document.getElementById('btnSaveDoctor');
            btnSave.disabled = true;
            btnSave.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang lưu...';

            try {
                const res = await fetch(contextPath + '/admin/doctors/' + doctorId, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        fullname: fullname,
                        specialty: specialty,
                        phone: phone,
                        email: email,
                        experienceYears: experienceYears
                    })
                });

                const result = await res.json();

                if (result.success) {
                    messageDiv.innerHTML = '<div class="alert alert-success"><i class="fas fa-check-circle"></i> ' + result.message + '</div>';
                    setTimeout(() => {
                        closeEditModal();
                        loadDoctors();
                    }, 1000);
                } else {
                    messageDiv.innerHTML = '<div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ' + result.message + '</div>';
                }
            } catch(e) {
                console.error('Lỗi cập nhật:', e);
                messageDiv.innerHTML = '<div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> Lỗi kết nối đến máy chủ!</div>';
            } finally {
                btnSave.disabled = false;
                btnSave.innerHTML = '<i class="fas fa-save"></i> Lưu thay đổi';
            }
        }

        // Xuất danh sách bác sĩ ra Excel
        function exportDoctorsToExcel() {
            if (!doctorsCache || doctorsCache.length === 0) {
                alert('Không có dữ liệu bác sĩ để xuất!');
                return;
            }

            const exportData = doctorsCache.map(doc => ({
                'Mã BS': 'BS' + String(doc.doctorId).padStart(3, '0'),
                'Họ và tên': doc.fullname || '',
                'Kinh nghiệm (năm)': doc.experienceYears || 0,
                'Chuyên khoa': doc.specialty || '',
                'Email': doc.email || '',
                'Số điện thoại': doc.phone || '',
                'Trạng thái': doc.isActive ? 'Hoạt động' : 'Khóa'
            }));

            const ws = XLSX.utils.json_to_sheet(exportData);

            // Điều chỉnh độ rộng cột
            ws['!cols'] = [
                { wch: 10 },  // Mã BS
                { wch: 25 },  // Họ và tên
                { wch: 18 },  // Kinh nghiệm
                { wch: 20 },  // Chuyên khoa
                { wch: 30 },  // Email
                { wch: 18 },  // SĐT
                { wch: 15 }   // Trạng thái
            ];

            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, 'Danh sách bác sĩ');

            const today = new Date();
            const dateStr = today.getDate().toString().padStart(2, '0') + '-' +
                            (today.getMonth() + 1).toString().padStart(2, '0') + '-' +
                            today.getFullYear();
            XLSX.writeFile(wb, 'DanhSachBacSi_' + dateStr + '.xlsx');
        }

        // Đóng modal khi click ngoài
        document.addEventListener('click', function(e) {
            if (e.target && e.target.id === 'editDoctorModal') {
                closeEditModal();
            }
            if (e.target && e.target.id === 'editPatientModal') {
                closeEditPatientModal();
            }
            if (e.target && e.target.id === 'viewReportModal') {
                closeViewReportModal();
            }
            if (e.target && e.target.id === 'editReportModal') {
                closeEditReportModal();
            }
        });

        // Hiển thị section (SỬA LỖI CHÍNH - thêm event parameter)
        function showSection(sectionId, event) {
            if (event) event.preventDefault(); // ✅ Ngăn href="#" navigate
            
            // Ẩn tất cả sections
            const sections = ['dashboardSection', 'doctorsSection', 'addDoctorSection', 'patientsSection', 'reportsSection', 'paymentsSection'];
            sections.forEach(sec => {
                const el = document.getElementById(sec);
                if (el) el.style.display = 'none';
            });

            // Hiện section được chọn
            const activeSection = document.getElementById(sectionId);
            if (activeSection) activeSection.style.display = 'block';

            // Cập nhật title
            const titles = {
                'dashboardSection': 'Tổng quan',
                'doctorsSection': 'Quản lý bác sĩ',
                'addDoctorSection': 'Thêm tài khoản bác sĩ',
                'patientsSection': 'Quản lý bệnh nhân',
                'reportsSection': 'Báo cáo thống kê',
                'paymentsSection': 'Xác nhận thanh toán'
            };
            document.getElementById('pageTitle').innerText = titles[sectionId] || '';

            // Highlight active menu
            document.querySelectorAll('.menu-item').forEach(item => item.classList.remove('active'));
            if (event && event.currentTarget) {
                event.currentTarget.classList.add('active');
            }

            // Load dữ liệu
            if (sectionId === 'dashboardSection') loadDashboard();
            else if (sectionId === 'doctorsSection') loadDoctors();
            else if (sectionId === 'patientsSection') loadPatients();
            else if (sectionId === 'reportsSection') loadReportsList();
            else if (sectionId === 'paymentsSection') loadPayments('pending');
        }

        let revenueChartInstance = null;

        async function loadRevenueChart() {
            try {
                const res = await fetch(contextPath + '/payment/revenue');
                const data = await res.json();
                const fmt = n => new Intl.NumberFormat('vi-VN').format(Math.round(n)) + 'đ';
                document.getElementById('totalRevenueDisplay').innerText = fmt(data.totalRevenue || 0);
                const ctx = document.getElementById('revenueChart');
                if (!ctx) return;
                const labels = data.labels || [];
                const values = data.values || [];
                if (revenueChartInstance) revenueChartInstance.destroy();
                revenueChartInstance = new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Doanh thu (VNĐ)',
                            data: values,
                            backgroundColor: 'rgba(16, 185, 129, 0.7)',
                            borderRadius: 8
                        }]
                    },
                    options: {
                        responsive: true,
                        plugins: { legend: { display: false } },
                        scales: {
                            x: {
                                ticks: {
                                    callback: function(index) {
                                        const lab = this.chart.data.labels[index] || '';
                                        // format YYYY-MM-DD -> DD/MM
                                        return lab ? (lab.substring(8) + '/' + lab.substring(5,7)) : lab;
                                    },
                                    maxRotation: 45,
                                    minRotation: 0,
                                    autoSkip: true,
                                    maxTicksLimit: 15
                                }
                            },
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    callback: v => new Intl.NumberFormat('vi-VN', { notation: 'compact' }).format(v)
                                }
                            }
                        }
                    }
                });
            } catch (e) {
                console.error('Revenue chart error', e);
            }
        }

        async function loadPayments(filter) {
            const tbody = document.getElementById('paymentsTableBody');
            if (!tbody) return;
            tbody.innerHTML = '<tr><td colspan="9" class="text-center"><i class="fas fa-spinner fa-spin"></i></td></tr>';
            try {
                const res = await fetch(contextPath + '/payment/admin/list?filter=' + (filter || 'all'));
                const list = await res.json();
                if (!list.length) {
                    tbody.innerHTML = '<tr><td colspan="9" class="text-center text-muted">Không có dữ liệu</td></tr>';
                    return;
                }
                const fmt = n => new Intl.NumberFormat('vi-VN').format(Math.round(n)) + 'đ';
                const statusText = s => ({
                    unpaid: 'Chưa TT', pending_admin: 'Chờ xác nhận', paid: 'Đã TT'
                })[s] || s;
                const methodText = m => m === 'cash' ? 'Tiền mặt' : (m === 'qr' ? 'QR' : '—');
                tbody.innerHTML = list.map(p => {
                    let action = '—';
                    if (p.paymentStatus === 'pending_admin' && (p.paymentMethod === 'cash' || p.paymentMethod === 'qr')) {
                        action = '<button class="btn-sm btn-add" onclick="confirmCashPayment(' + p.paymentId + ')"><i class="fas fa-check"></i> Xác nhận</button>';
                    }
                    return '<tr><td>' + p.paymentId + '</td><td>#' + p.appointmentId + '</td><td>' + escapeXml(p.patientName) + '</td><td>' + escapeXml(p.doctorName) + '</td><td>' + escapeXml(p.appointmentDate || '') + '</td><td><strong>' + fmt(p.totalAmount) + '</strong></td><td>' + methodText(p.paymentMethod) + '</td><td>' + statusText(p.paymentStatus) + '</td><td>' + action + '</td></tr>';
                }).join('');
            } catch (e) {
                tbody.innerHTML = '<tr><td colspan="9" class="text-danger">Lỗi tải dữ liệu</td></tr>';
            }
        }

        async function confirmCashPayment(paymentId) {
            if (!confirm('Xác nhận đã thanh toán cho hóa đơn #' + paymentId + '?')) return;
            try {
                const body = new URLSearchParams();
                body.append('paymentId', paymentId);
                const res = await fetch(contextPath + '/payment/admin/confirm', { method: 'POST', body: body });
                const data = await res.json();
                alert(data.message || (data.success ? 'OK' : 'Lỗi'));
                if (data.success) {
                    loadPayments('pending');
                    loadRevenueChart();
                }
            } catch (e) {
                alert('Lỗi kết nối');
            }
        }

        // Load Dashboard
        async function loadDashboard() {
            loadRevenueChart();
            try {
                const res = await fetch(contextPath + '/admin/recent-doctors');
                if (res.ok) {
                    const data = await res.json();
                    const tbody = document.querySelector('#recentDoctorsTable tbody');
                    if (tbody && data.recentDoctors) {
                        tbody.innerHTML = '';
                        data.recentDoctors.forEach(doc => {
                            tbody.innerHTML += `<tr>
                                <td>\${doc.doctorId || doc.id}</td>
                                <td>\${escapeXml(doc.fullname)}</td>
                                <td>\${escapeXml(doc.specialty || '')}</td>
                                <td>\${escapeXml(doc.phone || '')}</td>
                                <td>\${escapeXml(doc.createdAt || '')}</td>
                            </tr>`;
                        });
                    }
                }
            } catch(e) { 
                console.error('Lỗi tải dashboard:', e);
            }
        }

        // Load Patients
        async function loadPatients() {
            try {
                const res = await fetch(contextPath + '/admin/patients');
                if (!res.ok) return;
                const data = await res.json();
                patientsCache = data || [];
                const tbody = document.querySelector('#patientsTable tbody');
                if (!tbody) return;

                tbody.innerHTML = '';
                if (data && data.length > 0) {
                    data.forEach(pat => {
                        const patCode = 'BN' + String(pat.patientId).padStart(3, '0');
                        tbody.innerHTML += `<tr>
                            <td>\${patCode}</td>
                            <td>\${escapeXml(pat.fullname)}</td>
                            <td>\${escapeXml(pat.username || '')}</td>
                            <td>\${escapeXml(pat.email || '')}</td>
                            <td>\${escapeXml(pat.phone || '')}</td>
                            <td>\${escapeXml(pat.address || '')}</td>
                            <td><span class="\${pat.isActive ? 'badge-active' : 'badge-inactive'}">\${pat.isActive ? 'Hoạt động' : 'Khóa'}</span></td>
                            <td>
                                <button class="btn-sm btn-edit" onclick="editPatient(\${pat.patientId})">Sửa</button>
                                <button class="btn-sm btn-delete" onclick="deletePatient(\${pat.patientId})">Xóa</button>
                            </td>
                        </tr>`;
                    });
                } else {
                    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center;">Không có dữ liệu bệnh nhân</td></tr>';
                }
            } catch(e) { 
                console.error('Lỗi tải patients:', e);
                const tbody = document.querySelector('#patientsTable tbody');
                if (tbody) {
                    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center; color:red;">Lỗi tải dữ liệu</td></tr>';
                }
            }
        }

        // Quản lý bệnh nhân
        function editPatient(patientId) {
            const pat = patientsCache.find(p => p.patientId === patientId);
            if (!pat) {
                alert('Không tìm thấy thông tin bệnh nhân!');
                return;
            }
            document.getElementById('editPatientId').value = pat.patientId;
            document.getElementById('editPatientFullname').value = pat.fullname || '';
            document.getElementById('editPatientEmail').value = pat.email || '';
            document.getElementById('editPatientPhone').value = pat.phone || '';
            document.getElementById('editPatientAddress').value = pat.address || '';
            document.getElementById('editPatientMessage').innerHTML = '';
            document.getElementById('editPatientModal').classList.add('active');
        }

        function closeEditPatientModal() {
            document.getElementById('editPatientModal').classList.remove('active');
        }

        async function savePatient() {
            const patientId = document.getElementById('editPatientId').value;
            const fullname = document.getElementById('editPatientFullname').value.trim();
            const email = document.getElementById('editPatientEmail').value.trim();
            const phone = document.getElementById('editPatientPhone').value.trim();
            const address = document.getElementById('editPatientAddress').value.trim();
            const messageDiv = document.getElementById('editPatientMessage');

            if (!fullname) {
                messageDiv.innerHTML = '<div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> Họ tên không được để trống!</div>';
                return;
            }

            const btnSave = document.getElementById('btnSavePatient');
            btnSave.disabled = true;
            btnSave.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang lưu...';

            try {
                const res = await fetch(contextPath + '/admin/patients/' + patientId, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        fullname: fullname,
                        phone: phone,
                        email: email,
                        address: address
                    })
                });

                const result = await res.json();

                if (result.success) {
                    messageDiv.innerHTML = '<div class="alert alert-success"><i class="fas fa-check-circle"></i> ' + result.message + '</div>';
                    setTimeout(() => {
                        closeEditPatientModal();
                        loadPatients();
                    }, 1000);
                } else {
                    messageDiv.innerHTML = '<div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ' + result.message + '</div>';
                }
            } catch(e) {
                console.error('Lỗi cập nhật bệnh nhân:', e);
                messageDiv.innerHTML = '<div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> Lỗi kết nối đến máy chủ!</div>';
            } finally {
                btnSave.disabled = false;
                btnSave.innerHTML = '<i class="fas fa-save"></i> Lưu thay đổi';
            }
        }

        function deletePatient(patientId) {
            if (confirm('Bạn có chắc chắn muốn xóa bệnh nhân này? Toàn bộ tài khoản và thông tin liên quan sẽ bị xóa vĩnh viễn.')) {
                fetch(contextPath + '/admin/patients/' + patientId, { method: 'DELETE' })
                    .then(response => response.json())
                    .then(result => {
                        if (result.success) {
                            alert('Xóa bệnh nhân thành công!');
                            loadPatients(); // Tải lại danh sách
                            if (typeof loadDashboard === 'function') loadDashboard();
                        } else {
                            alert('Xóa thất bại: ' + result.message);
                        }
                    })
                    .catch(error => {
                        console.error('Lỗi:', error);
                        alert('Có lỗi xảy ra!');
                    });
            }
        }

        // Xuất danh sách bệnh nhân ra Excel
        function exportPatientsToExcel() {
            if (!patientsCache || patientsCache.length === 0) {
                alert('Không có dữ liệu bệnh nhân để xuất!');
                return;
            }

            const exportData = patientsCache.map(pat => ({
                'Mã BN': 'BN' + String(pat.patientId).padStart(3, '0'),
                'Họ và tên': pat.fullname || '',
                'Tên đăng nhập': pat.username || '',
                'Email': pat.email || '',
                'Số điện thoại': pat.phone || '',
                'Địa chỉ': pat.address || '',
                'Trạng thái': pat.isActive ? 'Hoạt động' : 'Khóa'
            }));

            const ws = XLSX.utils.json_to_sheet(exportData);

            // Điều chỉnh độ rộng cột
            ws['!cols'] = [
                { wch: 10 },  // Mã BN
                { wch: 25 },  // Họ và tên
                { wch: 18 },  // Tên đăng nhập
                { wch: 30 },  // Email
                { wch: 18 },  // SĐT
                { wch: 35 },  // Địa chỉ
                { wch: 15 }   // Trạng thái
            ];

            const wb = XLSX.utils.book_new();
            XLSX.utils.book_append_sheet(wb, ws, 'Danh sách bệnh nhân');

            const today = new Date();
            const dateStr = today.getDate().toString().padStart(2, '0') + '-' +
                            (today.getMonth() + 1).toString().padStart(2, '0') + '-' +
                            today.getFullYear();
            XLSX.writeFile(wb, 'DanhSachBenhNhan_' + dateStr + '.xlsx');
        }

        // Thêm bác sĩ form submit
        document.getElementById('addDoctorForm').addEventListener('submit', async function(e) {
            e.preventDefault();

            const formData = new URLSearchParams();
            formData.append('username', document.getElementById('username').value);
            formData.append('password', document.getElementById('password').value);
            formData.append('fullname', document.getElementById('fullname').value);
            formData.append('specialty', document.getElementById('specialty').value);
            formData.append('email', document.getElementById('email').value);
            formData.append('phone', document.getElementById('phone').value);
            formData.append('avatar', document.getElementById('avatar').value);
            formData.append('experienceYears', document.getElementById('experienceYears').value);

            const messageDiv = document.getElementById('addDoctorMessage');

            try {
                const response = await fetch(contextPath + '/admin/add-doctor', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: formData
                });

                const result = await response.json();

                if (result.success) {
                    messageDiv.innerHTML = `<div class="alert alert-success"><i class="fas fa-check-circle"></i> \${result.message}</div>`;
                    document.getElementById('addDoctorForm').reset();
                    setTimeout(() => messageDiv.innerHTML = '', 3000);
                    // Reload danh sách bác sĩ nếu đang ở section đó
                    if (document.getElementById('doctorsSection').style.display === 'block') {
                        loadDoctors();
                    }
                } else {
                    messageDiv.innerHTML = `<div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> \${result.message}</div>`;
                    setTimeout(() => messageDiv.innerHTML = '', 3000);
                }
            } catch(error) {
                messageDiv.innerHTML = `<div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> Lỗi kết nối đến máy chủ!</div>`;
                setTimeout(() => messageDiv.innerHTML = '', 3000);
            }
        });

        // Logout
        function logout() {
            window.location.href = contextPath + '/logout';
        }

        // ==================== BÁO CÁO ====================
        var reportsData = [];

        async function loadReportsList() {
            var tbody = document.getElementById('reportsTableBody');
            if (!tbody) return;

            try {
                const res = await fetch(contextPath + '/admin/reports-api');
                if (!res.ok) {
                    tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: red;">Lỗi tải dữ liệu từ máy chủ</td></tr>';
                    return;
                }
                const data = await res.json();
                reportsData = data || [];

                if (reportsData.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="7" style="text-align: center;">Chưa có báo cáo nào</td></tr>';
                    return;
                }

                var html = '';
                for (var i = 0; i < reportsData.length; i++) {
                    var r = reportsData[i];
                    
                    // Format dates
                    var pStart = r.periodStart ? formatDateStr(r.periodStart) : '';
                    var pEnd = r.periodEnd ? formatDateStr(r.periodEnd) : '';
                    var cAt = r.createdAt ? r.createdAt : '';

                    html += '<tr>' +
                        '<td>' + r.reportId + '</td>' +
                        '<td><strong>' + escapeXml(r.title) + '</strong></td>' +
                        '<td><span class="badge">' + escapeXml(r.type || r.reportType) + '</span></td>' +
                        '<td>' + pStart + ' → ' + pEnd + '</td>' +
                        '<td>' + cAt + '</td>' +
                        '<td>' + escapeXml(r.createdBy || '') + '</td>' +
                        '<td>' +
                            '<button class="btn-sm btn-view me-1" onclick="viewReportDetail(' + r.reportId + ')"><i class="fas fa-eye"></i> Xem</button>' +
                            '<button class="btn-sm btn-edit me-1" onclick="editReport(' + r.reportId + ')"><i class="fas fa-edit"></i> Sửa</button>' +
                            '<button class="btn-sm btn-delete" onclick="deleteReportItem(' + r.reportId + ')"><i class="fas fa-trash"></i> Xóa</button>' +
                        '</td>' +
                    '</tr>';
                }
                tbody.innerHTML = html;
            } catch (e) {
                console.error('Lỗi tải báo cáo:', e);
                tbody.innerHTML = '<tr><td colspan="7" style="text-align: center; color: red;">Lỗi kết nối máy chủ</td></tr>';
            }
        }

        // Helper định dạng ngày yyyy-mm-dd -> dd/mm/yyyy
        function formatDateStr(dateStr) {
            if (!dateStr) return '';
            var parts = dateStr.split('-');
            if (parts.length === 3) {
                return parts[2] + '/' + parts[1] + '/' + parts[0];
            }
            return dateStr;
        }

        function viewReportDetail(id) {
            var report = reportsData.find(r => r.reportId === id);
            if (!report) {
                alert('Không tìm thấy thông tin báo cáo!');
                return;
            }
            document.getElementById('viewReportTitle').innerText = report.title;
            document.getElementById('viewReportType').innerText = report.type || report.reportType;
            document.getElementById('viewCreatedBy').innerText = report.createdBy || '';
            document.getElementById('viewPeriod').innerText = formatDateStr(report.periodStart) + ' → ' + formatDateStr(report.periodEnd);
            document.getElementById('viewCreatedAt').innerText = report.createdAt || '';
            document.getElementById('viewReportContent').innerText = report.content;
            document.getElementById('viewReportModal').classList.add('active');
        }

        function closeViewReportModal() {
            document.getElementById('viewReportModal').classList.remove('active');
        }

        function editReport(id) {
            var report = reportsData.find(r => r.reportId === id);
            if (!report) {
                alert('Không tìm thấy thông tin báo cáo!');
                return;
            }
            document.getElementById('editReportId').value = report.reportId;
            document.getElementById('editReportTitleField').value = report.title || '';
            document.getElementById('editReportTypeField').value = report.type || report.reportType || 'Doanh thu';
            document.getElementById('editPeriodStart').value = report.periodStart || '';
            document.getElementById('editPeriodEnd').value = report.periodEnd || '';
            document.getElementById('editReportContent').value = report.content || '';
            document.getElementById('editReportMessage').innerHTML = '';
            document.getElementById('editReportModal').classList.add('active');
        }

        function closeEditReportModal() {
            document.getElementById('editReportModal').classList.remove('active');
        }

        async function saveReport() {
            const reportId = document.getElementById('editReportId').value;
            const title = document.getElementById('editReportTitleField').value.trim();
            const reportType = document.getElementById('editReportTypeField').value;
            const periodStart = document.getElementById('editPeriodStart').value;
            const periodEnd = document.getElementById('editPeriodEnd').value;
            const content = document.getElementById('editReportContent').value.trim();
            const messageDiv = document.getElementById('editReportMessage');

            if (!title || !content || !periodStart || !periodEnd) {
                messageDiv.innerHTML = '<div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> Vui lòng nhập đầy đủ các trường bắt buộc!</div>';
                return;
            }

            const btnSave = document.getElementById('btnSaveReport');
            btnSave.disabled = true;
            btnSave.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Đang lưu...';

            try {
                const res = await fetch(contextPath + '/admin/reports-api/' + reportId, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        title: title,
                        reportType: reportType,
                        periodStart: periodStart,
                        periodEnd: periodEnd,
                        content: content
                    })
                });

                const result = await res.json();

                if (result.success) {
                    messageDiv.innerHTML = '<div class="alert alert-success"><i class="fas fa-check-circle"></i> ' + result.message + '</div>';
                    setTimeout(() => {
                        closeEditReportModal();
                        loadReportsList();
                    }, 1000);
                } else {
                    messageDiv.innerHTML = '<div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> ' + result.message + '</div>';
                }
            } catch(e) {
                console.error('Lỗi cập nhật báo cáo:', e);
                messageDiv.innerHTML = '<div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> Lỗi kết nối đến máy chủ!</div>';
            } finally {
                btnSave.disabled = false;
                btnSave.innerHTML = '<i class="fas fa-save"></i> Lưu thay đổi';
            }
        }

        async function deleteReportItem(id) {
            if (confirm('Bạn có chắc chắn muốn xóa báo cáo này không?')) {
                try {
                    const res = await fetch(contextPath + '/admin/reports-api/' + id, { method: 'DELETE' });
                    const result = await res.json();
                    if (result.success) {
                        alert('Xóa thành công!');
                        loadReportsList();
                    } else {
                        alert('Xóa thất bại: ' + result.message);
                    }
                } catch (e) {
                    console.error('Lỗi xóa báo cáo:', e);
                    alert('Lỗi kết nối máy chủ!');
                }
            }
        }

        function showCreateReportForm() {
            document.getElementById('createReportForm').style.display = 'block';
            document.getElementById('reportForm').reset();
            document.getElementById('reportMessage').innerHTML = '';
        }

        function hideCreateReportForm() {
            document.getElementById('createReportForm').style.display = 'none';
        }

        async function createNewReport(e) {
            if (e) e.preventDefault();

            const title = document.getElementById('reportTitle').value.trim();
            const reportType = document.getElementById('reportType').value;
            const periodStart = document.getElementById('periodStart').value;
            const periodEnd = document.getElementById('periodEnd').value;
            const content = document.getElementById('reportContent').value.trim();
            const messageDiv = document.getElementById('reportMessage');

            if (!title || !reportType || !periodStart || !periodEnd || !content) {
                messageDiv.innerHTML = '<div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> Vui lòng nhập đầy đủ các thông tin bắt buộc!</div>';
                return;
            }

            try {
                const response = await fetch(contextPath + '/admin/reports-api', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        title: title,
                        reportType: reportType,
                        periodStart: periodStart,
                        periodEnd: periodEnd,
                        content: content
                    })
                });

                const result = await response.json();

                if (result.success) {
                    messageDiv.innerHTML = `<div class="alert alert-success"><i class="fas fa-check-circle"></i> \${result.message}</div>`;
                    document.getElementById('reportForm').reset();
                    setTimeout(() => {
                        hideCreateReportForm();
                        loadReportsList();
                    }, 1000);
                } else {
                    messageDiv.innerHTML = `<div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> \${result.message}</div>`;
                }
            } catch(error) {
                messageDiv.innerHTML = `<div class="alert alert-danger"><i class="fas fa-exclamation-circle"></i> Lỗi kết nối máy chủ!</div>`;
            }
        }

        // Khởi tạo khi trang load
        document.addEventListener('DOMContentLoaded', function() {
            // Gán sự kiện cho form báo cáo
            var reportForm = document.getElementById('reportForm');
            if (reportForm) {
                reportForm.onsubmit = createNewReport;
            }

            // Load dashboard mặc định
            loadDashboard();
        });
                                        </script>
                                    </body>

                                    </html>