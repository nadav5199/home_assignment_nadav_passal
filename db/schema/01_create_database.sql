USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'TaskManagerDB')
    EXEC('CREATE DATABASE TaskManagerDB');
GO

-- Ensure compatibility level supports THROW and other modern T-SQL features
ALTER DATABASE TaskManagerDB SET COMPATIBILITY_LEVEL = 130;
GO
