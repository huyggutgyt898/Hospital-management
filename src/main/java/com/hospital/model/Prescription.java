package com.hospital.model;

import java.sql.Timestamp;

public class Prescription {
    private int prescriptionId;
    private int appointmentId;
    private int medicineId;
    private int quantity;
    private String dosage;
    private String frequency;
    private String instruction;
    private Timestamp createdAt;
    
    // Các trường hiển thị phụ (từ JOIN)
    private String medicineName;
    private String patientName;
    private String doctorName;
    private String unit;
    private double unitPrice;
    
    // ==================== Constructors ====================
    
    public Prescription() {}
    
    public Prescription(int appointmentId, int medicineId, int quantity, 
                        String dosage, String frequency, String instruction) {
        this.appointmentId = appointmentId;
        this.medicineId = medicineId;
        this.quantity = quantity;
        this.dosage = dosage;
        this.frequency = frequency;
        this.instruction = instruction;
    }
    
    // ==================== Getters and Setters ====================
    
    public int getPrescriptionId() {
        return prescriptionId;
    }
    
    public void setPrescriptionId(int prescriptionId) {
        this.prescriptionId = prescriptionId;
    }
    
    public int getAppointmentId() {
        return appointmentId;
    }
    
    public void setAppointmentId(int appointmentId) {
        this.appointmentId = appointmentId;
    }
    
    public int getMedicineId() {
        return medicineId;
    }
    
    public void setMedicineId(int medicineId) {
        this.medicineId = medicineId;
    }
    
    public int getQuantity() {
        return quantity;
    }
    
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
    
    public String getDosage() {
        return dosage;
    }
    
    public void setDosage(String dosage) {
        this.dosage = dosage;
    }
    
    public String getFrequency() {
        return frequency;
    }
    
    public void setFrequency(String frequency) {
        this.frequency = frequency;
    }
    
    public String getInstruction() {
        return instruction;
    }
    
    public void setInstruction(String instruction) {
        this.instruction = instruction;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    // ==================== Các trường phụ (JOIN) ====================
    
    public String getMedicineName() {
        return medicineName;
    }
    
    public void setMedicineName(String medicineName) {
        this.medicineName = medicineName;
    }
    
    public String getPatientName() {
        return patientName;
    }
    
    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }
    
    public String getDoctorName() {
        return doctorName;
    }
    
    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }
    
    public String getUnit() {
        return unit;
    }
    
    public void setUnit(String unit) {
        this.unit = unit;
    }
    
    public double getUnitPrice() {
        return unitPrice;
    }
    
    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }
    
    // ==================== Helper Methods ====================
    
    public double getTotalPrice() {
        return unitPrice * quantity;
    }
    
    @Override
    public String toString() {
        return "Prescription{" +
                "prescriptionId=" + prescriptionId +
                ", appointmentId=" + appointmentId +
                ", medicineId=" + medicineId +
                ", quantity=" + quantity +
                ", dosage='" + dosage + '\'' +
                ", frequency='" + frequency + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}