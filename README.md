# Employee Task Manager

A simple internal task management system for tracking employees and their assigned tasks. Built with React, Node.js/Express, and Microsoft SQL Server.

---

## Prerequisites

- [Node.js](https://nodejs.org/) 18+
- [Docker](https://www.docker.com/) (for SQL Server)

---

## 1. Database Setup

### Start SQL Server in Docker

```bash
docker run -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=Admin1234!" \
  -p 1433:1433 --name sqlserver \
  -d mcr.microsoft.com/mssql/server:2022-latest
```

### Run the setup script

From the repo root:

```powershell
.\db\setup.ps1
```

This copies and executes `schema.sql`, `stored_procedures.sql`, and `seed.sql` against the running container in the correct order.

**Options:**

| Parameter | Default | Description |
|-----------|---------|-------------|
| `-Container` | `sqlserver` | Docker container name |
| `-Password` | `Admin1234!` | SA password |

```powershell
# Custom container name or password:
.\db\setup.ps1 -Container my-sql -Password "MyPass123!"
```

> Alternatively, connect to `localhost,1433` with SSMS or Azure Data Studio and run the three files in `db/` manually in order.

---

## 2. API Setup & Start

```bash
cd api
cp .env.example .env   # fill in your DB credentials
npm install
npm start              # or: npm run dev  (watch mode)
```

API runs at `http://localhost:3000`.

### Environment Variables (`api/.env`)

| Variable | Description | Default |
|----------|-------------|---------|
| `DB_SERVER` | SQL Server hostname | `localhost` |
| `DB_PORT` | SQL Server port | `1433` |
| `DB_NAME` | Database name | `TaskManagerDB` |
| `DB_USER` | SQL Server username | `sa` |
| `DB_PASSWORD` | SQL Server password | — |
| `PORT` | API listening port | `3000` |

### Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/employees` | Employee task summary (counts by status) |
| GET | `/tasks` | All tasks with employee and department |
| PATCH | `/tasks/:id/status` | Update a task's status |

---

## 3. React App Setup & Start

```bash
cd client
npm install
npm run dev
```

App runs at `http://localhost:5173`.
