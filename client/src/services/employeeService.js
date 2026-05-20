import { STRINGS } from '../strings';

export async function getEmployees() {
  const res = await fetch(`${STRINGS.API_BASE_URL}${STRINGS.ENDPOINT_EMPLOYEES}`);
  if (!res.ok) throw new Error(`${STRINGS.ERROR_REQUEST_FAILED}${res.status}`);
  return res.json();
}
