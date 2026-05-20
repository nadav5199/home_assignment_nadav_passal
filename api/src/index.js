require('dotenv').config();

const express    = require('express');
const cors       = require('cors');
const { connect } = require('./db');
const employees  = require('./routes/employees');
const tasks      = require('./routes/tasks');
const STRINGS    = require('./strings');

const app  = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use(STRINGS.ROUTE_EMPLOYEES, employees);
app.use(STRINGS.ROUTE_TASKS,     tasks);

connect()
  .then(() => {
    app.listen(PORT, () => console.log(`${STRINGS.LOG_API_RUNNING}${PORT}`));
  })
  .catch((err) => {
    console.error(`${STRINGS.LOG_DB_CONNECT_FAILED}`, err.message);
    process.exit(1);
  });
