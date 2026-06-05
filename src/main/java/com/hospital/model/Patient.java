/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.hospital.model;

/**
 *
 * @author Admin
 */
import java.sql.Timestamp;
import java.sql.Date;

public class Patient {
    private int patientId;
    private String fullname;
    private int age;
    private String gender;
    private String phone;
    private String address;
    private Date dateOfBirth;
    private Timestamp createdAt;
    private int accountId;
    private String healthInsurance;
    
    private String  username;
    private String  email;
    private boolean isActive;
    private static final System.Logger LOG = System.getLogger(Patient.class.getName());

    public void setUsername(String username) {
        this.username = username;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    public String getUsername() {
        return username;
    }

    public String getEmail() {
        return email;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public static System.Logger getLOG() {
        return LOG;
    }

    
    // ==================== Constructors ====================
    
    public Patient() {}
    
    public Patient(String fullname, int age, String gender, String phone, String address, Date dateOfBirth, int accountId) {
        this.fullname = fullname;
        this.age = age;
        this.gender = gender;
        this.phone = phone;
        this.address = address;
        this.dateOfBirth = dateOfBirth;
        this.accountId = accountId;
    }
    
    // ==================== Getters and Setters ====================
    
    public int getPatientId() {
        return patientId;
    }
    
    public void setPatientId(int patientId) {
        this.patientId = patientId;
    }
    
    public String getFullname() {
        return fullname;
    }
    
    public void setFullname(String fullname) {
        this.fullname = fullname;
    }
    
    public int getAge() {
        return age;
    }
    
    public void setAge(int age) {
        this.age = age;
    }
    
    public String getGender() {
        return gender;
    }
    
    public void setGender(String gender) {
        this.gender = gender;
    }
    
    public String getPhone() {
        return phone;
    }
    
    public void setPhone(String phone) {
        this.phone = phone;
    }
    
    public String getAddress() {
        return address;
    }
    
    public void setAddress(String address) {
        this.address = address;
    }
    
    public Date getDateOfBirth() {
        return dateOfBirth;
    }
    
    public void setDateOfBirth(Date dateOfBirth) {
        this.dateOfBirth = dateOfBirth;
        // Tự động tính tuổi nếu có ngày sinh
        if (dateOfBirth != null) {
            java.util.Date today = new java.util.Date();
            long diff = today.getTime() - dateOfBirth.getTime();
            this.age = (int) (diff / (1000L * 60 * 60 * 24 * 365));
        }
    }
    
    public Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
    
    public int getAccountId() {
        return accountId;
    }
    
    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public String getHealthInsurance() {
        return healthInsurance;
    }

    public void setHealthInsurance(String healthInsurance) {
        this.healthInsurance = healthInsurance;
    }

    public boolean hasHealthInsurance() {
        if (healthInsurance == null) {
            return false;
        }
        String v = healthInsurance.trim();
        return "Có".equalsIgnoreCase(v) || "co".equalsIgnoreCase(v)
                || "yes".equalsIgnoreCase(v) || "1".equals(v);
    }
    
    // ==================== Helper Methods ====================
    
    public String getGenderText() {
        if ("male".equalsIgnoreCase(gender)) return "Nam";
        if ("female".equalsIgnoreCase(gender)) return "Nữ";
        if ("other".equalsIgnoreCase(gender)) return "Khác";
        return gender;
    }
    
    @Override
    public String toString() {
        return "Patient{" +
                "patientId=" + patientId +
                ", fullname='" + fullname + '\'' +
                ", age=" + age +
                ", gender='" + gender + '\'' +
                ", phone='" + phone + '\'' +
                ", address='" + address + '\'' +
                ", accountId=" + accountId +
                '}';
    }
}
