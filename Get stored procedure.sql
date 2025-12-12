USE BankSystem;
GO


-- 1. PROCEDURE – ВИБІРКА КЛІЄНТІВ   (фільтр + пагінація + сортування + РАХУНКИ)
CREATE OR ALTER PROCEDURE dbo.sp_GetClients
    @ClientId INT = NULL,
    @Name NVARCHAR(50) = NULL,
    @AccountNumber NVARCHAR(26) = NULL,       -- фільтр по номеру рахунку
    @PageSize INT = 10,
    @PageNumber INT = 1,
    @SortColumn NVARCHAR(50) = 'ClientId',
    @SortDirection BIT = 0                    -- 0 = ASC, 1 = DESC
AS
BEGIN
    SET NOCOUNT ON;

    -- Перевірка існування ClientId
    IF @ClientId IS NOT NULL 
       AND NOT EXISTS (SELECT 1 FROM Clients WHERE ClientId = @ClientId)
    BEGIN
        PRINT ' Incorrect ClientId';
        RETURN;
    END;

    SELECT 
        c.ClientId,
        c.LastName,
        c.FirstName,
        c.MiddleName,
        c.ClientType,
        c.BirthDate,
        c.Phone,
        c.Address,
        ba.AccountId,
        ba.AccountNumber,
        ba.Balance,
        atp.AccountTypeName,
        cur.CurrencyCode
    FROM Clients c
    LEFT JOIN BankAccounts ba 
        ON ba.ClientId = c.ClientId
    LEFT JOIN AccountTypes atp
        ON ba.AccountTypeId = atp.AccountTypeId
    LEFT JOIN Currencies cur
        ON ba.CurrencyId = cur.CurrencyId
    WHERE (@ClientId IS NULL OR c.ClientId = @ClientId)
      AND (@Name IS NULL 
           OR c.LastName LIKE @Name + '%' 
           OR c.FirstName LIKE @Name + '%')
      AND (@AccountNumber IS NULL OR ba.AccountNumber = @AccountNumber)

    ORDER BY
        CASE WHEN @SortDirection = 0 THEN
            CASE @SortColumn
                WHEN 'ClientId'      THEN CAST(c.ClientId AS NVARCHAR)
                WHEN 'LastName'      THEN c.LastName
                WHEN 'FirstName'     THEN c.FirstName
                WHEN 'AccountNumber' THEN ba.AccountNumber
            END
        END ASC,
        CASE WHEN @SortDirection = 1 THEN
            CASE @SortColumn
                WHEN 'ClientId'      THEN CAST(c.ClientId AS NVARCHAR)
                WHEN 'LastName'      THEN c.LastName
                WHEN 'FirstName'     THEN c.FirstName
                WHEN 'AccountNumber' THEN ba.AccountNumber
            END
        END DESC

    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO





-- 2. PROCEDURE – КРЕДИТИ (JOIN + фільтр + пагінація + сортування + TotalToPay + % часу)
CREATE OR ALTER PROCEDURE dbo.sp_GetCredits
    @ClientId INT = NULL,
    @CreditTypeId INT = NULL,
    @DateFrom DATE = NULL,
    @DateTo DATE = NULL,
    @PageSize INT = 10,
    @PageNumber INT = 1,
    @SortColumn NVARCHAR(50) = 'CreditId',
    @SortDirection BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        c.CreditId,
        c.CreditNumber,
        c.Amount,
        c.InterestRate,
        c.StartDate,
        c.EndDate,
        cl.FirstName,
        cl.LastName,
        ct.CreditTypeName,
        cur.CurrencyCode,

        -- Тривалість кредиту (роки)
        DATEDIFF(year, c.StartDate, c.EndDate) AS Years,

        -- Загальна сума до сплати
        CAST(
            c.Amount 
            + (c.Amount * (c.InterestRate / 100) 
               * DATEDIFF(year, c.StartDate, c.EndDate)
              )
            AS DECIMAL(18,2)
        ) AS TotalToPay,

        -- Частина строку, що вже пройшла (0–1), красиво
        CAST(
            CASE 
                WHEN c.StartDate IS NULL 
                  OR c.EndDate IS NULL
                  OR DATEDIFF(day, c.StartDate, c.EndDate) = 0
                THEN NULL
                ELSE
                    CAST(
                        DATEDIFF(
                            day,
                            c.StartDate,
                            CASE 
                                WHEN GETDATE() > c.EndDate 
                                    THEN c.EndDate 
                                ELSE GETDATE() 
                            END
                        ) AS DECIMAL(10,4)
                    )
                    / CAST(
                        DATEDIFF(day, c.StartDate, c.EndDate) 
                        AS DECIMAL(10,4)
                    )
            END
            AS DECIMAL(6,4)
        ) AS PayPercent

    FROM Credits c
    JOIN Clients cl     ON c.ClientId = cl.ClientId
    JOIN CreditTypes ct ON c.CreditTypeId = ct.CreditTypeId
    JOIN Currencies cur ON c.CurrencyId = cur.CurrencyId

    WHERE (@ClientId IS NULL OR c.ClientId = @ClientId)
      AND (@CreditTypeId IS NULL OR c.CreditTypeId = @CreditTypeId)
      AND (@DateFrom IS NULL OR c.StartDate >= @DateFrom)
      AND (@DateTo   IS NULL OR c.EndDate   <= @DateTo)

    ORDER BY
        CASE WHEN @SortDirection = 0 THEN
            CASE @SortColumn
                WHEN 'Amount'    THEN CAST(c.Amount AS NVARCHAR)
                WHEN 'StartDate' THEN CAST(c.StartDate AS NVARCHAR)
                WHEN 'LastName'  THEN cl.LastName
                ELSE CAST(c.CreditId AS NVARCHAR)
            END
        END ASC,
        CASE WHEN @SortDirection = 1 THEN
            CASE @SortColumn
                WHEN 'Amount'    THEN CAST(c.Amount AS NVARCHAR)
                WHEN 'StartDate' THEN CAST(c.StartDate AS NVARCHAR)
                WHEN 'LastName'  THEN cl.LastName
                ELSE CAST(c.CreditId AS NVARCHAR)
            END
        END DESC

    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO




