/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.hospital.util;

/**
 *
 * @author Admin
 */
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class PasswordHash {
     // Mã hóa SHA-256 
    public static String hashSHA256(String password) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder();
            
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            return null;
        }
    }
    
    // So sánh password nhập vào với hash trong DB
    public static boolean verifyPassword(String inputPassword, String storedHash) {
        if (storedHash == null) return false;
        String hashedInput = hashSHA256(inputPassword);
        if (hashedInput != null && hashedInput.equals(storedHash)) {
            return true;
        }
        return inputPassword.equals(storedHash);
    }
}
