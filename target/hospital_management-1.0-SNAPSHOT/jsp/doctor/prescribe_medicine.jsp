<%@ page isELIgnored="true" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hospital.model.Account" %>
<%@ page import="com.hospital.dao.AppointmentDAO" %>
<%@ page import="com.hospital.model.Appointment" %>
<%
    Account account = (Account) session.getAttribute("account");
    if (account == null || !"doctor".equals(account.getRole())) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
    
    String appointmentIdStr = request.getParameter("appointmentId");
    String patientName = request.getParameter("patientName");
    boolean canPrescribe = false;
    String status = "";
    
    if (appointmentIdStr != null && !appointmentIdStr.isEmpty()) {
        try {
            int appointmentId = Integer.parseInt(appointmentIdStr);
            AppointmentDAO appointmentDAO = new AppointmentDAO();
            Appointment appt = appointmentDAO.getAppointmentById(appointmentId);
            if (appt != null) {
                status = appt.getStatus();
                // Chỉ cho phép kê đơn khi lịch hẹn đã hoàn thành (completed)
                canPrescribe = "completed".equals(status) || "confirmed".equals(status);
                if (!canPrescribe && patientName == null) {
                    patientName = appt.getPatientName();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kê đơn thuốc - HMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
            background: #f0f2f5;
            min-height: 100vh;
            padding: 20px;
        }
        .container-custom { max-width: 1400px; margin: 0 auto; }
        
        .card {
            background: white;
            border-radius: 16px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            overflow: hidden;
            margin-bottom: 25px;
        }
        .card-header {
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            color: white;
            padding: 16px 24px;
            font-weight: 700;
            font-size: 18px;
        }
        .card-body { padding: 24px; }
        
        .btn-primary-custom {
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            color: white;
            border: none;
            padding: 8px 20px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-success-custom {
            background: #10b981;
            color: white;
            border: none;
            padding: 10px 24px;
            border-radius: 8px;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-danger-custom {
            background: #ef4444;
            color: white;
            border: none;
            padding: 4px 12px;
            border-radius: 6px;
            font-size: 12px;
            cursor: pointer;
        }
        
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #e2e8f0; }
        th { background: #f8fafc; font-weight: 600; }
        
        .search-box { display: flex; gap: 10px; margin-bottom: 20px; }
        .search-input { flex: 1; padding: 10px 15px; border: 1px solid #e2e8f0; border-radius: 8px; }
        .btn-search { background: #3b82f6; color: white; border: none; padding: 10px 20px; border-radius: 8px; cursor: pointer; }
        
        .prescription-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px;
            background: #f8fafc;
            border-radius: 8px;
            margin-bottom: 10px;
        }
        .prescription-item-info { flex: 1; }
        .prescription-item-actions { display: flex; gap: 8px; }
        
        .total-box {
            background: #f1f5f9;
            padding: 16px;
            border-radius: 8px;
            text-align: right;
            font-size: 18px;
            font-weight: 700;
        }
        
        .stock-low { color: #dc2626; }
        .stock-normal { color: #10b981; }
        
        .warning-box {
            background: #fef3c7;
            border: 1px solid #f59e0b;
            border-radius: 12px;
            padding: 20px;
            text-align: center;
            color: #92400e;
        }
    </style>
</head>
<body>
<div class="container-custom">
    <!-- Header -->
    <div class="d-flex justify-content-between align-items-center mb-3">
        <a href="/jsp/dashboard/doctor_dashboard.jsp" class="text-decoration-none">
            <i class="fas fa-arrow-left me-1"></i> Quay lại Dashboard
        </a>
        <div>
            <span><i class="fas fa-user-md me-1"></i> <%= account.getFullname() %></span>
            <a href="${pageContext.request.contextPath}/logout" class="ms-3 text-decoration-none">Đăng xuất</a>
        </div>
    </div>

    <% if (!canPrescribe) { %>
        <!-- Không được phép kê đơn -->
        <div class="card">
            <div class="card-header">
                <i class="fas fa-exclamation-triangle me-2"></i> Không thể kê đơn thuốc
            </div>
            <div class="card-body">
                <div class="warning-box">
                    <i class="fas fa-clock fa-3x mb-3"></i>
                    <h4>Lịch hẹn chưa hoàn thành!</h4>
                    <p>Để kê đơn thuốc, lịch hẹn cần có trạng thái <strong>Đã hoàn thành (completed)</strong>.</p>
                    <p class="mt-2">Trạng thái hiện tại: 
                        <span class="badge <%= "completed".equals(status) ? "bg-success" : "bg-warning" %>">
                            <%= status != null ? status : "Không xác định" %>
                        </span>
                    </p>
                    <a href="${pageContext.request.contextPath}/jsp/doctor/doctor_dashboard.jsp" class="btn btn-primary mt-3">
                        <i class="fas fa-arrow-left me-1"></i> Quay lại Dashboard
                    </a>
                </div>
            </div>
        </div>
    <% } else { %>
        <!-- Thông tin bệnh nhân -->
        <div class="card">
            <div class="card-header">
                <i class="fas fa-user-circle me-2"></i> Kê đơn thuốc cho bệnh nhân
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-6">
                        <p><strong>Mã lịch hẹn:</strong> <span id="appointmentId"><%= appointmentIdStr %></span></p>
                        <p><strong>Bệnh nhân:</strong> <span id="patientName"><%= patientName != null ? patientName : "" %></span></p>
                    </div>
                    <div class="col-md-6 text-end">
                        <button class="btn-success-custom" onclick="savePrescription()">
                            <i class="fas fa-save me-2"></i> Lưu đơn thuốc
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Chọn thuốc -->
        <div class="card">
            <div class="card-header">
                <i class="fas fa-capsules me-2"></i> Danh sách thuốc trong kho
            </div>
            <div class="card-body">
                <div class="search-box">
                    <input type="text" id="searchMedicine" class="search-input" placeholder="Tìm kiếm thuốc...">
                    <button class="btn-search" onclick="searchMedicines()"><i class="fas fa-search"></i> Tìm</button>
                </div>
                <div style="overflow-x: auto;">
                    <table id="medicinesTable">
                        <thead>
                            <tr><th>ID</th><th>Tên thuốc</th><th>Đơn vị</th><th>Tồn kho</th><th>Đơn giá</th><th>Thao tác</th></tr>
                        </thead>
                        <tbody id="medicinesTableBody">
                            <tr><td colspan="6" class="text-center">Đang tải...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Đơn thuốc đang kê -->
        <div class="card">
            <div class="card-header">
                <i class="fas fa-prescription-bottle me-2"></i> Đơn thuốc đang kê
            </div>
            <div class="card-body">
                <div id="prescriptionItems" style="min-height: 150px;">
                    <div class="text-center text-muted p-4">Chưa có thuốc nào trong đơn</div>
                </div>
                <div class="total-box mt-3">
                    Tổng tiền: <span id="totalAmount">0</span> VNĐ
                </div>
            </div>
        </div>
    <% } %>
</div>

<!-- Modal nhập thông tin thuốc -->
<div class="modal fade" id="quantityModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title"><i class="fas fa-pills me-2"></i>Thông tin thuốc</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label fw-bold">Tên thuốc</label>
                    <input type="text" id="modalMedicineName" class="form-control" readonly>
                </div>
                <div class="row">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Số lượng <span class="text-danger">*</span></label>
                        <input type="number" id="modalQuantity" class="form-control" min="1" value="1">
                        <small class="text-muted" id="modalStock"></small>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Đơn giá</label>
                        <input type="text" id="modalUnitPrice" class="form-control" readonly>
                    </div>
                </div>
                <div class="row mt-2">
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Liều lượng <span class="text-danger">*</span></label>
                        <input type="text" id="dosage" class="form-control" placeholder="VD: 1 viên/lần">
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-bold">Tần suất <span class="text-danger">*</span></label>
                        <select id="frequency" class="form-select">
                            <option value="">-- Chọn tần suất --</option>
                            <option value="Ngày 1 lần">Ngày 1 lần</option>
                            <option value="Ngày 2 lần">Ngày 2 lần</option>
                            <option value="Ngày 3 lần">Ngày 3 lần</option>
                            <option value="Mỗi 4 giờ">Mỗi 4 giờ</option>
                            <option value="Mỗi 6 giờ">Mỗi 6 giờ</option>
                            <option value="Mỗi 8 giờ">Mỗi 8 giờ</option>
                            <option value="Mỗi 12 giờ">Mỗi 12 giờ</option>
                        </select>
                    </div>
                </div>
                <div class="mt-2">
                    <label class="form-label fw-bold">Thời gian dùng</label>
                    <select id="duration" class="form-select">
                        <option value="3">3 ngày</option>
                        <option value="5">5 ngày</option>
                        <option value="7">7 ngày</option>
                        <option value="10">10 ngày</option>
                        <option value="14">14 ngày</option>
                    </select>
                </div>
                <div class="mt-2">
                    <label class="form-label fw-bold">Hướng dẫn sử dụng</label>
                    <textarea id="instruction" rows="3" class="form-control" placeholder="VD: Uống sau khi ăn, uống nhiều nước..."></textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                <button type="button" class="btn btn-primary" onclick="addToPrescription()">Thêm vào đơn</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const contextPath = '<%= request.getContextPath() %>';
    let allMedicines = [];
    let prescriptionItems = [];
    let currentMedicine = null;

    // ==================== LOAD DANH SÁCH THUỐC ====================
    async function loadMedicines() {
        try {
            const response = await fetch(contextPath + '/doctor/medicines');
            const data = await response.json();
            allMedicines = data;
            renderMedicinesTable(allMedicines);
        } catch (error) {
            console.error('Lỗi tải thuốc:', error);
            document.getElementById('medicinesTableBody').innerHTML = '<tr><td colspan="6" class="text-center text-danger">Lỗi tải dữ liệu</td></tr>';
            // Dữ liệu mẫu fallback
            allMedicines = [
                { medicineId: 1, medicineName: 'Paracetamol 500mg', unit: 'Viên', stockQuantity: 1000, unitPrice: 5000 },
                { medicineId: 2, medicineName: 'Amoxicillin 250mg', unit: 'Viên', stockQuantity: 800, unitPrice: 8000 }
            ];
            renderMedicinesTable(allMedicines);
        }
    }

    function renderMedicinesTable(medicines) {
        const tbody = document.getElementById('medicinesTableBody');
        if (!medicines || medicines.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="text-center">Không có thuốc nào</td></tr>';
            return;
        }

        let html = '';
        for (let i = 0; i < medicines.length; i++) {
            const med = medicines[i];
            const stockClass = med.stockQuantity < 100 ? 'stock-low' : 'stock-normal';
            html += '<tr>';
            html += '<td>' + med.medicineId + '</td>';
            html += '<td><strong>' + escapeHtml(med.medicineName) + '</strong></td>';
            html += '<td>' + escapeHtml(med.unit) + '</td>';
            html += '<td class="' + stockClass + '">' + med.stockQuantity + '</td>';
            html += '<td>' + Number(med.unitPrice).toLocaleString() + 'đ</td>';
            html += '<td><button class="btn btn-sm btn-primary" onclick="openQuantityModal(' + med.medicineId + ')">Chọn</button></td>';
            html += '</tr>';
        }
        tbody.innerHTML = html;
    }

    function searchMedicines() {
        const keyword = document.getElementById('searchMedicine').value.toLowerCase();
        if (!keyword) {
            renderMedicinesTable(allMedicines);
            return;
        }
        const filtered = allMedicines.filter(m => m.medicineName.toLowerCase().includes(keyword));
        renderMedicinesTable(filtered);
    }

    // Mở modal nhập thông tin thuốc
    function openQuantityModal(medicineId) {
        currentMedicine = allMedicines.find(m => m.medicineId === medicineId);
        if (!currentMedicine) return;
        
        document.getElementById('modalMedicineName').value = currentMedicine.medicineName;
        document.getElementById('modalUnitPrice').value = currentMedicine.unitPrice.toLocaleString() + 'đ';
        document.getElementById('modalStock').innerHTML = 'Tồn kho: ' + currentMedicine.stockQuantity;
        document.getElementById('modalQuantity').value = 1;
        document.getElementById('dosage').value = '';
        document.getElementById('frequency').value = '';
        document.getElementById('duration').value = '7';
        document.getElementById('instruction').value = '';
        
        new bootstrap.Modal(document.getElementById('quantityModal')).show();
    }

    // Thêm vào đơn thuốc
    function addToPrescription() {
        const quantity = parseInt(document.getElementById('modalQuantity').value);
        const dosage = document.getElementById('dosage').value;
        const frequency = document.getElementById('frequency').value;
        const duration = document.getElementById('duration').value;
        const instruction = document.getElementById('instruction').value;
        
        if (quantity < 1 || quantity > currentMedicine.stockQuantity) {
            alert('Số lượng không hợp lệ! Tồn kho: ' + currentMedicine.stockQuantity);
            return;
        }
        
        if (!dosage) {
            alert('Vui lòng nhập liều lượng!');
            return;
        }
        
        if (!frequency) {
            alert('Vui lòng chọn tần suất!');
            return;
        }
        
        // Kiểm tra thuốc đã có trong đơn chưa
        const existingIndex = prescriptionItems.findIndex(item => item.medicineId === currentMedicine.medicineId);
        if (existingIndex !== -1) {
            prescriptionItems[existingIndex].quantity += quantity;
        } else {
            prescriptionItems.push({
                medicineId: currentMedicine.medicineId,
                medicineName: currentMedicine.medicineName,
                unit: currentMedicine.unit,
                unitPrice: currentMedicine.unitPrice,
                quantity: quantity,
                dosage: dosage,
                frequency: frequency,
                duration: duration,
                instruction: instruction
            });
        }
        
        bootstrap.Modal.getInstance(document.getElementById('quantityModal')).hide();
        renderPrescriptionItems();
    }

    // Hiển thị đơn thuốc
    function renderPrescriptionItems() {
        const container = document.getElementById('prescriptionItems');
        if (prescriptionItems.length === 0) {
            container.innerHTML = '<div class="text-center text-muted p-4">Chưa có thuốc nào trong đơn</div>';
            document.getElementById('totalAmount').innerText = '0';
            return;
        }
        
        let html = '';
        let total = 0;
        prescriptionItems.forEach((item, index) => {
            const itemTotal = item.unitPrice * item.quantity;
            total += itemTotal;
            html += `
                <div class="prescription-item">
                    <div class="prescription-item-info">
                        <strong>${escapeHtml(item.medicineName)}</strong><br>
                        Số lượng: ${item.quantity} ${escapeHtml(item.unit)} | Đơn giá: ${item.unitPrice.toLocaleString()}đ<br>
                        Liều lượng: ${escapeHtml(item.dosage)} | Tần suất: ${escapeHtml(item.frequency)}<br>
                        Thời gian: ${item.duration} ngày | Hướng dẫn: ${escapeHtml(item.instruction)}<br>
                        <span class="text-primary">Thành tiền: ${itemTotal.toLocaleString()}đ</span>
                    </div>
                    <div class="prescription-item-actions">
                        <button class="btn btn-warning btn-sm" onclick="editPrescriptionItem(${index})"><i class="fas fa-edit"></i></button>
                        <button class="btn-danger-custom" onclick="removePrescriptionItem(${index})"><i class="fas fa-trash"></i></button>
                    </div>
                </div>
            `;
        });
        container.innerHTML = html;
        document.getElementById('totalAmount').innerText = total.toLocaleString();
    }

    function editPrescriptionItem(index) {
        const item = prescriptionItems[index];
        currentMedicine = allMedicines.find(m => m.medicineId === item.medicineId);
        document.getElementById('modalMedicineName').value = item.medicineName;
        document.getElementById('modalUnitPrice').value = item.unitPrice.toLocaleString() + 'đ';
        document.getElementById('modalStock').innerHTML = 'Tồn kho: ' + currentMedicine.stockQuantity;
        document.getElementById('modalQuantity').value = item.quantity;
        document.getElementById('dosage').value = item.dosage || '';
        document.getElementById('frequency').value = item.frequency || '';
        document.getElementById('duration').value = item.duration || '7';
        document.getElementById('instruction').value = item.instruction || '';
        
        // Xóa item cũ, sẽ thêm lại sau khi sửa
        prescriptionItems.splice(index, 1);
        renderPrescriptionItems();
        
        new bootstrap.Modal(document.getElementById('quantityModal')).show();
    }

    function removePrescriptionItem(index) {
        prescriptionItems.splice(index, 1);
        renderPrescriptionItems();
    }

    // Lưu đơn thuốc
    async function savePrescription() {
        const appointmentId = document.getElementById('appointmentId').innerText;

        if (prescriptionItems.length === 0) {
            alert('Vui lòng thêm thuốc vào đơn!');
            return;
        }

        if (!confirm('Xác nhận lưu đơn thuốc?')) return;

        // Tạo mảng prescriptions từ prescriptionItems
        const prescriptions = prescriptionItems.map(item => ({
            medicineId: item.medicineId,
            quantity: item.quantity,
            dosage: item.dosage,
            frequency: item.frequency,
            instruction: item.instruction
        }));

        try {
            const response = await fetch(contextPath + '/doctor/prescription/save', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    appointmentId: appointmentId,
                    prescriptions: prescriptions
                })
            });
            const result = await response.json();
            if (result.success) {
                alert('Lưu đơn thuốc thành công!');
                window.location.href = contextPath + '/jsp/doctor/doctor_dashboard.jsp';
            } else {
                alert('Lỗi: ' + result.message);
            }
        } catch (error) {
            console.error('Lỗi lưu đơn:', error);
            alert('Lỗi lưu đơn thuốc!');
        }
    }


    function escapeHtml(text) {
        if (!text) return '';
        return text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    loadMedicines();
</script>
</body>
</html>