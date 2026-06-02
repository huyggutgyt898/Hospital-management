package com.hospital.dao;

import com.hospital.model.Prescription;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PrescriptionDAO {
    
    // ==================== CREATE ====================
    
    /**
     * Tạo mới một đơn thuốc
     */
    public boolean createPrescription(Prescription prescription) throws SQLException {
        String sql = "INSERT INTO prescription (appointment_id, medicine_id, quantity, dosage, frequency, instruction) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, prescription.getAppointmentId());
            stmt.setInt(2, prescription.getMedicineId());
            stmt.setInt(3, prescription.getQuantity());
            stmt.setString(4, prescription.getDosage());
            stmt.setString(5, prescription.getFrequency());
            stmt.setString(6, prescription.getInstruction());
            
            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        prescription.setPrescriptionId(rs.getInt(1));
                        return true;
                    }
                }
            }
            return false;
        }
    }
    
    /**
     * Tạo đơn thuốc với các tham số riêng lẻ
     */
    public boolean createPrescription(int appointmentId, int medicineId, int quantity, 
                                   String dosage, String frequency, String duration, String instruction) throws SQLException {
        String sql = "INSERT INTO prescription (appointment_id, medicine_id, quantity, dosage, frequency, instruction) "
                   + "VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setInt(1, appointmentId);
            stmt.setInt(2, medicineId);
            stmt.setInt(3, quantity);
            stmt.setString(4, dosage);
            stmt.setString(5, frequency);
            stmt.setString(6, instruction);

            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        return true;
                    }
                }
            }
            return false;
        }
    }
    
    // ==================== READ ====================
    
    /**
     * Lấy đơn thuốc theo ID
     */
    public Prescription getPrescriptionById(int prescriptionId) throws SQLException {
        String sql = "SELECT p.*, m.medicine_name, m.unit, m.unit_price "
                   + "FROM prescription p "
                   + "JOIN medicine m ON p.medicine_id = m.medicine_id "
                   + "WHERE p.prescription_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, prescriptionId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return mapResultSetToPrescription(rs);
            }
        }
        return null;
    }
    
    /**
     * Lấy danh sách đơn thuốc theo appointment_id
     */
    public List<Prescription> getPrescriptionsByAppointment(int appointmentId) throws SQLException {
        List<Prescription> list = new ArrayList<>();
        String sql = "SELECT p.*, m.medicine_name, m.unit, m.unit_price "
                   + "FROM prescription p "
                   + "JOIN medicine m ON p.medicine_id = m.medicine_id "
                   + "WHERE p.appointment_id = ? "
                   + "ORDER BY p.prescription_id ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, appointmentId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToPrescription(rs));
            }
        }
        return list;
    }
    
    /**
     * Lấy danh sách đơn thuốc theo bác sĩ (qua appointment)
     */
    public List<Prescription> getPrescriptionsByDoctor(int doctorId) throws SQLException {
        List<Prescription> list = new ArrayList<>();
        String sql = "SELECT p.*, m.medicine_name, m.unit, m.unit_price, "
                   + "pat.fullname as patient_name "
                   + "FROM prescription p "
                   + "JOIN medicine m ON p.medicine_id = m.medicine_id "
                   + "JOIN appointment a ON p.appointment_id = a.appointment_id "
                   + "JOIN patient pat ON a.patient_id = pat.patient_id "
                   + "WHERE a.doctor_id = ? "
                   + "ORDER BY p.created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, doctorId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToPrescription(rs));
            }
        }
        return list;
    }
    
    /**
     * Lấy danh sách đơn thuốc theo bệnh nhân
     */
    public List<Prescription> getPrescriptionsByPatient(int patientId) throws SQLException {
        List<Prescription> list = new ArrayList<>();
        String sql = "SELECT p.*, m.medicine_name, m.unit, m.unit_price, "
                   + "d.fullname as doctor_name "
                   + "FROM prescription p "
                   + "JOIN medicine m ON p.medicine_id = m.medicine_id "
                   + "JOIN appointment a ON p.appointment_id = a.appointment_id "
                   + "JOIN doctor d ON a.doctor_id = d.doctor_id "
                   + "WHERE a.patient_id = ? "
                   + "ORDER BY p.created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, patientId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                list.add(mapResultSetToPrescription(rs));
            }
        }
        return list;
    }
    
    /**
     * Lấy tất cả đơn thuốc
     */
    public List<Prescription> getAllPrescriptions() throws SQLException {
        List<Prescription> list = new ArrayList<>();
        String sql = "SELECT p.*, m.medicine_name, m.unit, m.unit_price, "
                   + "pat.fullname as patient_name "
                   + "FROM prescription p "
                   + "JOIN medicine m ON p.medicine_id = m.medicine_id "
                   + "JOIN appointment a ON p.appointment_id = a.appointment_id "
                   + "JOIN patient pat ON a.patient_id = pat.patient_id "
                   + "ORDER BY p.created_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSetToPrescription(rs));
            }
        }
        return list;
    }
    
    // ==================== UPDATE ====================
    
    /**
     * Cập nhật đơn thuốc
     */
    public boolean updatePrescription(Prescription prescription) throws SQLException {
        String sql = "UPDATE prescription SET quantity = ?, dosage = ?, frequency = ?, instruction = ? "
                   + "WHERE prescription_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, prescription.getQuantity());
            stmt.setString(2, prescription.getDosage());
            stmt.setString(3, prescription.getFrequency());
            stmt.setString(4, prescription.getInstruction());
            stmt.setInt(5, prescription.getPrescriptionId());
            return stmt.executeUpdate() > 0;
        }
    }
    
    // ==================== DELETE ====================
    
    /**
     * Xóa đơn thuốc theo ID
     */
    public boolean deletePrescription(int prescriptionId) throws SQLException {
        String sql = "DELETE FROM prescription WHERE prescription_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, prescriptionId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Xóa tất cả đơn thuốc của một appointment
     */
    public boolean deletePrescriptionsByAppointment(int appointmentId) throws SQLException {
        String sql = "DELETE FROM prescription WHERE appointment_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, appointmentId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    // ==================== STATISTICS ====================
    
    /**
     * Tính tổng tiền của đơn thuốc theo appointment
     */
    public double getTotalAmountByAppointment(int appointmentId) throws SQLException {
        String sql = "SELECT SUM(p.quantity * m.unit_price) as total "
                   + "FROM prescription p "
                   + "JOIN medicine m ON p.medicine_id = m.medicine_id "
                   + "WHERE p.appointment_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, appointmentId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getDouble("total");
            }
        }
        return 0;
    }
    
    /**
     * Đếm số lượng đơn thuốc theo appointment
     */
    public int countPrescriptionsByAppointment(int appointmentId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM prescription WHERE appointment_id = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, appointmentId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }
    
    // ==================== PRIVATE METHODS ====================
    
    private Prescription mapResultSetToPrescription(ResultSet rs) throws SQLException {
        Prescription p = new Prescription();
        p.setPrescriptionId(rs.getInt("prescription_id"));
        p.setAppointmentId(rs.getInt("appointment_id"));
        p.setMedicineId(rs.getInt("medicine_id"));
        p.setQuantity(rs.getInt("quantity"));
        p.setDosage(rs.getString("dosage"));
        p.setFrequency(rs.getString("frequency"));
        p.setInstruction(rs.getString("instruction"));
        p.setCreatedAt(rs.getTimestamp("created_at"));
        
        // Các trường JOIN (nếu có)
        try {
            p.setMedicineName(rs.getString("medicine_name"));
        } catch (SQLException e) {}
        try {
            p.setUnit(rs.getString("unit"));
        } catch (SQLException e) {}
        try {
            p.setUnitPrice(rs.getDouble("unit_price"));
        } catch (SQLException e) {}
        try {
            p.setPatientName(rs.getString("patient_name"));
        } catch (SQLException e) {}
        try {
            p.setDoctorName(rs.getString("doctor_name"));
        } catch (SQLException e) {}
        
        return p;
    }
}