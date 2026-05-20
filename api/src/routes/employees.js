const { Router } = require('express');
const { getPool } = require('../db');
const STRINGS     = require('../strings');

const router = Router();

router.get('/', async (req, res) => {
  try {
    const result = await getPool().request().execute(STRINGS.SP_GET_EMPLOYEE_TASK_SUMMARY);
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
