package com.hospital.servlet;

import com.hospital.dao.PaymentDAO;
import com.hospital.model.Account;
import com.hospital.model.BillDetail;
import com.hospital.model.BillLine;
import com.hospital.model.Payment;
import com.hospital.service.BillingService;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.json.JSONArray;
import org.json.JSONObject;

@WebServlet("/payment/*")
public class PaymentServlet extends HttpServlet {

    private final BillingService billingService = new BillingService();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String path = req.getPathInfo();

        try {
            if ("/revenue".equals(path)) {
                if (!isAdmin(req, resp)) {
                    return;
                }
                // Trả về dữ liệu doanh thu theo ngày cho 30 ngày gần nhất
                Map<String, Double> daily = paymentDAO.getDailyRevenueLastMonth();
                JSONObject json = new JSONObject();
                json.put("totalRevenue", paymentDAO.getTotalRevenue());
                JSONArray labels = new JSONArray();
                JSONArray values = new JSONArray();
                for (Map.Entry<String, Double> e : daily.entrySet()) {
                    labels.put(e.getKey());
                    values.put(e.getValue());
                }
                json.put("labels", labels);
                json.put("values", values);
                out.print(json.toString());
                return;
            }

            if ("/admin/list".equals(path)) {
                if (!isAdmin(req, resp)) {
                    return;
                }
                String filter = req.getParameter("filter");
                if (filter == null) {
                    filter = "all";
                }
                out.print(paymentsToJson(paymentDAO.listForAdmin(filter)));
                return;
            }

            if ("/my-bills".equals(path)) {
                Integer patientId = requirePatientId(req);
                if (patientId == null) {
                    out.print("[]");
                    return;
                }
                out.print(paymentsToJson(paymentDAO.listPayableByPatient(patientId)));
                return;
            }

            if ("/invoice".equals(path)) {
                int appointmentId = Integer.parseInt(req.getParameter("appointmentId"));
                BillDetail bill = billingService.buildBill(appointmentId);
                if (bill == null) {
                    out.print("{\"success\":false,\"message\":\"Không tìm thấy lịch hẹn\"}");
                    return;
                }
                Account account = (Account) req.getSession().getAttribute("account");
                if (account != null && "patient".equalsIgnoreCase(account.getRole())) {
                    Integer patientId = (Integer) req.getSession().getAttribute("patientId");
                    if (patientId != null && patientId != bill.getPatientId()) {
                        resp.setStatus(403);
                        out.print("{\"success\":false,\"message\":\"Forbidden\"}");
                        return;
                    }
                }
                out.print(billToJson(bill).put("success", true).toString());
                return;
            }

            out.print("{\"success\":false,\"message\":\"Not found\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"" + esc(e.getMessage()) + "\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String path = req.getPathInfo();

        try {
            if ("/submit".equals(path)) {
                Integer patientId = requirePatientId(req);
                if (patientId == null) {
                    out.print("{\"success\":false,\"message\":\"Vui lòng đăng nhập\"}");
                    return;
                }
                int appointmentId = Integer.parseInt(req.getParameter("appointmentId"));
                String method = req.getParameter("paymentMethod");
                if (!"cash".equals(method) && !"qr".equals(method)) {
                    out.print("{\"success\":false,\"message\":\"Phương thức không hợp lệ\"}");
                    return;
                }
                BillDetail bill = billingService.buildBill(appointmentId);
                if (bill == null || bill.getPatientId() != patientId) {
                    out.print("{\"success\":false,\"message\":\"Không có quyền\"}");
                    return;
                }
                if (!"completed".equals(bill.getAppointmentStatus())) {
                    out.print("{\"success\":false,\"message\":\"Chỉ thanh toán khi lịch hẹn đã hoàn thành\"}");
                    return;
                }
                billingService.syncPaymentRecord(appointmentId);
                boolean ok = paymentDAO.submitPayment(appointmentId, patientId, method);
                if (ok) {
                    String msg = ("cash".equals(method) || "qr".equals(method))
                            ? "Đã gửi yêu cầu thanh toán. Vui lòng chờ admin xác nhận."
                            : "Thanh toán thành công!";
                    out.print("{\"success\":true,\"message\":\"" + esc(msg) + "\",\"status\":\"pending_admin\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"Không thể thanh toán (có thể đã thanh toán)\"}");
                }
                return;
            }

            if ("/admin/confirm".equals(path)) {
                if (!isAdmin(req, resp)) {
                    return;
                }
                int paymentId = Integer.parseInt(req.getParameter("paymentId"));
                boolean ok = paymentDAO.adminConfirmCash(paymentId);
                out.print(ok
                        ? "{\"success\":true,\"message\":\"Đã xác nhận thanh toán hóa đơn\"}"
                        : "{\"success\":false,\"message\":\"Xác nhận thất bại\"}");
                return;
            }

            out.print("{\"success\":false,\"message\":\"Not found\"}");
        } catch (Exception e) {
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"" + esc(e.getMessage()) + "\"}");
        }
    }

