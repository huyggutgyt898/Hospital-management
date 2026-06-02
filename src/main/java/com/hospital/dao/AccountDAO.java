/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.hospital.dao;

/**
 *
 * @author Admin
 */
import com.hospital.model.Account;
import java.sql.*;

public class AccountDAO {
    
    // Kiểm tra username đã tồn tại chưa
    public boolean isUsernameExists(String username) throws SQLException {
        String sql = "SELECT COUNT(*) FROM account WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        }
        return false;
    }
    
     // Tạo tài khoản mới
    public int createAccount(Account account) throws SQLException {
        String sql = "INSERT INTO account (username, password_account, email, phone, fullname, role, is_active, created_at) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, account.getUsername());
            stmt.setString(2, account.getPasswordAccount());
            stmt.setString(3, account.getEmail());
            stmt.setString(4, account.getPhone());
            stmt.setString(5, account.getFullname());            
            stmt.setString(6, account.getRole());
            stmt.setBoolean(7, account.isIsActive());
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        }
        return -1;
    }
    
    public Account findById(int accountId) throws SQLException {
        String sql = "SELECT * FROM account WHERE account_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, accountId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapResultSetToAccount(rs);
            }
        }
        return null;
    }

     // Tìm tài khoản theo username
    public Account findByUsername(String username) throws SQLException {
        String sql = "SELECT * FROM account WHERE username = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToAccount(rs);
            }
        }
        return null;
    }
    
      // Map ResultSet sang Account object
    private Account mapResultSetToAccount(ResultSet rs) throws SQLException {
        Account account = new Account();
        account.setAccountID(rs.getInt("account_id"));
        account.setUsername(rs.getString("username"));
        account.setPasswordAccount(rs.getString("password_account"));
        account.setFullname(rs.getString("fullname"));
        account.setEmail(rs.getString("email"));
        account.setPhone(rs.getString("phone"));
        account.setRole(rs.getString("role"));
        account.setIsActive(rs.getBoolean("is_active"));
        account.setCreateAt(rs.getTimestamp("created_at"));
        
        return account;
    }
    
     // Cập nhật thời gian đăng nhập cuối (nếu cần)
    public void updateLastLogin(int accountId) throws SQLException {
        String sql = "UPDATE account SET last_login = CURRENT_TIMESTAMP WHERE account_id = ?";
        // Note: Bạn cần thêm cột last_login vào bảng account nếu muốn
    }
    
    public boolean updatePassword(int accountId, String hashedPassword) throws SQLException {
        String sql = "UPDATE account SET password_account = ? WHERE account_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, hashedPassword);
            stmt.setInt(2, accountId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    // Lấy tổng số người dùng (toàn bộ account)
    public int getTotalUsers() throws SQLException {
        String sql = "SELECT COUNT(*) FROM account";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    // Lấy tổng số bác sĩ (giả sử role = 'doctor' hoặc 'bacsi')
    public int getTotalDoctors() throws SQLException {
        String sql = "SELECT COUNT(*) FROM account WHERE role = 'doctor'";
        // Nếu role khác, sửa lại: 'bacsi', 'BS', 'Doctor' tùy theo database của bạn
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    // Lấy tổng số bệnh nhân (giả sử role = 'patient' hoặc 'benhnhan')
    public int getTotalPatients() throws SQLException {
        String sql = "SELECT COUNT(*) FROM account WHERE role = 'patient'";
        // Nếu role khác, sửa lại: 'benhnhan', 'Patient' tùy theo database
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
