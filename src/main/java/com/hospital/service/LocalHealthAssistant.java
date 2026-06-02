package com.hospital.service;

import java.text.Normalizer;
import java.util.regex.Pattern;

/**
 * Rule-based health assistant (no API key). Used when Groq is unavailable.
 */
public class LocalHealthAssistant {

    private static final Pattern DIACRITICS = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");

    public String reply(String message, String lang) {
        if (message == null || message.trim().isEmpty()) {
            return isEn(lang)
                    ? "Please type your health question in the search box below."
                    : "Vui lòng nhập câu hỏi sức khỏe vào ô tìm kiếm bên dưới.";
        }

        String q = normalize(message);

        if (containsAny(q, "dat lich", "dat hen", "book appointment", "lich kham")) {
            return isEn(lang)
                    ? "**Booking an appointment**\n\n1. Go to **Home → Book appointment**\n2. Choose a doctor, date and time\n3. Describe your symptoms and submit\n\nOr call hotline **1900 xxxx** for support."
                    : "**Đặt lịch khám**\n\n1. Vào **Trang chủ → Đặt lịch hẹn**\n2. Chọn bác sĩ, ngày và giờ\n3. Mô tả triệu chứng và gửi yêu cầu\n\nHoặc gọi hotline **1900 xxxx** để được hỗ trợ.";
        }

        if (containsAny(q, "gio lam viec", "mo cua", "working hours", "open hours")) {
            return isEn(lang)
                    ? "**Hospital hours (HMS)**\n\n• Outpatient: Mon–Sat 7:00–17:00\n• Emergency: **24/7**\n• Pharmacy: 7:00–20:00 daily"
                    : "**Giờ làm việc (HMS)**\n\n• Khám ngoại trú: T2–T7, 7:00–17:00\n• Cấp cứu: **24/7**\n• Nhà thuốc: 7:00–20:00 hàng ngày";
        }

        if (containsAny(q, "paracetamol", "paracetamol", "thuoc ha sot")) {
            return isEn(lang)
                    ? "**Paracetamol (general info)**\n\n• Adults: often 500mg every 4–6h, max **4g/day**\n• Take after food if stomach is sensitive\n• Do not combine with other paracetamol products\n\n⚠️ This is general information only. Follow your doctor's prescription."
                    : "**Paracetamol (thông tin tham khảo)**\n\n• Người lớn: thường 500mg mỗi 4–6h, tối đa **4g/ngày**\n• Uống sau ăn nếu dạ dày nhạy cảm\n• Không dùng chung nhiều thuốc chứa paracetamol\n\n⚠️ Chỉ mang tính tham khảo. Tuân theo chỉ định bác sĩ.";
        }

        if (containsAny(q, "sot xuat huyet", "dengue", "dengue fever")) {
            return isEn(lang)
                    ? "**Possible dengue warning signs**\n\n• High fever 39–40°C\n• Pain behind eyes, muscle/joint pain\n• Nose/gum bleeding, bruising, vomiting\n\n🚨 Seek emergency care immediately if severe abdominal pain, persistent vomiting, or drowsiness."
                    : "**Dấu hiệu nghi sốt xuất huyết**\n\n• Sốt cao 39–40°C\n• Đau sau hốc mắt, đau cơ khớp\n• Chảy máu cam/nướu, xuất huyết da, nôn\n\n🚨 Cần cấp cứu ngay nếu đau bụng dữ dội, nôn nhiều, li bì.";
        }

        if (containsAny(q, "dau dau", "sot nhe", "headache", "mild fever")) {
            return isEn(lang)
                    ? "**Headache with mild fever**\n\n• Rest and drink enough water\n• Paracetamol as directed if needed\n• Monitor temperature every 4–6h\n\nSee a doctor if fever >3 days, severe headache, stiff neck, rash, or breathing difficulty."
                    : "**Đau đầu, sốt nhẹ**\n\n• Nghỉ ngơi, uống đủ nước\n• Có thể dùng paracetamol theo hướng dẫn\n• Theo dõi nhiệt độ 4–6h/lần\n\nĐi khám nếu sốt >3 ngày, đau đầu dữ dội, cứng gáy, phát ban hoặc khó thở.";
        }

        if (containsAny(q, "thanh toan", "hoa don", "payment", "invoice")) {
            return isEn(lang)
                    ? "You can pay bills at **Home → Payment**. Online methods: cash at desk, bank transfer, or card (demo)."
                    : "Thanh toán tại **Trang chủ → Thanh toán**. Hỗ trợ: tiền mặt tại quầy, chuyển khoản, thẻ (demo).";
        }

        if (containsAny(q, "camon", "thank")) {
            return isEn(lang) ? "You're welcome! Wishing you good health. 🌿" : "Không có gì! Chúc bạn sức khỏe tốt. 🌿";
        }

        if (containsAny(q, "xin chao", "hello", "hi ")) {
            return isEn(lang)
                    ? "Hello! I'm the HMS health assistant. Ask about symptoms, medicines, appointments, or hospital services."
                    : "Xin chào! Tôi là trợ lý sức khỏe HMS. Bạn có thể hỏi về triệu chứng, thuốc, đặt lịch hoặc dịch vụ bệnh viện.";
        }

        return isEn(lang)
                ? "I understand you're asking about: \"" + message.trim() + "\"\n\n"
                + "I'm running in **offline assistant** mode (no Groq API key).\n"
                + "Try questions about: headache/fever, Paracetamol, dengue signs, booking, or hospital hours.\n\n"
                + "⚠️ For diagnosis or emergencies, please see a doctor or call **1900 xxxx**."
                : "Tôi nhận câu hỏi: \"" + message.trim() + "\"\n\n"
                + "Hiện đang dùng chế độ **trợ lý nội bộ** (chưa cấu hình API Groq miễn phí).\n"
                + "Bạn có thể hỏi: đau đầu/sốt, Paracetamol, sốt xuất huyết, đặt lịch, giờ làm việc.\n\n"
                + "⚠️ Chẩn đoán hoặc cấp cứu vui lòng gặp bác sĩ hoặc gọi **1900 xxxx**.";
    }

    private static boolean isEn(String lang) {
        return "en".equalsIgnoreCase(lang);
    }

    private static boolean containsAny(String text, String... keywords) {
        for (String kw : keywords) {
            if (text.contains(kw)) {
                return true;
            }
        }
        return false;
    }

    private static String normalize(String input) {
        String lower = input.toLowerCase().trim();
        String nfd = Normalizer.normalize(lower, Normalizer.Form.NFD);
        return DIACRITICS.matcher(nfd).replaceAll("");
    }
}
