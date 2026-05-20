const { setupDb, seedDb, teardownDb, getPool } = require('../helpers/db');

beforeAll(async () => {
  await setupDb();
  await seedDb();
});

afterAll(async () => {
  await teardownDb();
});

async function fetchOverdueTasks() {
  const result = await getPool().request().execute('usp_GetOverdueTasks');
  return result.recordset;
}

describe('usp_GetOverdueTasks', () => {
  test('returns exactly 4 overdue tasks', async () => {
    const rows = await fetchOverdueTasks();
    expect(rows).toHaveLength(4);
  });

  test('no returned task has status Done', async () => {
    const rows = await fetchOverdueTasks();
    for (const row of rows) {
      expect(row.Status).not.toBe('Done');
    }
  });

  test('all returned tasks have a DueDate in the past', async () => {
    const rows  = await fetchOverdueTasks();
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    for (const row of rows) {
      expect(new Date(row.DueDate).getTime()).toBeLessThan(today.getTime());
    }
  });

  test('tasks are ordered by DueDate ascending', async () => {
    const rows  = await fetchOverdueTasks();
    const dates = rows.map(r => new Date(r.DueDate).getTime());
    for (let i = 1; i < dates.length; i++) {
      expect(dates[i - 1]).toBeLessThanOrEqual(dates[i]);
    }
  });

  test('every row includes employee name and department', async () => {
    const rows = await fetchOverdueTasks();
    for (const row of rows) {
      expect(row).toHaveProperty('AssignedToName');
      expect(row).toHaveProperty('DepartmentName');
      expect(row.AssignedToName).not.toBeNull();
    }
  });
});
