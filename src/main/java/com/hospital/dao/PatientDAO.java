package com.hospital.dao;

import com.hospital.model.Patient;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PatientDAO {
    
    // ==================== CREATE ====================
    
    /**
     * Thêm mới một bệnh nhân
     * @param patient Đối tượng Patient cần thêm
     * @return patientId nếu thành công, -1 nếu thất bại
     */
    public int createPatient(Patient patient) throws SQLException {
        String sql = "INSERT INTO patient (fullname, age, gender, phone, address, date_of_birth, account_id, health_insurance) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, patient.getFullname());
            stmt.setInt(2, patient.getAge());
            stmt.setString(3, patient.getGender());
            stmt.setString(4, patient.getPhone());
            stmt.setString(5, patient.getAddress());
            stmt.setDate(6, patient.getDateOfBirth());
            stmt.setInt(7, patient.getAccountId());
            String healthInsurance = patient.getHealthInsurance() != null && !patient.getHealthInsurance().trim().isEmpty()
                    ? patient.getHealthInsurance().trim()
                    : "Chưa";
            stmt.setString(8, healthInsurance);
            
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

    public int createPatient(Connection conn, Patient patient) throws SQLException {
        String sql = "INSERT INTO patient (fullname, age, gender, phone, address, date_of_birth, account_id, health_insurance) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, patient.getFullname());
            stmt.setInt(2, patient.getAge());
            stmt.setString(3, patient.getGender());
            stmt.setString(4, patient.getPhone());
            stmt.setString(5, patient.getAddress());
            stmt.setDate(6, patient.getDateOfBirth());
            stmt.setInt(7, patient.getAccountId());
            String healthInsurance = patient.getHealthInsurance() != null && !patient.getHealthInsurance().trim().isEmpty()
                    ? patient.getHealthInsurance().trim()
                    : "Chưa";
            stmt.setString(8, healthInsurance);
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
     * Lấy thông tin bệnh nhân theo ID
     * @param patientId ID của bệnh nhân
     * @return Đối tượng Patient hoặc null nếu không tìm thấy
     */
    public Patient getPatientById(int patientId) throws SQLException {
        String sql = "SELECT * FROM patient WHERE patient_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, patientId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapResultSetToPatient(rs);
            }
        }
        return null;
    }
    
    /**
     * Lấy thông tin bệnh nhân theo account_id
     * @param accountId ID của tài khoản
     * @return Đối tượng Patient hoặc null nếu không tìm thấy
     */
    public Patient getPatientByAccountId(int accountId) throws SQLException {
        String sql = "SELECT * FROM patient WHERE account_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, accountId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapResultSetToPatient(rs);
            }
        }
        return null;
    }
    
    /**
     * Lấy patient_id theo account_id
     * @param accountId ID của tài khoản
     * @return patient_id nếu tìm thấy, -1 nếu không
     */
    public int getPatientIdByAccountId(int accountId) throws SQLException {
        String sql = "SELECT patient_id FROM patient WHERE account_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, accountId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("patient_id");
            }
        }
        return -1;
    }
    
    /**
     * Lấy danh sách tất cả bệnh nhân
     * @return Danh sách các bệnh nhân
     */
    public List<Patient> getAllPatients() throws SQLException {
        List<Patient> list = new ArrayList<>();
        String sql = "SELECT p.*, a.username, a.email, a.is_active "
                   + "FROM patient p "
                   + "JOIN account a ON p.account_id = a.account_id "
                   + "WHERE a.role = 'patient' "
                   + "ORDER BY p.patient_id ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToPatient(rs));
            }
        }
        return list;
    }
    
    /**
     * Lấy danh sách bệnh nhân theo giới tính
     * @param gender Giới tính cần lọc ('male', 'female', 'other')
     * @return Danh sách bệnh nhân theo giới tính
     */
    public List<Patient> getPatientsByGender(String gender) throws SQLException {
        List<Patient> list = new ArrayList<>();
        String sql = "SELECT p.*, a.username, a.email, a.is_active "
                   + "FROM patient p "
                   + "JOIN account a ON p.account_id = a.account_id "
                   + "WHERE a.role = 'patient' AND p.gender = ? "
                   + "ORDER BY p.patient_id ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, gender);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToPatient(rs));
            }
        }
        return list;
    }
    
    /**
     * Lấy danh sách bệnh nhân theo độ tuổi
     * @param minAge Tuổi tối thiểu
     * @param maxAge Tuổi tối đa
     * @return Danh sách bệnh nhân trong khoảng tuổi
     */
    public List<Patient> getPatientsByAgeRange(int minAge, int maxAge) throws SQLException {
        List<Patient> list = new ArrayList<>();
        String sql = "SELECT p.*, a.username, a.email, a.is_active "
                   + "FROM patient p "
                   + "JOIN account a ON p.account_id = a.account_id "
                   + "WHERE a.role = 'patient' AND p.age BETWEEN ? AND ? "
                   + "ORDER BY p.patient_id ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, minAge);
            stmt.setInt(2, maxAge);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToPatient(rs));
            }
        }
        return list;
    }
    
    /**
     * Tìm kiếm bệnh nhân theo tên hoặc số điện thoại
     * @param keyword Từ khóa tìm kiếm
     * @return Danh sách bệnh nhân phù hợp
     */
    public List<Patient> searchPatients(String keyword) throws SQLException {
        List<Patient> list = new ArrayList<>();
        String sql = "SELECT p.*, a.username, a.email, a.is_active "
                   + "FROM patient p "
                   + "JOIN account a ON p.account_id = a.account_id "
                   + "WHERE a.role = 'patient' AND (p.fullname LIKE ? OR p.phone LIKE ?) "
                   + "ORDER BY p.patient_id ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            String searchParam = "%" + keyword + "%";
            stmt.setString(1, searchParam);
            stmt.setString(2, searchParam);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToPatient(rs));
            }
        }
        return list;
    }
    
    /**
     * Lấy danh sách bệnh nhân mới nhất
     * @param limit Số lượng bệnh nhân cần lấy
     * @return Danh sách bệnh nhân mới nhất
     */
    public List<Patient> getRecentPatients(int limit) throws SQLException {
        List<Patient> list = new ArrayList<>();
        String sql = "SELECT p.*, a.username, a.email, a.is_active "
                   + "FROM patient p "
                   + "JOIN account a ON p.account_id = a.account_id "
                   + "WHERE a.role = 'patient' "
                   + "ORDER BY p.created_at DESC LIMIT ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToPatient(rs));
            }
        }
        return list;
    }
    
    // ==================== UPDATE ====================
    
    /**
     * Cập nhật thông tin bệnh nhân
     * @param patient Đối tượng Patient với thông tin mới
     * @return true nếu cập nhật thành công
     */
    public boolean updatePatient(Patient patient) throws SQLException {
        String sql = "UPDATE patient SET fullname = ?, age = ?, gender = ?, "
                   + "phone = ?, address = ?, date_of_birth = ? WHERE patient_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, patient.getFullname());
            stmt.setInt(2, patient.getAge());
            stmt.setString(3, patient.getGender());
            stmt.setString(4, patient.getPhone());
            stmt.setString(5, patient.getAddress());
            stmt.setDate(6, patient.getDateOfBirth());
            stmt.setInt(7, patient.getPatientId());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Cập nhật số điện thoại bệnh nhân
     * @param patientId ID bệnh nhân
     * @param phone Số điện thoại mới
     * @return true nếu cập nhật thành công
     */
    public boolean updatePhone(int patientId, String phone) throws SQLException {
        String sql = "UPDATE patient SET phone = ? WHERE patient_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, phone);
            stmt.setInt(2, patientId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Cập nhật địa chỉ bệnh nhân
     * @param patientId ID bệnh nhân
     * @param address Địa chỉ mới
     * @return true nếu cập nhật thành công
     */
    public boolean updateAddress(int patientId, String address) throws SQLException {
        String sql = "UPDATE patient SET address = ? WHERE patient_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, address);
            stmt.setInt(2, patientId);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Cập nhật thông tin bảo hiểm y tế (health_insurance)
     */
    public boolean updateHealthInsurance(int patientId, String healthInsurance) throws SQLException {
        String sql = "UPDATE patient SET health_insurance = ? WHERE patient_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, healthInsurance);
            stmt.setInt(2, patientId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    // ==================== DELETE ====================
    
    /**
     * Xóa bệnh nhân theo ID
     * @param patientId ID bệnh nhân cần xóa
     * @return true nếu xóa thành công
     */
    public boolean deletePatient(int patientId) throws SQLException {
        String sql = "DELETE FROM patient WHERE patient_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, patientId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Xóa bệnh nhân theo account_id
     * @param accountId ID tài khoản
     * @return true nếu xóa thành công
     */
    public boolean deletePatientByAccountId(int accountId) throws SQLException {
        String sql = "DELETE FROM patient WHERE account_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, accountId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    // ==================== STATISTICS ====================
    
    /**
     * Lấy tổng số bệnh nhân
     * @return Tổng số bệnh nhân
     */
    public int getTotalPatients() throws SQLException {
        String sql = "SELECT COUNT(*) FROM patient p "
                   + "JOIN account a ON p.account_id = a.account_id "
                   + "WHERE a.role = 'patient'";
        
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
     * Lấy thống kê bệnh nhân theo giới tính
     * @return Danh sách thống kê
     */
    public List<GenderStats> getPatientStatsByGender() throws SQLException {
        List<GenderStats> list = new ArrayList<>();
        String sql = "SELECT gender, COUNT(*) as count FROM patient GROUP BY gender";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                GenderStats stats = new GenderStats();
                stats.gender = rs.getString("gender");
                stats.count = rs.getInt("count");
                list.add(stats);
            }
        }
        return list;
    }
    
    /**
     * Lấy thống kê bệnh nhân theo độ tuổi
     * @return Mảng thống kê theo nhóm tuổi
     */
    public AgeStats getPatientStatsByAge() throws SQLException {
        AgeStats stats = new AgeStats();
        String sql = "SELECT "
                   + "SUM(CASE WHEN age < 18 THEN 1 ELSE 0 END) as under_18, "
                   + "SUM(CASE WHEN age BETWEEN 18 AND 35 THEN 1 ELSE 0 END) as age_18_35, "
                   + "SUM(CASE WHEN age BETWEEN 36 AND 50 THEN 1 ELSE 0 END) as age_36_50, "
                   + "SUM(CASE WHEN age BETWEEN 51 AND 65 THEN 1 ELSE 0 END) as age_51_65, "
                   + "SUM(CASE WHEN age > 65 THEN 1 ELSE 0 END) as over_65 "
                   + "FROM patient";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                stats.under18 = rs.getInt("under_18");
                stats.age18to35 = rs.getInt("age_18_35");
                stats.age36to50 = rs.getInt("age_36_50");
                stats.age51to65 = rs.getInt("age_51_65");
                stats.over65 = rs.getInt("over_65");
            }
        }
        return stats;
    }
    
    // ==================== PRIVATE METHODS ====================
    
    private Patient mapResultSetToPatient(ResultSet rs) throws SQLException {
        Patient patient = new Patient();
        patient.setPatientId(rs.getInt("patient_id"));
        patient.setFullname(rs.getString("fullname"));
        patient.setAge(rs.getInt("age"));
        patient.setGender(rs.getString("gender"));
        patient.setPhone(rs.getString("phone"));
        patient.setAddress(rs.getString("address"));
        patient.setDateOfBirth(rs.getDate("date_of_birth"));
        patient.setAccountId(rs.getInt("account_id"));

        try {
            patient.setHealthInsurance(rs.getString("health_insurance"));
        } catch (SQLException e) {
            // cột có thể chưa có
        }
        
        // Lấy thêm created_at nếu có
        try {
            patient.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (SQLException e) {
            // Cột không tồn tại, bỏ qua
        }
        
        // Lấy thêm thông tin account nếu có
        try {
            patient.setUsername(rs.getString("username"));
            patient.setEmail(rs.getString("email"));
            patient.setIsActive(rs.getInt("is_active") == 1);
        } catch (SQLException e) {
            // Nếu không có các cột này trong ResultSet, bỏ qua
        }
        
        return patient;
    }
    
    // ==================== INNER CLASSES ====================
    
    /**
     * Lớp thống kê theo giới tính
     */
    public static class GenderStats {
        public String gender;
        public int count;
        
        public GenderStats() {
            this.gender = "";
            this.count = 0;
        }
    }
    
    /**
     * Lớp thống kê theo độ tuổi
     */
    public static class AgeStats {
        public int under18;
        public int age18to35;
        public int age36to50;
        public int age51to65;
        public int over65;
        
        public AgeStats() {
            under18 = 0;
            age18to35 = 0;
            age36to50 = 0;
            age51to65 = 0;
            over65 = 0;
        }
    }
    
    /**
     * Cập nhật thông tin bệnh nhân (fullname, phone, email, address, gender, date_of_birth)
     */
    public boolean updatePatientInfo(int patientId, String fullname, String phone,
                                      String email, String address, String gender,
                                      Date dateOfBirth) throws SQLException {
        String sql = "UPDATE patient p JOIN account a ON p.account_id = a.account_id "
                   + "SET p.fullname = ?, p.phone = ?, a.email = ?, p.address = ?, a.fullname = ?, p.gender = ?, p.date_of_birth = ? "
                   + "WHERE p.patient_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, fullname);
            stmt.setString(2, phone);
            stmt.setString(3, email);
            stmt.setString(4, address);
            stmt.setString(5, fullname);
            stmt.setString(6, gender);
            if (dateOfBirth != null) {
                stmt.setDate(7, dateOfBirth);
            } else {
                stmt.setNull(7, Types.DATE);
            }
            stmt.setInt(8, patientId);
            return stmt.executeUpdate() > 0;
        }
    }

    /**
     * Cập nhật thông tin bệnh nhân (fullname, phone, email, address)
     */
    public boolean updatePatientInfo(int patientId, String fullname, String phone,
                                      String email, String address) throws SQLException {
        return updatePatientInfo(patientId, fullname, phone, email, address, null, null);
    }
    
    /**
     * Xóa bệnh nhân + account liên kết
     */
    public boolean deleteFullPatient(int patientId) throws SQLException {
        int accountId = -1;
        String getAccSql = "SELECT account_id FROM patient WHERE patient_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(getAccSql)) {
            stmt.setInt(1, patientId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) accountId = rs.getInt("account_id");
        }
        if (accountId == -1) return false;

        String delPat = "DELETE FROM patient WHERE patient_id = ?";
        String delAcc = "DELETE FROM account WHERE account_id = ?";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement s1 = conn.prepareStatement(delPat);
                 PreparedStatement s2 = conn.prepareStatement(delAcc)) {
                s1.setInt(1, patientId);
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
    
}