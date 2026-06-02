/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.hospital.servlet;

/**
 *
 * @author ICT
 */
import com.hospital.dao.DoctorDAO;
import com.hospital.dao.PatientDAO;
import com.hospital.dao.AccountDAO;
import com.hospital.dao.ReportDAO;
import com.hospital.dao.AdminDAO;
import com.hospital.model.Account;
import com.hospital.model.Doctor;
import com.hospital.model.Report;
import com.hospital.util.PasswordHash;
import java.io.IOException;
import static java.lang.System.out;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.json.JSONArray;
import org.json.JSONObject;
@WebServlet("/admin/*")
public class AdminAPIServlet extends HttpServlet {
    private DoctorDAO doctorDAO = new DoctorDAO();
    private PatientDAO patientDAO = new PatientDAO();
    private AccountDAO accountDAO = new AccountDAO();
    private ReportDAO reportDAO = new ReportDAO();
    private AdminDAO adminDAO = new AdminDAO();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        java.io.PrintWriter out = resp.getWriter();
        
        // Kiểm tra quyền ADMIN
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            resp.setStatus(401);
            out.print("{\"error\":\"Unauthorized\"}");
            return;
        }
        
        Account account = (Account) session.getAttribute("account");
        if (!"admin".equalsIgnoreCase(account.getRole())) {
            resp.setStatus(403);
            out.print("{\"error\":\"Forbidden\"}");
            return;
        }
        
        String pathInfo = req.getPathInfo();
        
        // GET /admin/doctors
        if ("/doctors".equals(pathInfo)) {
            try {
                List<Doctor> doctors = doctorDAO.getAllDoctors();
                JSONArray jsonArray = new JSONArray();
                for (Doctor doctor : doctors) {
                    JSONObject obj = new JSONObject();
                    obj.put("doctorId", doctor.getDoctorId());
                    obj.put("fullname", doctor.getFullname());
                    obj.put("specialty", doctor.getSpecialty());
                    obj.put("phone", doctor.getPhone());
                    obj.put("experienceYears", doctor.getExperience_years());
                    obj.put("username", doctor.getUsername());
                    obj.put("email", doctor.getEmail());
                    obj.put("isActive", doctor.isIsActive());
                    jsonArray.put(obj);
                }
                out.print(jsonArray.toString());
            } catch (Exception e) {
                e.printStackTrace();
                out.print("[]");
            }
        }
        // GET /admin/patients
        else if ("/patients".equals(pathInfo)) {
            try {
                List<com.hospital.model.Patient> patients = patientDAO.getAllPatients();
                JSONArray arr = new JSONArray();
                for (com.hospital.model.Patient p : patients) {
                    JSONObject obj = new JSONObject();
                    obj.put("patientId", p.getPatientId());
                    obj.put("fullname", p.getFullname() != null ? p.getFullname() : "");
                    obj.put("username", p.getUsername() != null ? p.getUsername() : "");
                    obj.put("email", p.getEmail() != null ? p.getEmail() : "");
                    obj.put("phone", p.getPhone() != null ? p.getPhone() : "");
                    obj.put("address", p.getAddress() != null ? p.getAddress() : "");
                    obj.put("isActive", p.isIsActive());
                    arr.put(obj);
                }
                out.print(arr.toString());
            } catch (Exception e) {
                e.printStackTrace();
                out.print("[]");
            }
        }
        // GET /admin/recent-doctors
        else if ("/recent-doctors".equals(pathInfo)) {
            try {
                List<Doctor> recentDocs = doctorDAO.getRecentDoctors(10);
                JSONArray arr = new JSONArray();
                for (Doctor d : recentDocs) {
                    JSONObject obj = new JSONObject();
                    obj.put("doctorId", d.getDoctorId());
                    obj.put("fullname", d.getFullname() != null ? d.getFullname() : "");
                    obj.put("specialty", d.getSpecialty() != null ? d.getSpecialty() : "");
                    obj.put("phone", d.getPhone() != null ? d.getPhone() : "");
                    obj.put("createdAt", d.getCreatedAt() != null ? d.getCreatedAt().toString() : "");
                    arr.put(obj);
                }
                JSONObject result = new JSONObject();
                result.put("recentDoctors", arr);
                out.print(result.toString());
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"recentDoctors\":[]}");
            }
        }
        // GET /admin/reports-api
        else if ("/reports-api".equals(pathInfo)) {
            try {
                List<Report> reports = reportDAO.getAllReports();
                JSONArray jsonArray = new JSONArray();
                for (Report r : reports) {
                    JSONObject obj = new JSONObject();
                    obj.put("reportId", r.getReportId());
                    obj.put("reportType", r.getReportType() != null ? r.getReportType() : "");
                    obj.put("title", r.getTitle() != null ? r.getTitle() : "");
                    obj.put("content", r.getContent() != null ? r.getContent() : "");
                    obj.put("periodStart", r.getPeriodStart() != null ? r.getPeriodStart().toString() : "");
                    obj.put("periodEnd", r.getPeriodEnd() != null ? r.getPeriodEnd().toString() : "");
                    obj.put("createdAt", r.getCreatedAt() != null ? r.getCreatedAt().toString() : "");
                    obj.put("createdBy", r.getCreatedBy() != null ? r.getCreatedBy() : "");
                    obj.put("accountId", r.getAccountId());
                    jsonArray.put(obj);
                }
                out.print(jsonArray.toString());
            } catch (Exception e) {
                e.printStackTrace();
                out.print("[]");
            }
        }
    }
    
    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        java.io.PrintWriter out = resp.getWriter();
        
        // Kiểm tra quyền ADMIN
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            resp.setStatus(401);
            out.print("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }
        
        Account account = (Account) session.getAttribute("account");
        if (!"admin".equalsIgnoreCase(account.getRole())) {
            resp.setStatus(403);
            out.print("{\"success\":false,\"message\":\"Forbidden\"}");
            return;
        }
        
        String pathInfo = req.getPathInfo();
        // DELETE /admin/doctors/{id}
        if (pathInfo != null && pathInfo.matches("/doctors/\\d+")) {
            try {
                String idPart = pathInfo.substring("/doctors/".length());
                int doctorId = Integer.parseInt(idPart);
                boolean success = doctorDAO.deleteFullDoctor(doctorId);
                JSONObject result = new JSONObject();
                result.put("success", success);
                result.put("message", success ? "Xóa thành công" : "Xóa thất bại");
                out.print(result.toString());
            } catch (Exception e) {
                e.printStackTrace();
                JSONObject result = new JSONObject();
                result.put("success", false);
                result.put("message", e.getMessage());
                out.print(result.toString());
            }
        }
        // DELETE /admin/patients/{id}
        else if (pathInfo != null && pathInfo.matches("/patients/\\d+")) {
            try {
                String idPart = pathInfo.substring("/patients/".length());
                int patientId = Integer.parseInt(idPart);
                boolean success = patientDAO.deleteFullPatient(patientId);
                JSONObject result = new JSONObject();
                result.put("success", success);
                result.put("message", success ? "Xóa bệnh nhân thành công" : "Xóa thất bại");
                out.print(result.toString());
            } catch (Exception e) {
                e.printStackTrace();
                JSONObject result = new JSONObject();
                result.put("success", false);
                result.put("message", e.getMessage());
                out.print(result.toString());
            }
        }
        // DELETE /admin/reports-api/{id}
        else if (pathInfo != null && pathInfo.matches("/reports-api/\\d+")) {
            try {
                String idPart = pathInfo.substring("/reports-api/".length());
                int reportId = Integer.parseInt(idPart);
                boolean success = reportDAO.deleteReport(reportId);
                JSONObject result = new JSONObject();
                result.put("success", success);
                result.put("message", success ? "Xóa báo cáo thành công!" : "Xóa thất bại");
                out.print(result.toString());
            } catch (Exception e) {
                e.printStackTrace();
                JSONObject result = new JSONObject();
                result.put("success", false);
                result.put("message", e.getMessage());
                out.print(result.toString());
            }
        }
    }
    
    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        java.io.PrintWriter out = resp.getWriter();
        
        // Kiểm tra quyền ADMIN
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            resp.setStatus(401);
            out.print("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }
        
        Account account = (Account) session.getAttribute("account");
        if (!"admin".equalsIgnoreCase(account.getRole())) {
            resp.setStatus(403);
            out.print("{\"success\":false,\"message\":\"Forbidden\"}");
            return;
        }
        
        String pathInfo = req.getPathInfo();
        
        // PUT /admin/doctors/{id}
        if (pathInfo != null && pathInfo.matches("/doctors/\\d+")) {
            try {
                String idPart = pathInfo.substring("/doctors/".length());
                int doctorId = Integer.parseInt(idPart);
                
                // Đọc JSON body
                StringBuilder sb = new StringBuilder();
                String line;
                java.io.BufferedReader reader = req.getReader();
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
                
                JSONObject json = new JSONObject(sb.toString());
                String fullname = json.optString("fullname", "");
                String specialty = json.optString("specialty", "");
                String phone = json.optString("phone", "");
                String email = json.optString("email", "");
                int experienceYears = json.optInt("experienceYears", 0);
                
                boolean success = doctorDAO.updateDoctorInfo(doctorId, fullname, specialty, phone, email, experienceYears);
                
                JSONObject result = new JSONObject();
                result.put("success", success);
                result.put("message", success ? "Cập nhật thành công!" : "Cập nhật thất bại!");
                out.print(result.toString());
            } catch (Exception e) {
                e.printStackTrace();
                JSONObject result = new JSONObject();
                result.put("success", false);
                result.put("message", "Lỗi: " + e.getMessage());
                out.print(result.toString());
            }
        }
        // PUT /admin/patients/{id}
        else if (pathInfo != null && pathInfo.matches("/patients/\\d+")) {
            try {
                String idPart = pathInfo.substring("/patients/".length());
                int patientId = Integer.parseInt(idPart);
                
                StringBuilder sb = new StringBuilder();
                String line;
                java.io.BufferedReader reader = req.getReader();
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
                
                JSONObject json = new JSONObject(sb.toString());
                String fullname = json.optString("fullname", "");
                String phone = json.optString("phone", "");
                String email = json.optString("email", "");
                String address = json.optString("address", "");
                
                boolean success = patientDAO.updatePatientInfo(patientId, fullname, phone, email, address);
                
                JSONObject result = new JSONObject();
                result.put("success", success);
                result.put("message", success ? "Cập nhật thành công!" : "Cập nhật thất bại!");
                out.print(result.toString());
            } catch (Exception e) {
                e.printStackTrace();
                JSONObject result = new JSONObject();
                result.put("success", false);
                result.put("message", "Lỗi: " + e.getMessage());
                out.print(result.toString());
            }
        }
        // PUT /admin/reports-api/{id}
        else if (pathInfo != null && pathInfo.matches("/reports-api/\\d+")) {
            try {
                String idPart = pathInfo.substring("/reports-api/".length());
                int reportId = Integer.parseInt(idPart);
                
                StringBuilder sb = new StringBuilder();
                String line;
                java.io.BufferedReader reader = req.getReader();
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
                
                JSONObject json = new JSONObject(sb.toString());
                String reportType = json.optString("reportType", "");
                String title = json.optString("title", "");
                String content = json.optString("content", "");
                String periodStartStr = json.optString("periodStart", "");
                String periodEndStr = json.optString("periodEnd", "");
                
                Report report = reportDAO.getReportById(reportId);
                if (report == null) {
                    JSONObject result = new JSONObject();
                    result.put("success", false);
                    result.put("message", "Không tìm thấy báo cáo!");
                    out.print(result.toString());
                    return;
                }
                
                report.setReportType(reportType);
                report.setTitle(title);
                report.setContent(content);
                if (!periodStartStr.isEmpty()) {
                    report.setPeriodStart(java.sql.Date.valueOf(periodStartStr));
                }
                if (!periodEndStr.isEmpty()) {
                    report.setPeriodEnd(java.sql.Date.valueOf(periodEndStr));
                }
                
                boolean success = reportDAO.updateReport(report);
                JSONObject result = new JSONObject();
                result.put("success", success);
                result.put("message", success ? "Cập nhật báo cáo thành công!" : "Cập nhật thất bại!");
                out.print(result.toString());
            } catch (Exception e) {
                e.printStackTrace();
                JSONObject result = new JSONObject();
                result.put("success", false);
                result.put("message", "Lỗi: " + e.getMessage());
                out.print(result.toString());
            }
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        java.io.PrintWriter out = resp.getWriter();
        
        // Kiểm tra quyền ADMIN
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            resp.setStatus(401);
            out.print("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }
        
        Account adminAccount = (Account) session.getAttribute("account");
        if (!"admin".equalsIgnoreCase(adminAccount.getRole())) {
            resp.setStatus(403);
            out.print("{\"success\":false,\"message\":\"Forbidden\"}");
            return;
        }
        
        String pathInfo = req.getPathInfo();
        
        // POST /admin/add-doctor
        if ("/add-doctor".equals(pathInfo)) {
            try {
                String username = req.getParameter("username");
                String password = req.getParameter("password");
                String fullname = req.getParameter("fullname");
                String specialty = req.getParameter("specialty");
                String email = req.getParameter("email");
                String phone = req.getParameter("phone");
                String avatar = req.getParameter("avatar");
                String experienceYearsStr = req.getParameter("experienceYears");
                
                if (username == null || username.trim().isEmpty() ||
                    password == null || password.trim().isEmpty() ||
                    fullname == null || fullname.trim().isEmpty()) {
                    
                    JSONObject result = new JSONObject();
                    result.put("success", false);
                    result.put("message", "Vui lòng nhập đầy đủ các trường bắt buộc!");
                    out.print(result.toString());
                    return;
                }
                
                // Kiểm tra username đã tồn tại chưa
                if (accountDAO.isUsernameExists(username)) {
                    JSONObject result = new JSONObject();
                    result.put("success", false);
                    result.put("message", "Tên đăng nhập đã tồn tại!");
                    out.print(result.toString());
                    return;
                }
                
                // Hashing password
                String hashedPassword = PasswordHash.hashSHA256(password);
                
                // Tạo Account object
                Account newAcc = new Account(username, hashedPassword, email, phone, fullname, "doctor");
                newAcc.setIsActive(true);
                
                // Lưu account và lấy accountID
                int accountId = accountDAO.createAccount(newAcc);
                if (accountId <= 0) {
                    JSONObject result = new JSONObject();
                    result.put("success", false);
                    result.put("message", "Lỗi tạo tài khoản bác sĩ!");
                    out.print(result.toString());
                    return;
                }
                
                // Tạo Doctor object
                Doctor newDoc = new Doctor();
                newDoc.setFullname(fullname);
                newDoc.setSpecialty(specialty);
                newDoc.setPhone(phone);
                newDoc.setAccountId(accountId);
                
                int expYears = 0;
                if (experienceYearsStr != null && !experienceYearsStr.trim().isEmpty()) {
                    try {
                        expYears = Integer.parseInt(experienceYearsStr.trim());
                    } catch (NumberFormatException e) {
                        // ignore
                    }
                }
                newDoc.setExperience_years(expYears);
                
                // Tự động tạo lianse_number
                String lianseNumber = "DOC" + (1000 + new java.util.Random().nextInt(9000));
                newDoc.setLianseNumber(lianseNumber);
                
                // Tự động tạo hoặc dùng avatar URL được truyền vào
                String avatarUrl = (avatar != null && !avatar.trim().isEmpty()) ? avatar.trim() : ("https://api.dicebear.com/7.x/avataaars/svg?seed=" + username);
                newDoc.setAvatar(avatarUrl);
                
                // Lưu doctor vào DB
                int doctorId = doctorDAO.createDoctor(newDoc);
                
                JSONObject result = new JSONObject();
                if (doctorId > 0) {
                    result.put("success", true);
                    result.put("message", "Tạo tài khoản bác sĩ thành công!");
                } else {
                    result.put("success", false);
                    result.put("message", "Lỗi tạo thông tin bác sĩ!");
                }
                out.print(result.toString());
            } catch (Exception e) {
                e.printStackTrace();
                JSONObject result = new JSONObject();
                result.put("success", false);
                result.put("message", "Lỗi: " + e.getMessage());
                out.print(result.toString());
            }
        }
        // POST /admin/reports-api
        else if ("/reports-api".equals(pathInfo)) {
            try {
                String reportType = req.getParameter("reportType");
                String title = req.getParameter("title");
                String content = req.getParameter("content");
                String periodStartStr = req.getParameter("periodStart");
                String periodEndStr = req.getParameter("periodEnd");
                
                // fallback to JSON payload
                if (title == null || title.isEmpty()) {
                    StringBuilder sb = new StringBuilder();
                    String line;
                    java.io.BufferedReader reader = req.getReader();
                    while ((line = reader.readLine()) != null) {
                        sb.append(line);
                    }
                    if (sb.length() > 0) {
                        JSONObject json = new JSONObject(sb.toString());
                        reportType = json.optString("reportType", "");
                        title = json.optString("title", "");
                        content = json.optString("content", "");
                        periodStartStr = json.optString("periodStart", "");
                        periodEndStr = json.optString("periodEnd", "");
                    }
                }
                
                if (title == null || title.trim().isEmpty() ||
                    content == null || content.trim().isEmpty() ||
                    periodStartStr == null || periodStartStr.trim().isEmpty() ||
                    periodEndStr == null || periodEndStr.trim().isEmpty()) {
                    
                    JSONObject result = new JSONObject();
                    result.put("success", false);
                    result.put("message", "Vui lòng nhập đầy đủ các thông tin bắt buộc!");
                    out.print(result.toString());
                    return;
                }
                
                Report report = new Report();
                report.setReportType(reportType);
                report.setTitle(title);
                report.setContent(content);
                report.setPeriodStart(java.sql.Date.valueOf(periodStartStr));
                report.setPeriodEnd(java.sql.Date.valueOf(periodEndStr));
                report.setCreatedAt(java.sql.Time.valueOf(java.time.LocalTime.now()));
                // Lấy tên người tạo từ bảng admin (ưu tiên) hoặc fallback sang account
                String adminFullname = adminDAO.getAdminFullnameByAccountId(adminAccount.getAccountID());
                report.setCreatedBy(adminFullname != null ? adminFullname : adminAccount.getFullname());
                report.setAccountId(adminAccount.getAccountID());
                
                boolean success = reportDAO.addReport(report);
                JSONObject result = new JSONObject();
                result.put("success", success);
                result.put("message", success ? "Tạo báo cáo thành công!" : "Tạo báo cáo thất bại!");
                out.print(result.toString());
            } catch (Exception e) {
                e.printStackTrace();
                JSONObject result = new JSONObject();
                result.put("success", false);
                result.put("message", "Lỗi: " + e.getMessage());
                out.print(result.toString());
            }
        }
    }
    
}