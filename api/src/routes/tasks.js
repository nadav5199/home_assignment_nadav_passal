const { Router } = require('express');
const { getPool, sql } = require('../db');

const router = Router();

router.get('/', async (req, res) => {
  try {
    const result = await getPool().request().execute('usp_GetAllTasks');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.patch('/:id/status', async (req, res) => {
  const id     = parseInt(req.params.id);
  const { status } = req.body;

  if (!status) {
    return res.status(400).json({ error: 'Request body must include a "status" field.' });
  }

  try {
    await getPool()
      .request()
      .input('TaskID',    sql.Int,         id)
      .input('NewStatus', sql.NVarChar(20), status)
      .execute('usp_UpdateTaskStatus');

    res.json({ message: 'Task status updated successfully.' });
  } catch (err) {
    const sqlErrorNumber = err.number;

    if (sqlErrorNumber === 50001) {
      return res.status(404).json({ error: err.message });
    }
    if (sqlErrorNumber === 50004 || sqlErrorNumber === 50005) {
      return res.status(400).json({ error: err.message });
    }

    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
