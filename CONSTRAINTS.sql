USE BankSystem;
GO


 -- FOREIGN KEYS
   

ALTER TABLE BankAccounts
ADD CONSTRAINT FK_BankAccounts_Clients FOREIGN KEY (ClientId) REFERENCES Clients(ClientId);

ALTER TABLE BankAccounts
ADD CONSTRAINT FK_BankAccounts_AccountTypes FOREIGN KEY (AccountTypeId) REFERENCES AccountTypes(AccountTypeId);

ALTER TABLE BankAccounts
ADD CONSTRAINT FK_BankAccounts_Currencies FOREIGN KEY (CurrencyId) REFERENCES Currencies(CurrencyId);

ALTER TABLE BankCards
ADD CONSTRAINT FK_BankCards_Accounts FOREIGN KEY (AccountId) REFERENCES BankAccounts(AccountId);

ALTER TABLE BankCards
ADD CONSTRAINT FK_BankCards_Clients FOREIGN KEY (ClientId) REFERENCES Clients(ClientId);

ALTER TABLE BankCards
ADD CONSTRAINT FK_BankCards_Types FOREIGN KEY (CardTypeId) REFERENCES CardTypes(CardTypeId);

ALTER TABLE Credits
ADD CONSTRAINT FK_Credits_Clients FOREIGN KEY (ClientId) REFERENCES Clients(ClientId);

ALTER TABLE Credits
ADD CONSTRAINT FK_Credits_Types FOREIGN KEY (CreditTypeId) REFERENCES CreditTypes(CreditTypeId);

ALTER TABLE Credits
ADD CONSTRAINT FK_Credits_Currencies FOREIGN KEY (CurrencyId) REFERENCES Currencies(CurrencyId);

ALTER TABLE Deposits
ADD CONSTRAINT FK_Deposits_Clients FOREIGN KEY (ClientId) REFERENCES Clients(ClientId);

ALTER TABLE Deposits
ADD CONSTRAINT FK_Deposits_Programs FOREIGN KEY (DepositProgramId) REFERENCES DepositPrograms(DepositProgramId);

ALTER TABLE Deposits
ADD CONSTRAINT FK_Deposits_Currencies FOREIGN KEY (CurrencyId) REFERENCES Currencies(CurrencyId);

ALTER TABLE EmployeePositions
ADD CONSTRAINT FK_EmpPos_Employees FOREIGN KEY (EmployeeId) REFERENCES BankEmployees(EmployeeId);

ALTER TABLE EmployeePositions
ADD CONSTRAINT FK_EmpPos_Positions FOREIGN KEY (PositionId) REFERENCES Positions(PositionId);

ALTER TABLE Transactions
ADD CONSTRAINT FK_Transactions_From FOREIGN KEY (FromAccountId) REFERENCES BankAccounts(AccountId);

ALTER TABLE Transactions
ADD CONSTRAINT FK_Transactions_To FOREIGN KEY (ToAccountId) REFERENCES BankAccounts(AccountId);

ALTER TABLE Transactions
ADD CONSTRAINT FK_Transactions_Type FOREIGN KEY (TransactionTypeId) REFERENCES TransactionTypes(TransactionTypeId);

ALTER TABLE Transactions
ADD CONSTRAINT FK_Transactions_Currency FOREIGN KEY (CurrencyId) REFERENCES Currencies(CurrencyId);

ALTER TABLE Commissions
ADD CONSTRAINT FK_Commissions_Transactions FOREIGN KEY (TransactionId) REFERENCES Transactions(TransactionId);
GO



  -- CHECK CONSTRAINTS
  

-- Телефон клієнта має бути у форматі +380XXXXXXXXX
ALTER TABLE Clients
WITH NOCHECK
ADD CONSTRAINT CK_Clients_Phone CHECK (
    Phone LIKE '+380[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
);

-- Баланс рахунку не може бути від’ємним
ALTER TABLE BankAccounts
ADD CONSTRAINT CK_BankAccounts_Balance CHECK (Balance >= 0);

