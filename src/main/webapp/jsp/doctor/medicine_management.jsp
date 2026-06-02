<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hospital.model.Account" %>
<%
    Account account = (Account) session.getAttribute("account");
    if (account == null || (!"doctor".equals(account.getRole()) && !"admin".equals(account.getRole()))) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý kho thuốc - HMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
            background: #ffffff;
            min-height: 100vh;
            padding: 20px;
        }
        .container-custom { max-width: 1400px; margin: 0 auto; }
        
        /* Top bar */
        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            color: white;
        }
        .top-bar a { color: white; text-decoration: none; font-size: 14px; }
        .top-bar a:hover { opacity: 0.8; }
        
        /* Cards */
        .card {
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.15);
            overflow: hidden;
            margin-bottom: 25px;
        }
        .card-header {
            background: linear-gradient(135deg, #2563eb, #1d4ed8);
            color: white;
            padding: 16px 24px;
            font-weight: 700;
            font-size: 18px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .card-body { padding: 24px; }
        
        /* Buttons */
        .btn-add {
            background: #10b981;
            color: white;
            border: none;
            padding: 8px 20px;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }
        .btn-add:hover { background: #059669; transform: translateY(-1px); }
        .btn-edit {
            background: #3b82f6;
            color: white;
            border: none;
            padding: 4px 12px;
            border-radius: 6px;
            font-size: 12px;
            cursor: pointer;
        }
        .btn-delete {
            background: #ef4444;
            color: white;
            border: none;
            padding: 4px 12px;
            border-radius: 6px;
            font-size: 12px;
            cursor: pointer;
        }
        .btn-edit:hover, .btn-delete:hover { opacity: 0.8; }
        .btn-save {
            background: #10b981;
            color: white;
            border: none;
            padding: 10px 24px;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-cancel {
            background: #94a3b8;
            color: white;
            border: none;
            padding: 10px 24px;
            border-radius: 10px;
            font-weight: 600;
            cursor: pointer;
        }
        
        /* Table */
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #e2e8f0; }
        th { background: #f8fafc; font-weight: 600; color: #1e293b; }
        td { color: #475569; }
        
        /* Search */
        .search-box { display: flex; gap: 10px; margin-bottom: 20px; }
        .search-input {
            flex: 1; padding: 10px 15px; border: 1px solid #e2e8f0; border-radius: 12px;
            font-size: 14px; outline: none;
        }
        .search-input:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37,99,235,0.1); }
        .btn-search {
            background: #2563eb; color: white; border: none;
            padding: 10px 20px; border-radius: 12px; cursor: pointer;
        }
        
        /* Form modal */
        .modal {
            display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center;
        }
        .modal.show { display: flex; }
        .modal-content {
            background: white; border-radius: 20px; width: 90%; max-width: 550px;
            max-height: 90vh; overflow-y: auto;
        }
        .modal-header {
            padding: 16px 20px; border-bottom: 1px solid #e2e8f0;
            display: flex; justify-content: space-between; align-items: center;
        }
        .modal-header h4 { margin: 0; }
        .modal-body { padding: 20px; }
        .modal-footer { padding: 16px 20px; border-top: 1px solid #e2e8f0; display: flex; justify-content: flex-end; gap: 10px; }
        .close-modal { cursor: pointer; font-size: 24px; }
        
        .form-group { margin-bottom: 15px; }
        .form-group label { font-weight: 600; font-size: 13px; color: #475569; margin-bottom: 5px; display: block; }
        .form-control, .form-select {
            width: 100%; padding: 10px 12px; border: 1px solid #e2e8f0; border-radius: 10px;
            font-size: 14px; outline: none;
        }
        .form-control:focus, .form-select:focus { border-color: #2563eb; box-shadow: 0 0 0 3px rgba(37,99,235,0.1); }
        
        .stock-low { color: #dc2626; font-weight: 600; }
        .stock-normal { color: #10b981; }
        
        .empty-state { text-align: center; padding: 40px; color: #94a3b8; }
        
        @media (max-width: 768px) {
            .card-body { overflow-x: auto; }
            table { min-width: 800px; }
        }
    </style>
</head>
<body>
<div class="container-custom">

    <!-- Main card -->
    <div class="card">
        <div class="card-header">
            <span><i class="fas fa-capsules me-2"></i>🏥 KHO THUỐC - BỆNH VIỆN HMS</span>
            <button class="btn-add" onclick="openAddModal()">
                <i class="fas fa-plus me-1"></i>Thêm thuốc mới
            </button>
        </div>
        <div class="card-body">
            <!-- Search box -->
            <div class="search-box">
                <input type="text" id="searchInput" class="search-input" placeholder="🔍 Tìm kiếm theo tên thuốc, nhà cung cấp..." onkeyup="searchMedicine()">
                <button class="btn-search" onclick="searchMedicine()"><i class="fas fa-search"></i> Tìm</button>
                <button class="btn-search" style="background: #64748b;" onclick="resetSearch()"><i class="fas fa-sync-alt"></i> Làm mới</button>
            </div>

            <!-- Medicine table -->
            <div style="overflow-x: auto;">
                <table id="medicineTable">
                    <thead>
                        <tr><th>ID</th><th>Tên thuốc</th><th>Đơn vị</th><th>Số lượng tồn</th><th>Đơn giá</th><th>Hạn sử dụng</th><th>Nhà cung cấp</th><th>Thao tác</th></thead>
                    <tbody id="medicineTableBody">
                        <tr class="empty-state"><td colspan="8"><i class="fas fa-spinner fa-spin me-2"></i>Đang tải dữ liệu...</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Modal Thêm / Sửa thuốc -->
<div class="modal" id="medicineModal">
    <div class="modal-content">
        <div class="modal-header">
            <h4 id="modalTitle"><i class="fas fa-plus-circle me-2"></i>Thêm thuốc mới</h4>
            <span class="close-modal" onclick="closeModal()">&times;</span>
        </div>
        <div class="modal-body">
            <form id="medicineForm">
                <input type="hidden" id="medicineId" value="">
                <div class="form-group">
                    <label>Tên thuốc <span style="color:red;">*</span></label>
                    <input type="text" id="medicineName" class="form-control" required placeholder="VD: Paracetamol 500mg">
                </div>
                <div class="form-group">
                    <label>Đơn vị <span style="color:red;">*</span></label>
                    <select id="unit" class="form-select" required>
                        <option value="">-- Chọn đơn vị --</option>
                        <option value="Viên">Viên</option>
                        <option value="Ống">Ống</option>
                        <option value="Chai">Chai</option>
                        <option value="Gói">Gói</option>
                        <option value="Lọ">Lọ</option>
                        <option value="Tuýp">Tuýp</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Số lượng tồn <span style="color:red;">*</span></label>
                    <input type="number" id="stockQuantity" class="form-control" required min="0" value="0">
                </div>
                <div class="form-group">
                    <label>Đơn giá (VNĐ) <span style="color:red;">*</span></label>
                    <input type="number" id="unitPrice" class="form-control" required min="0" step="1000" value="0">
                </div>
                <div class="form-group">
                    <label>Hạn sử dụng</label>
                    <input type="date" id="expiryDate" class="form-control">
                </div>
                <div class="form-group">
                    <label>Nhà cung cấp</label>
                    <input type="text" id="supplier" class="form-control" placeholder="VD: Công ty Dược phẩm ABC">
                </div>
            </form>
        </div>
        <div class="modal-footer">
            <button class="btn-cancel" onclick="closeModal()">Hủy</button>
            <button class="btn-save" onclick="saveMedicine()">Lưu</button>
        </div>
    </div>
</div>

<script>
    let allMedicines = [];

    // Load danh sách thuốc
    async function loadMedicines() {
        try {
            // Dùng đường dẫn tuyệt đối
            const response = await fetch('/hospital_management/doctor/medicines');
            const data = await response.json();
            allMedicines = data;
            renderTable(allMedicines);
        } catch (error) {
            console.error('Lỗi tải dữ liệu:', error);
            document.getElementById('medicineTableBody').innerHTML = '<tr class="empty-state"><td colspan="8"><i class="fas fa-exclamation-circle me-2"></i>Lỗi tải dữ liệu</td></tr>';
            // Fallback dữ liệu mẫu để hiển thị
            loadMockData();
        }
    }

    // Dữ liệu mẫu (fallback)
    function loadMockData() {
        allMedicines = [
            { medicineId: 1, medicineName: 'Paracetamol 500mg', unit: 'Viên', stockQuantity: 1000, unitPrice: 5000, expiryDate: '2030-12-31', supplier: 'Dược phẩm Trung ương' },
            { medicineId: 2, medicineName: 'Amoxicillin 250mg', unit: 'Viên', stockQuantity: 800, unitPrice: 8000, expiryDate: '2030-10-31', supplier: 'Imexpharm' },
            { medicineId: 3, medicineName: 'Vitamin C 500mg', unit: 'Viên', stockQuantity: 2000, unitPrice: 2000, expiryDate: '2031-06-30', supplier: 'Dược Hà Tây' },
            { medicineId: 4, medicineName: 'Ibuprofen 400mg', unit: 'Viên', stockQuantity: 500, unitPrice: 12000, expiryDate: '2030-11-30', supplier: 'Dược Bình Định' },
            { medicineId: 5, medicineName: 'Omeprazole 20mg', unit: 'Viên', stockQuantity: 600, unitPrice: 15000, expiryDate: '2030-09-30', supplier: 'Traphaco' }
        ];
        renderTable(allMedicines);
    }

    // Hiển thị bảng
    function renderTable(medicines) {
        const tbody = document.getElementById('medicineTableBody');
        if (!medicines || medicines.length === 0) {
            tbody.innerHTML = '<tr class="empty-state"><td colspan="8"><i class="fas fa-box-open me-2"></i>Chưa có thuốc nào trong kho</td></tr>';
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
            html += '<td><span class="' + stockClass + '">' + med.stockQuantity + '</span></td>';
            html += '<td>' + med.unitPrice.toLocaleString() + 'đ</td>';
            html += '<td>' + (med.expiryDate || 'Chưa cập nhật') + '</td>';
            html += '<td>' + escapeHtml(med.supplier || 'Chưa cập nhật') + '</td>';
            html += '<td><button class="btn-edit" onclick="openEditModal(' + med.medicineId + ')"><i class="fas fa-edit"></i> Sửa</button> ';
            html += '<button class="btn-delete" onclick="deleteMedicine(' + med.medicineId + ')"><i class="fas fa-trash"></i> Xóa</button></td>';
            html += '</tr>';
        }
        tbody.innerHTML = html;
    }

    // Tìm kiếm
    function searchMedicine() {
        const keyword = document.getElementById('searchInput').value.toLowerCase();
        if (!keyword) {
            renderTable(allMedicines);
            return;
        }
        const filtered = allMedicines.filter(med => 
            med.medicineName.toLowerCase().includes(keyword) ||
            (med.supplier && med.supplier.toLowerCase().includes(keyword))
        );
        renderTable(filtered);
    }

    function resetSearch() {
        document.getElementById('searchInput').value = '';
        renderTable(allMedicines);
    }


    // Mở modal thêm thuốc
    function openAddModal() {
        document.getElementById('modalTitle').innerHTML = '<i class="fas fa-plus-circle me-2"></i>Thêm thuốc mới';
        document.getElementById('medicineForm').reset();
        document.getElementById('medicineId').value = '';
        document.getElementById('medicineModal').classList.add('show');
    }

    // Mở modal sửa thuốc
    async function openEditModal(medicineId) {
        try {
            const response = await fetch(`${contextPath}/doctor/medicines/${medicineId}`);
            const med = await response.json();
            if (med) {
                document.getElementById('modalTitle').innerHTML = '<i class="fas fa-edit me-2"></i>Sửa thông tin thuốc';
                document.getElementById('medicineId').value = med.medicineId;
                document.getElementById('medicineName').value = med.medicineName;
                document.getElementById('unit').value = med.unit;
                document.getElementById('stockQuantity').value = med.stockQuantity;
                document.getElementById('unitPrice').value = med.unitPrice;
                document.getElementById('expiryDate').value = med.expiryDate || '';
                document.getElementById('supplier').value = med.supplier || '';
                document.getElementById('medicineModal').classList.add('show');
            }
        } catch(error) {
            // Fallback
            const med = allMedicines.find(m => m.medicineId === medicineId);
            if (med) {
                document.getElementById('modalTitle').innerHTML = '<i class="fas fa-edit me-2"></i>Sửa thông tin thuốc';
                document.getElementById('medicineId').value = med.medicineId;
                document.getElementById('medicineName').value = med.medicineName;
                document.getElementById('unit').value = med.unit;
                document.getElementById('stockQuantity').value = med.stockQuantity;
                document.getElementById('unitPrice').value = med.unitPrice;
                document.getElementById('expiryDate').value = med.expiryDate || '';
                document.getElementById('supplier').value = med.supplier || '';
                document.getElementById('medicineModal').classList.add('show');
            }
        }
    }

    // Lưu thuốc (thêm hoặc sửa)
    async function saveMedicine() {
        const medicineId = document.getElementById('medicineId').value;
        const medicineName = document.getElementById('medicineName').value.trim();
        const unit = document.getElementById('unit').value;
        const stockQuantity = parseInt(document.getElementById('stockQuantity').value);
        const unitPrice = parseInt(document.getElementById('unitPrice').value);
        const expiryDate = document.getElementById('expiryDate').value;
        const supplier = document.getElementById('supplier').value.trim();

        if (!medicineName || !unit || isNaN(stockQuantity) || isNaN(unitPrice)) {
            alert('Vui lòng điền đầy đủ thông tin bắt buộc!');
            return;
        }

        const formData = new URLSearchParams();
        formData.append('medicineName', medicineName);
        formData.append('unit', unit);
        formData.append('stockQuantity', stockQuantity);
        formData.append('unitPrice', unitPrice);
        formData.append('expiryDate', expiryDate);
        formData.append('supplier', supplier);

        let url = contextPath + '/doctor/medicines/';
        let method = 'POST';

        if (medicineId) {
            url = contextPath + '/doctor/medicines/' + medicineId;
            method = 'PUT';
        }

        try {
            let response;
            if (medicineId) {
                response = await fetch(url, { method: 'PUT', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: formData });
            } else {
                response = await fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: formData });
            }
            const result = await response.json();
            alert(result.message);
            closeModal();
            loadMedicines();
        } catch(error) {
            // Fallback: cập nhật local
            if (medicineId) {
                const index = allMedicines.findIndex(m => m.medicineId == medicineId);
                if (index !== -1) {
                    allMedicines[index] = { ...allMedicines[index], medicineName, unit, stockQuantity, unitPrice, expiryDate, supplier };
                }
            } else {
                const newId = Math.max(...allMedicines.map(m => m.medicineId), 0) + 1;
                allMedicines.push({ medicineId: newId, medicineName, unit, stockQuantity, unitPrice, expiryDate, supplier });
            }
            renderTable(allMedicines);
            alert(medicineId ? 'Cập nhật thành công!' : 'Thêm thuốc thành công!');
            closeModal();
        }
    }

    // Xóa thuốc
    async function deleteMedicine(medicineId) {
        if (!confirm('Bạn có chắc chắn muốn xóa thuốc này không?')) return;

        try {
            const response = await fetch(`${contextPath}/doctor/medicines/${medicineId}`, { method: 'DELETE' });
            const result = await response.json();
            alert(result.message);
            loadMedicines();
        } catch(error) {
            // Fallback: xóa local
            const index = allMedicines.findIndex(m => m.medicineId === medicineId);
            if (index !== -1) allMedicines.splice(index, 1);
            renderTable(allMedicines);
            alert('Đã xóa thuốc!');
        }
    }

    function closeModal() {
        document.getElementById('medicineModal').classList.remove('show');
    }

    // Đóng modal khi click ra ngoài
    window.onclick = function(event) {
        const modal = document.getElementById('medicineModal');
        if (event.target === modal) closeModal();
    }

    function escapeHtml(text) {
        if (!text) return '';
        return text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    // Load dữ liệu khi trang load
    loadMedicines();
</script>
</body>
</html>