-- 3. PROCEDURE – ДЕПОЗИТИ  (JOIN + фільтр + очікуваний прибуток)

CREATE OR ALTER PROCEDURE dbo.sp_GetDeposits
    @ClientId INT = NULL,
    @DepositProgramId INT = NULL,
    @DateFrom DATE = NULL,
    @DateTo DATE = NULL,
    @PageSize INT = 10,
    @PageNumber INT = 1,
    @SortColumn NVARCHAR(50) = 'DepositId',
    @SortDirection BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        d.DepositId,
        d.Amount,
        d.StartDate,
        d.EndDate,
        cl.LastName,
        cl.FirstName,
        dp.ProgramName,
        dp.InterestRate,
        dp.DurationMonths,
        cur.CurrencyCode,

        -- Очікуваний прибуток за весь строк (простий відсоток)
        d.Amount * (dp.InterestRate / 100) * (dp.DurationMonths / 12.0) AS ExpectedProfit
    FROM Deposits d
    JOIN Clients cl 
        ON d.ClientId = cl.ClientId
    JOIN DepositPrograms dp
        ON d.DepositProgramId = dp.DepositProgramId
    JOIN Currencies cur
        ON d.CurrencyId = cur.CurrencyId
    WHERE (@ClientId IS NULL OR d.ClientId = @ClientId)
      AND (@DepositProgramId IS NULL OR d.DepositProgramId = @DepositProgramId)
      AND (@DateFrom IS NULL OR d.StartDate >= @DateFrom)
      AND (@DateTo   IS NULL OR d.EndDate   <= @DateTo)

    ORDER BY
        CASE WHEN @SortDirection = 0 THEN
            CASE @SortColumn
                WHEN 'DepositId' THEN CAST(d.DepositId AS NVARCHAR)
                WHEN 'Amount'    THEN CAST(d.Amount AS NVARCHAR)
                WHEN 'StartDate' THEN CAST(d.StartDate AS NVARCHAR)
                WHEN 'LastName'  THEN cl.LastName
            END
        END ASC,
        CASE WHEN @SortDirection = 1 THEN
            CASE @SortColumn
                WHEN 'DepositId' THEN CAST(d.DepositId AS NVARCHAR)
                WHEN 'Amount'    THEN CAST(d.Amount AS NVARCHAR)
                WHEN 'StartDate' THEN CAST(d.StartDate AS NVARCHAR)
                WHEN 'LastName'  THEN cl.LastName
            END
        END DESC

    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO



 --4. PROCEDURE – ТРАНЗАКЦІЇ   (фільтр з якого / на який рахунок + тип + дати)
    