-- Номер рахунку повинен мати рівно 26 символів (IBAN)
ALTER TABLE BankAccounts
ADD CONSTRAINT CK_BankAccounts_AccountNumberLength CHECK (LEN(AccountNumber) = 26);

-- Сума транзакції має бути більшою за 0
ALTER TABLE Transactions
ADD CONSTRAINT CK_Transactions_Amount CHECK (Amount > 0);

-- Відсоткова ставка по кредиту — у межах 0.1–50%
ALTER TABLE Credits
ADD CONSTRAINT CK_Credits_InterestRate CHECK (InterestRate BETWEEN 0 AND 100);

-- Відсоткова ставка депозитної програми — 0–25%
ALTER TABLE DepositPrograms
ADD CONSTRAINT CK_DepositPrograms_InterestRate CHECK (InterestRate BETWEEN 0 AND 25);

-- Дата завершення депозиту пізніше за початок
ALTER TABLE Deposits
ADD CONSTRAINT CK_Deposits_Date CHECK (EndDate > StartDate);

-- Дата народження клієнта — реалістична (від 1900 року)
ALTER TABLE Clients
ADD CONSTRAINT CK_Clients_BirthDate CHECK (BirthDate >= '1900-01-01' AND BirthDate <= GETDATE());
GO



 -- UNIQUE CONSTRAINTS
  

ALTER TABLE BankAccounts
ADD CONSTRAINT UQ_BankAccounts_AccountNumber UNIQUE (AccountNumber);

ALTER TABLE BankCards
ADD CONSTRAINT UQ_BankCards_CardNumber UNIQUE (CardNumber);

ALTER TABLE Credits
ADD CONSTRAINT UQ_Credits_CreditNumber UNIQUE (CreditNumber);

ALTER TABLE Clients
ADD CONSTRAINT UQ_Clients_Phone UNIQUE (Phone);
GO



 -- DEFAULT CONSTRAINTS
  

ALTER TABLE BankAccounts
ADD CONSTRAINT DF_BankAccounts_Balance DEFAULT (0.00) FOR Balance;

ALTER TABLE Transactions
ADD CONSTRAINT DF_Transactions_Status DEFAULT ('Pending') FOR Status;

ALTER TABLE Transactions
ADD CONSTRAINT DF_Transactions_TransactionDate DEFAULT (GETDATE()) FOR TransactionDate;

ALTER TABLE Deposits
ADD CONSTRAINT DF_Deposits_StartDate DEFAULT (GETDATE()) FOR StartDate;
GO



 -- Тестові перевірки 
   

--  Телефон не у форматі — має викликати помилку
INSERT INTO Clients (LastName, FirstName, ClientType, BirthDate, Phone, Address)
VALUES ('Помилковий', 'Тест', 'Individual', '1985-02-02', '3806312345698', 'м. Київ, вул. Тестова, 1');

--  Баланс < 0 — має викликати помилку
INSERT INTO BankAccounts (ClientId, AccountNumber, AccountTypeId, Balance, CurrencyId)
VALUES (1, 'UA1123456789012345678901234566', 1, -100, 1);

--  Невірна довжина IBAN
INSERT INTO BankAccounts (ClientId, AccountNumber, AccountTypeId, Balance, CurrencyId)
VALUES (1, 'UA12345', 1, 100, 1);

--  Дата депозиту: кінець раніше початку
INSERT INTO Deposits (ClientId, DepositProgramId, Amount, StartDate, EndDate, CurrencyId)
VALUES (1, 1, 1000, '2025-12-01', '2025-01-01', 1);

--  Валідний приклад (усе має пройти)
INSERT INTO Clients (LastName, FirstName, ClientType, BirthDate, Phone, Address)
VALUES ('Коректний', 'Клієнт', 'Individual', '1990-05-10', '+380501234567', 'м. Київ, вул. Гарна, 10');
GO
