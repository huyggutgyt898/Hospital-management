package com.hospital.servlet;

import com.hospital.dao.AppointmentDAO;
import com.hospital.dao.DoctorDAO;
import com.hospital.dao.PatientDAO;
import com.hospital.dao.PaymentDAO;
import com.hospital.model.Appointment;
import com.hospital.model.Doctor;
import com.hospital.model.Payment;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

@WebServlet("/patient/*")
public class PatientAPIServlet extends HttpServlet {

    private DoctorDAO doctorDAO = new DoctorDAO();
    private AppointmentDAO appointmentDAO = new AppointmentDAO();
    private PatientDAO patientDAO = new PatientDAO();
    private PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession();
        Integer accountId = (Integer) session.getAttribute("accountId");
        Integer patientId = (Integer) session.getAttribute("patientId");

        // Auto-load patientId nếu chưa có
        if (patientId == null && accountId != null) {
            try {
                int pid = patientDAO.getPatientIdByAccountId(accountId);
                if (pid > 0) {
                    patientId = pid;
                    session.setAttribute("patientId", patientId);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        String pathInfo = req.getPathInfo();

        // ---- GET /patient/notifications ----
        if ("/notifications".equals(pathInfo)) {
            try {
                if (patientId == null) {
                    out.print("[]");
                    return;
                }

                StringBuilder json = new StringBuilder("[");
                boolean first = true;

                // 1) Đặt lịch (pending/confirmed) -> loại booking/information
                try {
                    List<Appointment> appointments = appointmentDAO.getAppointmentsByPatient(patientId);
                    for (Appointment a : appointments) {
                        String type = "booking";
                        String title = "Đặt lịch thành công";
                        String message = "Bạn đã đặt lịch với " + (a.getDoctorName() != null ? a.getDoctorName() : "bác sĩ") + " - " + a.getAppointmentDate() + " lúc " + a.getAppointmentTime();
                        String time = a.getCreatedAt() != null ? a.getCreatedAt().toString() : "";
                        if ("confirmed".equalsIgnoreCase(a.getStatus())) {
                            title = "Lịch hẹn đã được xác nhận";
                            type = "booking_confirmed";
                        }

                        if (!first) json.append(","); first = false;
                        json.append("{")
                            .append("\"type\":\"").append(type).append("\",")
                            .append("\"title\":\"").append(escapeJson(title)).append("\",")
                            .append("\"message\":\"").append(escapeJson(message)).append("\",")
                            .append("\"time\":\"").append(escapeJson(time)).append("\",")
                            .append("\"appointmentId\":").append(a.getAppointmentId())
                            .append("}");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }

                // 2) Payments -> invoice (unpaid) and payment success (paid)
                try {
                    List<Payment> pays = paymentDAO.listByPatient(patientId);
                    for (Payment p : pays) {
                        String type = "invoice";
                        String title = "Hóa đơn thanh toán";
                        String message = "Hóa đơn cho lịch #" + p.getAppointmentId() + ": " + p.getTotalAmount() + " VND";
                        String time = p.getCreatedAt() != null ? p.getCreatedAt().toString() : "";

                        if ("paid".equalsIgnoreCase(p.getPaymentStatus())) {
                            type = "payment_success";
                            title = "Thanh toán thành công";
                            message = "Thanh toán #" + p.getPaymentId() + ": " + p.getTotalAmount() + " VND";
                            time = p.getPaidAt() != null ? p.getPaidAt().toString() : time;
                        }

                        if (!first) json.append(","); first = false;
                        json.append("{")
                            .append("\"type\":\"").append(type).append("\",")
                            .append("\"title\":\"").append(escapeJson(title)).append("\",")
                            .append("\"message\":\"").append(escapeJson(message)).append("\",")
                            .append("\"time\":\"").append(escapeJson(time)).append("\",")
                            .append("\"paymentId\":").append(p.getPaymentId())
                            .append("}");
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }

                json.append("]");
                out.print(json.toString());
            } catch (Exception e) {
                e.printStackTrace();
                out.print("[]");
            }
            return;
        }

        // ---- GET /patient/doctors ----
        if ("/doctors".equals(pathInfo)) {
            try {
                List<Doctor> doctors = doctorDAO.getActiveDoctors();
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < doctors.size(); i++) {
                    if (i > 0) json.append(",");
                    Doctor d = doctors.get(i);
                    json.append("{")
                        .append("\"doctorId\":").append(d.getDoctorId()).append(",")
                        .append("\"fullname\":\"").append(escapeJson(d.getFullname())).append("\",")
                        .append("\"specialty\":\"").append(escapeJson(d.getSpecialty() != null ? d.getSpecialty() : "")).append("\",")
                        .append("\"experienceYears\":").append(d.getExperience_years()).append(",")
                        .append("\"phone\":\"").append(escapeJson(d.getPhone() != null ? d.getPhone() : "")).append("\",")
                        .append("\"avatar\":\"").append(escapeJson(d.getAvatar() != null ? d.getAvatar() : "https://api.dicebear.com/7.x/avataaars/svg?seed=" + d.getDoctorId())).append("\"")
                        .append("}");
                }
                json.append("]");
                out.print(json.toString());
            } catch (Exception e) {
                e.printStackTrace();
                out.print("[]");
            }

        // ---- GET /patient/booked-slots?doctorId=&date= ----
        } else if ("/booked-slots".equals(pathInfo)) {
            try {
                int doctorId = Integer.parseInt(req.getParameter("doctorId"));
                String date  = req.getParameter("date");

                // Lấy các slot đã đặt của bác sĩ trong ngày đó
                List<Appointment> appointments = appointmentDAO.getAppointmentsByDoctor(doctorId);
                StringBuilder json = new StringBuilder("{\"bookedSlots\":[");
                boolean first = true;
                for (Appointment a : appointments) {
                    if (date.equals(a.getAppointmentDate())
                            && ("pending".equals(a.getStatus()) || "confirmed".equals(a.getStatus()))) {
                        String at = a.getAppointmentTime() != null ? a.getAppointmentTime() : "";
                        if (at.length() >= 5) at = at.substring(0,5); // normalize to HH:mm to match client slots
                        if (!first) json.append(",");
                        json.append("\"").append(escapeJson(at)).append("\"");
                        first = false;
                    }
                }
                json.append("]}");
                out.print(json.toString());
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"bookedSlots\":[]}");
            }

        // ---- GET /patient/my-appointments ----
        } else if ("/check-status".equals(pathInfo)) {
            try {
                int appointmentId = Integer.parseInt(req.getParameter("appointmentId"));
                if (patientId == null) {
                    out.print("{\"status\":\"unknown\"}");
                    return;
                }
                Appointment apt = appointmentDAO.getAppointmentById(appointmentId);
                if (apt != null && apt.getPatientId() == patientId) {
                    out.print("{\"status\":\"" + apt.getStatus() + "\"}");
                } else {
                    out.print("{\"status\":\"unknown\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"status\":\"error\"}");
            }
        } else if ("/my-appointments".equals(pathInfo)) {
            if (patientId == null) {
                out.print("[]");
                return;
            }
            try {
                List<Appointment> list = appointmentDAO.getAppointmentsByPatient(patientId);
                StringBuilder json = new StringBuilder("[");
                for (int i = 0; i < list.size(); i++) {
                    if (i > 0) json.append(",");
                    Appointment a = list.get(i);
                    json.append("{")
                        .append("\"appointmentId\":").append(a.getAppointmentId()).append(",")
                        .append("\"doctorName\":\"").append(escapeJson(a.getDoctorName())).append("\",")
                        .append("\"date\":\"").append(escapeJson(a.getAppointmentDate())).append("\",")
                        .append("\"time\":\"").append(escapeJson(a.getAppointmentTime())).append("\",")
                        .append("\"status\":\"").append(escapeJson(a.getStatus())).append("\",")
                        .append("\"symptoms\":\"").append(escapeJson(a.getSymptoms())).append("\"")
                        .append("}");
                }
                json.append("]");
                out.print(json.toString());
            } catch (Exception e) {
                e.printStackTrace();
                out.print("[]");
            }
        }

        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");  // ← THÊM DÒNG NÀY
        resp.setContentType("application/json; charset=UTF-8");
        PrintWriter out = resp.getWriter();

        HttpSession session = req.getSession();
        Integer patientId = (Integer) session.getAttribute("patientId");

        if (patientId == null) {
            out.print("{\"success\":false,\"message\":\"Vui lòng đăng nhập lại!\"}");
            out.flush();
            return;
        }

        String pathInfo = req.getPathInfo();

        // ---- POST /patient/book ----
        if ("/book".equals(pathInfo)) {
            try {
                int    doctorId = Integer.parseInt(req.getParameter("doctorId"));
                String date     = req.getParameter("date");
                String time     = req.getParameter("time");
                String symptoms = req.getParameter("symptoms");
                String reason   = req.getParameter("reason");
                String notes    = req.getParameter("notes");

                // Kiểm tra trùng lịch
                boolean isBooked = appointmentDAO.isTimeSlotBooked(doctorId, date, time);
                if (isBooked) {
                    out.print("{\"success\":false,\"message\":\"Khung giờ này đã được đặt. Vui lòng chọn giờ khác!\"}");
                    out.flush();
                    return;
                }

                Appointment appointment = new Appointment();
                appointment.setPatientId(patientId);
                appointment.setDoctorId(doctorId);
                appointment.setAppointmentDate(date);
                appointment.setAppointmentTime(time);
                appointment.setSymptoms(symptoms != null ? symptoms : "");
                appointment.setReason(reason   != null ? reason   : "");
                appointment.setNotes(notes     != null ? notes    : "");
                // Status mặc định = 'pending' (xem AppointmentDAO.createAppointment)

                boolean success = appointmentDAO.createAppointment(appointment);
                if (success) {
                    out.print("{\"success\":true,\"message\":\"Đặt lịch thành công! Vui lòng chờ bác sĩ xác nhận.\",\"appointmentId\":" + appointment.getAppointmentId() + "}");
                } else {
                    out.print("{\"success\":false,\"message\":\"Đặt lịch thất bại, vui lòng thử lại!\"}");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.print("{\"success\":false,\"message\":\"Lỗi hệ thống: " + escapeJson(e.getMessage()) + "\"}");
            }
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