CREATE OR ALTER PROCEDURE dbo.sp_GetTransactions
    @FromAccountNumber NVARCHAR(26) = NULL,
    @ToAccountNumber   NVARCHAR(26) = NULL,
    @TransactionTypeId INT = NULL,
    @DateFrom DATETIME = NULL,
    @DateTo   DATETIME = NULL,
    @PageSize INT = 20,
    @PageNumber INT = 1,
    @SortColumn NVARCHAR(50) = 'TransactionDate',
    @SortDirection BIT = 1       -- 0 = ASC, 1 = DESC (за замовчуванням – останні зверху)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        t.TransactionId,
        t.TransactionDate,
        t.Amount,
        t.Purpose,
        t.Status,
        tt.TransactionTypeName,
        cur.CurrencyCode,
        fromAcc.AccountNumber AS FromAccountNumber,
        toAcc.AccountNumber   AS ToAccountNumber
    FROM Transactions t
    JOIN BankAccounts fromAcc 
        ON t.FromAccountId = fromAcc.AccountId
    JOIN BankAccounts toAcc 
        ON t.ToAccountId = toAcc.AccountId
    JOIN TransactionTypes tt
        ON t.TransactionTypeId = tt.TransactionTypeId
    JOIN Currencies cur
        ON t.CurrencyId = cur.CurrencyId
    WHERE (@FromAccountNumber IS NULL OR fromAcc.AccountNumber = @FromAccountNumber)
      AND (@ToAccountNumber   IS NULL OR toAcc.AccountNumber   = @ToAccountNumber)
      AND (@TransactionTypeId IS NULL OR t.TransactionTypeId   = @TransactionTypeId)
      AND (@DateFrom IS NULL OR t.TransactionDate >= @DateFrom)
      AND (@DateTo   IS NULL OR t.TransactionDate <= @DateTo)

    ORDER BY
        CASE WHEN @SortDirection = 0 THEN
            CASE @SortColumn
                WHEN 'TransactionDate' THEN CAST(t.TransactionDate AS NVARCHAR)
                WHEN 'Amount'          THEN CAST(t.Amount AS NVARCHAR)
                WHEN 'FromAccount'     THEN fromAcc.AccountNumber
                WHEN 'ToAccount'       THEN toAcc.AccountNumber
                ELSE CAST(t.TransactionId AS NVARCHAR)
            END
        END ASC,
        CASE WHEN @SortDirection = 1 THEN
            CASE @SortColumn
                WHEN 'TransactionDate' THEN CAST(t.TransactionDate AS NVARCHAR)
                WHEN 'Amount'          THEN CAST(t.Amount AS NVARCHAR)
                WHEN 'FromAccount'     THEN fromAcc.AccountNumber
                WHEN 'ToAccount'       THEN toAcc.AccountNumber
                ELSE CAST(t.TransactionId AS NVARCHAR)
            END
        END DESC

    OFFSET (@PageNumber - 1) * @PageSize ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO




  --  ПЕРЕВІРКА, ЩО ПРОЦЕДУРИ СТВОРИЛИСЯ

SELECT name 
FROM sys.objects 
WHERE type = 'P' AND name LIKE 'sp_Get%';
GO



      -- ТЕСТИ ДЛЯ sp_GetClients

-- Всі клієнти
EXEC dbo.sp_GetClients;

-- Пошук по імені (наприклад, "Ко" → Коваль)
EXEC dbo.sp_GetClients @Name = N'Ко';

-- Пошук по рахунку (існуючий IBAN з твоїх INSERT)
EXEC dbo.sp_GetClients @AccountNumber = 'UA712600010000000200000111';

-- Пагінація (5 записів, сторінка №2)
EXEC dbo.sp_GetClients 
    @PageSize = 5, 
    @PageNumber = 2;

-- Сортування по прізвищу DESC
EXEC dbo.sp_GetClients 
    @SortColumn = 'LastName', 
    @SortDirection = 1;
GO



      -- ТЕСТИ ДЛЯ sp_GetCredits

-- Всі кредити
EXEC dbo.sp_GetCredits;

-- Фільтр по клієнту (1 = Шевчук, 3 = Петренко)
EXEC dbo.sp_GetCredits @ClientId = 3;

-- Сортування по сумі (DESC)
EXEC dbo.sp_GetCredits 
    @SortColumn = 'Amount', 
    @SortDirection = 1;

-- Фільтр по датах
EXEC dbo.sp_GetCredits 
    @DateFrom = '2021-01-01',
    @DateTo   = '2030-01-01';
GO


      -- ТЕСТИ ДЛЯ sp_GetDeposits

-- Всі депозити
EXEC dbo.sp_GetDeposits;

-- По клієнту (наприклад, 2 = Коваль)
EXEC dbo.sp_GetDeposits @ClientId = 2;

-- По програмі (3 = 'Преміум 12 місяців')
EXEC dbo.sp_GetDeposits @DepositProgramId = 3;
GO


      -- ТЕСТИ ДЛЯ sp_GetTransactions

-- Всі транзакції (перші 20)
EXEC dbo.sp_GetTransactions;

-- Фільтр по FromAccount (Олег UAH рахунок)
EXEC dbo.sp_GetTransactions 
    @FromAccountNumber = 'UA712600010000000100000123';

-- Фільтр по ToAccount (Катерина UAH)
EXEC dbo.sp_GetTransactions 
    @ToAccountNumber = 'UA712600010000000300000999';

-- Фільтр по періоду серпень–вересень 2025
EXEC dbo.sp_GetTransactions 
    @DateFrom = '2025-08-01',
    @DateTo   = '2025-09-30';
GO











