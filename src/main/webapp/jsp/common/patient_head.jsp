<link rel="stylesheet" href="<%= patientCtx %>/css/patient-theme.css">
<script>
(function () {
    window.__PATIENT_CTX = '<%= patientCtx %>';
    window.__PATIENT_THEME = '<%= patientTheme %>';
    window.__PATIENT_LANG = '<%= patientLang %>';
    var dark = window.__PATIENT_THEME === 'dark';
    var root = document.documentElement;
    root.setAttribute('data-patient-theme', dark ? 'dark' : 'light');
    root.setAttribute('data-patient-lang', window.__PATIENT_LANG);
    root.lang = window.__PATIENT_LANG === 'en' ? 'en' : 'vi';
    if (dark) {
        root.classList.add('patient-dark');
    }
})();
</script>
