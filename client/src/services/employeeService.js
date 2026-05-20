const API_BASE = 'http://localhost:3000';

export async function getEmployees() {
  const res = await fetch(`${API_BASE}/employees`);
  if (!res.ok) throw new Error(`Request failed with status ${res.status}`);
  return res.json();
}
