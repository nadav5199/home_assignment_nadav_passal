const { Router } = require('express');
const { getPool } = require('../db');

const router = Router();

router.get('/', async (req, res) => {
  try {
    const result = await getPool().request().execute('usp_GetEmployeeTaskSummary');
    res.json(result.recordset);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
