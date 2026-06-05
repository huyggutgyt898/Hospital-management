<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hospital.model.Account" %>
<%
    Account account = (Account) session.getAttribute("account");
    if (account == null || !"doctor".equals(account.getRole())) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Dashboard - HMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Inter', system-ui, sans-serif; background: #ffffff; }
        
        /* Sidebar */
        .sidebar { position: fixed; left: 0; top: 0; width: 260px; height: 100%; background: linear-gradient(145deg, #1e3a5f 0%, #0f2b45 100%); color: #fff; overflow-y: auto; }
        .sidebar-header { padding: 24px 20px; border-bottom: 1px solid rgba(255,255,255,0.1); }
        .sidebar-header h3 { font-size: 20px; font-weight: 700; }
        .sidebar-header p { font-size: 12px; color: rgba(255,255,255,0.6); }
        .menu-item { padding: 12px 20px; display: flex; align-items: center; gap: 12px; color: rgba(255,255,255,0.8); text-decoration: none; cursor: pointer; margin: 4px 12px; border-radius: 10px; }
        .menu-item:hover, .menu-item.active { background: rgba(255,255,255,0.1); color: #fff; }
        .menu-item i { width: 22px; }
        .pending-badge { background: #ef4444; color: white; border-radius: 50px; font-size: 11px; padding: 2px 8px; font-weight: 700; margin-left: auto; display: none; }

        /* Main Content */
        .main-content { margin-left: 260px; padding: 20px 30px; }
        .top-bar { background: #fff; border-radius: 12px; padding: 15px 25px; margin-bottom: 25px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .page-title { font-size: 24px; font-weight: 700; color: #1e293b; }
        .user-info { display: flex; align-items: center; gap: 15px; }
        .logout-btn { background: #ef4444; color: #fff; border: none; padding: 8px 16px; border-radius: 8px; cursor: pointer; transition: all 0.2s; }
        .logout-btn:hover { background: #dc2626; }
        
        /* Cards */
        .card { background: #fff; border-radius: 12px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); margin-bottom: 25px; }
        .card-header { padding: 18px 24px; border-bottom: 1px solid #e2e8f0; font-weight: 600; font-size: 18px; display: flex; justify-content: space-between; align-items: center; }
        .card-body { padding: 20px 24px; }
        
        /* Tables */
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #e2e8f0; font-size: 14px; }
        th { background: #f8fafc; font-weight: 600; }
        tr:hover td { background: #f8fafc; }

        /* Status badges */
        .badge-pending   { background: #fef3c7; color: #d97706; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px; }
        .badge-confirmed { background: #d1fae5; color: #059669; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px; }
        .badge-completed { background: #e0e7ff; color: #6366f1; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px; }
        .badge-cancelled { background: #fee2e2; color: #ef4444; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 4px; }
        
        /* Buttons */
        .btn-sm { padding: 5px 12px; border-radius: 6px; font-size: 12px; cursor: pointer; border: none; margin: 2px; font-weight: 600; transition: all 0.2s; }
        .btn-primary { background: #3b82f6; color: #fff; }
        .btn-primary:hover { background: #2563eb; }
        .btn-success { background: #10b981; color: #fff; }
        .btn-success:hover { background: #059669; }
        .btn-danger { background: #ef4444; color: #fff; }
        .btn-danger:hover { background: #dc2626; }
        .btn-warning { background: #f59e0b; color: #fff; }
        .btn-warning:hover { background: #d97706; }
        .btn-purple { background: #6366f1; color: #fff; }
        .btn-purple:hover { background: #4f46e5; }
        
        /* Stats Grid */
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: #fff; border-radius: 12px; padding: 20px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
        .stat-info h3 { font-size: 28px; font-weight: 700; margin: 0; }
        .stat-info p { color: #64748b; font-size: 13px; margin-top: 5px; }
        .stat-icon { width: 50px; height: 50px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 22px; }

        /* Filter tabs */
        .filter-tabs { display: flex; gap: 8px; margin-bottom: 16px; flex-wrap: wrap; }
        .filter-tab { padding: 7px 16px; border-radius: 50px; font-size: 13px; font-weight: 600; cursor: pointer; border: 2px solid #e2e8f0; background: white; color: #64748b; transition: all 0.2s; }
        .filter-tab:hover { border-color: #047857; color: #047857; }
        .filter-tab.active { background: #047857; color: white; border-color: #047857; }
        .tab-count { background: rgba(0,0,0,0.1); border-radius: 50px; padding: 1px 7px; font-size: 11px; margin-left: 4px; }
        .filter-tab.active .tab-count { background: rgba(255,255,255,0.25); }

        /* Symptoms preview */
        .sym-preview { color: #94a3b8; font-size: 12px; max-width: 160px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }

        /* Forms */
        .form-control { width: 100%; padding: 10px 12px; border: 1px solid #e2e8f0; border-radius: 8px; font-size: 14px; transition: all 0.2s; }
        .form-control:focus { border-color: #3b82f6; outline: none; box-shadow: 0 0 0 3px rgba(59,130,246,0.1); }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 600; font-size: 13px; color: #475569; }
        
        /* Search Box */
        .search-box { display: flex; gap: 10px; margin-bottom: 20px; }
        .search-input { flex: 1; padding: 10px 15px; border: 1px solid #e2e8f0; border-radius: 8px; font-size: 14px; }
        .search-input:focus { outline: none; border-color: #3b82f6; }
        .btn-search { background: #3b82f6; color: #fff; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; }
        .btn-search:hover { background: #2563eb; }
        
        /* Grid layout */
        .form-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; }
        .form-grid-2 { display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px; }
        
        /* Modal */
        .modal { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center; }
        .modal.show { display: flex; }
        .modal-content { background: #fff; border-radius: 16px; width: 90%; max-width: 600px; max-height: 85vh; overflow-y: auto; }
        .modal-header { padding: 20px; border-bottom: 1px solid #e2e8f0; display: flex; justify-content: space-between; align-items: center; }
        .modal-body { padding: 20px; }
        .modal-footer { padding: 16px 20px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 10px; }
        .close-modal { cursor: pointer; font-size: 24px; color: #94a3b8; }
        .close-modal:hover { color: #1e293b; }

        /* Detail rows in modal */
        .detail-row { display: flex; padding: 10px 0; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
        .detail-row:last-child { border-bottom: none; }
        .detail-label { color: #64748b; font-weight: 600; width: 130px; flex-shrink: 0; }
        .detail-value { color: #1e293b; }

        /* Toast */
        .toast-msg { position: fixed; bottom: 24px; right: 24px; padding: 14px 20px; border-radius: 12px; font-size: 13px; font-weight: 600; box-shadow: 0 8px 24px rgba(0,0,0,0.12); z-index: 9999; display: none; align-items: center; gap: 10px; }
        .toast-msg.show { display: flex; }
        .toast-success { background: #d1fae5; color: #065f46; border: 1px solid #6ee7b7; }
        .toast-error   { background: #fee2e2; color: #991b1b; border: 1px solid #fca5a5; }

        .text-center { text-align: center; }
        .empty-state { text-align: center; padding: 36px; color: #94a3b8; font-size: 14px; }

        @media (max-width: 768px) {
            .sidebar { width: 70px; }
            .sidebar-header h3, .sidebar-header p, .menu-item span { display: none; }
            .main-content { margin-left: 70px; }
            .stats-grid { grid-template-columns: 1fr 1fr; }
            .form-grid { grid-template-columns: 1fr; }
        }
        
        #medicineStockContainer {
            display: none;
        }
    </style>
</head>
<body>
    <!-- ===== SIDEBAR ===== -->
    <div class="sidebar">
        <div class="sidebar-header">
            <h3>🏥 HMS</h3>
            <p>Bác sĩ</p>
        </div>
        <div class="menu-item active" onclick="showSection('appointments', this)">
            <i class="fas fa-calendar-check"></i>
            <span>Quản lý lịch hẹn</span>
            <span class="pending-badge" id="sidebarPendingBadge">0</span>
        </div>
        <div class="menu-item" onclick="showSection('prescriptions', this)">
            <i class="fas fa-prescription-bottle"></i> <span>Đơn thuốc</span>
        </div>
        <div class="menu-item" onclick="showSection('patientRecords', this)">
            <i class="fas fa-notes-medical"></i> <span>Hồ sơ bệnh nhân</span>
        </div>
        <div class="menu-item" onclick="showSection('medicineStock', this)">
            <i class="fas fa-capsules"></i> <span>Kho thuốc</span>
        </div>
        <div class="menu-item" onclick="showSection('medicalRecords', this)">
            <i class="fas fa-folder-open"></i> <span>Hồ sơ bệnh án</span>
        </div>
    </div>

    <!-- ===== MAIN CONTENT ===== -->
    <div class="main-content">
        <div class="top-bar">
            <div class="page-title" id="pageTitle">Quản lý lịch hẹn</div>
            <div class="user-info">
                <span><i class="fas fa-user-md"></i> <%= account.getFullname() %></span>
                <button class="logout-btn" onclick="logout()"><i class="fas fa-sign-out-alt"></i> Đăng xuất</button>
            </div>
        </div>

        <!-- ========== LỊCH HẸN ========== -->
        <div id="appointmentsSection">
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-info"><h3 id="pendingCount" style="color:#d97706;">0</h3><p>Chờ xác nhận</p></div>
                    <div class="stat-icon" style="background:#fef3c7;color:#d97706;"><i class="fas fa-clock"></i></div>
                </div>
                <div class="stat-card">
                    <div class="stat-info"><h3 id="confirmedCount" style="color:#059669;">0</h3><p>Đã xác nhận</p></div>
                    <div class="stat-icon" style="background:#d1fae5;color:#059669;"><i class="fas fa-calendar-check"></i></div>
                </div>
                <div class="stat-card">
                    <div class="stat-info"><h3 id="todayCount" style="color:#2563eb;">0</h3><p>Hôm nay</p></div>
                    <div class="stat-icon" style="background:#dbeafe;color:#2563eb;"><i class="fas fa-calendar-day"></i></div>
                </div>
                <div class="stat-card">
                    <div class="stat-info"><h3 id="totalCount" style="color:#6366f1;">0</h3><p>Tổng lịch hẹn</p></div>
                    <div class="stat-icon" style="background:#e0e7ff;color:#6366f1;"><i class="fas fa-list-alt"></i></div>
                </div>
            </div>

            <div class="card">
                <div class="card-header">
                    <span><i class="fas fa-list-alt me-2" style="color:#047857;"></i>Danh sách lịch hẹn</span>
                    <button class="btn-sm btn-success" onclick="loadAppointments()">
                        <i class="fas fa-sync-alt me-1"></i>Làm mới
                    </button>
                </div>
                <div class="card-body">
                    <!-- Filter tabs -->
                    <div class="filter-tabs">
                        <div class="filter-tab active" id="ftab-all"       onclick="filterTab('all')">Tất cả <span class="tab-count" id="fc-all">0</span></div>
                        <div class="filter-tab"        id="ftab-pending"   onclick="filterTab('pending')">⏳ Chờ xác nhận <span class="tab-count" id="fc-pending">0</span></div>
                        <div class="filter-tab"        id="ftab-confirmed" onclick="filterTab('confirmed')">✅ Đã xác nhận <span class="tab-count" id="fc-confirmed">0</span></div>
                        <div class="filter-tab"        id="ftab-prescribed" onclick="filterTab('prescribed')">💊 Đã kê đơn <span class="tab-count" id="fc-prescribed">0</span></div>
                        <div class="filter-tab"        id="ftab-completed" onclick="filterTab('completed')">✔ Hoàn thành <span class="tab-count" id="fc-completed">0</span></div>
                        <div class="filter-tab"        id="ftab-cancelled" onclick="filterTab('cancelled')">✖ Đã huỷ <span class="tab-count" id="fc-cancelled">0</span></div>
                    </div>

                    <table>
                        <thead>
                            <tr><th>#</th><th>Bệnh nhân</th><th>Ngày khám</th><th>Giờ</th><th>Triệu chứng</th><th>Trạng thái</th><th>Thanh toán</th><th>Thao tác</th></tr>
                        </thead>
                        <tbody id="appointmentsBody">
                            <tr><td colspan="7" class="empty-state"><i class="fas fa-spinner fa-spin me-1"></i>Đang tải...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ========== ĐƠN THUỐC ========== -->
        <div id="prescriptionsSection" style="display:none;">
            <div class="card">
                <div class="card-header">Đơn thuốc đã kê</div>
                <div class="card-body">
                    <table id="prescriptionsTable">
                        <thead><tr><th>ID</th><th>Bệnh nhân</th><th>Thuốc</th><th>Liều lượng</th><th>Số lượng</th><th>Ngày kê</th></tr></thead>
                        <tbody></tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ========== HỒ SƠ BỆNH NHÂN ========== -->
        <div id="patientRecordsSection" style="display:none;">
            <div class="card">
                <div class="card-header"><i class="fas fa-search"></i> Tìm kiếm bệnh nhân</div>
                <div class="card-body">
                    <div class="search-box">
                        <input type="text" id="searchPatientInput" placeholder="Nhập tên bệnh nhân hoặc số điện thoại..." class="search-input">
                        <button class="btn-search" onclick="searchPatient()"><i class="fas fa-search"></i> Tìm kiếm</button>
                        <button class="btn-search" style="background:#10b981;" onclick="loadAllPatients()"><i class="fas fa-sync-alt"></i> Tất cả</button>
                    </div>
                </div>
            </div>
            <div class="card">
                <div class="card-header"><i class="fas fa-list"></i> Danh sách bệnh nhân</div>
                <div class="card-body">
                    <table id="patientsTable">
                        <thead><tr><th>ID</th><th>Họ tên</th><th>Ngày sinh</th><th>Giới tính</th><th>SĐT</th><th>Địa chỉ</th><th>BHYT</th><th>Thao tác</th></tr></thead>
                        <tbody></tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ========== KHO THUỐC ========== -->
        <div id="medicineStockSection" style="display:none;">
            <div class="card">
                <div class="card-header" id="medFormHeader"><i class="fas fa-plus-circle"></i> Thêm thuốc mới</div>
                <div class="card-body">
                    <form id="addMedicineForm" class="form-grid">
                        <div class="form-group"><label>Tên thuốc *</label><input type="text" id="medName" class="form-control" required></div>
                        <div class="form-group"><label>Số lượng tồn *</label><input type="number" id="medQuantity" class="form-control" required></div>
                        <div class="form-group"><label>Đơn vị</label><select id="medUnit" class="form-control"><option>Viên</option><option>Ống</option><option>Chai</option><option>Gói</option><option>Lọ</option></select></div>
                        <div class="form-group"><label>Đơn giá *</label><input type="number" id="medPrice" class="form-control" required></div>
                        <div class="form-group"><label>Hạn sử dụng</label><input type="date" id="medExpiry" class="form-control" min=""></div>
                        <div class="form-group"><label>Nhà cung cấp</label><input type="text" id="medSupplier" class="form-control"></div>
                        <div class="form-group">
                            <label style="visibility:hidden;">x</label>
                            <button type="submit" id="medSubmitBtn" class="btn-success btn-sm" style="width:100%;padding:10px;"><i class="fas fa-plus"></i> Thêm thuốc</button>
                        </div>
                        <div class="form-group">
                            <label style="visibility:hidden;">x</label>
                            <button type="button" id="medCancelBtn" class="btn-secondary btn-sm" style="width:100%;padding:10px;display:none;" onclick="resetMedicineForm()"><i class="fas fa-times"></i> Hủy</button>
                        </div>
                    </form>
                </div>
            </div>
            <div class="card">
                <div class="card-header"><i class="fas fa-boxes"></i> Danh sách kho thuốc</div>
                <div class="card-body">
                    <div class="search-box">
                        <input type="text" id="searchMedicineInput" placeholder="Tìm kiếm thuốc..." class="search-input">
                        <button class="btn-search" onclick="searchMedicine()"><i class="fas fa-search"></i> Tìm kiếm</button>
                    </div>
                    <table id="medicineTable">
                        <thead><tr><th>ID</th><th>Tên thuốc</th><th>Số lượng</th><th>Đơn vị</th><th>Đơn giá</th><th>Hạn dùng</th><th>Thao tác</th></tr></thead>
                        <tbody></tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ========== HỒ SƠ BỆNH ÁN ========== -->
        <div id="medicalRecordsSection" style="display:none;">
            <div class="card">
                <div class="card-header"><i class="fas fa-file-alt"></i> Tạo hồ sơ bệnh án mới</div>
                <div class="card-body">
                    <form id="medicalRecordForm" class="form-grid-2">
                        <div class="form-group"><label>Chọn bệnh nhân *</label><select id="recordPatientId" class="form-control" required><option value="">-- Chọn bệnh nhân --</option></select></div>
                        <div class="form-group"><label>Ngày khám *</label><input type="date" id="recordDate" class="form-control" required></div>
                        <div class="form-group"><label>Chẩn đoán *</label><input type="text" id="recordDiagnosis" class="form-control" required></div>
                        <div class="form-group"><label>Triệu chứng</label><input type="text" id="recordSymptoms" class="form-control"></div>
                        <div class="form-group"><label>Kết quả xét nghiệm</label><textarea id="recordTestResults" rows="2" class="form-control"></textarea></div>
                        <div class="form-group"><label>Phương pháp điều trị</label><textarea id="recordTreatment" rows="2" class="form-control"></textarea></div>
                        <div class="form-group"><label>Ghi chú</label><textarea id="recordNotes" rows="2" class="form-control"></textarea></div>
                        <div class="form-group"><label style="visibility:hidden;">x</label><button type="submit" class="btn-primary btn-sm" style="width:100%;padding:10px;"><i class="fas fa-save"></i> Lưu hồ sơ</button></div>
                    </form>
                </div>
            </div>
            <div class="card">
                <div class="card-header" style="display:flex; justify-content:space-between; align-items:center; gap:10px;">
                    <span><i class="fas fa-history"></i> Lịch sử khám bệnh</span>
                    <button class="btn-sm btn-success" onclick="exportMedicalRecordsToExcel()"><i class="fas fa-file-excel"></i> Xuất Excel</button>
                </div>
                <div class="card-body">
                    <div class="search-box">
                        <input type="text" id="searchMedicalRecordInput" placeholder="Nhập tên bệnh nhân..." class="search-input">
                        <button class="btn-search" onclick="searchMedicalRecord()"><i class="fas fa-search"></i> Tìm kiếm</button>
                    </div>
                    <table id="medicalRecordsTable">
                        <thead><tr><th>ID</th><th>Bệnh nhân</th><th>Ngày khám</th><th>Chẩn đoán</th><th>Điều trị</th><th>Bác sĩ</th><th>Chi tiết</th></tr></thead>
                        <tbody></tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal chi tiết lịch hẹn -->
    <div class="modal" id="appointmentModal">
        <div class="modal-content">
            <div class="modal-header">
                <h4><i class="fas fa-calendar-check me-2" style="color:#047857;"></i>Chi tiết lịch hẹn</h4>
                <span class="close-modal" onclick="closeModal('appointmentModal')">&times;</span>
            </div>
            <div class="modal-body" id="appointmentModalBody"></div>
            <div class="modal-footer" id="appointmentModalFooter"></div>
        </div>
    </div>

    <!-- Modal chi tiết bệnh nhân -->
    <div class="modal" id="patientModal">
        <div class="modal-content">
            <div class="modal-header">
                <h4><i class="fas fa-user-circle"></i> Chi tiết bệnh nhân</h4>
                <span class="close-modal" onclick="closeModal('patientModal')">&times;</span>
            </div>
            <div class="modal-body" id="patientModalBody"></div>
            <div class="modal-footer"><button class="btn-sm btn-danger" onclick="closeModal('patientModal')">Đóng</button></div>
        </div>
    </div>

        <!-- Modal Sửa thông tin bệnh nhân (Doctor) -->
        <div id="editPatientModalDoctor" class="modal">
            <div class="modal-content">
                <div class="modal-header" style="background: linear-gradient(135deg,#059669 0%,#047857 100%); color: white;">
                    <h4 style="margin:0;"><i class="fas fa-user-edit"></i> Sửa thông tin bệnh nhân</h4>
                    <span class="close-modal" onclick="closeEditPatientModalDoctor()">&times;</span>
                </div>
                <div class="modal-body">
                    <div id="editPatientMessageDoctor"></div>
                    <input type="hidden" id="editPatientIdDoctor">
                    <div class="form-group"><label>Họ và tên</label><input type="text" id="editPatientFullnameDoctor" class="form-control"></div>
                    <div class="form-group"><label>Ngày sinh</label><input type="date" id="editPatientDateOfBirthDoctor" class="form-control"></div>
                    <div class="form-group"><label>Giới tính</label>
                        <select id="editPatientGenderDoctor" class="form-control">
                            <option value="">Chọn giới tính</option>
                            <option value="male">Nam</option>
                            <option value="female">Nữ</option>
                            <option value="other">Khác</option>
                        </select>
                    </div>
                    <div class="form-group"><label>Số điện thoại</label><input type="tel" id="editPatientPhoneDoctor" class="form-control"></div>
                    <div class="form-group"><label>Địa chỉ</label><input type="text" id="editPatientAddressDoctor" class="form-control"></div>
                    <div class="form-group"><label><input type="checkbox" id="editPatientHealthInsuranceDoctor"> Có bảo hiểm y tế</label></div>
                </div>
                <div class="modal-footer">
                    <button class="btn-danger" onclick="closeEditPatientModalDoctor()">Hủy</button>
                    <button class="btn-success" id="btnSavePatientDoctor" onclick="savePatientDoctor()"><i class="fas fa-save"></i> Lưu thay đổi</button>
                </div>
            </div>
        </div>

    <!-- Modal chi tiết bệnh án -->
    <div class="modal" id="medicalRecordModal">
        <div class="modal-content" style="max-width:700px;">
            <div class="modal-header">
                <h4><i class="fas fa-file-medical"></i> Chi tiết bệnh án</h4>
                <span class="close-modal" onclick="closeModal('medicalRecordModal')">&times;</span>
            </div>
            <div class="modal-body" id="medicalRecordModalBody"></div>
            <div class="modal-footer"><button class="btn-sm btn-danger" onclick="closeModal('medicalRecordModal')">Đóng</button></div>
        </div>
    </div>

    <!-- Toast thông báo -->
    <div class="toast-msg" id="toastEl">
        <i id="toastIcon" class="fas fa-check-circle"></i>
        <span id="toastText"></span>
    </div>

    <script>
        const contextPath = '<%= request.getContextPath() %>';
        let allAppointments = [];
        let currentFilter = 'all';
        let editingMedicineId = null;

        function initMedicineExpiryMin() {
            const expiryInput = document.getElementById('medExpiry');
            if (!expiryInput) return;
            const tomorrow = new Date();
            tomorrow.setDate(tomorrow.getDate() + 1);
            expiryInput.min = tomorrow.toISOString().split('T')[0];
        }
        initMedicineExpiryMin();

        // ==================== NAVIGATION ====================
        function showSection(section, el) {
            const titles = {
                appointments:'Quản lý lịch hẹn',
                prescriptions:'Đơn thuốc',
                patientRecords:'Hồ sơ bệnh nhân',
                medicineStock:'Kho thuốc',
                medicalRecords:'Hồ sơ bệnh án'
            };

            // Cập nhật active menu
            document.querySelectorAll('.menu-item').forEach(i => i.classList.remove('active'));
            if (el) el.classList.add('active');

            document.getElementById('pageTitle').innerText = titles[section] || section;

            // Xử lý các section bình thường
            const normalSections = ['appointments', 'prescriptions', 'patientRecords', 'medicalRecords'];
            normalSections.forEach(s => {
                const sec = document.getElementById(s + 'Section');
                if (sec) sec.style.display = s === section ? 'block' : 'none';
            });

            // ✅ Đơn giản hóa - không fetch JSP ngoài nữa
            const medSection = document.getElementById('medicineStockSection');
            if (medSection) medSection.style.display = section === 'medicineStock' ? 'block' : 'none';

            if (section === 'appointments')   loadAppointments();
            else if (section === 'prescriptions')  loadPrescriptions();
            else if (section === 'patientRecords') loadAllPatients();
            else if (section === 'medicineStock')  loadMedicine();
            else if (section === 'medicalRecords') { loadMedicalRecords(); loadPatientSelect(); }
        }


        // ==================== LỊCH HẸN ====================
        async function loadAppointments() {
            document.getElementById('appointmentsBody').innerHTML =
                '<tr><td colspan="7" class="empty-state"><i class="fas fa-spinner fa-spin me-1"></i>Đang tải...</td></tr>';
            try {
                const res = await fetch(contextPath + '/doctor/appointments');
                const data = await res.json();
                allAppointments = Array.isArray(data) ? data : (data.appointments || []);
            } catch (e) {
                console.error(e);
                allAppointments = [];
            }
            updateCounts();
            renderAppointments();
        }

        function updateCounts() {
            const cnt = (s) => s === 'all' ? allAppointments.length : allAppointments.filter(a => a.status === s).length;
            const today = new Date().toISOString().split('T')[0];

            document.getElementById('pendingCount').innerText   = cnt('pending');
            document.getElementById('confirmedCount').innerText = cnt('confirmed');
            document.getElementById('totalCount').innerText     = cnt('all');
            document.getElementById('todayCount').innerText     = allAppointments.filter(a => a.date === today && a.status !== 'cancelled').length;

            document.getElementById('fc-all').innerText       = cnt('all');
            document.getElementById('fc-pending').innerText   = cnt('pending');
            document.getElementById('fc-confirmed').innerText = cnt('confirmed');
            const fcPrescribed = document.getElementById('fc-prescribed');
            if (fcPrescribed) fcPrescribed.innerText = cnt('prescribed');
            document.getElementById('fc-completed').innerText = cnt('completed');
            document.getElementById('fc-cancelled').innerText = cnt('cancelled');

            const p = cnt('pending');
            const badge = document.getElementById('sidebarPendingBadge');
            badge.style.display = p > 0 ? 'inline' : 'none';
            badge.innerText = p;
        }

        function filterTab(status) {
            currentFilter = status;
            document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
            document.getElementById('ftab-' + status).classList.add('active');
            renderAppointments();
        }

        function renderAppointments() {
            const list = currentFilter === 'all' ? allAppointments : allAppointments.filter(a => a.status === currentFilter);
            const tbody = document.getElementById('appointmentsBody');
            if (list.length === 0) {
                tbody.innerHTML = '<tr><td colspan="8" class="empty-state"><i class="fas fa-calendar-times me-1"></i>Không có lịch hẹn nào.</td></tr>';
                return;
            }
            tbody.innerHTML = list.map(a =>
                '<tr>' +
                '<td>' + a.appointmentId + '</td>' +
                '<td><strong>' + esc(a.patientName || 'BN #' + a.patientId) + '</strong></td>' +
                '<td>' + esc(a.date) + '</td>' +
                '<td><span style="background:#f1f5f9;padding:3px 10px;border-radius:6px;font-size:13px;">' + esc(a.time) + '</span></td>' +
                '<td>' + (a.symptoms ? '<div class="sym-preview" title="' + esc(a.symptoms) + '">' + esc(a.symptoms) + '</div>' : '<span style="color:#cbd5e1;">—</span>') + '</td>' +
                '<td>' + getBadge(a.status) + '</td>' +
                '<td>' + getPaymentBadge(a) + '</td>' +
                '<td>' + getActions(a) + '</td>' +
                '</tr>'
            ).join('');
        }

        function formatGender(g) {
            if (!g && g !== 0) return '—';
            const v = String(g).trim().toLowerCase();
            if (v === 'male' || v === 'nam') return 'Nam';
            if (v === 'female' || v === 'nu' || v === 'nữ') return 'Nữ';
            return 'Khác';
        }

        function getBadge(status) {
            const map = {
                pending:   '<span class="badge-pending"><i class="fas fa-hourglass-half"></i>Chờ xác nhận</span>',
                confirmed: '<span class="badge-confirmed"><i class="fas fa-check-circle"></i>Đã xác nhận</span>',
                prescribed:'<span class="badge-confirmed" style="background:#ede9fe;color:#6d28d9;"><i class="fas fa-pills"></i>Đã kê đơn</span>',
                completed: '<span class="badge-completed"><i class="fas fa-check-double"></i>Hoàn thành</span>',
                cancelled: '<span class="badge-cancelled"><i class="fas fa-times-circle"></i>Đã huỷ</span>'
            };
            return map[status] || '<span>' + status + '</span>';
        }

        function getPaymentBadge(a) {
            if (a.status !== 'completed') return '<span style="color:#94a3b8;">—</span>';
            const ps = a.paymentStatus || 'none';
            if (ps === 'paid') return '<span class="badge-completed"><i class="fas fa-money-bill"></i>Đã thanh toán</span>';
            if (ps === 'pending_admin') return '<span class="badge-pending">Chờ admin</span>';
            if (ps === 'unpaid') return '<span class="badge-cancelled" style="background:#fef3c7;color:#b45309;">Chưa TT</span>';
            return '<span style="color:#94a3b8;">Chưa lập HĐ</span>';
        }

        function getActions(a) {
            let html = '<button class="btn-sm btn-primary" onclick="viewDetail(' + a.appointmentId + ')" title="Xem chi tiết"><i class="fas fa-eye"></i></button> ';
            if (a.status === 'pending') {
                html += '<button class="btn-sm btn-success" onclick="updateStatus(' + a.appointmentId + ',\'confirmed\')"><i class="fas fa-check me-1"></i>Xác nhận</button> ';
                html += '<button class="btn-sm btn-danger"  onclick="updateStatus(' + a.appointmentId + ',\'cancelled\')"><i class="fas fa-times me-1"></i>Từ chối</button>';
            } else if (a.status === 'confirmed') {
                html += '<button class="btn-sm btn-warning" onclick="prescribe(' + a.appointmentId + ',\'' + esc(a.patientName || '') + '\')"><i class="fas fa-prescription-bottle me-1"></i>Kê đơn</button>';
            } else if (a.status === 'prescribed') {
                html += '<button class="btn-sm btn-purple" onclick="updateStatus(' + a.appointmentId + ',\'completed\')"><i class="fas fa-check-double me-1"></i>Hoàn thành</button>';
            }
            return html;
        }

        function viewDetail(id) {
            const a = allAppointments.find(x => x.appointmentId === id);
            if (!a) return;
            document.getElementById('appointmentModalBody').innerHTML =
                drow('Bệnh nhân',  esc(a.patientName || 'BN #' + a.patientId)) +
                drow('Ngày khám',  esc(a.date)) +
                drow('Giờ khám',   esc(a.time)) +
                drow('Trạng thái', getBadge(a.status)) +
                drow('Triệu chứng', esc(a.symptoms) || '—') +
                drow('Lý do khám', esc(a.reason)   || '—') +
                drow('Ghi chú',    esc(a.notes)    || '—') +
                (a.status === 'completed' ? drow('Thanh toán', getPaymentBadge(a)) : '');

            let footer = '<button class="btn-sm btn-danger" onclick="closeModal(\'appointmentModal\')">Đóng</button>';
            if (a.status === 'pending') {
                footer = '<button class="btn-sm btn-success" onclick="updateStatus(' + id + ',\'confirmed\');closeModal(\'appointmentModal\')"><i class="fas fa-check me-1"></i>Xác nhận</button> ' +
                         '<button class="btn-sm btn-danger"  onclick="updateStatus(' + id + ',\'cancelled\');closeModal(\'appointmentModal\')"><i class="fas fa-times me-1"></i>Từ chối</button>';
            } else if (a.status === 'confirmed') {
                footer = '<button class="btn-sm btn-warning" onclick="prescribe(' + id + ',\'' + esc(a.patientName || '') + '\');closeModal(\'appointmentModal\')"><i class="fas fa-prescription-bottle me-1"></i>Kê đơn</button>';
            } else if (a.status === 'prescribed') {
                footer = '<button class="btn-sm btn-purple" onclick="updateStatus(' + id + ',\'completed\');closeModal(\'appointmentModal\')"><i class="fas fa-check-double me-1"></i>Hoàn thành</button>';
            }
            document.getElementById('appointmentModalFooter').innerHTML = footer;
            document.getElementById('appointmentModal').classList.add('show');
        }

        function drow(label, value) {
            return '<div class="detail-row"><span class="detail-label">' + label + '</span><span class="detail-value">' + value + '</span></div>';
        }

        async function updateStatus(id, status) {
            const labels = { confirmed:'xác nhận', cancelled:'từ chối/huỷ', completed:'hoàn thành', prescribed:'kê đơn' };
            if (!confirm('Bạn có chắc muốn ' + labels[status] + ' lịch hẹn #' + id + '?')) return;
            try {
                const res = await fetch(contextPath + '/doctor/update-appointment', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: 'appointmentId=' + id + '&status=' + status
                });
                const data = await res.json();
                if (data.success) {
                    showToast('success', data.message || 'Cập nhật thành công!');
                    const a = allAppointments.find(x => x.appointmentId === id);
                    if (a) a.status = status;
                    updateCounts();
                    renderAppointments();
                } else {
                    showToast('error', data.message || 'Cập nhật thất bại!');
                }
            } catch (e) {
                showToast('error', 'Lỗi kết nối!');
            }
        }
        
        // ==================== KÊ ĐƠN THUỐC ====================
        function prescribe(appointmentId, patientName) {
            window.location.href = contextPath + '/jsp/doctor/prescribe_medicine.jsp?appointmentId=' + appointmentId + '&patientName=' + encodeURIComponent(patientName);
        }

        // ==================== ĐƠN THUỐC ====================
        async function loadPrescriptions() {
            try {
                const res = await fetch(contextPath + '/doctor/prescriptions');
                const data = await res.json();
                const tbody = document.querySelector('#prescriptionsTable tbody');
                if (data && data.length > 0) {
                    tbody.innerHTML = data.map(p => '<tr><td>' + p.prescriptionId + '</td><td>' + p.patientName + '</td><td>' + p.medicineName + '</td><td>' + p.dosage + '</td><td>' + p.quantity + '</td><td>' + p.createdAt + '</td></tr>').join('');
                } else {
                    tbody.innerHTML = '<tr><td colspan="6" class="empty-state">Chưa có đơn thuốc nào</td></tr>';
                }
            } catch(e) {
                document.querySelector('#prescriptionsTable tbody').innerHTML = '<tr><td colspan="6" class="empty-state">Chưa có đơn thuốc nào</td></tr>';
            }
        }

        // ==================== HỒ SƠ BỆNH NHÂN ====================
        async function loadAllPatients() {
            const tbody = document.querySelector('#patientsTable tbody');
            tbody.innerHTML = '<tr><td colspan="7" class="empty-state"><i class="fas fa-spinner fa-spin"></i> Đang tải dữ liệu bệnh nhân...</td></tr>';
            try {
                const res = await fetch(contextPath + '/doctor/patients');
                if (!res.ok) {
                    throw new Error('HTTP ' + res.status);
                }
                const patients = await res.json();
                if (!patients || patients.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="7" class="empty-state">Chưa có bệnh nhân nào trong hệ thống.</td></tr>';
                    return;
                }
                renderPatientTable(patients);
            } catch(e) {
                console.error('Lỗi tải danh sách bệnh nhân:', e);
                tbody.innerHTML = '<tr><td colspan="7" class="empty-state">Không thể tải dữ liệu bệnh nhân. Vui lòng thử lại.</td></tr>';
            }
        }

        function renderPatientTable(patients) {
            document.querySelector('#patientsTable tbody').innerHTML = patients.map(p =>
                '<tr><td>' + p.patientId + '</td><td>' + esc(p.fullname) + '</td><td>' + (p.dateOfBirth||'—') + '</td><td>' + formatGender(p.gender) + '</td><td>' + (p.phone||'—') + '</td><td>' + (p.address||'—') + '</td>' +
                '<td style="text-align:center;"><input type="checkbox" onchange="toggleHealthInsurance(' + p.patientId + ', this.checked)" ' + (p.healthInsurance && p.healthInsurance.trim().toLowerCase() === 'có' ? 'checked' : '') + '></td>' +
                '<td><button class="btn-sm btn-primary" onclick="viewPatientDetail(' + p.patientId + ')">Xem</button> <button class="btn-sm btn-info" onclick="editPatient(' + p.patientId + ')">Sửa</button> <button class="btn-sm btn-success" onclick="createMedicalRecord(' + p.patientId + ')">Tạo bệnh án</button></td></tr>'
            ).join('');
        }

        function searchPatient() {
            const kw = document.getElementById('searchPatientInput').value.toLowerCase();
            document.querySelectorAll('#patientsTable tbody tr').forEach(r => { r.style.display = r.innerText.toLowerCase().includes(kw) ? '' : 'none'; });
        }

        async function viewPatientDetail(patientId) {
            const modalBody = document.getElementById('patientModalBody');
            modalBody.innerHTML = '<p><strong>ID:</strong> ' + patientId + '</p><p style="color:#94a3b8;font-size:13px;"><i class="fas fa-spinner fa-spin"></i> Đang tải chi tiết...</p>';
            document.getElementById('patientModal').classList.add('show');
            try {
                const res = await fetch(contextPath + '/doctor/patient?patientId=' + patientId);
                if (!res.ok) {
                    throw new Error('HTTP ' + res.status);
                }
                const p = await res.json();
                modalBody.innerHTML =
                    '<p><strong>ID:</strong> ' + p.patientId + '</p>' +
                    '<p><strong>Họ và tên:</strong> ' + esc(p.fullname) + '</p>' +
                    '<p><strong>Ngày sinh:</strong> ' + (p.dateOfBirth || '—') + '</p>' +
                    '<p><strong>Giới tính:</strong> ' + formatGender(p.gender) + '</p>' +
                    '<p><strong>Điện thoại:</strong> ' + (p.phone || '—') + '</p>' +
                    '<p><strong>Địa chỉ:</strong> ' + (p.address || '—') + '</p>';
            } catch (e) {
                console.error('Lỗi tải chi tiết bệnh nhân:', e);
                modalBody.innerHTML = '<p><strong>ID:</strong> ' + patientId + '</p><p class="empty-state">Không thể tải chi tiết bệnh nhân.</p>';
            }
        }

        function editPatient(patientId) {
            // open edit modal and populate
            document.getElementById('editPatientMessageDoctor').innerHTML = '';
            document.getElementById('editPatientIdDoctor').value = patientId;
            document.getElementById('editPatientFullnameDoctor').value = '';
            document.getElementById('editPatientDateOfBirthDoctor').value = '';
            document.getElementById('editPatientGenderDoctor').value = '';
            document.getElementById('editPatientPhoneDoctor').value = '';
            document.getElementById('editPatientAddressDoctor').value = '';
            document.getElementById('editPatientHealthInsuranceDoctor').checked = false;
            document.getElementById('editPatientModalDoctor').classList.add('show');
            fetch(contextPath + '/doctor/patient?patientId=' + patientId).then(r => r.json()).then(p => {
                document.getElementById('editPatientFullnameDoctor').value = p.fullname || '';
                document.getElementById('editPatientDateOfBirthDoctor').value = p.dateOfBirth || '';
                document.getElementById('editPatientGenderDoctor').value = p.gender || '';
                document.getElementById('editPatientPhoneDoctor').value = p.phone || '';
                document.getElementById('editPatientAddressDoctor').value = p.address || '';
                document.getElementById('editPatientHealthInsuranceDoctor').checked = (p.healthInsurance && p.healthInsurance.trim().toLowerCase() === 'có');
            }).catch(e => { console.error(e); });
        }

        function closeEditPatientModalDoctor() {
            document.getElementById('editPatientModalDoctor').classList.remove('show');
        }

        async function savePatientDoctor() {
            const patientId = document.getElementById('editPatientIdDoctor').value;
            const fullname = document.getElementById('editPatientFullnameDoctor').value.trim();
            const dateOfBirth = document.getElementById('editPatientDateOfBirthDoctor').value.trim();
            const gender = document.getElementById('editPatientGenderDoctor').value;
            const phone = document.getElementById('editPatientPhoneDoctor').value.trim();
            const address = document.getElementById('editPatientAddressDoctor').value.trim();
            const has = document.getElementById('editPatientHealthInsuranceDoctor').checked ? 'Có' : 'Chưa';
            const body = new URLSearchParams();
            body.append('patientId', patientId);
            body.append('fullname', fullname);
            body.append('dateOfBirth', dateOfBirth);
            body.append('gender', gender);
            body.append('phone', phone);
            body.append('address', address);
            body.append('healthInsurance', has);
            try {
                const res = await fetch(contextPath + '/doctor/update-patient', { method: 'POST', body: body });
                const data = await res.json();
                if (data.success) {
                    showToast('success', data.message || 'Đã lưu');
                    closeEditPatientModalDoctor();
                    loadAllPatients();
                } else {
                    showToast('error', data.message || 'Lỗi');
                }
            } catch (e) {
                console.error(e);
                showToast('error', 'Lỗi kết nối');
            }
        }

        async function toggleHealthInsurance(patientId, checked) {
            const val = checked ? 'Có' : 'Chưa';
            const body = new URLSearchParams();
            body.append('patientId', patientId);
            body.append('healthInsurance', val);
            try {
                const res = await fetch(contextPath + '/doctor/update-patient', { method: 'POST', body: body });
                const data = await res.json();
                if (!data.success) showToast('error', data.message || 'Cập nhật thất bại');
            } catch (e) {
                console.error(e);
                showToast('error', 'Lỗi kết nối');
            }
        }

        // ==================== KHO THUỐC ====================
        async function loadMedicine() {
            document.querySelector('#medicineTable tbody').innerHTML = 
                '<tr><td colspan="7" class="empty-state"><i class="fas fa-spinner fa-spin"></i> Đang tải...</td></tr>';
            try {
                const res = await fetch(contextPath + '/doctor/medicines/');
                const medicines = await res.json();
                if (!medicines || medicines.length === 0) {
                    document.querySelector('#medicineTable tbody').innerHTML = 
                        '<tr><td colspan="7" class="empty-state">Chưa có thuốc nào</td></tr>';
                    return;
                }
                document.querySelector('#medicineTable tbody').innerHTML = medicines.map(m =>
                    '<tr>' +
                    '<td>' + m.medicineId + '</td>' +
                    '<td><strong>' + esc(m.medicineName) + '</strong></td>' +
                    '<td><span style="color:' + (m.stockQuantity < 100 ? '#dc2626' : '#10b981') + ';">' + m.stockQuantity + '</span></td>' +
                    '<td>' + esc(m.unit) + '</td>' +
                    '<td>' + Number(m.unitPrice).toLocaleString() + 'đ</td>' +
                    '<td>' + (m.expiryDate || '—') + '</td>' +
                    '<td>' +
                    '<button class="btn-sm btn-warning" onclick="editMedicine(' + m.medicineId + ')"><i class="fas fa-edit"></i> Sửa</button> ' +
                    '<button class="btn-sm btn-danger" onclick="deleteMedicine(' + m.medicineId + ')"><i class="fas fa-trash"></i> Xóa</button>' +
                    '</td></tr>'
                ).join('');
            } catch(e) {
                console.error(e);
                document.querySelector('#medicineTable tbody').innerHTML = 
                    '<tr><td colspan="7" class="empty-state">Lỗi tải dữ liệu</td></tr>';
            }
        }

        function editMedicine(id) {
            fetch(contextPath + '/doctor/medicines/' + id)
                .then(res => res.ok ? res.json() : Promise.reject(res))
                .then(m => {
                    editingMedicineId = id;
                    document.getElementById('medName').value = m.medicineName || '';
                    document.getElementById('medQuantity').value = m.stockQuantity || '';
                    document.getElementById('medUnit').value = m.unit || 'Viên';
                    document.getElementById('medPrice').value = m.unitPrice || '';
                    document.getElementById('medExpiry').value = m.expiryDate || '';
                    document.getElementById('medSupplier').value = m.supplier || '';
                    document.getElementById('medFormHeader').innerHTML = '<i class="fas fa-edit"></i> Cập nhật thuốc';
                    document.getElementById('medSubmitBtn').innerHTML = '<i class="fas fa-save"></i> Lưu thay đổi';
                    document.getElementById('medCancelBtn').style.display = 'block';
                })
                .catch(err => {
                    console.error('Lỗi lấy thông tin thuốc:', err);
                    showToast('error', 'Không thể tải thông tin thuốc để sửa.');
                });
        }

        async function deleteMedicine(id) {
            if (!confirm('Bạn có chắc muốn xóa thuốc này không?')) return;
            try {
                const res = await fetch(contextPath + '/doctor/medicines/' + id, {
                    method: 'DELETE'
                });
                const result = await res.json();
                if (!result.success) {
                    const message = result.message || 'Xóa thất bại';
                    if (/đơn thuốc|foreign key|parent row/i.test(message)) {
                        alert(message);
                    } else {
                        showToast('error', message);
                    }
                } else {
                    showToast('success', result.message || 'Xóa thành công');
                    loadMedicine();
                }
            } catch (error) {
                console.error('Lỗi xóa thuốc:', error);
                showToast('error', 'Không thể xóa thuốc.');
            }
        }

        function resetMedicineForm() {
            editingMedicineId = null;
            document.getElementById('addMedicineForm').reset();
            document.getElementById('medFormHeader').innerHTML = '<i class="fas fa-plus-circle"></i> Thêm thuốc mới';
            document.getElementById('medSubmitBtn').innerHTML = '<i class="fas fa-plus"></i> Thêm thuốc';
            document.getElementById('medCancelBtn').style.display = 'none';
        }

        function searchMedicine() {
            const kw = document.getElementById('searchMedicineInput').value.toLowerCase();
            document.querySelectorAll('#medicineTable tbody tr').forEach(r => { r.style.display = (r.cells[1]?.innerText||'').toLowerCase().includes(kw) ? '' : 'none'; });
        }

        document.getElementById('addMedicineForm')?.addEventListener('submit', async function(e) {
            e.preventDefault();

            // Lấy dữ liệu từ form
            const medicineName = document.getElementById('medName').value;
            const unit = document.getElementById('medUnit').value;
            const stockQuantity = document.getElementById('medQuantity').value;
            const unitPrice = document.getElementById('medPrice').value;
            const expiryDate = document.getElementById('medExpiry').value;
            const supplier = document.getElementById('medSupplier').value;

            const stockQuantityNum = Number(stockQuantity);
            const unitPriceNum = Number(unitPrice);
            const minExpiry = new Date();
            minExpiry.setDate(minExpiry.getDate() + 1);
            minExpiry.setHours(0,0,0,0);

            if (!medicineName || !unit || !stockQuantity || !unitPrice) {
                showToast('error', 'Vui lòng điền đầy đủ thông tin bắt buộc!');
                return;
            }
            if (!Number.isFinite(stockQuantityNum) || stockQuantityNum <= 0) {
                showToast('error', 'Số lượng tồn phải là số lớn hơn 0');
                return;
            }
            if (!Number.isFinite(unitPriceNum) || unitPriceNum <= 0) {
                showToast('error', 'Đơn giá phải là số lớn hơn 0');
                return;
            }
            if (expiryDate) {
                const selectedExpiry = new Date(expiryDate);
                selectedExpiry.setHours(0,0,0,0);
                if (selectedExpiry < minExpiry) {
                    showToast('error', 'Hạn sử dụng phải từ ngày mai trở đi');
                    return;
                }
            }

            // Tạo form data
            const formData = new URLSearchParams();
            formData.append('medicineName', medicineName);
            formData.append('unit', unit);
            formData.append('stockQuantity', stockQuantityNum);
            formData.append('unitPrice', unitPriceNum);
            formData.append('expiryDate', expiryDate || '');
            formData.append('supplier', supplier || '');

            try {
                const method = editingMedicineId ? 'PUT' : 'POST';
            const url = contextPath + '/doctor/medicines' + (editingMedicineId ? '/' + editingMedicineId : '');
            const response = await fetch(url, {
                    method,
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: formData
                });

                const result = await response.json();
                showToast(result.success ? 'success' : 'error', result.message);

                if (result.success) {
                    // Reset form
                    resetMedicineForm();
                    // Tải lại danh sách thuốc
                    loadMedicine();
                }
            } catch (error) {
                console.error('Lỗi thêm thuốc:', error);
                showToast('error', 'Lỗi kết nối đến máy chủ!');
            }
        });


        // ==================== HỒ SƠ BỆNH ÁN ====================
        let medicalRecordsCache = [];

        async function loadPatientSelect() {
            const sel = document.getElementById('recordPatientId');
            sel.innerHTML = '<option value="">-- Chọn bệnh nhân --</option>';
            try {
                const res = await fetch(contextPath + '/doctor/patients');
                if (!res.ok) {
                    throw new Error('HTTP ' + res.status);
                }
                const patients = await res.json();
                patients.forEach(p => {
                    sel.innerHTML += '<option value="' + p.patientId + '">' + esc(p.fullname) + '</option>';
                });
            } catch (e) {
                console.error('Lỗi tải danh sách bệnh nhân cho hồ sơ bệnh án:', e);
                sel.innerHTML += '<option value="">Không thể tải bệnh nhân</option>';
            }
        }

        async function loadMedicalRecords(search = '') {
            const tbody = document.querySelector('#medicalRecordsTable tbody');
            tbody.innerHTML = '<tr><td colspan="7" class="empty-state"><i class="fas fa-spinner fa-spin me-1"></i> Đang tải dữ liệu...</td></tr>';
            try {
                const url = contextPath + '/doctor/medical-records' + (search ? '?search=' + encodeURIComponent(search) : '');
                const res = await fetch(url);
                const data = await res.json();
                medicalRecordsCache = Array.isArray(data) ? data : [];
                if (!medicalRecordsCache.length) {
                    tbody.innerHTML = '<tr><td colspan="7" class="empty-state">Chưa có hồ sơ bệnh án để hiển thị.</td></tr>';
                    return;
                }
                tbody.innerHTML = medicalRecordsCache.map(r =>
                    '<tr>' +
                    '<td>' + r.id + '</td>' +
                    '<td>' + esc(r.patientName) + '</td>' +
                    '<td>' + esc(r.examinationDate) + '</td>' +
                    '<td>' + esc(r.diagnosis) + '</td>' +
                    '<td>' + esc(r.treatmentMethod) + '</td>' +
                    '<td>' + esc(r.doctorName) + '</td>' +
                    '<td><button class="btn-sm btn-primary" onclick="viewMedicalRecord(' + r.id + ')"><i class="fas fa-eye"></i> Xem</button></td>' +
                    '</tr>'
                ).join('');
            } catch (e) {
                console.error('Lỗi tải hồ sơ bệnh án:', e);
                tbody.innerHTML = '<tr><td colspan="7" class="empty-state">Không thể tải dữ liệu. Vui lòng thử lại.</td></tr>';
            }
        }

        function searchMedicalRecord() {
            const kw = document.getElementById('searchMedicalRecordInput').value.trim();
            loadMedicalRecords(kw);
        }

        function createMedicalRecord(patientId) {
            showSection('medicalRecords', null);
            setTimeout(() => {
                document.getElementById('recordPatientId').value = patientId;
            }, 250);
        }

        function viewMedicalRecord(id) {
            const record = medicalRecordsCache.find(r => r.id === id || r.id == id);
            if (!record) {
                showToast('error', 'Không tìm thấy chi tiết hồ sơ.');
                return;
            }
            document.getElementById('medicalRecordModalBody').innerHTML =
                '<div class="detail-row"><span class="detail-label">Mã bệnh án:</span><span class="detail-value">' + record.id + '</span></div>' +
                '<div class="detail-row"><span class="detail-label">Bệnh nhân:</span><span class="detail-value">' + esc(record.patientName) + '</span></div>' +
                '<div class="detail-row"><span class="detail-label">Bác sĩ:</span><span class="detail-value">' + esc(record.doctorName) + '</span></div>' +
                '<div class="detail-row"><span class="detail-label">Ngày khám:</span><span class="detail-value">' + esc(record.examinationDate) + '</span></div>' +
                '<div class="detail-row"><span class="detail-label">Chẩn đoán:</span><span class="detail-value">' + esc(record.diagnosis) + '</span></div>' +
                '<div class="detail-row"><span class="detail-label">Triệu chứng:</span><span class="detail-value">' + esc(record.symptoms) + '</span></div>' +
                '<div class="detail-row"><span class="detail-label">Kết quả xét nghiệm:</span><span class="detail-value">' + esc(record.testResults) + '</span></div>' +
                '<div class="detail-row"><span class="detail-label">Phương pháp điều trị:</span><span class="detail-value">' + esc(record.treatmentMethod) + '</span></div>' +
                '<div class="detail-row"><span class="detail-label">Ghi chú:</span><span class="detail-value">' + esc(record.notes) + '</span></div>';
            document.getElementById('medicalRecordModal').classList.add('show');
        }

        document.getElementById('medicalRecordForm')?.addEventListener('submit', async function(e) {
            e.preventDefault();
            const patientId = this.recordPatientId.value;
            const examinationDate = this.recordDate.value;
            const diagnosis = this.recordDiagnosis.value;
            if (!patientId || !examinationDate || !diagnosis) {
                showToast('error', 'Vui lòng nhập đầy đủ thông tin bắt buộc!');
                return;
            }
            const payload = new URLSearchParams();
            payload.append('patientId', patientId);
            payload.append('examinationDate', examinationDate);
            payload.append('diagnosis', diagnosis);
            payload.append('symptoms', this.recordSymptoms.value || '');
            payload.append('testResults', this.recordTestResults.value || '');
            payload.append('treatmentMethod', this.recordTreatment.value || '');
            payload.append('notes', this.recordNotes.value || '');
            try {
                const res = await fetch(contextPath + '/doctor/medical-records', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: payload.toString()
                });
                const result = await res.json();
                if (result.success) {
                    showToast('success', result.message || 'Lưu hồ sơ thành công!');
                    this.reset();
                    loadMedicalRecords();
                } else {
                    showToast('error', result.message || 'Lưu hồ sơ thất bại.');
                }
            } catch (error) {
                console.error('Lỗi lưu hồ sơ bệnh án:', error);
                showToast('error', 'Lỗi kết nối đến máy chủ.');
            }
        });

        function exportMedicalRecordsToExcel() {
            if (!medicalRecordsCache || medicalRecordsCache.length === 0) {
                showToast('error', 'Không có hồ sơ bệnh án để xuất.');
                return;
            }
            const header = ['ID', 'Bệnh nhân', 'Ngày khám', 'Chẩn đoán', 'Triệu chứng', 'Kết quả xét nghiệm', 'Phương pháp điều trị', 'Ghi chú', 'Bác sĩ', 'Ngày tạo'];
            const rows = medicalRecordsCache.map((r, index) => ({
                cells: [
                    r.id,
                    r.patientName,
                    r.examinationDate,
                    r.diagnosis,
                    r.symptoms,
                    r.testResults,
                    r.treatmentMethod,
                    r.notes,
                    r.doctorName,
                    r.createdAt || ''
                ],
                odd: index % 2 === 1
            }));
            const headerHtml = '<tr style="background:#2d3748;color:#fff;font-weight:bold;text-align:center;">' + header.map(col => '<th style="padding:10px 8px;border:1px solid #94a3b8;">' + col + '</th>').join('') + '</tr>';
            const rowsHtml = rows.map(row => '<tr style="background:' + (row.odd ? '#e2e8f0' : '#ffffff') + ';">' + row.cells.map(cell => '<td style="padding:8px 10px;border:1px solid #94a3b8;">' + String(cell || '').replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;') + '</td>').join('') + '</tr>').join('');
            const html = '<html><head><meta charset="UTF-8"></head><body><table style="border-collapse:collapse;font-family:Arial,Helvetica,sans-serif;">' + headerHtml + rowsHtml + '</table></body></html>';
            const bom = '\uFEFF';
            const blob = new Blob([bom + html], { type: 'application/vnd.ms-excel;charset=utf-8' });
            const url = URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'medical_records_' + new Date().toISOString().slice(0,10) + '.xls';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }

        // ==================== UTILS ====================
        function closeModal(id) { document.getElementById(id).classList.remove('show'); }
        function logout() { window.location.href = contextPath + '/logout'; }
        function esc(s) { if (!s) return ''; return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }

        function showToast(type, msg) {
            const t = document.getElementById('toastEl');
            document.getElementById('toastText').innerText = msg;
            t.className = 'toast-msg show toast-' + type;
            document.getElementById('toastIcon').className = type === 'success' ? 'fas fa-check-circle' : 'fas fa-times-circle';
            setTimeout(() => t.classList.remove('show'), 3000);
        }

        window.onclick = function(e) {
            ['appointmentModal','patientModal','medicalRecordModal'].forEach(id => {
                if (e.target === document.getElementById(id)) closeModal(id);
            });
        };

        // Init
        loadAppointments();
    </script>
</body>
</html>