const { Router } = require('express');
const { getPool, sql } = require('../db');
const STRINGS          = require('../strings');

const router = Router();

router.get('/', async (req, res) => {
  try {
    const result = await getPool().request().execute(STRINGS.SP_GET_ALL_TASKS);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.patch('/:id/status', async (req, res) => {
  const id     = parseInt(req.params.id);
  const { status } = req.body;

  if (!status) {
    return res.status(400).json({ error: STRINGS.ERR_STATUS_REQUIRED });
  }

  try {
    await getPool()
      .request()
      .input(STRINGS.PARAM_TASK_ID,    sql.Int,         id)
      .input(STRINGS.PARAM_NEW_STATUS, sql.NVarChar(20), status)
      .execute(STRINGS.SP_UPDATE_TASK_STATUS);

    res.json({ message: STRINGS.MSG_TASK_STATUS_UPDATED });
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
