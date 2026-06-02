/* ============================================
   DASHBOARD.JS
   ============================================ */
document.addEventListener('DOMContentLoaded', async () => {
  // Load stats
  const stats = await fetchDashboardStats();
  const el = id => document.getElementById(id);
  if (el('stat-patients'))     el('stat-patients').textContent     = stats.totalPatients;
  if (el('stat-doctors'))      el('stat-doctors').textContent      = stats.totalDoctors;
  if (el('stat-appointments')) el('stat-appointments').textContent = stats.appointmentsToday;
  if (el('stat-medicines'))    el('stat-medicines').textContent    = stats.medicines;

  // Load recent appointments table
  const appointments = await fetchAppointments();
  renderTable('recent-appointments-body', appointments.slice(0, 5), [
    { key: 'patientName', label: 'Bệnh nhân', render: r => `<div class="patient-row-profile">${avatarHtml(r.patientName)} <span>${r.patientName}</span></div>` },
    { key: 'id', label: 'Medical ID', render: r => `90000000${String(r.id).padStart(4,'0')}` },
    { key: 'doctorName', label: 'Bác sĩ' },
    { key: 'date', label: 'Thời gian', render: r => `${r.date} ${r.time}` },
    { key: 'status', label: 'Trạng thái', render: r => {
      const map = { done: ['badge-primary','Bên nhận'], pending: ['badge-warning','Đang chờ'], cancelled: ['badge-danger','Huỷ'] };
      const [cls, label] = map[r.status] || ['badge-gray', r.status];
      return `<span class="badge ${cls}">${label}</span>`;
    }},
  ]);
});
