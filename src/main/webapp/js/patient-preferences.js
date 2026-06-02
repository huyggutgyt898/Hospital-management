/**
 * Patient theme + i18n (session + cookies via PatientPreferencesServlet)
 */
(function () {
    var root = document.documentElement;
    var lang = root.getAttribute('data-patient-lang') || window.__PATIENT_LANG || 'vi';
    var theme = root.getAttribute('data-patient-theme') || window.__PATIENT_THEME || 'light';
    var ctx = window.__PATIENT_CTX || '';

    function applyTheme() {
        var dark = theme === 'dark';
        document.body.classList.toggle('patient-dark', dark);
        root.classList.toggle('patient-dark', dark);
        root.setAttribute('data-patient-theme', dark ? 'dark' : 'light');
    }

    function applyI18n() {
        document.querySelectorAll('[data-i18n-vi][data-i18n-en]').forEach(function (el) {
            var text = lang === 'en' ? el.getAttribute('data-i18n-en') : el.getAttribute('data-i18n-vi');
            if (!text) {
                return;
            }
            if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
                el.setAttribute('placeholder', text);
            } else {
                el.textContent = text;
            }
        });
        root.lang = lang === 'en' ? 'en' : 'vi';
    }

    window.PatientPrefs = {
        lang: lang,
        theme: theme,
        ctx: ctx,

        t: function (vi, en) {
            return lang === 'en' ? en : vi;
        },

        applyTheme: applyTheme,
        applyI18n: applyI18n,

        saveTheme: function (isDark) {
            var value = isDark ? 'dark' : 'light';
            theme = value;
            applyTheme();
            return fetch(ctx + '/patient/preferences', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    'Accept': 'application/json'
                },
                body: 'theme=' + encodeURIComponent(value)
            });
        },

        saveLanguage: function (newLang) {
            var redirect = encodeURIComponent(window.location.href);
            window.location.href = ctx + '/patient/preferences?lang=' + encodeURIComponent(newLang)
                + '&redirect=' + redirect;
        }
    };

    applyTheme();
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', applyI18n);
    } else {
        applyI18n();
    }
})();
