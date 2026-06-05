package com.hospital.model;

public class BillLine {
    private String description;
    private int quantity;
    private double unitPrice;
    private double lineTotal;
    private String unit;

    public BillLine() {
    }

    public BillLine(String description, int quantity, double unitPrice, double lineTotal, String unit) {
        this.description = description;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.lineTotal = lineTotal;
        this.unit = unit;
    }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public int getQuantity() { return quantity; }
    public void setQuantity(int quantity) { this.quantity = quantity; }
    public double getUnitPrice() { return unitPrice; }
    public void setUnitPrice(double unitPrice) { this.unitPrice = unitPrice; }
    public double getLineTotal() { return lineTotal; }
    public void setLineTotal(double lineTotal) { this.lineTotal = lineTotal; }
    public String getUnit() { return unit; }
    public void setUnit(String unit) { this.unit = unit; }
}
