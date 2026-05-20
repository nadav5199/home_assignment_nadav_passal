require('dotenv').config();

const fs   = require('fs');
const path = require('path');
const sql  = require('mssql');

const baseConfig = {
  server:   process.env.DB_SERVER   || 'localhost',
  port:     parseInt(process.env.DB_PORT) || 1433,
  user:     process.env.DB_USER     || 'sa',
  password: process.env.DB_PASSWORD,
  options:  { trustServerCertificate: true },
};

let pool;

function splitBatches(content) {
  return content
    .split(/^\s*GO\s*$/im)
    .map(b => b.trim())
    .filter(b => b.length > 0 && !/^USE\s+\S+\s*;?\s*$/i.test(b));
}

async function runBatches(connection, content) {
  for (const batch of splitBatches(content)) {
    await connection.request().query(batch);
  }
}

async function setupDb() {
  // Connect to master so we can create TaskManagerDB if it doesn't exist
  const master = await new sql.ConnectionPool({ ...baseConfig, database: 'master' }).connect();
  await master.request().query(`
    IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TaskManagerDB')
      EXEC('CREATE DATABASE TaskManagerDB');
    ALTER DATABASE TaskManagerDB SET COMPATIBILITY_LEVEL = 130;
  `);
  await master.close();

  // Now connect to TaskManagerDB
  pool = await new sql.ConnectionPool({ ...baseConfig, database: 'TaskManagerDB' }).connect();

  // Create tables
  const schemaDir = path.resolve(__dirname, '../../../db/schema');
  for (const file of ['02_departments.sql', '03_employees.sql', '04_tasks.sql']) {
    const content = fs.readFileSync(path.join(schemaDir, file), 'utf8');
    await runBatches(pool, content);
  }

  // Create / replace stored procedures
  const spDir = path.resolve(__dirname, '../../../db/stored_procedures');
  for (const file of fs.readdirSync(spDir).filter(f => f.endsWith('.sql')).sort()) {
    const content = fs.readFileSync(path.join(spDir, file), 'utf8');
    await runBatches(pool, content);
  }
}

async function seedDb() {
  const seedPath = path.resolve(__dirname, '../../../db/seed.sql');
  const content  = fs.readFileSync(seedPath, 'utf8');
  await runBatches(pool, content);
}

async function teardownDb() {
  if (pool) {
    await pool.close();
    pool = null;
  }
}

function getPool() {
  return pool;
}

module.exports = { setupDb, seedDb, teardownDb, getPool, sql };
