<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hospital.model.Account" %>
<%@ page import="java.util.*" %>
<%@ include file="/jsp/common/patient_prefs.jsp" %>
<%
    Account account = (Account) session.getAttribute("account");
    if (account == null || !"patient".equalsIgnoreCase(account.getRole())) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
    
    // Dữ liệu mẫu - thực tế sẽ lấy từ database
    String invoiceId = request.getParameter("invoiceId") != null ? request.getParameter("invoiceId") : "INV-001";
    String appointmentId = request.getParameter("appointmentId") != null ? request.getParameter("appointmentId") : "APT-001";
    String doctorName = "Bác sĩ Nguyễn Văn An";
    String appointmentDate = "2024-05-15";
    double examinationFee = 200000;
    double medicineFee = 350000;
    double totalAmount = examinationFee + medicineFee;
%>
<!DOCTYPE html>
<html lang="<%= patientIsEn ? "en" : "vi" %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= patientIsEn ? "Payment - HMS" : "Thanh toán - HMS" %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <%@ include file="/jsp/common/patient_head.jsp" %>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }
        
        .container-custom {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        /* Header */
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            color: white;
        }
        
        .header a {
            color: white;
            text-decoration: none;
        }
        
        /* Payment Container */
        .payment-container {
            display: flex;
            gap: 30px;
            flex-wrap: wrap;
        }
        
        /* Invoice Card */
        .invoice-card {
            flex: 1.2;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
            overflow: hidden;
        }
        
        .invoice-header {
            background: linear-gradient(135deg, #1e3a5f, #0f2b45);
            color: white;
            padding: 20px 25px;
        }
        
        .invoice-header h3 {
            margin: 0;
            font-size: 20px;
        }
        
        .invoice-body {
            padding: 25px;
        }
        
        .hospital-info {
            text-align: center;
            padding-bottom: 20px;
            border-bottom: 2px dashed #e2e8f0;
            margin-bottom: 20px;
        }
        
        .hospital-info h2 {
            color: #1e3a5f;
            font-weight: 800;
        }
        
        .invoice-info {
            background: #f8fafc;
            padding: 15px;
            border-radius: 12px;
            margin-bottom: 20px;
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
        }
        
        .invoice-info-item {
            margin: 5px 0;
        }
        
        .invoice-info-item strong {
            color: #475569;
        }
        
        .table-details {
            width: 100%;
            margin-bottom: 20px;
        }
        
        .table-details th, .table-details td {
            padding: 12px;
            border-bottom: 1px solid #e2e8f0;
        }
        
        .table-details th {
            background: #f8fafc;
            font-weight: 600;
        }
        
        .total-row {
            background: #f1f5f9;
            font-weight: 700;
            font-size: 18px;
        }
        
        /* Payment Card */
        .payment-card {
            flex: 0.8;
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.15);
            overflow: hidden;
            align-self: flex-start;
            position: sticky;
            top: 20px;
        }
        
        .payment-header {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
            padding: 20px 25px;
        }
        
        .payment-body {
            padding: 25px;
        }
        
        .amount-display {
            text-align: center;
            padding: 20px;
            background: #f0fdf4;
            border-radius: 16px;
            margin-bottom: 25px;
        }
        
        .amount-display .label {
            font-size: 14px;
            color: #065f46;
        }
        
        .amount-display .value {
            font-size: 32px;
            font-weight: 800;
            color: #059669;
        }
        
        .payment-methods {
            margin-bottom: 25px;
        }
        
        .payment-method {
            display: flex;
            align-items: center;
            padding: 15px;
            border: 2px solid #e2e8f0;
            border-radius: 12px;
            margin-bottom: 12px;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .payment-method:hover {
            border-color: #10b981;
            background: #f0fdf4;
        }
        
        .payment-method.selected {
            border-color: #10b981;
            background: #f0fdf4;
        }
        
        .payment-method input {
            margin-right: 12px;
        }
        
        .payment-method i {
            font-size: 24px;
            width: 40px;
            color: #64748b;
        }
        
        .payment-method.selected i {
            color: #10b981;
        }
        
        .payment-method .method-name {
            font-weight: 600;
            flex: 1;
        }
        
        .btn-pay {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s;
        }
        
        .btn-pay:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(16,185,129,0.35);
        }
        
        .secure-badge {
            text-align: center;
            margin-top: 20px;
            font-size: 12px;
            color: #94a3b8;
        }
        
        /* Modal */
        .modal {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 1000;
            align-items: center;
            justify-content: center;
        }
        
        .modal.show {
            display: flex;
        }
        
        .modal-content {
            background: white;
            border-radius: 20px;
            width: 90%;
            max-width: 400px;
            text-align: center;
            padding: 30px;
            animation: popIn 0.3s ease;
        }
        
        @keyframes popIn {
            from {
                opacity: 0;
                transform: scale(0.8);
            }
            to {
                opacity: 1;
                transform: scale(1);
            }
        }
        
        .success-icon {
            width: 70px;
            height: 70px;
            background: #d1fae5;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
        }
        
        .success-icon i {
            font-size: 35px;
            color: #10b981;
        }
        
        .modal h4 {
            font-size: 24px;
            margin-bottom: 10px;
        }
        
        .btn-close-modal {
            margin-top: 20px;
            padding: 10px 30px;
            background: #10b981;
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
        }
        
        @media (max-width: 768px) {
            .payment-container {
                flex-direction: column;
            }
            .payment-card {
                position: static;
            }
        }
    </style>
