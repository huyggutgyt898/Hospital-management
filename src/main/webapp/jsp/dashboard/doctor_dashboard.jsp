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
                        <div class="filter-tab"        id="ftab-completed" onclick="filterTab('completed')">✔ Hoàn thành <span class="tab-count" id="fc-completed">0</span></div>
                        <div class="filter-tab"        id="ftab-cancelled" onclick="filterTab('cancelled')">✖ Đã huỷ <span class="tab-count" id="fc-cancelled">0</span></div>
                    </div>

                    <table>
                        <thead>
                            <tr><th>#</th><th>Bệnh nhân</th><th>Ngày khám</th><th>Giờ</th><th>Triệu chứng</th><th>Trạng thái</th><th>Thao tác</th></tr>
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
                        <thead><tr><th>ID</th><th>Họ tên</th><th>Ngày sinh</th><th>Giới tính</th><th>SĐT</th><th>Địa chỉ</th><th>Thao tác</th></tr></thead>
                        <tbody></tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- ========== KHO THUỐC ========== -->
        <div id="medicineStockSection" style="display:none;">
            <div class="card">
                <div class="card-header"><i class="fas fa-plus-circle"></i> Thêm thuốc mới</div>
                <div class="card-body">
                    <form id="addMedicineForm" class="form-grid">
                        <div class="form-group"><label>Tên thuốc *</label><input type="text" id="medName" class="form-control" required></div>
                        <div class="form-group"><label>Số lượng tồn *</label><input type="number" id="medQuantity" class="form-control" required></div>
                        <div class="form-group"><label>Đơn vị</label><select id="medUnit" class="form-control"><option>Viên</option><option>Ống</option><option>Chai</option><option>Gói</option><option>Lọ</option></select></div>
                        <div class="form-group"><label>Đơn giá *</label><input type="number" id="medPrice" class="form-control" required></div>
                        <div class="form-group"><label>Hạn sử dụng</label><input type="date" id="medExpiry" class="form-control"></div>
                        <div class="form-group"><label>Nhà cung cấp</label><input type="text" id="medSupplier" class="form-control"></div>
                        <div class="form-group"><label style="visibility:hidden;">x</label><button type="submit" class="btn-success btn-sm" style="width:100%;padding:10px;"><i class="fas fa-plus"></i> Thêm thuốc</button></div>
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
                <div class="card-header"><i class="fas fa-history"></i> Lịch sử khám bệnh</div>
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
                tbody.innerHTML = '<tr><td colspan="7" class="empty-state"><i class="fas fa-calendar-times me-1"></i>Không có lịch hẹn nào.</td></tr>';
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
                '<td>' + getActions(a) + '</td>' +
                '</tr>'
            ).join('');
        }

        function getBadge(status) {
            const map = {
                pending:   '<span class="badge-pending"><i class="fas fa-hourglass-half"></i>Chờ xác nhận</span>',
                confirmed: '<span class="badge-confirmed"><i class="fas fa-check-circle"></i>Đã xác nhận</span>',
                completed: '<span class="badge-completed"><i class="fas fa-check-double"></i>Hoàn thành</span>',
                cancelled: '<span class="badge-cancelled"><i class="fas fa-times-circle"></i>Đã huỷ</span>'
            };
            return map[status] || '<span>' + status + '</span>';
        }

        function getActions(a) {
            let html = '<button class="btn-sm btn-primary" onclick="viewDetail(' + a.appointmentId + ')"><i class="fas fa-eye"></i></button> ';
            if (a.status === 'pending') {
                html += '<button class="btn-sm btn-success" onclick="updateStatus(' + a.appointmentId + ',\'confirmed\')"><i class="fas fa-check me-1"></i>Xác nhận</button> ';
                html += '<button class="btn-sm btn-danger"  onclick="updateStatus(' + a.appointmentId + ',\'cancelled\')"><i class="fas fa-times me-1"></i>Từ chối</button>';
            } else if (a.status === 'confirmed') {
                html += '<button class="btn-sm btn-purple" onclick="updateStatus(' + a.appointmentId + ',\'completed\')"><i class="fas fa-check-double me-1"></i>Hoàn thành</button> ';
                html += '<button class="btn-sm btn-danger"  onclick="updateStatus(' + a.appointmentId + ',\'cancelled\')"><i class="fas fa-times me-1"></i>Huỷ</button>';
            } else if (a.status === 'completed') {
                html += '<button class="btn-sm btn-warning" onclick="prescribe(' + a.appointmentId + ',\'' + esc(a.patientName || '') + '\')"><i class="fas fa-prescription-bottle me-1"></i>Kê đơn</button>';
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
                drow('Ghi chú',    esc(a.notes)    || '—');

            let footer = '<button class="btn-sm btn-danger" onclick="closeModal(\'appointmentModal\')">Đóng</button>';
            if (a.status === 'pending') {
                footer = '<button class="btn-sm btn-success" onclick="updateStatus(' + id + ',\'confirmed\');closeModal(\'appointmentModal\')"><i class="fas fa-check me-1"></i>Xác nhận</button> ' +
                         '<button class="btn-sm btn-danger"  onclick="updateStatus(' + id + ',\'cancelled\');closeModal(\'appointmentModal\')"><i class="fas fa-times me-1"></i>Từ chối</button>';
            } else if (a.status === 'confirmed') {
                footer = '<button class="btn-sm btn-purple" onclick="updateStatus(' + id + ',\'completed\');closeModal(\'appointmentModal\')"><i class="fas fa-check-double me-1"></i>Hoàn thành</button> ' +
                         '<button class="btn-sm btn-danger" onclick="updateStatus(' + id + ',\'cancelled\');closeModal(\'appointmentModal\')"><i class="fas fa-times me-1"></i>Huỷ</button>';
            }
            document.getElementById('appointmentModalFooter').innerHTML = footer;
            document.getElementById('appointmentModal').classList.add('show');
        }

        function drow(label, value) {
            return '<div class="detail-row"><span class="detail-label">' + label + '</span><span class="detail-value">' + value + '</span></div>';
        }

        async function updateStatus(id, status) {
            const labels = { confirmed:'xác nhận', cancelled:'từ chối/huỷ', completed:'hoàn thành' };
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
            try {
                const res = await fetch(contextPath + '/doctor/patients');
                renderPatientTable(await res.json());
            } catch(e) {
                renderPatientTable([
                    { patientId:1, fullname:'Nguyễn Văn A', dateOfBirth:'1990-05-15', gender:'Nam', phone:'0912345678', address:'Hà Nội' },
                    { patientId:2, fullname:'Trần Thị B',   dateOfBirth:'1985-10-20', gender:'Nữ', phone:'0987654321', address:'TP.HCM' }
                ]);
            }
        }

        function renderPatientTable(patients) {
            document.querySelector('#patientsTable tbody').innerHTML = patients.map(p =>
                '<tr><td>' + p.patientId + '</td><td>' + p.fullname + '</td><td>' + (p.dateOfBirth||'—') + '</td><td>' + (p.gender||'—') + '</td><td>' + (p.phone||'—') + '</td><td>' + (p.address||'—') + '</td>' +
                '<td><button class="btn-sm btn-primary" onclick="viewPatientDetail(' + p.patientId + ')">Xem</button> <button class="btn-sm btn-success" onclick="createMedicalRecord(' + p.patientId + ')">Tạo bệnh án</button></td></tr>'
            ).join('');
        }

        function searchPatient() {
            const kw = document.getElementById('searchPatientInput').value.toLowerCase();
            document.querySelectorAll('#patientsTable tbody tr').forEach(r => { r.style.display = r.innerText.toLowerCase().includes(kw) ? '' : 'none'; });
        }

        function viewPatientDetail(patientId) {
            document.getElementById('patientModalBody').innerHTML = '<p><strong>ID:</strong> ' + patientId + '</p><p style="color:#94a3b8;font-size:13px;">Kết nối API để lấy chi tiết.</p>';
            document.getElementById('patientModal').classList.add('show');
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

            // Kiểm tra dữ liệu bắt buộc
            if (!medicineName || !unit || !stockQuantity || !unitPrice) {
                showToast('error', 'Vui lòng điền đầy đủ thông tin bắt buộc!');
                return;
            }

            // Tạo form data
            const formData = new URLSearchParams();
            formData.append('medicineName', medicineName);
            formData.append('unit', unit);
            formData.append('stockQuantity', stockQuantity);
            formData.append('unitPrice', unitPrice);
            formData.append('expiryDate', expiryDate || '');
            formData.append('supplier', supplier || '');

            try {
                const response = await fetch(contextPath + '/doctor/medicines', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: formData
                });

                const result = await response.json();
                showToast(result.success ? 'success' : 'error', result.message);

                if (result.success) {
                    // Reset form
                    e.target.reset();
                    // Tải lại danh sách thuốc
                    loadMedicine();
                }
            } catch (error) {
                console.error('Lỗi thêm thuốc:', error);
                showToast('error', 'Lỗi kết nối đến máy chủ!');
            }
        });


        // ==================== HỒ SƠ BỆNH ÁN ====================
        async function loadPatientSelect() {
            const sel = document.getElementById('recordPatientId');
            sel.innerHTML = '<option value="">-- Chọn bệnh nhân --</option>';
            try {
                const res = await fetch(contextPath + '/doctor/patients');
                (await res.json()).forEach(p => { sel.innerHTML += '<option value="' + p.patientId + '">' + p.fullname + '</option>'; });
            } catch(e) {
                sel.innerHTML += '<option value="1">Nguyễn Văn A</option><option value="2">Trần Thị B</option>';
            }
        }

        function loadMedicalRecords() {
            document.querySelector('#medicalRecordsTable tbody').innerHTML =
                '<tr><td>1</td><td>Nguyễn Văn A</td><td>01/05/2024</td><td>Cảm cúm</td><td>Nghỉ ngơi, uống thuốc</td><td>BS. Nguyễn</td><td><button class="btn-sm btn-primary" onclick="viewMedicalRecord(1)">Chi tiết</button></td></tr>' +
                '<tr><td>2</td><td>Trần Thị B</td><td>05/05/2024</td><td>Đau dạ dày</td><td>Uống thuốc, kiêng ăn</td><td>BS. Nguyễn</td><td><button class="btn-sm btn-primary" onclick="viewMedicalRecord(2)">Chi tiết</button></td></tr>';
        }

        function searchMedicalRecord() {
            const kw = document.getElementById('searchMedicalRecordInput').value.toLowerCase();
            document.querySelectorAll('#medicalRecordsTable tbody tr').forEach(r => { r.style.display = r.innerText.toLowerCase().includes(kw) ? '' : 'none'; });
        }

        function createMedicalRecord(patientId) {
            showSection('medicalRecords', null);
            setTimeout(() => { document.getElementById('recordPatientId').value = patientId; }, 300);
        }

        function viewMedicalRecord(id) {
            document.getElementById('medicalRecordModalBody').innerHTML =
                '<p><strong>Mã bệnh án:</strong> ' + id + '</p><p><strong>Bệnh nhân:</strong> Nguyễn Văn A</p>' +
                '<p><strong>Ngày khám:</strong> 01/05/2024</p><p><strong>Chẩn đoán:</strong> Cảm cúm</p>' +
                '<p><strong>Triệu chứng:</strong> Sốt, ho, đau họng</p><p><strong>Điều trị:</strong> Nghỉ ngơi, Paracetamol</p>';
            document.getElementById('medicalRecordModal').classList.add('show');
        }

        document.getElementById('medicalRecordForm')?.addEventListener('submit', function(e) {
            e.preventDefault();
            if (!this.recordPatientId.value || !this.recordDate.value || !this.recordDiagnosis.value) { alert('Vui lòng nhập đầy đủ thông tin bắt buộc!'); return; }
            alert('Đã tạo hồ sơ bệnh án thành công!');
            this.reset();
            loadMedicalRecords();
        });

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