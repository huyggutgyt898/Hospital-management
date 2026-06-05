/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.hospital.servlet;

import com.hospital.dao.PrescriptionDAO;
import com.hospital.model.Prescription;
import com.hospital.dao.MedicineDAO;
import com.hospital.model.Medicine;
import java.sql.Date;
import com.hospital.dao.AppointmentDAO;
import com.hospital.dao.DoctorDAO;
import com.hospital.dao.MedicalRecordDAO;
import com.hospital.dao.PaymentDAO;
import com.hospital.model.Account;
import com.hospital.model.Appointment;
import com.hospital.model.Doctor;
import com.hospital.model.MedicalRecord;
import com.hospital.service.BillingService;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.BufferedReader;
import org.json.JSONObject;
import org.json.JSONArray;

@WebServlet("/doctor/*")
public class DoctorAPIServlet extends HttpServlet {

    private AppointmentDAO appointmentDAO = new AppointmentDAO();
    private DoctorDAO doctorDAO = new DoctorDAO();
    private MedicalRecordDAO medicalRecordDAO = new MedicalRecordDAO();
    private com.hospital.dao.PatientDAO patientDAO = new com.hospital.dao.PatientDAO();
    private PaymentDAO paymentDAO = new PaymentDAO();
    private MedicineDAO medicineDAO = new MedicineDAO();
    private PrescriptionDAO prescriptionDAO = new PrescriptionDAO();
    private BillingService billingService = new BillingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        // Kiểm tra quyền
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            resp.setStatus(401);
            out.print("{\"error\":\"Unauthorized\"}");
            return;
        }
        Account account = (Account) session.getAttribute("account");
        if (!"doctor".equalsIgnoreCase(account.getRole())) {
            resp.setStatus(403);
            out.print("{\"error\":\"Forbidden\"}");
            return;
        }

        String pathInfo = req.getPathInfo();

        // ---- GET /doctor/appointments ----
        if ("/appointments".equals(pathInfo)) {
            try {
                // Lấy doctorId theo account
                Doctor doctor = doctorDAO.getDoctorByAccountId(account.getAccountID());
                if (doctor == null) {
                    out.print("[]");
                    return;
                }

                List<Appointment> list = appointmentDAO.getAppointmentsByDoctor(doctor.getDoctorId());
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < list.size(); i++) {
                    if (i > 0) json.append(",");
                    Appointment a = list.get(i);
                    com.hospital.model.Payment payment = paymentDAO.getByAppointmentId(a.getAppointmentId());
                    String paymentStatus = payment != null && payment.getPaymentStatus() != null ? payment.getPaymentStatus() : "";
                    json.append("{")
                        .append("\"appointmentId\":").append(a.getAppointmentId()).append(",")
                        .append("\"patientId\":").append(a.getPatientId()).append(",")
                        .append("\"patientName\":\"").append(esc(a.getPatientName())).append("\",")
                        .append("\"date\":\"").append(esc(a.getAppointmentDate())).append("\",")
                        .append("\"time\":\"").append(esc(a.getAppointmentTime())).append("\",")
                        .append("\"status\":\"").append(esc(a.getStatus())).append("\",")
                        .append("\"symptoms\":\"").append(esc(a.getSymptoms())).append("\",")
                        .append("\"reason\":\"").append(esc(a.getReason())).append("\",")
                        .append("\"notes\":\"").append(esc(a.getNotes())).append("\",")
                        .append("\"paymentStatus\":\"").append(esc(paymentStatus)).append("\"")
                        .append("}");
                }
                json.append("]");
                out.print(json.toString());
            } catch (Exception e) {
                e.printStackTrace();
                out.print("[]");
            }
        }
        
        // ---- GET /doctor/prescriptions - Lấy danh sách đơn thuốc ----
        else if ("/prescriptions".equals(pathInfo)) {
            try {
                // Lấy doctorId theo account
                Doctor doctor = doctorDAO.getDoctorByAccountId(account.getAccountID());
                if (doctor == null) {
                    out.print("[]");
                    return;
                }

                List<Prescription> prescriptions = prescriptionDAO.getPrescriptionsByDoctor(doctor.getDoctorId());
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < prescriptions.size(); i++) {
                    if (i > 0) json.append(",");
                    Prescription p = prescriptions.get(i);
                    json.append("{")
                        .append("\"prescriptionId\":").append(p.getPrescriptionId()).append(",")
                        .append("\"patientName\":\"").append(esc(p.getPatientName())).append("\",")
                        .append("\"medicineName\":\"").append(esc(p.getMedicineName())).append("\",")
                        .append("\"dosage\":\"").append(esc(p.getDosage())).append("\",")
                        .append("\"quantity\":").append(p.getQuantity()).append(",")
                        .append("\"createdAt\":\"").append(p.getCreatedAt() != null ? p.getCreatedAt() : "").append("\"")
                        .append("}");
                }
                json.append("]");
                out.print(json.toString());
            } catch (Exception e) {
                e.printStackTrace();
                out.print("[]");
            }
        }
        
        // ---- GET /doctor/patients ----
        else if ("/patients".equals(pathInfo)) {
            try {
                com.hospital.dao.PatientDAO patientDAO = new com.hospital.dao.PatientDAO();
                java.util.List<com.hospital.model.Patient> patients = patientDAO.getAllPatients();
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < patients.size(); i++) {
                    if (i > 0) json.append(",");
                    com.hospital.model.Patient p = patients.get(i);
                    json.append("{")
                        .append("\"patientId\":").append(p.getPatientId()).append(",")
                        .append("\"fullname\":\"").append(esc(p.getFullname())).append("\",")
                        .append("\"phone\":\"").append(esc(p.getPhone() != null ? p.getPhone() : "")).append("\",")
                        .append("\"gender\":\"").append(esc(p.getGender() != null ? p.getGender() : "")).append("\",")
                    .append("\"address\":\"").append(esc(p.getAddress() != null ? p.getAddress() : "")).append("\",")
                    .append("\"healthInsurance\":\"").append(esc(p.getHealthInsurance() != null ? p.getHealthInsurance() : "")).append("\",")
                        .append("\"dateOfBirth\":\"").append(p.getDateOfBirth() != null ? p.getDateOfBirth().toString() : "").append("\"")
                        .append("}");
                }
                json.append("]");
                out.print(json.toString());
            } catch (Exception e) {
                e.printStackTrace();
                out.print("[]");
            }
        }

        // ---- GET /doctor/medical-records ----
        else if ("/medical-records".equals(pathInfo)) {
            try {
                Doctor doctor = doctorDAO.getDoctorByAccountId(account.getAccountID());
                if (doctor == null) {
                    out.print("[]");
                    return;
                }
                String search = req.getParameter("search");
                java.util.List<MedicalRecord> records = medicalRecordDAO.getMedicalRecordsByDoctor(doctor.getDoctorId(), search);
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < records.size(); i++) {
                    if (i > 0) json.append(",");
                    MedicalRecord r = records.get(i);
                    json.append("{")
                        .append("\"id\":").append(r.getId()).append(",")
                        .append("\"patientId\":").append(r.getPatientId()).append(",")
                        .append("\"patientName\":\"").append(esc(r.getPatientName())).append("\",")
                        .append("\"doctorName\":\"").append(esc(r.getDoctorName())).append("\",")
                        .append("\"examinationDate\":\"").append(esc(r.getExaminationDate())).append("\",")
                        .append("\"diagnosis\":\"").append(esc(r.getDiagnosis())).append("\",")
                        .append("\"symptoms\":\"").append(esc(r.getSymptoms())).append("\",")
                        .append("\"testResults\":\"").append(esc(r.getTestResults())).append("\",")
                        .append("\"treatmentMethod\":\"").append(esc(r.getTreatmentMethod())).append("\",")
                        .append("\"notes\":\"").append(esc(r.getNotes())).append("\",")
                        .append("\"createdAt\":\"").append(r.getCreatedAt() != null ? r.getCreatedAt() : "").append("\"")
                        .append("}");
                }
                json.append("]");
                out.print(json.toString());
            } catch (Exception e) {
                e.printStackTrace();
                out.print("[]");
            }
        }
        
        // ---- GET /doctor/patient?patientId=123 - Lấy chi tiết bệnh nhân ----
        else if ("/patient".equals(pathInfo)) {
            try {
                String patientIdParam = req.getParameter("patientId");
                if (patientIdParam == null || patientIdParam.isEmpty()) {
                    resp.setStatus(400);
                    out.print("{\"error\":\"Missing patientId\"}");
                    return;
                }
                int patientId = Integer.parseInt(patientIdParam);
                com.hospital.dao.PatientDAO patientDAO = new com.hospital.dao.PatientDAO();
                com.hospital.model.Patient p = patientDAO.getPatientById(patientId);
                if (p == null) {
                    resp.setStatus(404);
                    out.print("{\"error\":\"Patient not found\"}");
                    return;
                }
                StringBuilder patientJson = new StringBuilder();
                patientJson.append("{")
                        .append("\"patientId\":").append(p.getPatientId()).append(",")
                        .append("\"fullname\":\"").append(esc(p.getFullname())).append("\",")
                        .append("\"phone\":\"").append(esc(p.getPhone() != null ? p.getPhone() : "")).append("\",")
                        .append("\"gender\":\"").append(esc(p.getGender() != null ? p.getGender() : "")).append("\",")
                        .append("\"address\":\"").append(esc(p.getAddress() != null ? p.getAddress() : "")).append("\",")
                        .append("\"healthInsurance\":\"").append(esc(p.getHealthInsurance() != null ? p.getHealthInsurance() : "")).append("\",")
                        .append("\"dateOfBirth\":\"").append(p.getDateOfBirth() != null ? p.getDateOfBirth().toString() : "").append("\"")
                        .append("}");
                out.print(patientJson.toString());
            } catch (Exception e) {
                e.printStackTrace();
                resp.setStatus(500);
                out.print("{\"error\":\"Unable to load patient details\"}");
            }
        }
        
        // ---- GET /doctor/medicines - Lấy danh sách thuốc ----
        else if ("/medicines".equals(pathInfo)) {
            try {
                List<Medicine> medicines = medicineDAO.getAllMedicines();
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < medicines.size(); i++) {
                    if (i > 0) json.append(",");
                    Medicine m = medicines.get(i);
                    json.append("{")
                        .append("\"medicineId\":").append(m.getMedicineId()).append(",")
                        .append("\"medicineName\":\"").append(esc(m.getMedicineName())).append("\",")
                        .append("\"unit\":\"").append(esc(m.getUnit())).append("\",")
                        .append("\"stockQuantity\":").append(m.getStockQuantity()).append(",")
                        .append("\"unitPrice\":").append(m.getUnitPrice()).append(",")
                        .append("\"expiryDate\":\"").append(m.getExpiryDate() != null ? m.getExpiryDate() : "").append("\",")
                        .append("\"supplier\":\"").append(esc(m.getSupplier() != null ? m.getSupplier() : "")).append("\"")
                        .append("}");
                }
                json.append("]");
                out.print(json.toString());
            } catch (Exception e) {
                e.printStackTrace();
                out.print("[]");
            }
        }

        
        
        System.out.println("PathInfo: '" + req.getPathInfo() + "'");
        System.out.println("ServletPath: '" + req.getServletPath() + "'");
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        // Kiểm tra quyền
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            out.print("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }
        Account account = (Account) session.getAttribute("account");
        if (!"doctor".equalsIgnoreCase(account.getRole())) {
            out.print("{\"success\":false,\"message\":\"Forbidden\"}");
            return;
        }

        String pathInfo = req.getPathInfo();

        // ---- POST /doctor/update-appointment ----
        if ("/update-appointment".equals(pathInfo)) {
            try {
                int    appointmentId = Integer.parseInt(req.getParameter("appointmentId"));
                String newStatus     = req.getParameter("status");

                // Validate status hợp lệ
                if (!newStatus.matches("confirmed|completed|cancelled")) {
                    out.print("{\"success\":false,\"message\":\"Trạng thái không hợp lệ!\"}");
                    return;
                }

                // Kiểm tra lịch hẹn có thuộc về bác sĩ này không
                Doctor doctor = doctorDAO.getDoctorByAccountId(account.getAccountID());
                Appointment appt = appointmentDAO.getAppointmentById(appointmentId);

                if (appt == null || doctor == null || appt.getDoctorId() != doctor.getDoctorId()) {
                    out.print("{\"success\":false,\"message\":\"Không có quyền cập nhật lịch hẹn này!\"}");
                    return;
                }

                boolean success = appointmentDAO.updateStatus(appointmentId, newStatus);
                if (success) {
                    String msg = newStatus.equals("confirmed")  ? "Đã xác nhận lịch hẹn!" :
                                 newStatus.equals("completed")  ? "Đã hoàn thành lịch hẹn!" :
                                 "Đã huỷ lịch hẹn!";
                    out.print("{\"success\":true,\"message\":\"" + msg + "\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"Cập nhật thất bại!\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"success\":false,\"message\":\"Lỗi hệ thống: " + esc(e.getMessage()) + "\"}");
            }
        }

        // ---- POST /doctor/update-patient ----
        else if ("/update-patient".equals(pathInfo)) {
            try {
                int patientId = Integer.parseInt(req.getParameter("patientId"));
                String fullname = req.getParameter("fullname") != null ? req.getParameter("fullname") : "";
                String dateOfBirthParam = req.getParameter("dateOfBirth");
                String gender = req.getParameter("gender") != null ? req.getParameter("gender") : "";
                String phone = req.getParameter("phone") != null ? req.getParameter("phone") : "";
                String address = req.getParameter("address") != null ? req.getParameter("address") : "";
                String healthInsurance = req.getParameter("healthInsurance") != null ? req.getParameter("healthInsurance") : "";
                String email = req.getParameter("email") != null ? req.getParameter("email") : "";

                Date dateOfBirth = null;
                if (dateOfBirthParam != null && !dateOfBirthParam.trim().isEmpty()) {
                    dateOfBirth = Date.valueOf(dateOfBirthParam.trim());
                }

                boolean ok1 = patientDAO.updatePatientInfo(patientId, fullname, phone, email, address, gender, dateOfBirth);
                boolean ok2 = true;
                try { ok2 = patientDAO.updateHealthInsurance(patientId, healthInsurance); } catch (Exception ex) { ex.printStackTrace(); }

                if (ok1) out.print("{\"success\":true,\"message\":\"Cập nhật thông tin bệnh nhân thành công\"}");
                else out.print("{\"success\":false,\"message\":\"Cập nhật thất bại\"}");
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"success\":false,\"message\":\"Lỗi server\"}");
            }
        }

        // ---- POST /doctor/medical-records ----
        else if ("/medical-records".equals(pathInfo)) {
            try {
                int patientId = Integer.parseInt(req.getParameter("patientId"));
                String examinationDate = req.getParameter("examinationDate");
                String diagnosis = req.getParameter("diagnosis");
                String symptoms = req.getParameter("symptoms");
                String testResults = req.getParameter("testResults");
                String treatmentMethod = req.getParameter("treatmentMethod");
                String notes = req.getParameter("notes");

                if (examinationDate == null || examinationDate.isEmpty() || diagnosis == null || diagnosis.isEmpty()) {
                    out.print("{\"success\":false,\"message\":\"Ngày khám và chẩn đoán là bắt buộc.\"}");
                    return;
                }

                Doctor doctor = doctorDAO.getDoctorByAccountId(account.getAccountID());
                if (doctor == null) {
                    out.print("{\"success\":false,\"message\":\"Không tìm thấy thông tin bác sĩ.\"}");
                    return;
                }

                MedicalRecord record = new MedicalRecord();
                record.setPatientId(patientId);
                record.setDoctorId(doctor.getDoctorId());
                record.setExaminationDate(examinationDate);
                record.setDiagnosis(diagnosis);
                record.setSymptoms(symptoms);
                record.setTestResults(testResults);
                record.setTreatmentMethod(treatmentMethod);
                record.setNotes(notes);

                int createdId = medicalRecordDAO.createMedicalRecord(record);
                if (createdId > 0) {
                    out.print("{\"success\":true,\"message\":\"Đã lưu hồ sơ bệnh án thành công.\",\"recordId\":" + createdId + "}");
                } else {
                    out.print("{\"success\":false,\"message\":\"Lưu hồ sơ thất bại.\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"success\":false,\"message\":\"Lỗi hệ thống: " + esc(e.getMessage()) + "\"}");
            }
        }
        
        // ---- GET /doctor/medicines/{id} - Lấy chi tiết 1 thuốc ----
        else if (pathInfo != null && pathInfo.matches("/medicines/\\d+")) {
            try {
                String idPart = pathInfo.substring("/medicines/".length());
                int id = Integer.parseInt(idPart);
                Medicine m = medicineDAO.getMedicineById(id);
                if (m != null) {
                    StringBuilder json = new StringBuilder();
                    json.append("{")
                        .append("\"medicineId\":").append(m.getMedicineId()).append(",")
                        .append("\"medicineName\":\"").append(esc(m.getMedicineName())).append("\",")
                        .append("\"unit\":\"").append(esc(m.getUnit())).append("\",")
                        .append("\"stockQuantity\":").append(m.getStockQuantity()).append(",")
                        .append("\"unitPrice\":").append(m.getUnitPrice()).append(",")
                        .append("\"expiryDate\":\"").append(m.getExpiryDate() != null ? m.getExpiryDate() : "").append("\",")
                        .append("\"supplier\":\"").append(esc(m.getSupplier() != null ? m.getSupplier() : "")).append("\"")
                        .append("}");
                    out.print(json.toString());
                } else {
                    out.print("{}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{}");
            }
        }
        
        // ---- POST /doctor/medicines - Thêm thuốc mới ----
        else if ("/medicines".equals(pathInfo)) {
            try {
                String medicineName = req.getParameter("medicineName");
                String unit = req.getParameter("unit");
                int stockQuantity = Integer.parseInt(req.getParameter("stockQuantity"));
                double unitPrice = Double.parseDouble(req.getParameter("unitPrice"));
                String expiryDateStr = req.getParameter("expiryDate");
                String supplier = req.getParameter("supplier");

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
                out.print("{\"success\":false,\"message\":\"" + esc(e.getMessage()) + "\"}");
            }
        }
        
        // ---- POST /doctor/prescription/save - Lưu đơn thuốc ----
        else if ("/prescription/save".equals(pathInfo)) {
            try {
                // Đọc JSON từ request body
                StringBuilder sb = new StringBuilder();
                String line;
                BufferedReader reader = req.getReader();
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
                String jsonBody = sb.toString();

                // Parse JSON (dùng thư viện org.json)
                JSONObject json = new JSONObject(jsonBody);
                int appointmentId = json.getInt("appointmentId");
                JSONArray prescriptions = json.getJSONArray("prescriptions");

                boolean allSuccess = true;
                for (int i = 0; i < prescriptions.length(); i++) {
                    JSONObject p = prescriptions.getJSONObject(i);
                    int medicineId = p.getInt("medicineId");
                    int quantity = p.getInt("quantity");
                    String dosage = p.optString("dosage", "");
                    String frequency = p.optString("frequency", "");
                    String instruction = p.optString("instruction", "");

                    // Thêm vào bảng prescription
                    Prescription prescription = new Prescription();
                    prescription.setAppointmentId(appointmentId);
                    prescription.setMedicineId(medicineId);
                    prescription.setQuantity(quantity);
                    prescription.setDosage(dosage);
                    prescription.setFrequency(frequency);
                    prescription.setInstruction(instruction);

                    boolean success = prescriptionDAO.createPrescription(prescription);  
                    if (!success) allSuccess = false;

                }

                if (allSuccess) {
                    // Kê đơn xong thì đánh dấu lịch hẹn đã hoàn thành.
                    // Dùng giá trị 'completed' hợp lệ với ràng buộc chk_status.
                    Appointment appt = appointmentDAO.getAppointmentById(appointmentId);
                    if (appt != null && !"completed".equals(appt.getStatus())
                            && !"cancelled".equals(appt.getStatus())) {
                        appointmentDAO.updateStatus(appointmentId, "completed");
                    }
                    // Tạo/sync hóa đơn thanh toán ngay khi kê đơn xong.
                    billingService.syncPaymentRecord(appointmentId);
                    out.print("{\"success\":true,\"message\":\"Đã lưu đơn thuốc và tạo hóa đơn!\"}");
                } else {
                    out.print("{\"success\":false,\"message\":\"Có lỗi xảy ra!\"}");
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

        // Kiểm tra quyền
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            out.print("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }
        Account account = (Account) session.getAttribute("account");
        if (!"doctor".equalsIgnoreCase(account.getRole())) {
            out.print("{\"success\":false,\"message\":\"Forbidden\"}");
            return;
        }

        String pathInfo = req.getPathInfo();
        out.flush();
    }
    
    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        // Kiểm tra quyền
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            out.print("{\"success\":false,\"message\":\"Unauthorized\"}");
            return;
        }
        Account account = (Account) session.getAttribute("account");
        if (!"doctor".equalsIgnoreCase(account.getRole())) {
            out.print("{\"success\":false,\"message\":\"Forbidden\"}");
            return;
        }

        String pathInfo = req.getPathInfo();

        out.flush();
    }

    private String esc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
}