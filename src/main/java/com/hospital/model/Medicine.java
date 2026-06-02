package com.hospital.model;

import java.sql.Timestamp;
import java.sql.Date;

public class Medicine {
    private int medicineId;
    private String medicineName;
    private String unit;
    private int stockQuantity;
    private double unitPrice;
    private Date expiryDate;
    private String supplier;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    
    // ==================== Constructors ====================
    
    public Medicine() {}
    
    public Medicine(String medicineName, String unit, int stockQuantity, double unitPrice, Date expiryDate, String supplier) {
        this.medicineName = medicineName;
        this.unit = unit;
        this.stockQuantity = stockQuantity;
        this.unitPrice = unitPrice;
        this.expiryDate = expiryDate;
        this.supplier = supplier;
    }
    
    // ==================== Getters and Setters ====================
    
    public int getMedicineId() {
        return medicineId;
    }
    
    public void setMedicineId(int medicineId) {
        this.medicineId = medicineId;
    }
    
    public String getMedicineName() {
        return medicineName;
    }
    
    public void setMedicineName(String medicineName) {
        this.medicineName = medicineName;
    }
    
    public String getUnit() {
        return unit;
    }
    
    public void setUnit(String unit) {
        this.unit = unit;
    }
    
    public int getStockQuantity() {
        return stockQuantity;
    }
    
    public void setStockQuantity(int stockQuantity) {
        this.stockQuantity = stockQuantity;
    }
    
    public double getUnitPrice() {
        return unitPrice;
    }
    
    public void setUnitPrice(double unitPrice) {
        this.unitPrice = unitPrice;
    }
    
    public Date getExpiryDate() {
        return expiryDate;
    }
    
    public void setExpiryDate(Date expiryDate) {
        this.expiryDate = expiryDate;
    }
    
    public String getSupplier() {
        return supplier;
    }
    
    public void setSupplier(String supplier) {
        this.supplier = supplier;
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public Timestamp getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    // ==================== Helper Methods ====================
    
    public boolean isLowStock() {
        return stockQuantity < 100;
    }
    
    public boolean isExpired() {
        if (expiryDate == null) return false;
        Date today = new Date(System.currentTimeMillis());
        return expiryDate.before(today);
    }
    
    @Override
    public String toString() {
        return "Medicine{" +
                "medicineId=" + medicineId +
                ", medicineName='" + medicineName + '\'' +
                ", unit='" + unit + '\'' +
                ", stockQuantity=" + stockQuantity +
                ", unitPrice=" + unitPrice +
                '}';
    }
}