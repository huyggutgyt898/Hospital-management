/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.hospital.model;

import java.sql.Timestamp;

/**
 *
 * @author Admin
 */
public class Doctor {
    private int doctorId;
    private String fullname;
    private String specialty;
    private String phone;
    private String lianseNumber;      // Số chứng chỉ hành nghề / Mã số bác sĩ
    private String avatar;             // Đường dẫn ảnh đại diện
    private int accountId;
    private int experience_years;
    private Timestamp createdAt;
    
    private String  username;
    private String  email;
    private boolean isActive;
    // + getUsername/setUsername, getEmail/setEmail, isActive/setActive

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

    public Doctor() {
    }

    public Doctor(int doctorId, String fullname, String specialty, String phone, String lianseNumber, String avatar, int accountId, int experience_years) {
        this.doctorId = doctorId;
        this.fullname = fullname;
        this.specialty = specialty;
        this.phone = phone;
        this.lianseNumber = lianseNumber;
        this.avatar = avatar;
        this.accountId = accountId;
        this.experience_years = experience_years;
    }

    public int getDoctorId() {
        return doctorId;
    }

    public String getFullname() {
        return fullname;
    }

    public String getSpecialty() {
        return specialty;
    }

    public String getPhone() {
        return phone;
    }

    public String getLianseNumber() {
        return lianseNumber;
    }

    public String getAvatar() {
        return avatar;
    }

    public int getAccountId() {
        return accountId;
    }

    public int getExperience_years() {
        return experience_years;
    }

    public void setDoctorId(int doctorId) {
        this.doctorId = doctorId;
    }

    public void setFullname(String fullname) {
        this.fullname = fullname;
    }

    public void setSpecialty(String specialty) {
        this.specialty = specialty;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public void setLianseNumber(String lianseNumber) {
        this.lianseNumber = lianseNumber;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public void setAccountId(int accountId) {
        this.accountId = accountId;
    }

    public void setExperience_years(int experience_years) {
        this.experience_years = experience_years;
    }
    
    
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }
  
}
