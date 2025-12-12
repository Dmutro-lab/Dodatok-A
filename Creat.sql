CREATE DATABASE BankSystem;
GO

SELECT ClientId, FirstName, LastName 
FROM Clients;

Use BankSystem;
-- Клієнти
CREATE TABLE Clients (
    ClientId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    LastName NVARCHAR(50) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50),
    ClientType NVARCHAR(20) NOT NULL,
    BirthDate DATE,
    Phone NVARCHAR(14),
    Address NVARCHAR(200)
);

-- Типи рахунків
CREATE TABLE AccountTypes (
    AccountTypeId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    AccountTypeName NVARCHAR(50) NOT NULL
);

-- Валюти
CREATE TABLE Currencies (
    CurrencyId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    CurrencyCode NVARCHAR(3) NOT NULL,   -- ISO: USD, EUR, UAH
    CurrencyName NVARCHAR(50) NOT NULL
);

-- Банківські рахунки
CREATE TABLE BankAccounts (
    AccountId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ClientId INT NOT NULL,
    AccountNumber NVARCHAR(26) NOT NULL,
    AccountTypeId INT NOT NULL,
    Balance DECIMAL(18,2) NOT NULL,
    CurrencyId INT NOT NULL
);

-- Типи карт
CREATE TABLE CardTypes (
    CardTypeId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    CardTypeName NVARCHAR(50) NOT NULL -- Visa / MasterCard
);

-- Банківські картки
CREATE TABLE BankCards (
    CardId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    AccountId INT NOT NULL,
    ClientId INT NOT NULL,
    CardTypeId INT NOT NULL,
    CardNumber NVARCHAR(16) NOT NULL,
    ExpirationDate DATE NOT NULL
);

-- Типи кредитів
CREATE TABLE CreditTypes (
    CreditTypeId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    CreditTypeName NVARCHAR(50) NOT NULL
);

-- Кредити
CREATE TABLE Credits (
    CreditId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ClientId INT NOT NULL,
    CreditTypeId INT NOT NULL,
    CreditNumber NVARCHAR(30) NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    InterestRate DECIMAL(5,2) NOT NULL,
    StartDate DATE,
    EndDate DATE,
    CurrencyId INT NOT NULL
);

-- Депозитні програми
CREATE TABLE DepositPrograms (
    DepositProgramId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ProgramName NVARCHAR(100) NOT NULL,
    InterestRate DECIMAL(5,2) NOT NULL,
    DurationMonths INT NOT NULL
);

-- Депозити
CREATE TABLE Deposits (
    DepositId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ClientId INT NOT NULL,
    DepositProgramId INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    StartDate DATE,
    EndDate DATE,
    CurrencyId INT NOT NULL
);

-- Посади
CREATE TABLE Positions (
    PositionId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    PositionName NVARCHAR(50) NOT NULL 
);

-- Працівники
CREATE TABLE BankEmployees (
    EmployeeId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    LastName NVARCHAR(50) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    MiddleName NVARCHAR(50),
    BirthDate DATE,
    Phone NVARCHAR(20)
);

-- Історія посад працівників
CREATE TABLE EmployeePositions (
    EmployeePositionId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    EmployeeId INT NOT NULL,
    PositionId INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL
);

-- Відділення банку
CREATE TABLE BankBranches (
    BranchId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    Address NVARCHAR(200) NOT NULL
);

-- Типи транзакцій
CREATE TABLE TransactionTypes (
    TransactionTypeId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    TransactionTypeName NVARCHAR(50) NOT NULL
);

-- Транзакції
CREATE TABLE Transactions (
    TransactionId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FromAccountId INT NOT NULL,
    ToAccountId INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    TransactionTypeId INT NOT NULL,
    TransactionDate DATETIME NOT NULL,
    Purpose NVARCHAR(200),
    Status NVARCHAR(30) NOT NULL,
    CurrencyId INT NOT NULL
);

-- Комісії
CREATE TABLE Commissions (
    CommissionId INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
    TransactionId INT NOT NULL,
    CommissionAmount DECIMAL(18,2) NOT NULL
);

