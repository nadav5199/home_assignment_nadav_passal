const sql = require('mssql');

const config = {
  server:   process.env.DB_SERVER,
  port:     parseInt(process.env.DB_PORT) || 1433,
  database: process.env.DB_NAME,
  user:     process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  options: {
    trustServerCertificate: true,
  },
};

let pool;

async function connect() {
  if (pool) return;
  pool = await sql.connect(config);
  console.log('Connected to SQL Server');
}

function getPool() {
  return pool;
}

module.exports = { connect, getPool, sql };
