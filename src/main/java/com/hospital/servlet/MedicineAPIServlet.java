package com.hospital.servlet;

import com.hospital.dao.MedicineDAO;
import com.hospital.model.Medicine;
import com.hospital.model.Account;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.sql.Date;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/doctor/medicines/*")
public class MedicineAPIServlet extends HttpServlet {
    
    private MedicineDAO medicineDAO = new MedicineDAO();
    
    // Kiểm tra quyền chung
    private boolean isAuthorized(HttpSession session) {
        if (session == null) return false;
        Account account = (Account) session.getAttribute("account");
        if (account == null) return false;
        String role = account.getRole();
        return "doctor".equalsIgnoreCase(role) || "admin".equalsIgnoreCase(role);
    }
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        
        HttpSession session = req.getSession(false);
        if (!isAuthorized(session)) {
            resp.setStatus(403);
            out.print("{\"error\":\"Forbidden\"}");
            return;
        }
        
        String pathInfo = req.getPathInfo();
        
        // GET /doctor/medicines - Lấy danh sách
        if (pathInfo == null || "/".equals(pathInfo)) {
            try {
                List<Medicine> medicines = medicineDAO.getAllMedicines();
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < medicines.size(); i++) {
                    if (i > 0) json.append(",");
                    Medicine m = medicines.get(i);
                    json.append("{")
                        .append("\"medicineId\":").append(m.getMedicineId()).append(",")
                        .append("\"medicineName\":\"").append(escapeJson(m.getMedicineName())).append("\",")
                        .append("\"unit\":\"").append(escapeJson(m.getUnit())).append("\",")
                        .append("\"stockQuantity\":").append(m.getStockQuantity()).append(",")
                        .append("\"unitPrice\":").append(m.getUnitPrice()).append(",")
                        .append("\"expiryDate\":\"").append(m.getExpiryDate() != null ? m.getExpiryDate() : "").append("\",")
                        .append("\"supplier\":\"").append(escapeJson(m.getSupplier() != null ? m.getSupplier() : "")).append("\"")
                        .append("}");
                }
                json.append("]");
                out.print(json.toString());
            } catch (Exception e) {
                e.printStackTrace();
                out.print("[]");
            }
        }
        // GET /doctor/medicines/{id}
        else if (pathInfo != null && pathInfo.matches("/\\d+")) {
            try {
                int id = Integer.parseInt(pathInfo.substring(1));
                Medicine m = medicineDAO.getMedicineById(id);
                if (m != null) {
                    StringBuilder json = new StringBuilder();
                    json.append("{")
                        .append("\"medicineId\":").append(m.getMedicineId()).append(",")
                        .append("\"medicineName\":\"").append(escapeJson(m.getMedicineName())).append("\",")
                        .append("\"unit\":\"").append(escapeJson(m.getUnit())).append("\",")
                        .append("\"stockQuantity\":").append(m.getStockQuantity()).append(",")
                        .append("\"unitPrice\":").append(m.getUnitPrice()).append(",")
                        .append("\"expiryDate\":\"").append(m.getExpiryDate() != null ? m.getExpiryDate() : "").append("\",")
                        .append("\"supplier\":\"").append(escapeJson(m.getSupplier() != null ? m.getSupplier() : "")).append("\"")
                        .append("}");
                    out.print(json.toString());
                } else {
                    out.print("{}");
                }
            } catch (Exception e) {
                out.print("{}");
            }
        }
        // GET /doctor/medicines/search?keyword=
        else if ("/search".equals(pathInfo)) {
            String keyword = req.getParameter("keyword");
            try {
                List<Medicine> medicines = medicineDAO.searchMedicines(keyword);
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < medicines.size(); i++) {
                    if (i > 0) json.append(",");
                    Medicine m = medicines.get(i);
                    json.append("{")
                        .append("\"medicineId\":").append(m.getMedicineId()).append(",")
                        .append("\"medicineName\":\"").append(escapeJson(m.getMedicineName())).append("\",")
                        .append("\"unit\":\"").append(escapeJson(m.getUnit())).append("\",")
                        .append("\"stockQuantity\":").append(m.getStockQuantity()).append(",")
                        .append("\"unitPrice\":").append(m.getUnitPrice()).append(",")
                        .append("\"expiryDate\":\"").append(m.getExpiryDate() != null ? m.getExpiryDate() : "").append("\",")
                        .append("\"supplier\":\"").append(escapeJson(m.getSupplier() != null ? m.getSupplier() : "")).append("\"")
                        .append("}");
                }
                json.append("]");
                out.print(json.toString());
            } catch (Exception e) {
                out.print("[]");
            }
        }
        out.flush();
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        
        HttpSession session = req.getSession(false);
        if (!isAuthorized(session)) {
            out.print("{\"success\":false,\"message\":\"Forbidden\"}");
            return;
        }
        
        String pathInfo = req.getPathInfo();
        
        // POST /doctor/medicines - Thêm thuốc mới
        if (pathInfo == null || "/".equals(pathInfo)) {
            try {
                String medicineName = req.getParameter("medicineName");
                String unit = req.getParameter("unit");
                int stockQuantity = Integer.parseInt(req.getParameter("stockQuantity"));
                double unitPrice = Double.parseDouble(req.getParameter("unitPrice"));
                String expiryDateStr = req.getParameter("expiryDate");
                String supplier = req.getParameter("supplier");

                if (medicineName == null || medicineName.trim().isEmpty()) {
                    out.print("{\"success\":false,\"message\":\"Tên thuốc không được để trống\"}");
                    return;
                }
                if (stockQuantity <= 0) {
                    out.print("{\"success\":false,\"message\":\"Số lượng tồn phải lớn hơn 0\"}");
                    return;
                }
                if (unitPrice <= 0) {
                    out.print("{\"success\":false,\"message\":\"Đơn giá phải lớn hơn 0\"}");
                    return;
                }
                if (expiryDateStr != null && !expiryDateStr.isEmpty()) {
                    LocalDate expiryDate = LocalDate.parse(expiryDateStr);
                    if (!expiryDate.isAfter(LocalDate.now())) {
                        out.print("{\"success\":false,\"message\":\"Hạn sử dụng phải là ngày mai trở đi\"}");
                        return;
                    }
                }

                Medicine medicine = new Medicine();
                medicine.setMedicineName(medicineName);
                medicine.setUnit(unit);
                medicine.setStockQuantity(stockQuantity);
                medicine.setUnitPrice(unitPrice);
                if (expiryDateStr != null && !expiryDateStr.isEmpty()) {
                    medicine.setExpiryDate(Date.valueOf(expiryDateStr));
                }
                medicine.setSupplier(supplier);
                
                int id = medicineDAO.createMedicine(medicine);
                if (id > 0) {
                    out.print("{\"success\":true,\"message\":\"Thêm thuốc thành công!\",\"medicineId\":" + id + "}");
                } else {
                    out.print("{\"success\":false,\"message\":\"Thêm thuốc thất bại!\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
            }
        }
        out.flush();
    }
    
    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        
        HttpSession session = req.getSession(false);
        if (!isAuthorized(session)) {
            out.print("{\"success\":false,\"message\":\"Forbidden\"}");
            return;
        }
        
        String pathInfo = req.getPathInfo();
        
        // PUT /doctor/medicines/{id}
        if (pathInfo != null && pathInfo.matches("/\\d+")) {
            try {
                int id = Integer.parseInt(pathInfo.substring(1));
                Map<String, String> putParams = parseFormBody(req);
                String medicineName = putParams.get("medicineName");
                String unit = putParams.get("unit");
                int stockQuantity = Integer.parseInt(putParams.getOrDefault("stockQuantity", "0"));
                double unitPrice = Double.parseDouble(putParams.getOrDefault("unitPrice", "0"));
                String expiryDateStr = putParams.get("expiryDate");
                String supplier = putParams.get("supplier");

                if (medicineName == null || medicineName.trim().isEmpty()) {
                    out.print("{\"success\":false,\"message\":\"Tên thuốc không được để trống\"}");
                    return;
                }
                if (stockQuantity <= 0) {
                    out.print("{\"success\":false,\"message\":\"Số lượng tồn phải lớn hơn 0\"}");
                    return;
                }
                if (unitPrice <= 0) {
                    out.print("{\"success\":false,\"message\":\"Đơn giá phải lớn hơn 0\"}");
                    return;
                }
                if (expiryDateStr != null && !expiryDateStr.isEmpty()) {
                    LocalDate expiryDate = LocalDate.parse(expiryDateStr);
                    if (!expiryDate.isAfter(LocalDate.now())) {
                        out.print("{\"success\":false,\"message\":\"Hạn sử dụng phải là ngày mai trở đi\"}");
                        return;
                    }
                }

                Medicine medicine = new Medicine();
                medicine.setMedicineId(id);
                medicine.setMedicineName(medicineName);
                medicine.setUnit(unit);
                medicine.setStockQuantity(stockQuantity);
                medicine.setUnitPrice(unitPrice);
                if (expiryDateStr != null && !expiryDateStr.isEmpty()) {
                    medicine.setExpiryDate(Date.valueOf(expiryDateStr));
                }
                medicine.setSupplier(supplier);
                
                boolean success = medicineDAO.updateMedicine(medicine);
                if (success) {
                    out.print("{\"success\":true,\"message\":\"Cập nhật thuốc thành công!\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"Cập nhật thất bại!\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"success\":false,\"message\":\"" + e.getMessage() + "\"}");
            }
        } else {
            out.print("{\"success\":false,\"message\":\"Invalid request\"}");
        }
        out.flush();
    }
    
    private Map<String, String> parseFormBody(HttpServletRequest req) throws IOException {
        Map<String, String> params = new HashMap<>();
        StringBuilder bodyBuilder = new StringBuilder();
        String line;
        try (java.io.BufferedReader reader = req.getReader()) {
            while ((line = reader.readLine()) != null) {
                bodyBuilder.append(line);
            }
        }
        String body = bodyBuilder.toString();
        if (body.isEmpty()) {
            return params;
        }
        for (String pair : body.split("&")) {
            String[] parts = pair.split("=", 2);
            if (parts.length == 2) {
                String key = URLDecoder.decode(parts[0], StandardCharsets.UTF_8.name());
                String value = URLDecoder.decode(parts[1], StandardCharsets.UTF_8.name());
                params.put(key, value);
            }
        }
        return params;
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        
        HttpSession session = req.getSession(false);
        if (!isAuthorized(session)) {
            out.print("{\"success\":false,\"message\":\"Forbidden\"}");
            return;
        }
        
        String pathInfo = req.getPathInfo();
        
        // DELETE /doctor/medicines/{id}
        if (pathInfo != null && pathInfo.matches("/\\d+")) {
            try {
                int id = Integer.parseInt(pathInfo.substring(1));
                boolean success = medicineDAO.deleteMedicine(id);
                if (success) {
                    out.print("{\"success\":true,\"message\":\"Xóa thuốc thành công!\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"Xóa thất bại!\"}");
                }
            } catch (SQLException e) {
                e.printStackTrace();
                String msg = e.getMessage() != null ? e.getMessage() : "Lỗi hệ thống";
                if (msg.contains("Cannot delete or update a parent row") || msg.toLowerCase().contains("foreign key")) {
                    out.print("{\"success\":false,\"message\":\"Không thể xóa thuốc này vì đã có đơn thuốc liên quan. Vui lòng kiểm tra đơn thuốc hoặc ẩn thuốc.\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"" + escapeJson(msg) + "\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"success\":false,\"message\":\"" + escapeJson(e.getMessage()) + "\"}");
            }
        } else {
            out.print("{\"success\":false,\"message\":\"Invalid request\"}");
        }
        out.flush();
    }
    
    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
}