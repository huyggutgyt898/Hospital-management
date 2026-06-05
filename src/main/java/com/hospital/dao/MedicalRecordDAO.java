package com.hospital.dao;

import com.hospital.model.MedicalRecord;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class MedicalRecordDAO {

    public int createMedicalRecord(MedicalRecord record) throws SQLException {
        String sql = "INSERT INTO medical_record (patient_id, doctor_id, examination_date, diagnosis, symptoms, test_results, treatment_method, notes) "
                   + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, record.getPatientId());
            stmt.setInt(2, record.getDoctorId());
            stmt.setDate(3, Date.valueOf(record.getExaminationDate()));
            stmt.setString(4, record.getDiagnosis());
            stmt.setString(5, record.getSymptoms());
            stmt.setString(6, record.getTestResults());
            stmt.setString(7, record.getTreatmentMethod());
            stmt.setString(8, record.getNotes());

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

    public MedicalRecord getMedicalRecordById(int id) throws SQLException {
        String sql = "SELECT mr.*, p.fullname as patient_name, d.fullname as doctor_name "
                   + "FROM medical_record mr "
                   + "LEFT JOIN patient p ON mr.patient_id = p.patient_id "
                   + "LEFT JOIN doctor d ON mr.doctor_id = d.doctor_id "
                   + "WHERE mr.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToMedicalRecord(rs);
                }
            }
        }
        return null;
    }

    public List<MedicalRecord> getMedicalRecordsByDoctor(int doctorId, String search) throws SQLException {
        List<MedicalRecord> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT mr.*, p.fullname as patient_name, d.fullname as doctor_name ");
        sql.append("FROM medical_record mr ");
        sql.append("LEFT JOIN patient p ON mr.patient_id = p.patient_id ");
        sql.append("LEFT JOIN doctor d ON mr.doctor_id = d.doctor_id ");
        sql.append("WHERE mr.doctor_id = ? ");
        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (p.fullname LIKE ? OR mr.diagnosis LIKE ? OR mr.symptoms LIKE ? OR mr.treatment_method LIKE ?)");
        }
        sql.append(" ORDER BY mr.examination_date DESC, mr.created_at DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            stmt.setInt(1, doctorId);
            if (search != null && !search.trim().isEmpty()) {
                String wildcard = "%" + search.trim() + "%";
                stmt.setString(2, wildcard);
                stmt.setString(3, wildcard);
                stmt.setString(4, wildcard);
                stmt.setString(5, wildcard);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSetToMedicalRecord(rs));
                }
            }
        }
        return list;
    }

    private MedicalRecord mapResultSetToMedicalRecord(ResultSet rs) throws SQLException {
        MedicalRecord record = new MedicalRecord();
        record.setId(rs.getInt("id"));
        record.setPatientId(rs.getInt("patient_id"));
        record.setDoctorId(rs.getInt("doctor_id"));
        record.setExaminationDate(rs.getDate("examination_date") != null ? rs.getDate("examination_date").toString() : null);
        record.setDiagnosis(rs.getString("diagnosis"));
        record.setSymptoms(rs.getString("symptoms"));
        record.setTestResults(rs.getString("test_results"));
        record.setTreatmentMethod(rs.getString("treatment_method"));
        record.setNotes(rs.getString("notes"));
        record.setCreatedAt(rs.getTimestamp("created_at"));
        record.setPatientName(rs.getString("patient_name"));
        record.setDoctorName(rs.getString("doctor_name"));
        return record;
    }
}
