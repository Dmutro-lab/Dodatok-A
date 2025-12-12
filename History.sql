USE BankSystem;
GO

-- 1. Clients

ALTER TABLE dbo.Clients ADD
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
        CONSTRAINT DF_Clients_ValidFrom DEFAULT SYSUTCDATETIME(),
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
        CONSTRAINT DF_Clients_ValidTo DEFAULT CONVERT(DATETIME2,'9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);
GO

ALTER TABLE dbo.Clients
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Clients_History));
GO

-- Приклади оновлень для Clients
UPDATE dbo.Clients
SET Phone = '+380501111111'
WHERE ClientId = 1;

UPDATE dbo.Clients
SET Phone = '+380679999999'
WHERE ClientId = 2;
GO
SELECT *
FROM dbo.Clients_History;



-- 2. Credits

ALTER TABLE dbo.Credits ADD
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
        CONSTRAINT DF_Credits_ValidFrom DEFAULT SYSUTCDATETIME(),
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
        CONSTRAINT DF_Credits_ValidTo DEFAULT CONVERT(DATETIME2,'9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);
GO

ALTER TABLE dbo.Credits
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Credits_History));
GO

-- Приклади оновлень для Credits
UPDATE dbo.Credits
SET Amount = Amount + 5000
WHERE CreditId = 1;

UPDATE dbo.Credits
SET InterestRate = 8.00
WHERE CreditId = 3;
GO

SELECT *
FROM dbo.Credits_History;

SELECT *
FROM Credits
FOR SYSTEM_TIME AS OF '2025-12-11 18:24:10';

SELECT *
FROM Credits
FOR SYSTEM_TIME AS OF '2025-12-11T18:24:18.2100000'
WHERE CreditId = 1;

-- 3. Deposits

ALTER TABLE dbo.Deposits ADD
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
        CONSTRAINT DF_Deposits_ValidFrom DEFAULT SYSUTCDATETIME(),
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
        CONSTRAINT DF_Deposits_ValidTo DEFAULT CONVERT(DATETIME2,'9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);
GO

ALTER TABLE dbo.Deposits
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.Deposits_History));
GO

-- Приклади оновлень для Deposits
UPDATE dbo.Deposits
SET Amount = Amount + 200
WHERE DepositId = 2;

UPDATE dbo.Deposits
SET EndDate = DATEADD(month, 1, EndDate)
WHERE DepositId = 3;
GO


-- 4. DepositPrograms

ALTER TABLE dbo.DepositPrograms ADD
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN
        CONSTRAINT DF_DepositPrograms_ValidFrom DEFAULT SYSUTCDATETIME(),
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN
        CONSTRAINT DF_DepositPrograms_ValidTo DEFAULT CONVERT(DATETIME2,'9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo);
GO

ALTER TABLE dbo.DepositPrograms
SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.DepositPrograms_History));
GO

-- Приклади оновлень для DepositPrograms
UPDATE dbo.DepositPrograms
SET InterestRate = 7.00
WHERE DepositProgramId = 2;

UPDATE dbo.DepositPrograms
SET ProgramName = N'Стандартний 6 місяців Plus'
WHERE DepositProgramId = 2;
GO


-- 5. Вибірки історичних даних

-- Усі версії Credits
SELECT *
FROM dbo.Credits
FOR SYSTEM_TIME ALL;

-- Стан Credits на конкретну дату
SELECT *
FROM dbo.Credits
FOR SYSTEM_TIME AS OF '2024-01-01T00:00:00'
WHERE CreditId = 1;

-- Повна історія DepositId = 2
SELECT *
FROM dbo.Deposits
FOR SYSTEM_TIME ALL
WHERE DepositId = 2
ORDER BY ValidFrom;

-- Усі Clients, активні у період 2024
SELECT *
FROM dbo.Clients
FOR SYSTEM_TIME FROM '2024-01-01' TO '2024-12-31';


-- 1. Clients — історія
SELECT * FROM dbo.Clients_History;

-- 2. Credits — історія
SELECT * FROM dbo.Credits_History;

-- 3. Deposits — історія
SELECT * FROM dbo.Deposits_History;

-- 4. DepositPrograms — історія
SELECT * FROM dbo.DepositPrograms_History;
