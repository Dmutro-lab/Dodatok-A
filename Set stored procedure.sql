
-- PROCEDURE: sp_SetClients
CREATE OR ALTER PROCEDURE dbo.sp_SetClients
    @ClientId INT = NULL OUTPUT,
    @LastName NVARCHAR(50) = NULL,
    @FirstName NVARCHAR(50) = NULL,
    @MiddleName NVARCHAR(50) = NULL,
    @ClientType NVARCHAR(20) = NULL,
    @BirthDate DATE = NULL,
    @Phone NVARCHAR(14) = NULL,
    @Address NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Перевірка обов’язкових полів для INSERT
    IF @ClientId IS NULL 
       AND (@LastName IS NULL OR @FirstName IS NULL OR @ClientType IS NULL)
    BEGIN
        RAISERROR(N'LastName, FirstName і ClientType є обов’язковими.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        
        -- INSERT
        IF @ClientId IS NULL
        BEGIN
            INSERT INTO Clients
                (LastName, FirstName, MiddleName, ClientType, BirthDate, Phone, Address)
            VALUES
                (@LastName, @FirstName, @MiddleName, @ClientType,
                 @BirthDate, @Phone, @Address);

            SET @ClientId = SCOPE_IDENTITY();
            RETURN;
        END

        -- UPDATE
        UPDATE Clients
        SET 
            LastName   = ISNULL(@LastName, LastName),
            FirstName  = ISNULL(@FirstName, FirstName),
            MiddleName = ISNULL(@MiddleName, MiddleName),
            ClientType = ISNULL(@ClientType, ClientType),
            BirthDate  = ISNULL(@BirthDate, BirthDate),
            Phone      = ISNULL(@Phone, Phone),
            Address    = ISNULL(@Address, Address)
        WHERE ClientId = @ClientId;

    END TRY
    BEGIN CATCH
        RAISERROR(ERROR_MESSAGE(), 16, 1);
    END CATCH
END;
GO


-- PROCEDURE: sp_SetCredits
CREATE OR ALTER PROCEDURE dbo.sp_SetCredits
    @CreditId INT = NULL OUTPUT,
    @ClientId INT = NULL,
    @CreditTypeId INT = NULL,
    @CreditNumber NVARCHAR(30) = NULL,
    @Amount DECIMAL(18,2) = NULL,
    @InterestRate DECIMAL(5,2) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @CurrencyId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @CreditId IS NULL AND
       (@ClientId IS NULL OR @CreditTypeId IS NULL OR 
        @CreditNumber IS NULL OR @Amount IS NULL OR 
        @InterestRate IS NULL OR @CurrencyId IS NULL)
    BEGIN
        RAISERROR(N'Всі поля крім дат є обов’язковими для INSERT.', 16, 1);
        RETURN;
    END

    BEGIN TRY

        -- INSERT
        IF @CreditId IS NULL
        BEGIN
            INSERT INTO Credits
                (ClientId, CreditTypeId, CreditNumber, Amount, InterestRate, 
                 StartDate, EndDate, CurrencyId)
            VALUES
                (@ClientId, @CreditTypeId, @CreditNumber, @Amount, @InterestRate,
                 @StartDate, @EndDate, @CurrencyId);

            SET @CreditId = SCOPE_IDENTITY();
            RETURN;
        END

        -- UPDATE
        UPDATE Credits
        SET 
            ClientId      = ISNULL(@ClientId, ClientId),
            CreditTypeId  = ISNULL(@CreditTypeId, CreditTypeId),
            CreditNumber  = ISNULL(@CreditNumber, CreditNumber),
            Amount        = ISNULL(@Amount, Amount),
            InterestRate  = ISNULL(@InterestRate, InterestRate),
            StartDate     = ISNULL(@StartDate, StartDate),
            EndDate       = ISNULL(@EndDate, EndDate),
            CurrencyId    = ISNULL(@CurrencyId, CurrencyId)
        WHERE CreditId = @CreditId;

    END TRY
    BEGIN CATCH
        RAISERROR(ERROR_MESSAGE(), 16, 1);
    END CATCH
END;
GO





-- PROCEDURE: sp_SetDeposits
CREATE OR ALTER PROCEDURE dbo.sp_SetDeposits
    @DepositId INT = NULL OUTPUT,
    @ClientId INT = NULL,
    @DepositProgramId INT = NULL,
    @Amount DECIMAL(18,2) = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @CurrencyId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @DepositId IS NULL AND
       (@ClientId IS NULL OR @DepositProgramId IS NULL 
        OR @Amount IS NULL OR @CurrencyId IS NULL)
    BEGIN
        RAISERROR(N'ClientId, DepositProgramId, Amount, CurrencyId — обов’язкові.', 16, 1);
        RETURN;
    END

    BEGIN TRY
        
        -- INSERT
        IF @DepositId IS NULL
        BEGIN
            INSERT INTO Deposits
                (ClientId, DepositProgramId, Amount, StartDate, EndDate, CurrencyId)
            VALUES
                (@ClientId, @DepositProgramId, @Amount,
                 @StartDate, @EndDate, @CurrencyId);

            SET @DepositId = SCOPE_IDENTITY();
            RETURN;
        END

        -- UPDATE
        UPDATE Deposits
        SET 
            ClientId         = ISNULL(@ClientId, ClientId),
            DepositProgramId = ISNULL(@DepositProgramId, DepositProgramId),
            Amount           = ISNULL(@Amount, Amount),
            StartDate        = ISNULL(@StartDate, StartDate),
            EndDate          = ISNULL(@EndDate, EndDate),
            CurrencyId       = ISNULL(@CurrencyId, CurrencyId)
        WHERE DepositId = @DepositId;

    END TRY
    BEGIN CATCH
        RAISERROR(ERROR_MESSAGE(), 16, 1);
    END CATCH
END;
GO



-- sp_SetClients — додавання та оновлення



DECLARE @newClientId INT;
-- Спроба додати клієнта БЕЗ обов?язкових полів

EXEC dbo.sp_SetClients
    @LastName   = N'Тестовий',
    @FirstName  = N'Клієнт',
    @ClientType = N'Individual',
    @ClientId   = @newClientId OUTPUT;

SELECT @newClientId AS CreatedClientId;


EXEC dbo.sp_SetClients
    @ClientId = 3,
    @Phone = '+380991234568';


-- sp_SetBankAccounts — додавання та оновлення

DECLARE @newAccId INT = NULL;

EXEC dbo.sp_SetBankAccounts
    @AccountId = @newAccId OUTPUT,
    @ClientId = 1,
    @AccountNumber = 'UA000000000000000000000001',
    @AccountTypeId = 1,
    @Balance = 1500.00,
    @CurrencyId = 1;

SELECT @newAccId AS CreatedAccountId;

EXEC dbo.sp_SetBankAccounts
    @AccountId = 2,
    @Balance = 9999.98;



   --  sp_SetCredits — додавання та оновлення

 DECLARE @newCreditId INT = NULL;

EXEC dbo.sp_SetCredits
    @CreditId = @newCreditId OUTPUT,
    @ClientId = 1,
    @CreditTypeId = 1,
    @CreditNumber = 'CR-2025-0001',
    @Amount = 50000,
    @InterestRate = 12.5,
    @StartDate = '2025-01-01',
    @EndDate = '2027-01-01',
    @CurrencyId = 1;

SELECT @newCreditId AS CreatedCreditId;

EXEC dbo.sp_SetCredits
    @CreditId = 1,
    @Amount = 999998;


-- sp_SetDeposits — додавання та оновлення

DECLARE @newDepId INT = NULL;

EXEC dbo.sp_SetDeposits
    @DepositId = @newDepId OUTPUT,
    @ClientId = 2,
    @DepositProgramId = 1,
    @Amount = 3000,
    @StartDate = '2025-10-01',
    @EndDate = '2026-01-01',
    @CurrencyId = 1;

SELECT @newDepId AS CreatedDepositId;

EXEC dbo.sp_SetDeposits
    @DepositId = 1,
    @Amount = 7776;


    SELECT * 
FROM BankAccounts
ORDER BY AccountId;
USE BankSystem;
GO

BEGIN TRY
    EXEC dbo.sp_SetClients
        @LastName = NULL,
        @FirstName = NULL,
        @ClientType = NULL;
END TRY
BEGIN CATCH
    SELECT 
        ERROR_NUMBER()  AS ErrNum,
        ERROR_MESSAGE() AS ErrMsg;
END CATCH
GO