</head>
<body class="<%= patientIsDark ? "patient-dark" : "" %>">
<div class="container-custom">
    <!-- Header -->
    <div class="header">
        <a href="${pageContext.request.contextPath}/index.jsp">
            <i class="fas fa-arrow-left me-2"></i><%= pt(patientIsEn, "Quay lại trang chủ", "Back to home") %>
        </a>
        <div>
            <span><i class="fas fa-user-circle me-1"></i><%= account.getFullname() %></span>
            <a href="${pageContext.request.contextPath}/logout" class="ms-3"><%= pt(patientIsEn, "Đăng xuất", "Logout") %></a>
        </div>
    </div>

    <div class="payment-container">
        <!-- Invoice Card -->
        <div class="invoice-card">
            <div class="invoice-header">
                <h3><i class="fas fa-file-invoice me-2"></i><%= pt(patientIsEn, "HÓA ĐƠN THANH TOÁN", "PAYMENT INVOICE") %></h3>
            </div>
            <div class="invoice-body">
                <div class="hospital-info">
                    <h2>🏥 HMS</h2>
                    <p>Bệnh viện đa khoa HMS<br>123 Đường Nguyễn Trãi, Hà Nội</p>
                </div>
                
                <div class="invoice-info">
                    <div class="invoice-info-item"><strong>Số hóa đơn:</strong> <%= invoiceId %></div>
                    <div class="invoice-info-item"><strong>Ngày lập:</strong> <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(new java.util.Date()) %></div>
                    <div class="invoice-info-item"><strong>Mã lịch hẹn:</strong> <%= appointmentId %></div>
                    <div class="invoice-info-item"><strong>Bệnh nhân:</strong> <%= account.getFullname() %></div>
                </div>
                
                <table class="table-details">
                    <thead>
                        <tr><th>Dịch vụ</th><th>Số lượng</th><th>Đơn giá</th><th>Thành tiền</th></tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Phí khám bệnh (BS. <%= doctorName %>)</td>
                            <td>1</td>
                            <td><%= String.format("%,.0f", examinationFee) %>đ</td>
                            <td><%= String.format("%,.0f", examinationFee) %>đ</td>
                        </tr>
                        <tr>
                            <td>Thuốc điều trị</td>
                            <td>1</td>
                            <td><%= String.format("%,.0f", medicineFee) %>đ</td>
                            <td><%= String.format("%,.0f", medicineFee) %>đ</td>
                        </tr>
                    </tbody>
                    <tfoot>
                        <tr class="total-row">
                            <td colspan="3"><strong>Tổng cộng</strong></td>
                            <td><strong><%= String.format("%,.0f", totalAmount) %>đ</strong></td>
                        </tr>
                    </tfoot>
                </table>
                
                <div class="invoice-info" style="margin-top: 20px;">
                    <div class="invoice-info-item"><strong>Hình thức thanh toán:</strong> <span id="selectedMethodLabel">Chưa chọn</span></div>
                    <div class="invoice-info-item"><strong>Trạng thái:</strong> <span class="badge bg-warning">Chờ thanh toán</span></div>
                </div>
            </div>
        </div>
        
        <!-- Payment Card -->
        <div class="payment-card">
            <div class="payment-header">
                <h3><i class="fas fa-credit-card me-2"></i><%= pt(patientIsEn, "THANH TOÁN", "PAYMENT") %></h3>
            </div>
            <div class="payment-body">
                <div class="amount-display">
                    <div class="label"><%= pt(patientIsEn, "SỐ TIỀN CẦN THANH TOÁN", "AMOUNT DUE") %></div>
                    <div class="value"><%= String.format("%,.0f", totalAmount) %>đ</div>
                </div>
                
                <div class="payment-methods">
                    <div class="payment-method" onclick="selectMethod('cash')">
                        <input type="radio" name="paymentMethod" id="cash" value="cash">
                        <i class="fas fa-money-bill-wave"></i>
                        <span class="method-name">Tiền mặt tại quầy</span>
                        <i class="fas fa-chevron-right"></i>
                    </div>
                    <div class="payment-method" onclick="selectMethod('bank')">
                        <input type="radio" name="paymentMethod" id="bank" value="bank">
                        <i class="fas fa-university"></i>
                        <span class="method-name">Chuyển khoản ngân hàng</span>
                        <i class="fas fa-chevron-right"></i>
                    </div>
                    <div class="payment-method" onclick="selectMethod('card')">
                        <input type="radio" name="paymentMethod" id="card" value="card">
                        <i class="fas fa-credit-card"></i>
                        <span class="method-name">Thẻ tín dụng / Ghi nợ</span>
                        <i class="fas fa-chevron-right"></i>
                    </div>
                    <div class="payment-method" onclick="selectMethod('qr')">
                        <input type="radio" name="paymentMethod" id="qr" value="qr">
                        <i class="fas fa-qrcode"></i>
                        <span class="method-name">QR Code</span>
                        <i class="fas fa-chevron-right"></i>
                    </div>
                </div>
                
                <button class="btn-pay" onclick="processPayment()">
                    <i class="fas fa-shield-alt me-2"></i>THANH TOÁN NGAY
                </button>
                
                <div class="secure-badge">
                    <i class="fas fa-lock me-1"></i> Thanh toán an toàn, bảo mật
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Success Modal -->
<div class="modal" id="successModal">
    <div class="modal-content">
        <div class="success-icon">
            <i class="fas fa-check-circle"></i>
        </div>
        <h4>Thanh toán thành công!</h4>
        <p>Cảm ơn bạn đã sử dụng dịch vụ của HMS.<br>Hóa đơn của bạn đã được thanh toán.</p>
        <button class="btn-close-modal" onclick="closeModalAndRedirect()">Về trang chủ</button>
    </div>
