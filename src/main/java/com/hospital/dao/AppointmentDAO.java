package com.hospital.dao;

import com.hospital.model.Appointment;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AppointmentDAO {
    
    // ==================== CREATE ====================
    
    /**
     * Tạo mới một lịch hẹn
     * @param appointment Đối tượng Appointment cần tạo
     * @return true nếu tạo thành công, false nếu thất bại
     */
    public boolean createAppointment(Appointment appointment) throws SQLException {
        String sql = "INSERT INTO appointment (patient_id, doctor_id, appointment_date, appointment_time, "
                   + "symptoms, reason, notes, status) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, 'pending')";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, appointment.getPatientId());
            stmt.setInt(2, appointment.getDoctorId());
            stmt.setString(3, appointment.getAppointmentDate());
            stmt.setString(4, appointment.getAppointmentTime());
            stmt.setString(5, appointment.getSymptoms());
            stmt.setString(6, appointment.getReason());
            stmt.setString(7, appointment.getNotes());
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        appointment.setAppointmentId(generatedKeys.getInt(1));
                        return true;
                    }
                }
            }
            return false;
        }
    }
    
    // ==================== READ ====================
    
    /**
     * Lấy lịch hẹn theo ID
     * @param appointmentId ID của lịch hẹn
     * @return Đối tượng Appointment hoặc null nếu không tìm thấy
     */
    public Appointment getAppointmentById(int appointmentId) throws SQLException {
        String sql = "SELECT a.*, "
                   + "p.fullname as patient_name, "
                   + "d.fullname as doctor_name "
                   + "FROM appointment a "
                   + "LEFT JOIN patient p ON a.patient_id = p.patient_id "
                   + "LEFT JOIN doctor d ON a.doctor_id = d.doctor_id "
                   + "WHERE a.appointment_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, appointmentId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapResultSetToAppointment(rs);
            }
        }
        return null;
    }
    
    /**
     * Lấy danh sách lịch hẹn theo bệnh nhân
     * @param patientId ID của bệnh nhân
     * @return Danh sách lịch hẹn của bệnh nhân
     */
    public List<Appointment> getAppointmentsByPatient(int patientId) throws SQLException {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, d.fullname as doctor_name "
                   + "FROM appointment a "
                   + "JOIN doctor d ON a.doctor_id = d.doctor_id "
                   + "WHERE a.patient_id = ? "
                   + "ORDER BY a.appointment_date DESC, a.appointment_time DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, patientId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToAppointment(rs));
            }
        }
        return list;
    }
    
    /**
     * Lấy danh sách lịch hẹn theo bác sĩ
     * @param doctorId ID của bác sĩ
     * @return Danh sách lịch hẹn của bác sĩ
     */
    public List<Appointment> getAppointmentsByDoctor(int doctorId) throws SQLException {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, p.fullname as patient_name "
                   + "FROM appointment a "
                   + "JOIN patient p ON a.patient_id = p.patient_id "
                   + "WHERE a.doctor_id = ? "
                   + "ORDER BY a.appointment_date ASC, a.appointment_time ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, doctorId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToAppointment(rs));
            }
        }
        return list;
    }
    
    /**
     * Lấy danh sách lịch hẹn theo trạng thái
     * @param status Trạng thái cần lọc (pending, confirmed, completed, cancelled)
     * @return Danh sách lịch hẹn theo trạng thái
     */
    public List<Appointment> getAppointmentsByStatus(String status) throws SQLException {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, p.fullname as patient_name, d.fullname as doctor_name "
                   + "FROM appointment a "
                   + "JOIN patient p ON a.patient_id = p.patient_id "
                   + "JOIN doctor d ON a.doctor_id = d.doctor_id "
                   + "WHERE a.status = ? "
                   + "ORDER BY a.appointment_date DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToAppointment(rs));
            }
        }
        return list;
    }
    
    /**
     * Lấy danh sách lịch hẹn trong khoảng thời gian
     * @param startDate Ngày bắt đầu
     * @param endDate Ngày kết thúc
     * @return Danh sách lịch hẹn trong khoảng thời gian
     */
    public List<Appointment> getAppointmentsByDateRange(String startDate, String endDate) throws SQLException {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, p.fullname as patient_name, d.fullname as doctor_name "
                   + "FROM appointment a "
                   + "JOIN patient p ON a.patient_id = p.patient_id "
                   + "JOIN doctor d ON a.doctor_id = d.doctor_id "
                   + "WHERE a.appointment_date BETWEEN ? AND ? "
                   + "ORDER BY a.appointment_date ASC, a.appointment_time ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, startDate);
            stmt.setString(2, endDate);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToAppointment(rs));
            }
        }
        return list;
    }
    
    /**
     * Lấy danh sách lịch hẹn hôm nay của bác sĩ
     * @param doctorId ID của bác sĩ
     * @return Danh sách lịch hẹn hôm nay
     */
    public List<Appointment> getTodayAppointmentsByDoctor(int doctorId) throws SQLException {
        List<Appointment> list = new ArrayList<>();
        String sql = "SELECT a.*, p.fullname as patient_name "
                   + "FROM appointment a "
                   + "JOIN patient p ON a.patient_id = p.patient_id "
                   + "WHERE a.doctor_id = ? AND a.appointment_date = CURDATE() "
                   + "ORDER BY a.appointment_time ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, doctorId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToAppointment(rs));
            }
        }
        return list;
    }
    
    // ==================== UPDATE ====================
    
    /**
     * Cập nhật trạng thái lịch hẹn
     * @param appointmentId ID của lịch hẹn
     * @param status Trạng thái mới
     * @return true nếu cập nhật thành công
     */
    public boolean updateStatus(int appointmentId, String status) throws SQLException {
        String sql = "UPDATE appointment SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE appointment_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
            stmt.setInt(2, appointmentId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Cập nhật toàn bộ thông tin lịch hẹn
     * @param appointment Đối tượng Appointment với thông tin mới
     * @return true nếu cập nhật thành công
     */
    public boolean updateAppointment(Appointment appointment) throws SQLException {
        String sql = "UPDATE appointment SET "
                   + "appointment_date = ?, appointment_time = ?, "
                   + "symptoms = ?, reason = ?, notes = ?, "
                   + "updated_at = CURRENT_TIMESTAMP "
                   + "WHERE appointment_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, appointment.getAppointmentDate());
            stmt.setString(2, appointment.getAppointmentTime());
            stmt.setString(3, appointment.getSymptoms());
            stmt.setString(4, appointment.getReason());
            stmt.setString(5, appointment.getNotes());
            stmt.setInt(6, appointment.getAppointmentId());
            return stmt.executeUpdate() > 0;
        }
    }
    
    // ==================== DELETE ====================
    
    /**
     * Xóa lịch hẹn theo ID
     * @param appointmentId ID của lịch hẹn cần xóa
     * @return true nếu xóa thành công
     */
    public boolean deleteAppointment(int appointmentId) throws SQLException {
        String sql = "DELETE FROM appointment WHERE appointment_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, appointmentId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    // ==================== STATISTICS ====================
    
    /**
     * Lấy thống kê lịch hẹn của bác sĩ
     * @param doctorId ID của bác sĩ
     * @return Đối tượng chứa thống kê
     */
    public DoctorStats getDoctorStats(int doctorId) throws SQLException {
        DoctorStats stats = new DoctorStats();
        String sql = "SELECT "
                   + "SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_count, "
                   + "SUM(CASE WHEN status = 'confirmed' THEN 1 ELSE 0 END) as confirmed_count, "
                   + "SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_count, "
                   + "SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_count, "
                   + "SUM(CASE WHEN appointment_date = CURDATE() THEN 1 ELSE 0 END) as today_count, "
                   + "COUNT(*) as total_count "
                   + "FROM appointment WHERE doctor_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, doctorId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                stats.pendingCount = rs.getInt("pending_count");
                stats.confirmedCount = rs.getInt("confirmed_count");
                stats.completedCount = rs.getInt("completed_count");
                stats.cancelledCount = rs.getInt("cancelled_count");
                stats.todayCount = rs.getInt("today_count");
                stats.totalCount = rs.getInt("total_count");
            }
        }
        return stats;
    }
    
    /**
     * Lấy thống kê lịch hẹn theo bệnh nhân
     * @param patientId ID của bệnh nhân
     * @return Đối tượng chứa thống kê
     */
    public PatientStats getPatientStats(int patientId) throws SQLException {
        PatientStats stats = new PatientStats();
        String sql = "SELECT "
                   + "COUNT(*) as total_count, "
                   + "SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_count, "
                   + "SUM(CASE WHEN status = 'pending' THEN 1 ELSE 0 END) as pending_count "
                   + "FROM appointment WHERE patient_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, patientId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                stats.totalCount = rs.getInt("total_count");
                stats.completedCount = rs.getInt("completed_count");
                stats.pendingCount = rs.getInt("pending_count");
            }
        }
        return stats;
    }
    
    /**
     * Kiểm tra thời gian có bị trùng lịch không
     * @param doctorId ID bác sĩ
     * @param date Ngày khám
     * @param time Giờ khám
     * @return true nếu đã có lịch hẹn, false nếu chưa có
     */
    public boolean isTimeSlotBooked(int doctorId, String date, String time) throws SQLException {
        String sql = "SELECT COUNT(*) FROM appointment "
                   + "WHERE doctor_id = ? AND appointment_date = ? AND appointment_time = ? "
                   + "AND status IN ('pending', 'confirmed')";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, doctorId);
            stmt.setString(2, date);
            stmt.setString(3, time);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }
    
    // ==================== PRIVATE METHODS ====================
    
    private Appointment mapResultSetToAppointment(ResultSet rs) throws SQLException {
        Appointment appointment = new Appointment();
        appointment.setAppointmentId(rs.getInt("appointment_id"));
        appointment.setPatientId(rs.getInt("patient_id"));
        appointment.setDoctorId(rs.getInt("doctor_id"));
        appointment.setAppointmentDate(rs.getString("appointment_date"));
        appointment.setAppointmentTime(rs.getString("appointment_time"));
        appointment.setStatus(rs.getString("status"));
        appointment.setSymptoms(rs.getString("symptoms"));
        appointment.setReason(rs.getString("reason"));
        appointment.setNotes(rs.getString("notes"));
        appointment.setCreatedAt(rs.getTimestamp("created_at"));
        appointment.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        // Các trường JOIN (nếu có)
        try {
            appointment.setPatientName(rs.getString("patient_name"));
        } catch (SQLException e) { /* Không có cột này */ }
        
        try {
            appointment.setDoctorName(rs.getString("doctor_name"));
        } catch (SQLException e) { /* Không có cột này */ }
        
        return appointment;
    }
    
    // ==================== INNER CLASSES ====================
    
    /**
     * Lớp thống kê cho bác sĩ
     */
    public static class DoctorStats {
        public int pendingCount;
        public int confirmedCount;
        public int completedCount;
        public int cancelledCount;
        public int todayCount;
        public int totalCount;
        
        public DoctorStats() {
            pendingCount = 0;
            confirmedCount = 0;
            completedCount = 0;
            cancelledCount = 0;
            todayCount = 0;
            totalCount = 0;
        }
    }
    
    /**
     * Lớp thống kê cho bệnh nhân
     */
    public static class PatientStats {
        public int totalCount;
        public int completedCount;
        public int pendingCount;
        
        public PatientStats() {
            totalCount = 0;
            completedCount = 0;
            pendingCount = 0;
        }
    }
    
    // Lấy tổng số lịch hẹn (nếu có bảng appointment)
    public int getTotalAppointments() throws SQLException {
        String sql = "SELECT COUNT(*) FROM appointment";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
}