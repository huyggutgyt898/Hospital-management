package com.hospital.dao;

import com.hospital.model.BillDetail;
import com.hospital.model.Payment;
import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class PaymentDAO {

    public Payment getByAppointmentId(int appointmentId) throws SQLException {
        String sql = "SELECT * FROM payment WHERE appointment_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, appointmentId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapPayment(rs);
            }
        }
        return null;
    }

    public Payment getById(int paymentId) throws SQLException {
        String sql = "SELECT p.*, pt.fullname AS patient_name, d.fullname AS doctor_name, "
                + "a.appointment_date, a.appointment_time "
                + "FROM payment p "
                + "JOIN appointment a ON p.appointment_id = a.appointment_id "
                + "JOIN patient pt ON p.patient_id = pt.patient_id "
                + "JOIN doctor d ON a.doctor_id = d.doctor_id "
                + "WHERE p.payment_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, paymentId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapPaymentWithJoin(rs);
            }
        }
        return null;
    }

    public Payment createOrUpdateFromBill(BillDetail bill) throws SQLException {
        Payment existing = getByAppointmentId(bill.getAppointmentId());
        if (existing == null) {
            String sql = "INSERT INTO payment (appointment_id, patient_id, examination_fee, medicine_fee, "
                    + "subtotal, discount_percent, discount_amount, total_amount, has_insurance, payment_status) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'unpaid')";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setInt(1, bill.getAppointmentId());
                stmt.setInt(2, bill.getPatientId());
                stmt.setDouble(3, bill.getExaminationFee());
                stmt.setDouble(4, bill.getMedicineFee());
                stmt.setDouble(5, bill.getSubtotal());
                stmt.setDouble(6, bill.getDiscountPercent());
                stmt.setDouble(7, bill.getDiscountAmount());
                stmt.setDouble(8, bill.getTotalAmount());
                stmt.setBoolean(9, bill.isHasInsurance());
                stmt.executeUpdate();
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        return getById(keys.getInt(1));
                    }
                }
            }
            return getByAppointmentId(bill.getAppointmentId());
        }

        String sql = "UPDATE payment SET examination_fee = ?, medicine_fee = ?, subtotal = ?, "
                + "discount_percent = ?, discount_amount = ?, total_amount = ?, has_insurance = ?, "
                + "updated_at = CURRENT_TIMESTAMP WHERE appointment_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDouble(1, bill.getExaminationFee());
            stmt.setDouble(2, bill.getMedicineFee());
            stmt.setDouble(3, bill.getSubtotal());
            stmt.setDouble(4, bill.getDiscountPercent());
            stmt.setDouble(5, bill.getDiscountAmount());
            stmt.setDouble(6, bill.getTotalAmount());
            stmt.setBoolean(7, bill.isHasInsurance());
            stmt.setInt(8, bill.getAppointmentId());
            stmt.executeUpdate();
        }
        return getByAppointmentId(bill.getAppointmentId());
    }

    public boolean submitPayment(int appointmentId, int patientId, String method) throws SQLException {
        String status = ("cash".equals(method) || "qr".equals(method)) ? "pending_admin" : "paid";
        String sql = "UPDATE payment SET payment_method = ?, payment_status = ?, "
                + "paid_at = " + ("paid".equals(status) ? "CURRENT_TIMESTAMP" : "NULL") + ", "
                + "admin_confirmed = ?, updated_at = CURRENT_TIMESTAMP "
                + "WHERE appointment_id = ? AND patient_id = ? AND payment_status = 'unpaid'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, method);
            stmt.setString(2, status);
            stmt.setBoolean(3, "paid".equals(status));
            stmt.setInt(4, appointmentId);
            stmt.setInt(5, patientId);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean adminConfirmCash(int paymentId) throws SQLException {
        String sql = "UPDATE payment SET payment_status = 'paid', admin_confirmed = 1, "
                + "paid_at = COALESCE(paid_at, CURRENT_TIMESTAMP), updated_at = CURRENT_TIMESTAMP "
                + "WHERE payment_id = ? AND payment_method IN ('cash', 'qr') AND payment_status = 'pending_admin'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, paymentId);
            return stmt.executeUpdate() > 0;
        }
    }

    public List<Payment> listForAdmin(String filter) throws SQLException {
        List<Payment> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT p.*, pt.fullname AS patient_name, d.fullname AS doctor_name, "
                + "a.appointment_date, a.appointment_time "
                + "FROM payment p "
                + "JOIN appointment a ON p.appointment_id = a.appointment_id "
                + "JOIN patient pt ON p.patient_id = pt.patient_id "
                + "JOIN doctor d ON a.doctor_id = d.doctor_id "
                + "WHERE 1=1 ");
        if ("pending".equals(filter)) {
            sql.append("AND p.payment_status = 'pending_admin' ");
        } else if ("paid".equals(filter)) {
            sql.append("AND p.payment_status = 'paid' ");
        } else if ("unpaid".equals(filter)) {
            sql.append("AND p.payment_status = 'unpaid' ");
        }
        sql.append("ORDER BY p.created_at DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString());
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapPaymentWithJoin(rs));
            }
        }
        return list;
    }

    public List<Payment> listPayableByPatient(int patientId) throws SQLException {
        List<Payment> list = new ArrayList<>();
        String sql = "SELECT p.*, d.fullname AS doctor_name, a.appointment_date, a.appointment_time, "
                + "a.status AS appt_status "
                + "FROM payment p "
                + "JOIN appointment a ON p.appointment_id = a.appointment_id "
                + "JOIN doctor d ON a.doctor_id = d.doctor_id "
                + "WHERE p.patient_id = ? AND a.status = 'completed' "
                + "ORDER BY p.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, patientId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Payment pay = mapPayment(rs);
                pay.setDoctorName(rs.getString("doctor_name"));
                pay.setAppointmentDate(rs.getString("appointment_date"));
                pay.setAppointmentTime(rs.getString("appointment_time"));
                list.add(pay);
            }
        }
        return list;
    }

    public double getTotalRevenue() throws SQLException {
        String sql = "SELECT COALESCE(SUM(total_amount), 0) FROM payment WHERE payment_status = 'paid'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        }
        return 0;
    }

    public Map<String, Double> getMonthlyRevenue(int months) throws SQLException {
        Map<String, Double> map = new LinkedHashMap<>();
        String sql = "SELECT DATE_FORMAT(paid_at, '%Y-%m') AS ym, COALESCE(SUM(total_amount), 0) AS revenue "
                + "FROM payment WHERE payment_status = 'paid' AND paid_at IS NOT NULL "
                + "AND paid_at >= DATE_SUB(CURDATE(), INTERVAL ? MONTH) "
                + "GROUP BY ym ORDER BY ym ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, months);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                map.put(rs.getString("ym"), rs.getDouble("revenue"));
            }
        }
        return map;
    }

    /**
     * Lấy doanh thu theo ngày cho 30 ngày gần nhất (bao gồm ngày hôm nay).
     * Trả về LinkedHashMap với key là ngày YYYY-MM-DD để dễ biểu diễn trên biểu đồ.
     */
    public Map<String, Double> getDailyRevenueLastMonth() throws SQLException {
        Map<String, Double> map = new LinkedHashMap<>();
        java.time.LocalDate today = java.time.LocalDate.now();
        java.time.LocalDate start = today.minusDays(29); // 30 ngày gồm hôm nay
        // Khởi tạo map với 0 cho mỗi ngày
        java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd");
        for (java.time.LocalDate d = start; !d.isAfter(today); d = d.plusDays(1)) {
            map.put(d.format(fmt), 0.0);
        }

        String sql = "SELECT DATE(paid_at) AS d, COALESCE(SUM(total_amount),0) AS revenue "
                + "FROM payment WHERE payment_status = 'paid' AND paid_at IS NOT NULL "
                + "AND paid_at >= ? GROUP BY d ORDER BY d ASC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDate(1, java.sql.Date.valueOf(start));
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                java.sql.Date d = rs.getDate("d");
                if (d != null) {
                    String key = d.toLocalDate().format(fmt);
                    map.put(key, rs.getDouble("revenue"));
                }
            }
        }
        return map;
    }

    /**
     * Lấy danh sách payment theo patient (gồm thông tin join với appointment/doctor)
     */
    public List<Payment> listByPatient(int patientId) throws SQLException {
        List<Payment> list = new ArrayList<>();
        String sql = "SELECT p.*, pt.fullname AS patient_name, d.fullname AS doctor_name, "
                + "a.appointment_date, a.appointment_time "
                + "FROM payment p "
                + "JOIN appointment a ON p.appointment_id = a.appointment_id "
                + "JOIN patient pt ON p.patient_id = pt.patient_id "
                + "JOIN doctor d ON a.doctor_id = d.doctor_id "
                + "WHERE p.patient_id = ? "
                + "ORDER BY COALESCE(p.paid_at, p.created_at) DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, patientId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapPaymentWithJoin(rs));
            }
        }
        return list;
    }

    private Payment mapPayment(ResultSet rs) throws SQLException {
        Payment p = new Payment();
        p.setPaymentId(rs.getInt("payment_id"));
        p.setAppointmentId(rs.getInt("appointment_id"));
        p.setPatientId(rs.getInt("patient_id"));
        p.setExaminationFee(rs.getDouble("examination_fee"));
        p.setMedicineFee(rs.getDouble("medicine_fee"));
        p.setSubtotal(rs.getDouble("subtotal"));
        p.setDiscountPercent(rs.getDouble("discount_percent"));
        p.setDiscountAmount(rs.getDouble("discount_amount"));
        p.setTotalAmount(rs.getDouble("total_amount"));
        p.setHasInsurance(rs.getBoolean("has_insurance"));
        p.setPaymentMethod(rs.getString("payment_method"));
        p.setPaymentStatus(rs.getString("payment_status"));
        p.setAdminConfirmed(rs.getBoolean("admin_confirmed"));
        p.setPaidAt(rs.getTimestamp("paid_at"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        p.setUpdatedAt(rs.getTimestamp("updated_at"));
        return p;
    }

    private Payment mapPaymentWithJoin(ResultSet rs) throws SQLException {
        Payment p = mapPayment(rs);
        try {
            p.setPatientName(rs.getString("patient_name"));
            p.setDoctorName(rs.getString("doctor_name"));
            p.setAppointmentDate(rs.getString("appointment_date"));
            p.setAppointmentTime(rs.getString("appointment_time"));
        } catch (SQLException ignored) {
        }
        return p;
    }
}
