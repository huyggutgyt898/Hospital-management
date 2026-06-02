/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.hospital.dao;

/**
 *
 * @author Admin
 */
import com.hospital.model.Doctor;
import com.hospital.model.Account;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DoctorDAO {
    
    // ==================== CREATE ====================
    
    
    public int createDoctor(Doctor doctor) throws SQLException {
        String sql = "INSERT INTO doctor (fullname, specialty, phone, lianse_number, avatar, account_id, experience_years) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, doctor.getFullname());
            stmt.setString(2, doctor.getSpecialty());
            stmt.setString(3, doctor.getPhone());
            stmt.setString(4, doctor.getLianseNumber());
            stmt.setString(5, doctor.getAvatar());
            stmt.setInt(6, doctor.getAccountId());
            stmt.setInt(7, doctor.getExperience_years());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        }
        return -1;
    }
    
    // ==================== READ ====================
    
    /**
     * Lấy thông tin bác sĩ theo ID
     * @param doctorId ID của bác sĩ
     * @return Đối tượng Doctor hoặc null nếu không tìm thấy
     */
    public Doctor getDoctorById(int doctorId) throws SQLException {
        String sql = "SELECT * FROM doctor WHERE doctor_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, doctorId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapResultSetToDoctor(rs);
            }
        }
        return null;
    }
    
    /**
     * Lấy thông tin bác sĩ theo account_id
     * @param accountId ID của tài khoản
     * @return Đối tượng Doctor hoặc null nếu không tìm thấy
     */
    public Doctor getDoctorByAccountId(int accountId) throws SQLException {
        String sql = "SELECT * FROM doctor WHERE account_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, accountId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapResultSetToDoctor(rs);
            }
        }
        return null;
    }
    
    /**
     * Lấy danh sách tất cả bác sĩ
     * @return Danh sách các bác sĩ
     */
    public List<Doctor> getAllDoctors() throws SQLException {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT d.*, a.username, a.email, a.is_active " +
             "FROM doctor d " +
             "JOIN account a ON d.account_id = a.account_id " +
             "WHERE a.role = 'doctor' ORDER BY d.doctor_id ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToDoctor(rs));
            }
        }
        return list;
    }
    
    /**
     * Lấy danh sách bác sĩ theo chuyên khoa
     * @param specialty Chuyên khoa cần tìm
     * @return Danh sách bác sĩ theo chuyên khoa
     */
    public List<Doctor> getDoctorsBySpecialty(String specialty) throws SQLException {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT d.*, a.username, a.email, a.is_active "
                   + "FROM doctor d "
                   + "JOIN account a ON d.account_id = a.account_id "
                   + "WHERE a.role = 'doctor' AND d.specialty LIKE ? "
                   + "ORDER BY d.doctor_id ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, "%" + specialty + "%");
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToDoctor(rs));
            }
        }
        return list;
    }
    
    /**
     * Lấy danh sách bác sĩ đang hoạt động
     * @return Danh sách bác sĩ đang hoạt động
     */
    public List<Doctor> getActiveDoctors() throws SQLException {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT d.doctor_id, d.fullname, d.specialty, d.phone, " +
                     "d.lianse_number, d.avatar, d.account_id, d.experience_years, " +
                     "a.username, a.email, a.is_active " +
                     "FROM doctor d " +
                     "JOIN account a ON d.account_id = a.account_id " +
                     "WHERE a.role = 'doctor' AND a.is_active = 1 " +
                     "ORDER BY d.doctor_id ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToDoctor(rs));
            }
        }
        return list;
    }
    
    /**
     * Tìm kiếm bác sĩ theo tên
     * @param keyword Từ khóa tìm kiếm
     * @return Danh sách bác sĩ phù hợp
     */
    public List<Doctor> searchDoctors(String keyword) throws SQLException {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT d.doctor_id, d.fullname, d.specialty, d.phone, " +
             "d.lianse_number, d.avatar, d.account_id, d.experience_years, " +
             "a.username, a.email, a.is_active " +
             "FROM doctor d " +
             "JOIN account a ON d.account_id = a.account_id " +
             "WHERE a.role = 'doctor' AND (d.fullname LIKE ? OR d.specialty LIKE ?) " +
             "ORDER BY d.doctor_id ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            String searchParam = "%" + keyword + "%";
            stmt.setString(1, searchParam);
            stmt.setString(2, searchParam);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToDoctor(rs));
            }
        }
        return list;
    }
    
    // ==================== UPDATE ====================
    
    /**
     * Cập nhật thông tin bác sĩ
     * @param doctor Đối tượng Doctor với thông tin mới
     * @return true nếu cập nhật thành công
     */
    public boolean updateDoctor(Doctor doctor) throws SQLException {
        String sql = "UPDATE doctor SET fullname = ?, specialty = ?, phone = ?, "
                   + "lianse_number = ?, avatar = ? WHERE doctor_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, doctor.getFullname());
            stmt.setString(2, doctor.getSpecialty());
            stmt.setString(3, doctor.getPhone());
            stmt.setString(4, doctor.getLianseNumber());
            stmt.setString(5, doctor.getAvatar());
            stmt.setInt(6, doctor.getDoctorId());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Cập nhật chuyên khoa của bác sĩ
     * @param doctorId ID bác sĩ
     * @param specialty Chuyên khoa mới
     * @return true nếu cập nhật thành công
     */
    public boolean updateSpecialty(int doctorId, String specialty) throws SQLException {
        String sql = "UPDATE doctor SET specialty = ? WHERE doctor_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, specialty);
            stmt.setInt(2, doctorId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    // ==================== DELETE ====================
    
    /**
     * Xóa bác sĩ theo ID
     * @param doctorId ID bác sĩ cần xóa
     * @return true nếu xóa thành công
     */
    public boolean deleteDoctor(int doctorId) throws SQLException {
        String sql = "DELETE FROM doctor WHERE doctor_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, doctorId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Xóa bác sĩ theo account_id
     * @param accountId ID tài khoản
     * @return true nếu xóa thành công
     */
    public boolean deleteDoctorByAccountId(int accountId) throws SQLException {
        String sql = "DELETE FROM doctor WHERE account_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, accountId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    // ==================== STATISTICS ====================
    
    /**
     * Lấy tổng số bác sĩ
     * @return Tổng số bác sĩ
     */
    public int getTotalDoctors() throws SQLException {
        String sql = "SELECT COUNT(*) FROM doctor d "
                   + "JOIN account a ON d.account_id = a.account_id "
                   + "WHERE a.role = 'doctor'";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    /**
     * Lấy thống kê bác sĩ theo chuyên khoa
     * @return Danh sách thống kê
     */
    public List<SpecialtyStats> getDoctorStatsBySpecialty() throws SQLException {
        List<SpecialtyStats> list = new ArrayList<>();
        String sql = "SELECT specialty, COUNT(*) as count FROM doctor GROUP BY specialty";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                SpecialtyStats stats = new SpecialtyStats();
                stats.specialty = rs.getString("specialty");
                stats.count = rs.getInt("count");
                list.add(stats);
            }
        }
        return list;
    }
    
    // ==================== PRIVATE METHODS ====================
    
    private Doctor mapResultSetToDoctor(ResultSet rs) throws SQLException {
        Doctor doctor = new Doctor();
        doctor.setDoctorId(rs.getInt("doctor_id"));
        doctor.setFullname(rs.getString("fullname"));
        doctor.setSpecialty(rs.getString("specialty"));
        doctor.setPhone(rs.getString("phone"));
        doctor.setLianseNumber(rs.getString("lianse_number"));
        doctor.setAvatar(rs.getString("avatar"));
        doctor.setAccountId(rs.getInt("account_id"));
        doctor.setExperience_years(rs.getInt("experience_years")); 
        
        try {
        doctor.setUsername(rs.getString("username"));
        doctor.setEmail(rs.getString("email"));
        doctor.setIsActive(rs.getInt("is_active") == 1);
        } catch (SQLException e) {
            // Nếu không có các cột này trong ResultSet, bỏ qua
        }
        
        return doctor;
    }
    
    // ==================== INNER CLASSES ====================
    
    /**
     * Lớp thống kê theo chuyên khoa
     */
    public static class SpecialtyStats {
        public String specialty;
        public int count;
        
        public SpecialtyStats() {
            this.specialty = "";
            this.count = 0;
        }
    }
    
    public List<Doctor> getRecentDoctors(int limit) throws SQLException {
        List<Doctor> list = new ArrayList<>();
        String sql = "SELECT d.doctor_id, d.fullname, d.specialty, d.phone, a.created_at " +
                     "FROM doctor d " +
                     "JOIN account a ON d.account_id = a.account_id " +
                     "ORDER BY a.created_at DESC " +
                     "LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                Doctor doc = new Doctor();
                doc.setDoctorId(rs.getInt("doctor_id"));
                doc.setFullname(rs.getString("fullname"));
                doc.setSpecialty(rs.getString("specialty"));
                doc.setPhone(rs.getString("phone"));
                doc.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(doc);
            }
        }
        return list;
    }
    
    /**
 * Xóa bác sĩ + account liên kết
 */
    public boolean deleteFullDoctor(int doctorId) throws SQLException {
        // Lấy account_id trước
        int accountId = -1;
        String getAccSql = "SELECT account_id FROM doctor WHERE doctor_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(getAccSql)) {
            stmt.setInt(1, doctorId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) accountId = rs.getInt("account_id");
        }
        if (accountId == -1) return false;

        // Xóa doctor trước (FK), rồi xóa account
        String delDoc = "DELETE FROM doctor WHERE doctor_id = ?";
        String delAcc = "DELETE FROM account WHERE account_id = ?";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement s1 = conn.prepareStatement(delDoc);
                 PreparedStatement s2 = conn.prepareStatement(delAcc)) {
                s1.setInt(1, doctorId);
                s1.executeUpdate();
                s2.setInt(1, accountId);
                s2.executeUpdate();
                conn.commit();
                return true;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        }
    }

    /**
     * Cập nhật thông tin bác sĩ (fullname, specialty, phone, email, experience_years)
     */
    public boolean updateDoctorInfo(int doctorId, String fullname, String specialty,
                                     String phone, String email, int experienceYears) throws SQLException {
        String sql = "UPDATE doctor d JOIN account a ON d.account_id = a.account_id "
                   + "SET d.fullname = ?, d.specialty = ?, d.phone = ?, a.email = ?, d.experience_years = ? "
                   + "WHERE d.doctor_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, fullname);
            stmt.setString(2, specialty);
            stmt.setString(3, phone);
            stmt.setString(4, email);
            stmt.setInt(5, experienceYears);
            stmt.setInt(6, doctorId);
            return stmt.executeUpdate() > 0;
        }
    }
    
}
