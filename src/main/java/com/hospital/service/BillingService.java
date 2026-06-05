package com.hospital.service;

import com.hospital.dao.AppointmentDAO;
import com.hospital.dao.PatientDAO;
import com.hospital.dao.PaymentDAO;
import com.hospital.dao.PrescriptionDAO;
import com.hospital.model.Appointment;
import com.hospital.model.BillDetail;
import com.hospital.model.BillLine;
import com.hospital.model.Patient;
import com.hospital.model.Payment;
import com.hospital.model.Prescription;
import java.sql.SQLException;
import java.util.List;

public class BillingService {

    public static final double EXAMINATION_FEE = 200_000d;
    public static final double INSURANCE_DISCOUNT_PERCENT = 80d;

    private final AppointmentDAO appointmentDAO = new AppointmentDAO();
    private final PatientDAO patientDAO = new PatientDAO();
    private final PrescriptionDAO prescriptionDAO = new PrescriptionDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    public BillDetail buildBill(int appointmentId) throws SQLException {
        Appointment appt = appointmentDAO.getAppointmentById(appointmentId);
        if (appt == null) {
            return null;
        }

        Patient patient = patientDAO.getPatientById(appt.getPatientId());
        boolean hasInsurance = patient != null && patient.hasHealthInsurance();

        BillDetail bill = new BillDetail();
        bill.setAppointmentId(appointmentId);
        bill.setPatientId(appt.getPatientId());
        bill.setPatientName(patient != null ? patient.getFullname() : appt.getPatientName());
        bill.setDoctorName(appt.getDoctorName());
        bill.setAppointmentDate(appt.getAppointmentDate());
        bill.setAppointmentTime(appt.getAppointmentTime());
        bill.setAppointmentStatus(appt.getStatus());
        bill.setHasInsurance(hasInsurance);
        bill.setExaminationFee(EXAMINATION_FEE);

        double medicineFee = 0;
        List<Prescription> prescriptions = prescriptionDAO.getPrescriptionsByAppointment(appointmentId);
        for (Prescription p : prescriptions) {
            double unitPrice = p.getUnitPrice() > 0 ? p.getUnitPrice() : 0;
            double lineTotal = unitPrice * p.getQuantity();
            medicineFee += lineTotal;
            bill.getLines().add(new BillLine(
                    p.getMedicineName() != null ? p.getMedicineName() : ("Thuốc #" + p.getMedicineId()),
                    p.getQuantity(),
                    unitPrice,
                    lineTotal,
                    p.getUnit() != null ? p.getUnit() : "Viên"
            ));
        }

        bill.getLines().add(0, new BillLine(
                "Phí khám bệnh" + (appt.getDoctorName() != null ? " (BS. " + appt.getDoctorName() + ")" : ""),
                1,
                EXAMINATION_FEE,
                EXAMINATION_FEE,
                "Lần"
        ));

        bill.setMedicineFee(medicineFee);
        double subtotal = EXAMINATION_FEE + medicineFee;
        bill.setSubtotal(subtotal);

        if (hasInsurance) {
            bill.setDiscountPercent(INSURANCE_DISCOUNT_PERCENT);
            bill.setDiscountAmount(subtotal * INSURANCE_DISCOUNT_PERCENT / 100d);
            bill.setTotalAmount(subtotal - bill.getDiscountAmount());
        } else {
            bill.setDiscountPercent(0);
            bill.setDiscountAmount(0);
            bill.setTotalAmount(subtotal);
        }

        Payment payment = paymentDAO.getByAppointmentId(appointmentId);
        if (payment != null) {
            bill.setPaymentStatus(payment.getPaymentStatus());
            bill.setPaymentMethod(payment.getPaymentMethod());
        } else {
            bill.setPaymentStatus("unpaid");
        }

        return bill;
    }

    public Payment syncPaymentRecord(int appointmentId) throws SQLException {
        BillDetail bill = buildBill(appointmentId);
        if (bill == null) {
            return null;
        }
        return paymentDAO.createOrUpdateFromBill(bill);
    }
}
