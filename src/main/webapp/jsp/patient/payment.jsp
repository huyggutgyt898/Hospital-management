<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.hospital.model.Account" %>
<%@ include file="/jsp/common/patient_prefs.jsp" %>
<%
    Account account = (Account) session.getAttribute("account");
    if (account == null || !"patient".equalsIgnoreCase(account.getRole())) {
        response.sendRedirect(request.getContextPath() + "/jsp/auth/login.jsp");
        return;
    }
    String ctx = request.getContextPath();
    String initialAppointmentId = request.getParameter("appointmentId");
    if (initialAppointmentId == null) initialAppointmentId = "";
%>
<!DOCTYPE html>
<html lang="<%= patientIsEn ? "en" : "vi" %>">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pt(patientIsEn, "Thanh toán - HMS", "Payment - HMS") %></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <%@ include file="/jsp/common/patient_head.jsp" %>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', system-ui, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 24px 16px;
        }
        .container-custom { max-width: 1200px; margin: 0 auto; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px; color: #fff; }
        .header a { color: #fff; text-decoration: none; }
        .payment-container { display: flex; gap: 24px; flex-wrap: wrap; }
        .invoice-card, .payment-card {
            background: #fff; border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.15); overflow: hidden;
        }
        .invoice-card { flex: 1.2; min-width: 320px; }
        .payment-card { flex: 1; min-width: 300px; }
        .invoice-header, .payment-header {
            background: linear-gradient(135deg, #1e3a5f, #0f2b45);
            color: #fff; padding: 18px 24px;
        }
        .invoice-body, .payment-body { padding: 24px; }
        .bill-select { margin-bottom: 16px; }
        .bill-list {
            display: grid;
            gap: 12px;
            margin-top: 10px;
        }
        .bill-card {
            padding: 16px;
            border-radius: 14px;
            background: #f8fafc;
            border: 2px solid transparent;
            cursor: pointer;
            transition: border-color 0.2s, transform 0.2s;
        }
        .bill-card:hover {
            transform: translateY(-1px);
            border-color: #c7d2fe;
        }
        .bill-card.selected {
            border-color: #2563eb;
            background: #eff6ff;
        }
        .bill-select select {
            width: 100%; padding: 10px 14px; border-radius: 10px;
            border: 2px solid #e2e8f0; font-size: 14px;
        }
        .table-details { width: 100%; border-collapse: collapse; margin-top: 12px; }
        .table-details th, .table-details td {
            padding: 10px 8px; border-bottom: 1px solid #e2e8f0; font-size: 14px;
        }
        .table-details th { background: #f8fafc; }
        .total-row td { font-weight: 700; font-size: 16px; color: #047857; }
        .discount-row td { color: #2563eb; }
        .amount-display {
            background: linear-gradient(135deg, #10b981, #059669);
            color: #fff; padding: 20px; border-radius: 14px; text-align: center; margin-bottom: 20px;
        }
        .amount-display .value { font-size: 32px; font-weight: 800; }
        .payment-method {
            display: flex; align-items: center; gap: 12px;
            padding: 14px 16px; border: 2px solid #e2e8f0; border-radius: 12px;
            margin-bottom: 12px; cursor: pointer; transition: all 0.2s;
        }
        .payment-method.selected { border-color: #2563eb; background: #eff6ff; }
        .btn-pay {
            width: 100%; background: linear-gradient(135deg, #10b981, #059669);
            color: #fff; border: none; padding: 14px; border-radius: 12px;
            font-weight: 700; font-size: 16px; cursor: pointer; margin-top: 8px;
        }
        .btn-pay:disabled { opacity: 0.6; cursor: not-allowed; }
        .qr-panel {
            display: none; text-align: center; margin-top: 16px;
            padding: 16px; background: #f8fafc; border-radius: 12px;
        }
        .qr-panel.show { display: block; }
        .qr-panel img { max-width: 260px; border-radius: 12px; border: 2px solid #e2e8f0; }
        .status-badge {
            display: inline-block; padding: 6px 12px; border-radius: 20px;
            font-size: 12px; font-weight: 600;
        }
        .status-unpaid { background: #fef3c7; color: #b45309; }
        .status-pending { background: #dbeafe; color: #1d4ed8; }
        .status-paid { background: #dcfce7; color: #166534; }
        .empty-msg { text-align: center; padding: 40px; color: #64748b; }
        .modal { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center; }
        .modal.show { display: flex; }
        .modal-content { background: #fff; padding: 32px; border-radius: 16px; text-align: center; max-width: 400px; }
    </style>
</head>
<body class="<%= patientIsDark ? "patient-dark" : "" %>">
<div class="container-custom">
    <div class="header">
        <a href="<%= ctx %>/index.jsp"><i class="fas fa-arrow-left me-2"></i><%= pt(patientIsEn, "Quay lại trang chủ", "Back to home") %></a>
        <div>
            <span><i class="fas fa-user-circle me-1"></i><%= account.getFullname() %></span>
            <a href="<%= ctx %>/logout" class="ms-3"><%= pt(patientIsEn, "Đăng xuất", "Logout") %></a>
        </div>
    </div>

    <div class="payment-container">
        <div class="invoice-card">
            <div class="invoice-header">
                <h3><i class="fas fa-file-invoice me-2"></i><%= pt(patientIsEn, "HÓA ĐƠN THANH TOÁN", "PAYMENT INVOICE") %></h3>
            </div>
            <div class="invoice-body">
                <div class="bill-select">
                    <label class="form-label fw-bold"><%= pt(patientIsEn, "Danh sách hóa đơn cần thanh toán", "List of payable invoices") %></label>
                    <div id="billList" class="bill-list"></div>
                </div>
                <div id="invoiceContent">
                    <div class="empty-msg"><i class="fas fa-spinner fa-spin"></i> <%= pt(patientIsEn, "Đang tải hóa đơn...", "Loading invoice...") %></div>
                </div>
            </div>
        </div>

        <div class="payment-card">
            <div class="payment-header">
                <h3><i class="fas fa-credit-card me-2"></i><%= pt(patientIsEn, "THANH TOÁN", "PAYMENT") %></h3>
            </div>
            <div class="payment-body">
                <div class="amount-display">
                    <div class="label"><%= pt(patientIsEn, "SỐ TIỀN CẦN THANH TOÁN", "AMOUNT DUE") %></div>
                    <div class="value" id="totalDisplay">0đ</div>
                </div>

                <div id="payBlock">
                    <div class="payment-method" onclick="selectMethod('cash', event)">
                        <input type="radio" name="paymentMethod" id="cash" value="cash">
                        <i class="fas fa-money-bill-wave fa-lg"></i>
                        <span class="flex-grow-1"><%= pt(patientIsEn, "Tiền mặt (chờ admin xác nhận)", "Cash (admin confirmation)") %></span>
                    </div>
                    <div class="payment-method" onclick="selectMethod('qr', event)">
                        <input type="radio" name="paymentMethod" id="qr" value="qr">
                        <i class="fas fa-qrcode fa-lg"></i>
                        <span class="flex-grow-1"><%= pt(patientIsEn, "Chuyển khoản/QR (chờ admin xác nhận)", "Bank transfer/QR (awaiting admin)") %></span>
                    </div>

                    <div class="qr-panel" id="qrPanel">
                        <p class="mb-2"><strong>HOANG MINH HIEU — MB Bank</strong><br>0961016972</p>
                        <img src="<%= ctx %>/assets/img/payment-qr.png" alt="VietQR">
                        <p class="mt-2 small text-muted"><%= pt(patientIsEn, "Chuyển khoản đúng số tiền bên trên và chờ admin xác nhận", "Transfer the exact amount shown and wait for admin confirmation") %></p>
                    </div>

                    <button type="button" class="btn-pay" id="btnPay" onclick="processPayment()">
                        <i class="fas fa-shield-alt me-2"></i><%= pt(patientIsEn, "THANH TOÁN NGAY", "PAY NOW") %>
                    </button>
                </div>
                <div id="paidMessage" style="display:none;" class="text-center text-success fw-bold py-4">
                    <i class="fas fa-check-circle fa-3x mb-3"></i>
                    <p id="paidMessageText"></p>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="modal" id="successModal">
    <div class="modal-content">
        <i class="fas fa-check-circle fa-4x text-success mb-3"></i>
        <h4 id="modalTitle"><%= pt(patientIsEn, "Thành công", "Success") %></h4>
        <p id="modalBody"></p>
        <button class="btn btn-primary mt-3" onclick="closeModalAndRedirect()"><%= pt(patientIsEn, "Về trang chủ", "Back to home") %></button>
    </div>
</div>

<script>
    const contextPath = '<%= ctx %>';
    const patientLang = '<%= patientLang %>';
    const initialAppointmentId = '<%= initialAppointmentId %>';
    let selectedMethod = null;
    let currentBill = null;

    function fmt(n) {
        return new Intl.NumberFormat('vi-VN').format(Math.round(n)) + 'đ';
    }

    function t(vi, en) { return patientLang === 'en' ? en : vi; }

    function paymentStatusLabel(status) {
        if (status === 'paid') return '<span class="status-badge status-paid">' + t('Đã thanh toán', 'Paid') + '</span>';
        if (status === 'pending_admin') return '<span class="status-badge status-pending">' + t('Chờ admin xác nhận', 'Awaiting admin') + '</span>';
        return '<span class="status-badge status-unpaid">' + t('Chưa thanh toán', 'Unpaid') + '</span>';
    }

    let bills = [];

    async function loadBillList() {
        const billList = document.getElementById('billList');
        try {
            const res = await fetch(contextPath + '/payment/my-bills');
            bills = (await res.json()).filter(b => b.paymentStatus !== 'paid');
            if (bills.length === 0) {
                billList.innerHTML = '<div class="empty-msg"><i class="fas fa-info-circle"></i> ' + t('Chưa có hóa đơn cần thanh toán. Lịch hẹn phải hoàn thành và đã kê đơn.', 'No bills to pay yet.') + '</div>';
                document.getElementById('invoiceContent').innerHTML = '<div class="empty-msg"><i class="fas fa-info-circle"></i> ' + t('Chưa có hóa đơn cần thanh toán. Lịch hẹn phải hoàn thành và đã kê đơn.', 'No bills to pay yet.') + '</div>';
                updatePayUI({ paymentStatus: 'paid' });
                return;
            }

            billList.innerHTML = bills.map(b =>
                '<div id="bill-card-' + b.appointmentId + '" class="bill-card" onclick="selectBill(' + b.appointmentId + ')">' +
                    '<div><strong>#' + b.appointmentId + '</strong> — ' + (b.doctorName || '') + '</div>' +
                    '<div>' + (b.appointmentDate || '') + ' ' + (b.appointmentTime || '') + '</div>' +
                    '<div>' + paymentStatusLabel(b.paymentStatus) + ' • <strong>' + fmt(b.totalAmount) + '</strong></div>' +
                '</div>'
            ).join('');

            const selectedId = initialAppointmentId || bills[0].appointmentId;
            selectBill(selectedId);
        } catch (e) {
            console.error(e);
            billList.innerHTML = '<div class="empty-msg text-danger">' + t('Lỗi tải danh sách hóa đơn', 'Failed to load bill list') + '</div>';
        }
    }

    async function selectBill(appointmentId) {
        if (!appointmentId) return;
        currentBill = bills.find(b => b.appointmentId === Number(appointmentId));
        document.querySelectorAll('.bill-card').forEach(el => el.classList.remove('selected'));
        const card = document.getElementById('bill-card-' + appointmentId);
        if (card) card.classList.add('selected');
        await loadInvoice(appointmentId);
    }

    async function loadInvoice(id) {
        if (!id) return;
        document.getElementById('invoiceContent').innerHTML = '<div class="empty-msg"><i class="fas fa-spinner fa-spin"></i></div>';
        try {
            const res = await fetch(contextPath + '/payment/invoice?appointmentId=' + id);
            const data = await res.json();
            if (!data.success) {
                document.getElementById('invoiceContent').innerHTML = '<div class="empty-msg text-danger">' + (data.message || 'Error') + '</div>';
                return;
            }
            currentBill = data;
            renderInvoice(data);
            updatePayUI(data);
        } catch (e) {
            document.getElementById('invoiceContent').innerHTML = '<div class="empty-msg text-danger">' + t('Lỗi tải hóa đơn', 'Failed to load invoice') + '</div>';
        }
    }

    function renderInvoice(data) {
        let rows = '';
        (data.lines || []).forEach(line => {
            rows += '<tr><td>' + line.description + '</td><td>' + line.quantity + ' ' + (line.unit || '') + '</td><td>' + fmt(line.unitPrice) + '</td><td>' + fmt(line.lineTotal) + '</td></tr>';
        });
        let discountHtml = '';
        if (data.discountAmount > 0) {
            discountHtml = '<tr class="discount-row"><td colspan="3">' + t('Giảm BHYT (80%)', 'Insurance discount (80%)') + '</td><td>-' + fmt(data.discountAmount) + '</td></tr>';
        }
        document.getElementById('invoiceContent').innerHTML =
            '<div class="invoice-info" style="background:#f8fafc;padding:12px;border-radius:10px;margin-bottom:12px;">' +
            '<div><strong>' + t('Mã lịch hẹn', 'Appointment') + ':</strong> #' + data.appointmentId + '</div>' +
            '<div><strong>' + t('Bệnh nhân', 'Patient') + ':</strong> ' + (data.patientName || '') + '</div>' +
            '<div><strong>' + t('Bác sĩ', 'Doctor') + ':</strong> ' + (data.doctorName || '') + '</div>' +
            '<div><strong>' + t('Ngày khám', 'Date') + ':</strong> ' + (data.appointmentDate || '') + ' ' + (data.appointmentTime || '') + '</div>' +
            '<div class="mt-2">' + paymentStatusLabel(data.paymentStatus) + (data.hasInsurance ? ' <span class="badge bg-primary">' + t('Có BHYT', 'Insured') + '</span>' : '') + '</div></div>' +
            '<table class="table-details"><thead><tr><th>' + t('Dịch vụ', 'Service') + '</th><th>' + t('SL', 'Qty') + '</th><th>' + t('Đơn giá', 'Unit') + '</th><th>' + t('Thành tiền', 'Total') + '</th></tr></thead><tbody>' +
            rows + '<tr><td colspan="3"><strong>' + t('Tạm tính', 'Subtotal') + '</strong></td><td>' + fmt(data.subtotal) + '</td></tr>' +
            discountHtml + '<tr class="total-row"><td colspan="3"><strong>' + t('Tổng thanh toán', 'Total due') + '</strong></td><td><strong>' + fmt(data.totalAmount) + '</strong></td></tr></tbody></table>';
        document.getElementById('totalDisplay').textContent = fmt(data.totalAmount);
    }

    function updatePayUI(data) {
        const paid = data.paymentStatus === 'paid';
        const pending = data.paymentStatus === 'pending_admin';
        document.getElementById('payBlock').style.display = (paid || pending) ? 'none' : 'block';
        document.getElementById('paidMessage').style.display = (paid || pending) ? 'block' : 'none';
        if (paid) document.getElementById('paidMessageText').textContent = t('Hóa đơn đã thanh toán.', 'Invoice already paid.');
        if (pending) document.getElementById('paidMessageText').textContent = t('Đã gửi yêu cầu thanh toán. Chờ admin xác nhận.', 'Payment request sent. Awaiting admin confirmation.');
    }

    function selectMethod(method, ev) {
        selectedMethod = method;
        document.querySelectorAll('.payment-method').forEach(el => el.classList.remove('selected'));
        if (ev && ev.currentTarget) ev.currentTarget.classList.add('selected');
        document.getElementById(method).checked = true;
        document.getElementById('qrPanel').classList.toggle('show', method === 'qr');
    }

    async function processPayment() {
        if (!currentBill || !currentBill.appointmentId) {
            alert(t('Vui lòng chọn hóa đơn', 'Please select an invoice'));
            return;
        }
        if (!selectedMethod) {
            alert(t('Vui lòng chọn phương thức thanh toán', 'Please select payment method'));
            return;
        }
        const btn = document.getElementById('btnPay');
        btn.disabled = true;
        try {
            const body = new URLSearchParams();
            body.append('appointmentId', currentBill.appointmentId);
            body.append('paymentMethod', selectedMethod);
            const res = await fetch(contextPath + '/payment/submit', { method: 'POST', body: body });
            const data = await res.json();
            if (data.success) {
                document.getElementById('modalBody').textContent = data.message;
                document.getElementById('successModal').classList.add('show');
                await loadInvoice(currentBill.appointmentId);
                await loadBillList();
            } else {
                alert(data.message || t('Thanh toán thất bại', 'Payment failed'));
            }
        } catch (e) {
            alert(t('Lỗi kết nối', 'Connection error'));
        } finally {
            btn.disabled = false;
        }
    }

    function closeModalAndRedirect() {
        window.location.href = contextPath + '/index.jsp';
    }

    document.addEventListener('DOMContentLoaded', loadBillList);
</script>
<script src="<%= ctx %>/js/patient-preferences.js"></script>
</body>
</html>
