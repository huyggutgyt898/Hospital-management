/* ============================================
   USERS.JS
   ============================================ */
let allUsers = [];

document.addEventListener('DOMContentLoaded', async () => {
  allUsers = await fetchUsers();
  renderUsers(allUsers);

  document.getElementById('user-search')?.addEventListener('input', e => {
    const filtered = filterTable(e.target.value, allUsers, ['name','email','role']);
    renderUsers(filtered);
  });

  document.getElementById('role-filter')?.addEventListener('change', e => {
    const val = e.target.value;
    const filtered = val === 'all' ? allUsers : allUsers.filter(u => u.role === val);
    renderUsers(filtered);
  });

  document.getElementById('btn-add-user')?.addEventListener('click', () => {
    Modal.open('modal-user');
  });

  document.getElementById('btn-save-user')?.addEventListener('click', async () => {
    const name = document.getElementById('user-name')?.value?.trim();
    if (!name) { Toast.error('Nhập họ tên'); return; }
    Toast.success('Thêm người dùng thành công!');
    Modal.close('modal-user');
    allUsers = await fetchUsers();
    renderUsers(allUsers);
  });
});

function renderUsers(data) {
  renderTable('users-body', data, [
    { key: 'id', label: 'Mã ND' },
    { key: 'name', render: r => `<div class="patient-row-profile">${avatarHtml(r.name)} <span>${r.name}</span></div>` },
    { key: 'email', render: r => r.email || '...' },
    { key: 'role', render: r => `<span class="badge badge-gray">${r.role}</span>` },
    { key: 'status', render: r => `<span class="badge badge-success">✅ Hoạt động</span>` },
    { key: 'actions', render: r => `<div class="td-actions"><button class="btn btn-icon btn-icon-edit">✏️</button></div>` },
  ]);
}
