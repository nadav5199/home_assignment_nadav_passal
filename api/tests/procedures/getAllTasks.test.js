const { setupDb, seedDb, teardownDb, getPool } = require('../helpers/db');

beforeAll(async () => {
  await setupDb();
  await seedDb();
});

afterAll(async () => {
  await teardownDb();
});

async function fetchAllTasks() {
  const result = await getPool().request().execute('usp_GetAllTasks');
  return result.recordset;
}

describe('usp_GetAllTasks', () => {
  test('returns all 13 tasks', async () => {
    const rows = await fetchAllTasks();
    expect(rows).toHaveLength(13);
  });

  test('every row has required columns', async () => {
    const rows = await fetchAllTasks();
    for (const row of rows) {
      expect(row).toHaveProperty('TaskID');
      expect(row).toHaveProperty('Title');
      expect(row).toHaveProperty('Status');
      expect(row).toHaveProperty('DueDate');
      expect(row).toHaveProperty('AssignedToName');
      expect(row).toHaveProperty('DepartmentName');
    }
  });

  test('all tasks have an assigned employee and department', async () => {
    const rows = await fetchAllTasks();
    for (const row of rows) {
      expect(row.AssignedToName).not.toBeNull();
      expect(row.DepartmentName).not.toBeNull();
    }
  });

  test('tasks are ordered by CreatedAt descending', async () => {
    const rows  = await fetchAllTasks();
    const dates = rows.map(r => new Date(r.CreatedAt).getTime());
    for (let i = 1; i < dates.length; i++) {
      expect(dates[i - 1]).toBeGreaterThanOrEqual(dates[i]);
    }
  });

  test('contains all three statuses', async () => {
    const rows     = await fetchAllTasks();
    const statuses = new Set(rows.map(r => r.Status));
    expect(statuses).toContain('Pending');
    expect(statuses).toContain('In Progress');
    expect(statuses).toContain('Done');
  });
});
