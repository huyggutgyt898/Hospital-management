package com.hospital.dao;

import com.hospital.model.Admin;
import java.sql.*;

public class AdminDAO {

    /**
     * Lấy thông tin admin theo account_id.
     * Dùng để lấy fullname của người tạo báo cáo từ bảng admin.
     */
    public Admin getAdminByAccountId(int accountId) {
        String sql = "SELECT * FROM admin WHERE account_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, accountId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                Admin admin = new Admin();
                admin.setAdminId(rs.getInt("admin_id"));
                admin.setFullname(rs.getString("fullname"));
                admin.setPosition(rs.getString("position"));
                admin.setNotes(rs.getString("notes"));
                admin.setAccountId(rs.getInt("account_id"));
                return admin;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy fullname của admin theo account_id.
     * Trả về null nếu không tìm thấy.
     */
    public String getAdminFullnameByAccountId(int accountId) {
        Admin admin = getAdminByAccountId(accountId);
        return (admin != null) ? admin.getFullname() : null;
    }
}
