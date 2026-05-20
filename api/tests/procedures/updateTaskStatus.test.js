const { setupDb, seedDb, teardownDb, getPool, sql } = require('../helpers/db');

beforeAll(async () => { await setupDb(); });
beforeEach(async () => { await seedDb(); });
afterAll(async  () => { await teardownDb(); });

async function updateStatus(taskId, newStatus) {
  return getPool()
    .request()
    .input('TaskID',    sql.Int,         taskId)
    .input('NewStatus', sql.NVarChar(20), newStatus)
    .execute('usp_UpdateTaskStatus');
}

describe('usp_UpdateTaskStatus', () => {
  test('Pending -> In Progress succeeds', async () => {
    // Task 1 is Pending
    await expect(updateStatus(1, 'In Progress')).resolves.toBeDefined();

    const result = await getPool()
      .request()
      .query('SELECT Status FROM Tasks WHERE TaskID = 1');
    expect(result.recordset[0].Status).toBe('In Progress');
  });

  test('In Progress -> Done succeeds', async () => {
    // Task 2 is In Progress
    await expect(updateStatus(2, 'Done')).resolves.toBeDefined();

    const result = await getPool()
      .request()
      .query('SELECT Status FROM Tasks WHERE TaskID = 2');
    expect(result.recordset[0].Status).toBe('Done');
  });

  test('throws 50005 for Pending -> Done (skipping a step)', async () => {
    const err = await updateStatus(1, 'Done').catch(e => e);
    expect(err.number).toBe(50005);
    expect(err.message).toMatch(/invalid status transition/i);
  });

  test('throws 50005 for In Progress -> Pending (backwards)', async () => {
    const err = await updateStatus(2, 'Pending').catch(e => e);
    expect(err.number).toBe(50005);
    expect(err.message).toMatch(/invalid status transition/i);
  });

  test('throws 50005 for Done -> anything (cannot reopen)', async () => {
    // Task 6 is Done
    const err = await updateStatus(6, 'In Progress').catch(e => e);
    expect(err.number).toBe(50005);
    expect(err.message).toMatch(/invalid status transition/i);
  });

  test('throws 50004 for an unrecognised status value', async () => {
    const err = await updateStatus(1, 'Cancelled').catch(e => e);
    expect(err.number).toBe(50004);
    expect(err.message).toMatch(/invalid status value/i);
  });

  test('throws 50001 when task does not exist', async () => {
    const err = await updateStatus(9999, 'In Progress').catch(e => e);
    expect(err.number).toBe(50001);
    expect(err.message).toMatch(/task not found/i);
  });
});
