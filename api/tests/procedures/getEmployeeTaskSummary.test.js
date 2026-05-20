const { setupDb, seedDb, teardownDb, getPool } = require('../helpers/db');

beforeAll(async () => {
  await setupDb();
  await seedDb();
});

afterAll(async () => {
  await teardownDb();
});

async function fetchSummary() {
  const result = await getPool().request().execute('usp_GetEmployeeTaskSummary');
  return result.recordset;
}

describe('usp_GetEmployeeTaskSummary', () => {
  test('returns all 6 employees', async () => {
    const rows = await fetchSummary();
    expect(rows).toHaveLength(6);
  });

  test('every row has required columns', async () => {
    const rows = await fetchSummary();
    for (const row of rows) {
      expect(row).toHaveProperty('EmployeeID');
      expect(row).toHaveProperty('FullName');
      expect(row).toHaveProperty('DepartmentName');
      expect(row).toHaveProperty('TotalTasks');
      expect(row).toHaveProperty('PendingTasks');
      expect(row).toHaveProperty('InProgressTasks');
      expect(row).toHaveProperty('DoneTasks');
      expect(row).toHaveProperty('NearestDueTaskTitle');
      expect(row).toHaveProperty('NearestDueDate');
    }
  });

  test('Alice has 4 total tasks (3 Pending, 1 In Progress)', async () => {
    const rows  = await fetchSummary();
    const alice = rows.find(r => r.FullName === 'Alice Johnson');
    expect(alice).toBeDefined();
    expect(alice.TotalTasks).toBe(4);
    expect(alice.PendingTasks).toBe(3);
    expect(alice.InProgressTasks).toBe(1);
    expect(alice.DoneTasks).toBe(0);
  });

  test('Bob has 2 total tasks (1 Pending, 1 Done)', async () => {
    const rows = await fetchSummary();
    const bob  = rows.find(r => r.FullName === 'Bob Smith');
    expect(bob).toBeDefined();
    expect(bob.TotalTasks).toBe(2);
    expect(bob.PendingTasks).toBe(1);
    expect(bob.DoneTasks).toBe(1);
  });

  test('status counts per employee sum to TotalTasks', async () => {
    const rows = await fetchSummary();
    for (const row of rows) {
      expect(row.PendingTasks + row.InProgressTasks + row.DoneTasks).toBe(row.TotalTasks);
    }
  });

  test('NearestDueDate is null for employees with no upcoming open tasks', async () => {
    const rows  = await fetchSummary();
    // Frank only has one open task and it is overdue — no future open task
    const frank = rows.find(r => r.FullName === 'Frank Miller');
    expect(frank).toBeDefined();
    expect(frank.NearestDueDate).toBeNull();
  });
});