</div>

<script>
    let selectedMethod = null;
    
    function selectMethod(method) {
        selectedMethod = method;
        
        // Update UI
        document.querySelectorAll('.payment-method').forEach(el => {
            el.classList.remove('selected');
        });
        event.currentTarget.classList.add('selected');
        
        // Check radio button
        document.getElementById(method).checked = true;
        
        // Update label
        const methodNames = {
            'cash': 'Tiền mặt tại quầy',
            'bank': 'Chuyển khoản ngân hàng',
            'card': 'Thẻ tín dụng / Ghi nợ',
            'qr': 'QR Code'
        };
        document.getElementById('selectedMethodLabel').innerText = methodNames[method];
    }
    
    async function processPayment() {
        if (!selectedMethod) {
            alert('Vui lòng chọn phương thức thanh toán!');
            return;
        }
        
        // Disable button and show loading
        const btn = document.querySelector('.btn-pay');
        btn.disabled = true;
        btn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Đang xử lý...';
        
        // Simulate payment processing (call API here)
        setTimeout(() => {
            // Show success modal
            document.getElementById('successModal').classList.add('show');
            
            // Reset button
            btn.disabled = false;
            btn.innerHTML = '<i class="fas fa-shield-alt me-2"></i>THANH TOÁN NGAY';
        }, 1500);
        
        // Thực tế sẽ gọi API:
        // const response = await fetch(contextPath + '/payment/process', {
        //     method: 'POST',
        //     headers: { 'Content-Type': 'application/json' },
        //     body: JSON.stringify({
        //         invoiceId: '<%= invoiceId %>',
        //         paymentMethod: selectedMethod,
        //         amount: <%= totalAmount %>
        //     })
        // });
    }
    
    function closeModalAndRedirect() {
        window.location.href = '${pageContext.request.contextPath}/index.jsp';
    }
    
    // Close modal when clicking outside
    window.onclick = function(event) {
        const modal = document.getElementById('successModal');
        if (event.target === modal) {
            modal.classList.remove('show');
        }
    }
</script>
<script src="${pageContext.request.contextPath}/js/patient-preferences.js"></script>
</body>
</html>