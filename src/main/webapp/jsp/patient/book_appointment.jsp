<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hospital.model.Account" %>
<%@ page import="com.hospital.dao.PatientDAO" %>
<%@ include file="/jsp/common/patient_prefs.jsp" %>
<%
    Account account = (Account) session.getAttribute("account");
    if (account == null || !"patient".equalsIgnoreCase(account.getRole())) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }

    Integer patientId = (Integer) session.getAttribute("patientId");
    if (patientId == null) {
        try {
            PatientDAO patientDAO = new PatientDAO();
            int pid = patientDAO.getPatientIdByAccountId(account.getAccountID());
            if (pid > 0) {
                patientId = pid;
                session.setAttribute("patientId", patientId);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="<%= patientIsEn ? "en" : "vi" %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= patientIsEn ? "Book appointment - HMS" : "Đặt lịch hẹn - HMS" %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <%@ include file="/jsp/common/patient_head.jsp" %>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container-custom { max-width: 900px; margin: 0 auto; }

        /* Navbar top */
        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            color: white;
        }
        .top-bar a { color: white; text-decoration: none; font-size: 14px; }
        .top-bar a:hover { opacity: 0.8; }

        /* Card */
        .main-card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15);
            overflow: hidden;
        }
        .card-header-custom {
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            color: white;
            padding: 22px 28px;
            font-size: 18px;
            font-weight: 700;
        }
        .card-body-custom { padding: 28px; }

        /* Progress steps */
        .steps-wrapper {
            display: flex;
            align-items: center;
            margin-bottom: 32px;
            position: relative;
        }
        .step-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            flex: 1;
            position: relative;
            z-index: 1;
        }
        .step-circle {
            width: 42px; height: 42px;
            border-radius: 50%;
            background: #e2e8f0;
            color: #94a3b8;
            font-weight: 700;
            font-size: 15px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
            border: 3px solid #e2e8f0;
        }
        .step-label {
            font-size: 11px;
            margin-top: 6px;
            color: #94a3b8;
            font-weight: 500;
            text-align: center;
        }
        .step-item.active .step-circle {
            background: #2563eb;
            color: white;
            border-color: #2563eb;
            box-shadow: 0 0 0 4px rgba(37,99,235,0.2);
        }
        .step-item.active .step-label { color: #2563eb; font-weight: 600; }
        .step-item.done .step-circle {
            background: #10b981;
            color: white;
            border-color: #10b981;
        }
        .step-item.done .step-label { color: #10b981; }
        .step-connector {
            flex: 1;
            height: 3px;
            background: #e2e8f0;
            margin-bottom: 22px;
            transition: background 0.3s;
            z-index: 0;
        }
        .step-connector.done { background: #10b981; }

        /* Step content */
        .step-content { display: none; animation: fadeUp 0.3s ease; }
        .step-content.active { display: block; }
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(12px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* Doctor cards */
        .doctor-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 14px; }
        @media(max-width: 576px) { .doctor-grid { grid-template-columns: 1fr; } }

        .doctor-card {
            border: 2px solid #e2e8f0;
            border-radius: 14px;
            padding: 16px;
            cursor: pointer;
            transition: all 0.25s;
            background: #fff;
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .doctor-card:hover {
            border-color: #2563eb;
            box-shadow: 0 6px 20px rgba(37,99,235,0.12);
            transform: translateY(-2px);
        }
        .doctor-card.selected {
            border-color: #2563eb;
            background: #eff6ff;
        }
        .doctor-avatar {
            width: 52px; height: 52px;
            background: linear-gradient(135deg, #dbeafe, #bfdbfe);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .doctor-avatar i { color: #2563eb; font-size: 22px; }
        .doctor-info h6 { font-size: 14px; font-weight: 700; margin-bottom: 3px; color: #1e293b; }
        .doctor-info p { font-size: 12px; color: #64748b; margin-bottom: 2px; }

        /* Time slots */
        .time-grid {
            display: flex; flex-wrap: wrap; gap: 10px; margin-top: 10px;
        }
        .time-slot {
            padding: 8px 18px;
            border: 2px solid #e2e8f0;
            border-radius: 50px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            color: #475569;
            background: white;
            transition: all 0.2s;
        }
        .time-slot:hover { border-color: #2563eb; color: #2563eb; background: #eff6ff; }
        .time-slot.selected { background: #2563eb; color: white; border-color: #2563eb; }
        .time-slot.booked {
            background: #f1f5f9; color: #cbd5e1;
            border-color: #e2e8f0; cursor: not-allowed;
            text-decoration: line-through;
        }

        /* Form */
        .form-label { font-weight: 600; font-size: 14px; color: #374151; margin-bottom: 6px; }
        .form-control, .form-select {
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            padding: 10px 14px;
            font-size: 14px;
            transition: border-color 0.2s;
        }
        .form-control:focus, .form-select:focus {
            border-color: #2563eb;
            box-shadow: 0 0 0 3px rgba(37,99,235,0.1);
            outline: none;
        }

        /* Summary */
        .summary-box {
            background: #f8fafc;
            border-radius: 14px;
            border: 1px solid #e2e8f0;
            padding: 20px;
        }
        .summary-row {
            display: flex;
            padding: 10px 0;
            border-bottom: 1px solid #f1f5f9;
            font-size: 14px;
        }
        .summary-row:last-child { border-bottom: none; }
        .summary-label { color: #64748b; font-weight: 600; width: 150px; flex-shrink: 0; }
        .summary-value { color: #1e293b; font-weight: 500; }

        .status-badge {
            display: inline-flex; align-items: center; gap: 6px;
            background: #fef3c7; color: #d97706;
            border-radius: 50px; padding: 6px 14px;
            font-size: 13px; font-weight: 600;
            margin-top: 12px;
        }

        /* Buttons */
        .btn-next {
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            color: white; border: none;
            padding: 11px 28px; border-radius: 10px;
            font-weight: 600; font-size: 14px;
            cursor: pointer; transition: all 0.2s;
        }
        .btn-next:hover { transform: translateY(-1px); box-shadow: 0 6px 16px rgba(37,99,235,0.35); }
        .btn-next:disabled { background: #94a3b8; cursor: not-allowed; transform: none; box-shadow: none; }
        .btn-back {
            background: #f1f5f9; color: #475569; border: none;
            padding: 11px 24px; border-radius: 10px;
            font-weight: 600; font-size: 14px; cursor: pointer;
            transition: background 0.2s;
        }
        .btn-back:hover { background: #e2e8f0; }
        .btn-confirm {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white; border: none;
            padding: 11px 28px; border-radius: 10px;
            font-weight: 600; font-size: 14px;
            cursor: pointer; transition: all 0.2s;
        }
        .btn-confirm:hover { transform: translateY(-1px); box-shadow: 0 6px 16px rgba(16,185,129,0.35); }

        /* Alert */
        .alert-info-custom {
            background: #eff6ff; border: 1px solid #bfdbfe;
            border-radius: 10px; padding: 14px 16px;
            font-size: 13px; color: #1d4ed8;
            display: flex; align-items: flex-start; gap: 10px;
            margin-bottom: 18px;
        }

        /* Loading */
        .loading-doctors {
            text-align: center; padding: 40px;
            color: #94a3b8; font-size: 14px;
        }
        .spinner {
            border: 3px solid #e2e8f0;
            border-top-color: #2563eb;
            border-radius: 50%;
            width: 32px; height: 32px;
            animation: spin 0.8s linear infinite;
            margin: 0 auto 12px;
        }
        @keyframes spin { to { transform: rotate(360deg); } }

        /* Success modal overlay */
        .success-overlay {
            display: none;
            position: fixed; inset: 0;
            background: rgba(0,0,0,0.5);
            z-index: 9999;
            align-items: center; justify-content: center;
        }
        .success-overlay.show { display: flex; }
        .success-box {
            background: white;
            border-radius: 20px;
            padding: 40px;
            max-width: 420px;
            width: 90%;
            text-align: center;
            animation: popIn 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        @keyframes popIn {
            from { transform: scale(0.7); opacity: 0; }
            to   { transform: scale(1); opacity: 1; }
        }
        .success-icon {
            width: 72px; height: 72px;
            background: linear-gradient(135deg, #d1fae5, #a7f3d0);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            margin: 0 auto 20px;
        }
        .success-icon i { color: #10b981; font-size: 32px; }
        
        .filter-section {
            background: #f8fafc;
            padding: 15px;
            border-radius: 12px;
            margin-bottom: 20px;
            border: 1px solid #e2e8f0;
        }
        
    </style>
</head>
<body class="<%= patientIsDark ? "patient-dark" : "" %>">
<div class="container-custom">

    <!-- Top bar -->
    <div class="top-bar">
        <a href="${pageContext.request.contextPath}/index.jsp">
            <i class="fas fa-arrow-left me-2"></i><%= pt(patientIsEn, "Quay lại trang chủ", "Back to home") %>
        </a>
        <div style="display:flex; align-items:center; gap:16px;">
            <span><i class="fas fa-user-circle me-1"></i><%= account.getFullname() %></span>
            <a href="${pageContext.request.contextPath}/logout">
                <i class="fas fa-sign-out-alt me-1"></i><%= pt(patientIsEn, "Đăng xuất", "Logout") %>
            </a>
        </div>
    </div>

    <!-- Main card -->
    <div class="main-card">
        <div class="card-header-custom">
            <i class="fas fa-calendar-plus me-2"></i><%= pt(patientIsEn, "ĐẶT LỊCH HẸN KHÁM BỆNH", "BOOK MEDICAL APPOINTMENT") %>
        </div>
        <div class="card-body-custom">

            <!-- Progress Steps -->
            <div class="steps-wrapper">
                <div class="step-item active" id="ind1">
                    <div class="step-circle">1</div>
                    <div class="step-label"><%= pt(patientIsEn, "Chọn bác sĩ", "Choose doctor") %></div>
                </div>
                <div class="step-connector" id="conn1"></div>
                <div class="step-item" id="ind2">
                    <div class="step-circle">2</div>
                    <div class="step-label"><%= pt(patientIsEn, "Ngày & Giờ", "Date & time") %></div>
                </div>
                <div class="step-connector" id="conn2"></div>
                <div class="step-item" id="ind3">
                    <div class="step-circle">3</div>
                    <div class="step-label"><%= pt(patientIsEn, "Triệu chứng", "Symptoms") %></div>
                </div>
                <div class="step-connector" id="conn3"></div>
                <div class="step-item" id="ind4">
                    <div class="step-circle">4</div>
                    <div class="step-label"><%= pt(patientIsEn, "Xác nhận", "Confirm") %></div>
                </div>
            </div>

            <!-- ========== STEP 1: Chọn bác sĩ ========== -->
            <div class="step-content active" id="step1">
                <h5 class="mb-1" style="font-weight:700; color:#1e293b;">
                    <i class="fas fa-user-md me-2" style="color:#2563eb;"></i><%= pt(patientIsEn, "Chọn bác sĩ khám bệnh", "Choose your doctor") %>
                </h5>
                <p class="text-muted mb-4" style="font-size:13px;"><%= pt(patientIsEn, "Chọn bác sĩ phù hợp với tình trạng của bạn", "Select a doctor that fits your needs") %></p>
                
                <!-- Bộ lọc bác sĩ -->
                <div class="filter-section" style="background: #f8fafc; padding: 15px; border-radius: 12px; margin-bottom: 20px;">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label" style="font-size: 13px;">Chuyên khoa</label>
                            <select id="filterSpecialty" class="form-select" style="font-size: 13px;">
                                <option value="">Tất cả chuyên khoa</option>
                                <option value="Tim mạch">Tim mạch</option>
                                <option value="Nhi khoa">Nhi khoa</option>
                                <option value="Nội tổng quát">Nội tổng quát</option>
                                <option value="Chỉnh hình">Chỉnh hình</option>
                                <option value="Da liễu">Da liễu</option>
                                <option value="Sản phụ khoa">Sản phụ khoa</option>
                                <option value="Hô hấp">Hô hấp</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label" style="font-size: 13px;">Số năm kinh nghiệm</label>
                            <select id="filterExperience" class="form-select" style="font-size: 13px;">
                                <option value="0">Tất cả</option>
                                <option value="5">Trên 5 năm</option>
                                <option value="10">Trên 10 năm</option>
                                <option value="15">Trên 15 năm</option>
                            </select>
                        </div>
                    </div>
                    <div class="mt-2 text-end">
                        <button class="btn-sm btn-primary" onclick="filterDoctors()" style="background: #2563eb; color: white; border: none; padding: 5px 15px; border-radius: 20px;">Lọc</button>
                        <button class="btn-sm btn-secondary" onclick="resetFilter()" style="background: #94a3b8; color: white; border: none; padding: 5px 15px; border-radius: 20px;">Xóa lọc</button>
                    </div>
                </div>

                <div id="doctorList">
                    <div class="loading-doctors">
                        <div class="spinner"></div>
                        Đang tải danh sách bác sĩ...
                    </div>
                </div>

                <div class="mt-4 d-flex justify-content-end">
                    <button class="btn-next" id="btn1Next" onclick="goStep(2)" disabled>
                        Tiếp theo <i class="fas fa-arrow-right ms-1"></i>
                    </button>
                </div>
            </div>

            <!-- ========== STEP 2: Ngày & Giờ ========== -->
            <div class="step-content" id="step2">
                <h5 class="mb-1" style="font-weight:700; color:#1e293b;">
                    <i class="fas fa-calendar-day me-2" style="color:#2563eb;"></i>Chọn ngày và giờ khám
                </h5>
                <p class="text-muted mb-4" style="font-size:13px;">Hệ thống sẽ tự động kiểm tra lịch trống của bác sĩ</p>

                <div class="row g-3">
                    <div class="col-md-5">
                        <label class="form-label">Ngày khám <span style="color:red">*</span></label>
                        <input type="date" id="appointmentDate" class="form-control"
                               min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>"
                               onchange="onDateChange(this.value)">
                    </div>
                    <div class="col-md-7">
                        <label class="form-label">Khung giờ có sẵn <span style="color:red">*</span></label>
                        <div id="timeSlots">
                            <p style="font-size:13px; color:#94a3b8; margin-top:8px;">
                                <i class="fas fa-info-circle me-1"></i>Vui lòng chọn ngày trước
                            </p>
                        </div>
                    </div>
                </div>

                <div class="mt-4 d-flex justify-content-between">
                    <button class="btn-back" onclick="goStep(1)">
                        <i class="fas fa-arrow-left me-1"></i>Quay lại
                    </button>
                    <button class="btn-next" id="btn2Next" onclick="goStep(3)" disabled>
                        Tiếp theo <i class="fas fa-arrow-right ms-1"></i>
                    </button>
                </div>
            </div>

            <!-- ========== STEP 3: Triệu chứng ========== -->
            <div class="step-content" id="step3">
                <h5 class="mb-1" style="font-weight:700; color:#1e293b;">
                    <i class="fas fa-notes-medical me-2" style="color:#2563eb;"></i>Thông tin triệu chứng
                </h5>
                <p class="text-muted mb-4" style="font-size:13px;">Mô tả chi tiết giúp bác sĩ chuẩn bị tốt hơn</p>

                <div class="row g-3">
                    <div class="col-12">
                        <label class="form-label">Mô tả triệu chứng <span style="color:red">*</span></label>
                        <textarea id="symptoms" rows="4" class="form-control"
                                  placeholder="VD: Tôi bị đau đầu, sốt nhẹ khoảng 37.5°C từ 2 ngày nay..."></textarea>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Lý do khám</label>
                        <input type="text" id="reason" class="form-control"
                               placeholder="VD: Kiểm tra định kỳ, tái khám...">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Ghi chú thêm cho bác sĩ</label>
                        <input type="text" id="notes" class="form-control"
                               placeholder="VD: Dị ứng thuốc, tiền sử bệnh...">
                    </div>
                </div>

                <div class="mt-4 d-flex justify-content-between">
                    <button class="btn-back" onclick="goStep(2)">
                        <i class="fas fa-arrow-left me-1"></i>Quay lại
                    </button>
                    <button class="btn-next" onclick="goStep(4)">
                        Xem lại <i class="fas fa-arrow-right ms-1"></i>
                    </button>
                </div>
            </div>

            <!-- ========== STEP 4: Xác nhận ========== -->
            <div class="step-content" id="step4">
                <h5 class="mb-1" style="font-weight:700; color:#1e293b;">
                    <i class="fas fa-check-circle me-2" style="color:#2563eb;"></i>Xác nhận thông tin đặt lịch
                </h5>
                <p class="text-muted mb-3" style="font-size:13px;">Kiểm tra kỹ thông tin trước khi gửi yêu cầu</p>

                <div class="alert-info-custom">
                    <i class="fas fa-clock" style="margin-top:2px; flex-shrink:0;"></i>
                    <div>
                        <strong>Lưu ý:</strong> Sau khi đặt lịch, trạng thái sẽ là <strong>Chờ xác nhận</strong>.
                        Bác sĩ sẽ xem xét và xác nhận lịch hẹn của bạn. Bạn sẽ được thông báo khi bác sĩ phản hồi.
                    </div>
                </div>

                <div class="summary-box" id="summaryBox"></div>

                <div class="mt-4 d-flex justify-content-between">
                    <button class="btn-back" onclick="goStep(3)">
                        <i class="fas fa-arrow-left me-1"></i>Quay lại
                    </button>
                    <button class="btn-confirm" onclick="submitAppointment()" id="btnConfirm">
                        <i class="fas fa-paper-plane me-2"></i>Gửi yêu cầu đặt lịch
                    </button>
                </div>
            </div>

        </div>
    </div>
</div>

<!-- Success Modal -->
<div class="success-overlay" id="successOverlay">
    <div class="success-box">
        <div class="success-icon">
            <i class="fas fa-check"></i>
        </div>
        <h4 style="font-weight:700; color:#1e293b; margin-bottom:10px;">Đặt lịch thành công!</h4>
        <p style="color:#64748b; font-size:14px; margin-bottom:8px;">
            Yêu cầu của bạn đã được gửi tới bác sĩ.
        </p>
        <div class="status-badge" style="margin: 0 auto 20px;">
            <i class="fas fa-hourglass-half"></i> Đang chờ bác sĩ xác nhận
        </div>
        <p style="color:#94a3b8; font-size:12px; margin-bottom:24px;">
            Bác sĩ sẽ xác nhận lịch hẹn sớm nhất có thể. Bạn có thể theo dõi trạng thái tại trang chủ.
        </p>
        <button class="btn-confirm" style="width:100%;" onclick="window.location.href='${pageContext.request.contextPath}/index.jsp'">
            <i class="fas fa-home me-2"></i>Về trang chủ
        </button>
    </div>
</div>

<script>
    const ctx = '<%= request.getContextPath() %>';
    const patientLang = '<%= patientLang %>';
    function pt(vi, en) { return patientLang === 'en' ? en : vi; }
    let selectedDoctor = null;
    let selectedDate = null;
    let selectedTime = null;
    let currentStep = 1;
    let allDoctors = []; // Lưu danh sách bác sĩ gốc

    // ===== STEP NAVIGATION =====
    function goStep(step) {
        // Validate trước khi chuyển
        if (step === 2 && !selectedDoctor) { alert(pt('Vui lòng chọn bác sĩ!', 'Please select a doctor!')); return; }
        if (step === 3 && (!selectedDate || !selectedTime)) { alert(pt('Vui lòng chọn ngày và giờ khám!', 'Please select date and time!')); return; }

        // Ẩn step hiện tại
        document.getElementById('step' + currentStep).classList.remove('active');

        // Cập nhật indicators
        for (let i = 1; i <= 4; i++) {
            const ind = document.getElementById('ind' + i);
            ind.classList.remove('active', 'done');
            if (i < step) ind.classList.add('done');
            else if (i === step) ind.classList.add('active');
        }
        for (let i = 1; i <= 3; i++) {
            const conn = document.getElementById('conn' + i);
            conn.classList.toggle('done', i < step);
        }

        currentStep = step;
        document.getElementById('step' + step).classList.add('active');

        if (step === 4) renderSummary();
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    // ===== LOAD DOCTORS =====
    async function loadDoctors() {
        try {
            const res = await fetch(ctx + '/patient/doctors');
            const doctors = await res.json();
            const container = document.getElementById('doctorList');

            if (!doctors || doctors.length === 0) {
                container.innerHTML = '<p style="color:#94a3b8; text-align:center; padding:30px;">Chưa có bác sĩ nào trong hệ thống.</p>';
                return;
            }

            // Lưu danh sách gốc
            allDoctors = doctors;

            // Hiển thị danh sách
            renderDoctors(doctors);
        } catch (e) {
            document.getElementById('doctorList').innerHTML =
                '<div class="doctor-grid">' +
                '<div class="doctor-card" onclick="selectDoctor(1,\'BS. Nguyễn Văn An\',\'Tim mạch\',12)" data-id="1">' +
                '<div class="doctor-avatar"><i class="fas fa-user-md"></i></div>' +
                '<div class="doctor-info"><h6>BS. Nguyễn Văn An</h6><p><i class="fas fa-stethoscope me-1" style="color:#2563eb;"></i>Tim mạch</p><p><i class="fas fa-star me-1" style="color:#f59e0b;"></i>12 năm kinh nghiệm</p></div></div>' +
                '<div class="doctor-card" onclick="selectDoctor(2,\'BS. Trần Thị Bình\',\'Nhi khoa\',8)" data-id="2">' +
                '<div class="doctor-avatar"><i class="fas fa-user-md"></i></div>' +
                '<div class="doctor-info"><h6>BS. Trần Thị Bình</h6><p><i class="fas fa-stethoscope me-1" style="color:#2563eb;"></i>Nhi khoa</p><p><i class="fas fa-star me-1" style="color:#f59e0b;"></i>8 năm kinh nghiệm</p></div></div>' +
                '</div>';
        }
    }

    function selectDoctor(id, name, specialty, exp) {
        selectedDoctor = { doctorId: id, fullname: name, specialty: specialty, experience_years: exp };
        document.querySelectorAll('.doctor-card').forEach(c => {
            c.classList.toggle('selected', c.getAttribute('data-id') == id);
        });
        document.getElementById('btn1Next').disabled = false;
        // Reset date/time khi đổi bác sĩ
        selectedDate = null;
        selectedTime = null;
        document.getElementById('appointmentDate').value = '';
        document.getElementById('timeSlots').innerHTML =
            '<p style="font-size:13px; color:#94a3b8; margin-top:8px;"><i class="fas fa-info-circle me-1"></i>Vui lòng chọn ngày khám</p>';
        document.getElementById('btn2Next').disabled = true;
    }

    // ===== DATE & TIME =====
    async function onDateChange(date) {
        selectedDate = date;
        selectedTime = null;
        document.getElementById('btn2Next').disabled = true;

        if (!date || !selectedDoctor) return;

        const slotsAll = ['08:00','09:00','10:00','11:00','13:30','14:00','15:00','16:00'];
        let bookedSlots = [];

        try {
            const res = await fetch(ctx + '/patient/booked-slots?doctorId=' + selectedDoctor.doctorId + '&date=' + date);
            const data = await res.json();
            bookedSlots = data.bookedSlots || [];
        } catch (e) { /* ignore, show all */ }

        const today = new Date().toISOString().split('T')[0];
        const nowTime = new Date().toTimeString().slice(0, 5);
        const isToday = date === today;

        let html = '<div class="time-grid">';
        let availableCount = 0;
        slotsAll.forEach(slot => {
            const isBooked = bookedSlots.includes(slot);
            const isPast = isToday && slot <= nowTime;
            if (isBooked || isPast) return;
            availableCount += 1;
            html += '<span class="time-slot" onclick="selectTime(\'' + slot + '\')" data-time="' + slot + '">' + slot + '</span>';
        });
        html += '</div>';
        if (availableCount === 0) {
            document.getElementById('timeSlots').innerHTML = '<p style="font-size:13px; color:#94a3b8; margin-top:8px;">' +
                '<i class="fas fa-info-circle me-1"></i>' +
                (isToday
                    ? pt('Không còn khung giờ khả dụng cho ngày hôm nay.', 'No available time slots remain for today.')
                    : pt('Không có khung giờ khả dụng cho ngày này.', 'No available time slots for this date.')) +
                '</p>';
            return;
        }
        document.getElementById('timeSlots').innerHTML = html;
    }

    function selectTime(time) {
        selectedTime = time;
        document.querySelectorAll('.time-slot:not(.booked)').forEach(s => {
            s.classList.toggle('selected', s.getAttribute('data-time') === time);
        });
        document.getElementById('btn2Next').disabled = false;
    }

    // ===== SUMMARY =====
    function renderSummary() {
        const symptoms = document.getElementById('symptoms').value || 'Chưa nhập';
        const reason   = document.getElementById('reason').value   || 'Không có';
        const notes    = document.getElementById('notes').value    || 'Không có';

        document.getElementById('summaryBox').innerHTML =
            '<div class="summary-row"><span class="summary-label"><i class="fas fa-user-md me-2" style="color:#2563eb;"></i>Bác sĩ</span>' +
            '<span class="summary-value">' + esc(selectedDoctor ? selectedDoctor.fullname : '-') + '</span></div>' +

            '<div class="summary-row"><span class="summary-label"><i class="fas fa-stethoscope me-2" style="color:#2563eb;"></i>Chuyên khoa</span>' +
            '<span class="summary-value">' + esc(selectedDoctor ? selectedDoctor.specialty : '-') + '</span></div>' +

            '<div class="summary-row"><span class="summary-label"><i class="fas fa-calendar me-2" style="color:#2563eb;"></i>Ngày khám</span>' +
            '<span class="summary-value">' + (selectedDate || '-') + '</span></div>' +

            '<div class="summary-row"><span class="summary-label"><i class="fas fa-clock me-2" style="color:#2563eb;"></i>Giờ khám</span>' +
            '<span class="summary-value">' + (selectedTime || '-') + '</span></div>' +

            '<div class="summary-row"><span class="summary-label"><i class="fas fa-notes-medical me-2" style="color:#2563eb;"></i>Triệu chứng</span>' +
            '<span class="summary-value">' + esc(symptoms) + '</span></div>' +

            '<div class="summary-row"><span class="summary-label"><i class="fas fa-tag me-2" style="color:#2563eb;"></i>Lý do khám</span>' +
            '<span class="summary-value">' + esc(reason) + '</span></div>' +

            '<div class="summary-row"><span class="summary-label"><i class="fas fa-sticky-note me-2" style="color:#2563eb;"></i>Ghi chú</span>' +
            '<span class="summary-value">' + esc(notes) + '</span></div>';
    }

    // ===== SUBMIT =====
    async function submitAppointment() {
        if (!selectedDoctor || !selectedDate || !selectedTime) {
            alert('Thông tin chưa đầy đủ. Vui lòng kiểm tra lại!');
            return;
        }

        const btn = document.getElementById('btnConfirm');
        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Đang gửi...';

        // Lấy giá trị và encodeURIComponent để đảm bảo tiếng Việt
        const symptoms = document.getElementById('symptoms').value;
        const reason = document.getElementById('reason').value;
        const notes = document.getElementById('notes').value;

        const formData = new URLSearchParams();
        formData.append('doctorId', selectedDoctor.doctorId);
        formData.append('date', selectedDate);
        formData.append('time', selectedTime);
        formData.append('symptoms', symptoms);
        formData.append('reason', reason);
        formData.append('notes', notes);

        try {
            const res = await fetch(ctx + '/patient/book', {
                method: 'POST',
                headers: { 
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'  // ← THÊM charset
                },
                body: formData
            });
            const data = await res.json();

            if (data.success) {
                if (data.appointmentId) {
                setAppointmentId(data.appointmentId);
                }
                document.getElementById('successOverlay').classList.add('show');
            } else {
                alert('Lỗi: ' + data.message);
                btn.disabled = false;
                btn.innerHTML = '<i class="fas fa-paper-plane me-2"></i>Gửi yêu cầu đặt lịch';
            }
        } catch (e) {
            alert('Lỗi kết nối: ' + e.message);
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-paper-plane me-2"></i>Gửi yêu cầu đặt lịch';
        }
    }
    
    // ===== KIỂM TRA TRẠNG THÁI LỊCH HẸN =====
    let appointmentId = null;

    // Hàm lưu appointmentId sau khi đặt lịch thành công
    function setAppointmentId(id) {
        appointmentId = id;
        // Bắt đầu kiểm tra định kỳ
        startStatusCheck();
    }

    // Hàm kiểm tra trạng thái lịch hẹn
    async function checkAppointmentStatus() {
        if (!appointmentId) return;

        try {
            const res = await fetch(ctx + '/patient/check-status?appointmentId=' + appointmentId);
            const data = await res.json();

            if (data.status === 'confirmed') {
                // Bác sĩ đã xác nhận
                showNotification('confirmed');
                stopStatusCheck(); // Dừng kiểm tra
            } else if (data.status === 'cancelled') {
                showNotification('cancelled');
                stopStatusCheck();
            } else if (data.status === 'completed') {
                showNotification('completed');
                stopStatusCheck();
            }
        } catch (e) {
            console.error('Lỗi kiểm tra trạng thái:', e);
        }
    }

    let statusInterval = null;

    function startStatusCheck() {
        if (statusInterval) clearInterval(statusInterval);
        // Kiểm tra mỗi 30 giây
        statusInterval = setInterval(checkAppointmentStatus, 30000);
    }

    function stopStatusCheck() {
        if (statusInterval) {
            clearInterval(statusInterval);
            statusInterval = null;
        }
    }

    // Hàm hiển thị thông báo khi bác sĩ xác nhận
    function showNotification(status) {
        let title = '';
        let message = '';
        let icon = '';

        switch(status) {
            case 'confirmed':
                title = 'Lịch hẹn đã được xác nhận!';
                message = 'Bác sĩ đã xác nhận lịch hẹn của bạn. Vui lòng đến đúng giờ.';
                icon = '✅';
                break;
            case 'cancelled':
                title = 'Lịch hẹn đã bị hủy';
                message = 'Lịch hẹn của bạn đã bị hủy. Vui lòng đặt lịch khác.';
                icon = '❌';
                break;
            case 'completed':
                title = 'Đã hoàn thành khám!';
                message = 'Cảm ơn bạn đã sử dụng dịch vụ của chúng tôi.';
                icon = '🎉';
                break;
            default:
                return;
        }

        // Hiển thị thông báo (alert hoặc modal)
        if ('Notification' in window && Notification.permission === 'granted') {
            new Notification(title, { body: message, icon: '/favicon.ico' });
        }

        // Hiển thị alert (hoặc có thể dùng modal đẹp hơn)
        alert(icon + ' ' + title + '\n' + message);

        // Cập nhật giao diện nếu cần
        updateAppointmentStatusInUI(status);
    }

    // Cập nhật giao diện khi có thay đổi trạng thái
    function updateAppointmentStatusInUI(status) {
        const statusMap = {
            'confirmed': { text: 'Đã xác nhận', class: 'confirmed' },
            'cancelled': { text: 'Đã hủy', class: 'cancelled' },
            'completed': { text: 'Đã hoàn thành', class: 'completed' }
        };

        const info = statusMap[status];
        if (info) {
            // Tìm hoặc tạo element hiển thị trạng thái
            let statusElement = document.getElementById('appointmentStatus');
            if (!statusElement) {
                statusElement = document.createElement('div');
                statusElement.id = 'appointmentStatus';
                statusElement.className = 'status-badge';
                document.querySelector('.summary-box').after(statusElement);
            }
            statusElement.innerHTML = `<i class="fas ${status == 'confirmed' ? 'fa-check-circle' : (status == 'cancelled' ? 'fa-times-circle' : 'fa-hourglass-half')}"></i> ${info.text}`;
            statusElement.classList.add(info.class);
        }
    }

    // Xin phép thông báo trình duyệt (nếu muốn dùng Notification)
    if ('Notification' in window) {
        Notification.requestPermission();
    }
    
    // Hiển thị danh sách bác sĩ
    function renderDoctors(doctors) {
        const container = document.getElementById('doctorList');

        if (!doctors || doctors.length === 0) {
            container.innerHTML = '<p style="color:#94a3b8; text-align:center; padding:30px;">Không tìm thấy bác sĩ phù hợp.</p>';
            return;
        }

        let html = '<div class="doctor-grid">';
        doctors.forEach(d => {
            const spec = d.specialty || 'Bác sĩ đa khoa';
            const exp = d.experienceYears || 0;
            const phone = d.phone || '';
            const avatarUrl = d.avatar || 'https://api.dicebear.com/7.x/avataaars/svg?seed=' + d.doctorId;

            html += '<div class="doctor-card" onclick="selectDoctor(' + d.doctorId + ',\'' +
                escJs(d.fullname) + '\',\'' + escJs(spec) + '\',' + exp + ')" data-id="' + d.doctorId + '">' +
                '<div class="doctor-avatar">' +
                '<img src="' + avatarUrl + '" alt="avatar" style="width: 52px; height: 52px; border-radius: 50%; object-fit: cover;">' +
                '</div>' +
                '<div class="doctor-info">' +
                '<h6>' + esc(d.fullname) + '</h6>' +
                '<p><i class="fas fa-stethoscope me-1" style="color:#2563eb;"></i>' + esc(spec) + '</p>' +
                '<p><i class="fas fa-star me-1" style="color:#f59e0b;"></i>' + exp + ' năm kinh nghiệm</p>' +
                (phone ? '<p><i class="fas fa-phone me-1"></i>' + esc(phone) + '</p>' : '') +
                '</div></div>';
        });
        html += '</div>';
        container.innerHTML = html;
    }

    // Lọc bác sĩ
    function filterDoctors() {
        const specialty = document.getElementById('filterSpecialty').value;
        const experience = parseInt(document.getElementById('filterExperience').value);

        let filtered = [...allDoctors];

        // Lọc theo chuyên khoa
        if (specialty) {
            filtered = filtered.filter(d => d.specialty === specialty);
        }

        // Lọc theo số năm kinh nghiệm
        if (experience > 0) {
            filtered = filtered.filter(d => (d.experienceYears || 0) >= experience);
        }

        renderDoctors(filtered);

        // Reset selected doctor
        selectedDoctor = null;
        document.getElementById('btn1Next').disabled = true;
        document.querySelectorAll('.doctor-card').forEach(c => c.classList.remove('selected'));
    }

    // Xóa lọc
    function resetFilter() {
        document.getElementById('filterSpecialty').value = '';
        document.getElementById('filterExperience').value = '0';
        renderDoctors(allDoctors);

        // Reset selected doctor
        selectedDoctor = null;
        document.getElementById('btn1Next').disabled = true;
        document.querySelectorAll('.doctor-card').forEach(c => c.classList.remove('selected'));
    }
    
    // ===== HELPERS =====
    function esc(s) {
        if (!s) return '';
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
    }
    function escJs(s) {
        if (!s) return '';
        return String(s).replace(/\\/g,'\\\\').replace(/'/g,"\\'");
    }

    // Init
    loadDoctors();
</script>
<script src="${pageContext.request.contextPath}/js/patient-preferences.js"></script>
</body>
</html>
