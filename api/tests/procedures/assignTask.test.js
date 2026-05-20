const { setupDb, seedDb, teardownDb, getPool, sql } = require('../helpers/db');

beforeAll(async () => { await setupDb(); });
beforeEach(async () => { await seedDb(); });
afterAll(async  () => { await teardownDb(); });

async function assignTask(taskId, employeeId) {
  return getPool()
    .request()
    .input('TaskID',     sql.Int, taskId)
    .input('EmployeeID', sql.Int, employeeId)
    .execute('usp_AssignTask');
}

describe('usp_AssignTask', () => {
  test('successfully assigns a Pending task to a valid employee', async () => {
    // Task 1 is Pending; reassign it to Bob (ID 2)
    await expect(assignTask(1, 2)).resolves.toBeDefined();

    const result = await getPool()
      .request()
      .query('SELECT AssignedTo FROM Tasks WHERE TaskID = 1');
    expect(result.recordset[0].AssignedTo).toBe(2);
  });

  test('successfully assigns an In Progress task to a valid employee', async () => {
    // Task 2 is In Progress — assigning is still allowed
    await expect(assignTask(2, 2)).resolves.toBeDefined();
  });

  test('throws 50001 when task does not exist', async () => {
    const err = await assignTask(9999, 1).catch(e => e);
    expect(err.number).toBe(50001);
    expect(err.message).toMatch(/task not found/i);
  });

  test('throws 50002 when employee does not exist', async () => {
    const err = await assignTask(1, 9999).catch(e => e);
    expect(err.number).toBe(50002);
    expect(err.message).toMatch(/employee not found/i);
  });

  test('throws 50003 when task is already Done', async () => {
    // Task 6 (Deploy to staging) is Done in seed data
    const err = await assignTask(6, 1).catch(e => e);
    expect(err.number).toBe(50003);
    expect(err.message).toMatch(/already done/i);
  });
});
