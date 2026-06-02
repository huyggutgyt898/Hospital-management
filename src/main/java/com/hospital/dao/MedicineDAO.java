package com.hospital.dao;

import com.hospital.model.Medicine;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MedicineDAO {
    
    // ==================== CREATE ====================
    
    public int createMedicine(Medicine medicine) throws SQLException {
        String sql = "INSERT INTO medicine (medicine_name, unit, stock_quantity, unit_price, expiry_date, supplier) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, medicine.getMedicineName());
            stmt.setString(2, medicine.getUnit());
            stmt.setInt(3, medicine.getStockQuantity());
            stmt.setDouble(4, medicine.getUnitPrice());
            stmt.setDate(5, medicine.getExpiryDate());
            stmt.setString(6, medicine.getSupplier());
            
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
    
    public Medicine getMedicineById(int medicineId) throws SQLException {
        String sql = "SELECT * FROM medicine WHERE medicine_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, medicineId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapResultSetToMedicine(rs);
            }
        }
        return null;
    }
    
    public List<Medicine> getAllMedicines() throws SQLException {
        List<Medicine> list = new ArrayList<>();
        String sql = "SELECT * FROM medicine ORDER BY medicine_id ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToMedicine(rs));
            }
        }
        return list;
    }
    
    public List<Medicine> searchMedicines(String keyword) throws SQLException {
        List<Medicine> list = new ArrayList<>();
        String sql = "SELECT * FROM medicine WHERE medicine_name LIKE ? OR supplier LIKE ? ORDER BY medicine_id ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            String searchParam = "%" + keyword + "%";
            stmt.setString(1, searchParam);
            stmt.setString(2, searchParam);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToMedicine(rs));
            }
        }
        return list;
    }
    
    public List<Medicine> getLowStockMedicines(int threshold) throws SQLException {
        List<Medicine> list = new ArrayList<>();
        String sql = "SELECT * FROM medicine WHERE stock_quantity < ? ORDER BY stock_quantity ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, threshold);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToMedicine(rs));
            }
        }
        return list;
    }
    
    // ==================== UPDATE ====================
    
    public boolean updateMedicine(Medicine medicine) throws SQLException {
        String sql = "UPDATE medicine SET medicine_name = ?, unit = ?, stock_quantity = ?, "
                   + "unit_price = ?, expiry_date = ?, supplier = ? WHERE medicine_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, medicine.getMedicineName());
            stmt.setString(2, medicine.getUnit());
            stmt.setInt(3, medicine.getStockQuantity());
            stmt.setDouble(4, medicine.getUnitPrice());
            stmt.setDate(5, medicine.getExpiryDate());
            stmt.setString(6, medicine.getSupplier());
            stmt.setInt(7, medicine.getMedicineId());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean updateStockQuantity(int medicineId, int newQuantity) throws SQLException {
        String sql = "UPDATE medicine SET stock_quantity = ? WHERE medicine_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, newQuantity);
            stmt.setInt(2, medicineId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    public boolean reduceStock(int medicineId, int quantity) throws SQLException {
        String sql = "UPDATE medicine SET stock_quantity = stock_quantity - ? WHERE medicine_id = ? AND stock_quantity >= ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, quantity);
            stmt.setInt(2, medicineId);
            stmt.setInt(3, quantity);
            return stmt.executeUpdate() > 0;
        }
    }
    
    // ==================== DELETE ====================
    
    public boolean deleteMedicine(int medicineId) throws SQLException {
        String sql = "DELETE FROM medicine WHERE medicine_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, medicineId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    // ==================== STATISTICS ====================
    
    public int getTotalMedicines() throws SQLException {
        String sql = "SELECT COUNT(*) FROM medicine";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    public int getLowStockCount(int threshold) throws SQLException {
        String sql = "SELECT COUNT(*) FROM medicine WHERE stock_quantity < ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, threshold);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    // ==================== PRIVATE METHODS ====================
    
    private Medicine mapResultSetToMedicine(ResultSet rs) throws SQLException {
        Medicine medicine = new Medicine();
        medicine.setMedicineId(rs.getInt("medicine_id"));
        medicine.setMedicineName(rs.getString("medicine_name"));
        medicine.setUnit(rs.getString("unit"));
        medicine.setStockQuantity(rs.getInt("stock_quantity"));
        medicine.setUnitPrice(rs.getDouble("unit_price"));
        medicine.setExpiryDate(rs.getDate("expiry_date"));
        medicine.setSupplier(rs.getString("supplier"));
        medicine.setCreatedAt(rs.getTimestamp("created_at"));
        medicine.setUpdatedAt(rs.getTimestamp("updated_at"));
        return medicine;
    }
}