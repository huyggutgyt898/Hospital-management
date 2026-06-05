-- Chạy script này trên database hopital_hms trước khi dùng tính năng thanh toán

CREATE TABLE IF NOT EXISTS payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL,
    patient_id INT NOT NULL,
    examination_fee DECIMAL(12,2) NOT NULL DEFAULT 200000,
    medicine_fee DECIMAL(12,2) NOT NULL DEFAULT 0,
    subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
    discount_percent DECIMAL(5,2) NOT NULL DEFAULT 0,
    discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    has_insurance TINYINT(1) NOT NULL DEFAULT 0,
    payment_method VARCHAR(20) NULL COMMENT 'cash, qr',
    payment_status VARCHAR(30) NOT NULL DEFAULT 'unpaid' COMMENT 'unpaid, pending_admin, paid',
    admin_confirmed TINYINT(1) NOT NULL DEFAULT 0,
    paid_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_payment_appointment (appointment_id),
    KEY idx_payment_status (payment_status),
    KEY idx_payment_patient (patient_id)
);
