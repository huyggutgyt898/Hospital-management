package com.hospital.model;

public class Admin {
    private int adminId;
    private String fullname;
    private String position;
    private String notes;
    private int accountId;

    public Admin() {}

    public Admin(int adminId, String fullname, String position, String notes, int accountId) {
        this.adminId = adminId;
        this.fullname = fullname;
        this.position = position;
        this.notes = notes;
        this.accountId = accountId;
    }

    public int getAdminId() { return adminId; }
    public void setAdminId(int adminId) { this.adminId = adminId; }

    public String getFullname() { return fullname; }
    public void setFullname(String fullname) { this.fullname = fullname; }

    public String getPosition() { return position; }
    public void setPosition(String position) { this.position = position; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public int getAccountId() { return accountId; }
    public void setAccountId(int accountId) { this.accountId = accountId; }
}
