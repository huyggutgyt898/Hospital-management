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

public class Account {
    private int accountID;
    private String username;
    private String passwordAccount;
    private String email;
    private String phone;
    private String fullname;
    private String role;
    private boolean isActive;
    private Timestamp createAt;

    public Account() {
    }

    public Account(String username, String passwordAccount, String email, String phone, String fullname, String role) {
        this.username = username;
        this.passwordAccount = passwordAccount;
        this.email = email;
        this.phone = phone;
        this.fullname = fullname;
        this.role = role;
        this.isActive = true;
    }

    public int getAccountID() {
        return accountID;
    }

    public String getUsername() {
        return username;
    }

    public String getPasswordAccount() {
        return passwordAccount;
    }

    public String getEmail() {
        return email;
    }

    public String getPhone() {
        return phone;
    }

    public String getFullname() {
        return fullname;
    }

    public String getRole() {
        return role;
    }

    public boolean isIsActive() {
        return isActive;
    }

    public Timestamp getCreateAt() {
        return createAt;
    }

    public void setAccountID(int accountID) {
        this.accountID = accountID;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setPasswordAccount(String passwordAccount) {
        this.passwordAccount = passwordAccount;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public void setFullname(String fullname) {
        this.fullname = fullname;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public void setIsActive(boolean isActive) {
        this.isActive = isActive;
    }

    public void setCreateAt(Timestamp createAt) {
        this.createAt = createAt;
    }
    
}
