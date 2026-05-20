require('dotenv').config();

const express    = require('express');
const cors       = require('cors');
const { connect } = require('./db');
const employees  = require('./routes/employees');
const tasks      = require('./routes/tasks');

const app  = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.use('/employees', employees);
app.use('/tasks',     tasks);

connect()
  .then(() => {
    app.listen(PORT, () => console.log(`API running on http://localhost:${PORT}`));
  })
  .catch((err) => {
    console.error('Failed to connect to database:', err.message);
    process.exit(1);
  });
