USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TaskManagerDB')
BEGIN
    CREATE DATABASE TaskManagerDB;
END
GO