    private Integer requirePatientId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return null;
        }
        return (Integer) session.getAttribute("patientId");
    }

    private boolean isAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            resp.setStatus(401);
            resp.getWriter().print("{\"error\":\"Unauthorized\"}");
            return false;
        }
        Account account = (Account) session.getAttribute("account");
        if (!"admin".equalsIgnoreCase(account.getRole())) {
            resp.setStatus(403);
            resp.getWriter().print("{\"error\":\"Forbidden\"}");
            return false;
        }
        return true;
    }

    private JSONArray paymentsToJson(List<Payment> list) {
        JSONArray arr = new JSONArray();
        for (Payment p : list) {
            arr.put(new JSONObject()
                    .put("paymentId", p.getPaymentId())
                    .put("appointmentId", p.getAppointmentId())
                    .put("patientId", p.getPatientId())
                    .put("patientName", p.getPatientName() != null ? p.getPatientName() : "")
                    .put("doctorName", p.getDoctorName() != null ? p.getDoctorName() : "")
                    .put("appointmentDate", p.getAppointmentDate() != null ? p.getAppointmentDate() : "")
                    .put("appointmentTime", p.getAppointmentTime() != null ? p.getAppointmentTime() : "")
                    .put("totalAmount", p.getTotalAmount())
                    .put("paymentStatus", p.getPaymentStatus())
                    .put("paymentMethod", p.getPaymentMethod() != null ? p.getPaymentMethod() : "")
                    .put("hasInsurance", p.isHasInsurance()));
        }
        return arr;
    }

    private JSONObject billToJson(BillDetail bill) {
        JSONObject json = new JSONObject();
        json.put("appointmentId", bill.getAppointmentId());
        json.put("patientName", bill.getPatientName());
        json.put("doctorName", bill.getDoctorName());
        json.put("appointmentDate", bill.getAppointmentDate());
        json.put("appointmentTime", bill.getAppointmentTime());
        json.put("appointmentStatus", bill.getAppointmentStatus());
        json.put("hasInsurance", bill.isHasInsurance());
        json.put("examinationFee", bill.getExaminationFee());
        json.put("medicineFee", bill.getMedicineFee());
        json.put("subtotal", bill.getSubtotal());
        json.put("discountPercent", bill.getDiscountPercent());
        json.put("discountAmount", bill.getDiscountAmount());
        json.put("totalAmount", bill.getTotalAmount());
        json.put("paymentStatus", bill.getPaymentStatus());
        json.put("paymentMethod", bill.getPaymentMethod() != null ? bill.getPaymentMethod() : "");
        JSONArray lines = new JSONArray();
        for (BillLine line : bill.getLines()) {
            lines.put(new JSONObject()
                    .put("description", line.getDescription())
                    .put("quantity", line.getQuantity())
                    .put("unitPrice", line.getUnitPrice())
                    .put("lineTotal", line.getLineTotal())
                    .put("unit", line.getUnit()));
        }
        json.put("lines", lines);
        return json;
    }

    private String esc(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
