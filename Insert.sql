
INSERT INTO Clients (LastName, FirstName, MiddleName, ClientType, BirthDate, Phone, Address) VALUES
('Шевчук', 'Олег', 'Миколайович', 'Individual', '1982-03-18', '+380631112233', 'м. Київ, вул. Саксаганського, 12'),
('Коваль', 'Катерина', 'Іванівна', 'Individual', '1991-07-05', '+380503334455', 'м. Львів, вул. Вороного, 8'),
('Петренко', 'Дмитро', 'Олександрович', 'Individual', '1979-12-22', '+380672223344', 'м. Харків, просп. Науки, 15'),
('Мельник', 'Ірина', 'Петрівна', 'Individual', '1996-01-30', '+380985551122', 'м. Одеса, вул. Дерибасівська, 3'),
('Бондаренко', 'Сергій', 'Володимирович', 'Individual', '1988-09-10', '+380677778899', 'м. Дніпро, вул. Воскресенська, 20'),
('Гнатюк', 'Ольга', 'Романівна', 'Individual', '1993-05-02', '+380661234567', 'м. Вінниця, вул. Замостянська, 44');


-- Типи рахунків
INSERT INTO AccountTypes (AccountTypeName) VALUES
('Поточний'),
('Заощаджувальний'),
('Бізнес');


-- Валюти

INSERT INTO Currencies (CurrencyCode, CurrencyName) VALUES
('UAH', 'Ukrainian Hryvnia'),
('USD', 'US Dollar'),
('EUR', 'Euro');

-- Банківські рахунки 

-- AccountNumber — умовні IBAN-подібні 26 символів (без проб)
INSERT INTO BankAccounts (ClientId, AccountNumber, AccountTypeId, Balance, CurrencyId) VALUES
(1, 'UA712600010000000100000123', 1, 27500.75, 1), -- Шевчук Checking UAH
(1, 'UA712600010000000100000124', 2, 8000.00, 2),  -- Шевчук Savings USD
(2, 'UA712600010000000200000111', 1, 1250.50, 1),  -- Коваль Checking UAH
(3, 'UA712600010000000300000999', 1, 560000.00, 1),-- Петренко Checking UAH
(4, 'UA712600010000000400000222', 2, 4200.00, 3),  -- Мельник Savings EUR
(5, 'UA712600010000000500000333', 1, 9800.20, 1),  -- Бондаренко Checking UAH
(6, 'UA712600010000000600000444', 2, 150.00, 2),   -- Гнатюк Savings USD
(7, 'UA712600010000000700000555', 3, 350000.00, 1),-- АгроТрейд Business UAH
(2, 'UA712600010000000200000112', 2, 500.00, 1),   -- Коваль Savings UAH
(5, 'UA712600010000000500000334', 2, 20000.00, 2); -- Бондаренко Savings USD


-- Типи карт

INSERT INTO CardTypes (CardTypeName) VALUES ('Visa'), ('MasterCard');


-- Банківські картки 

INSERT INTO BankCards (AccountId, ClientId, CardTypeId, CardNumber, ExpirationDate) VALUES
(1, 1, 1, '4147201234567890', '2028-05-31'), -- Олег Visa на перший рахунок
(2, 1, 2, '5500001111222233', '2027-11-30'), -- Олег MC на USD savings
(3, 2, 1, '4147209876543210', '2026-09-30'), -- Катерина Visa
(6, 5, 2, '5555666677778884', '2029-02-28'), -- Сергій MasterCard
(5, 4, 1, '4147001122334455', '2027-07-31'); -- Ірина Visa


-- Типи кредитів

INSERT INTO CreditTypes (CreditTypeName) VALUES
('Споживчий кредит'),
('Іпотека'),
('Бізнес кредит');


-- Кредити (декілька прикладів)

INSERT INTO Credits (ClientId, CreditTypeId, CreditNumber, Amount, InterestRate, StartDate, EndDate, CurrencyId) VALUES
(3, 2, 'Споживчий кредит-2021-0001', 350000.00, 7.50, '2021-06-01', '2041-06-01', 1), -- Петренко іпотека UAH
(1, 1, 'Іпотека-2024-015', 15000.00, 14.00, '2024-10-01', '2026-10-01', 2),      -- Шевчук споживчий USD
(7, 3, 'Бізнес-2025-007', 200000.00, 10.00, '2025-02-15', '2029-02-15', 1);    -- АгроТрейд бізнес кредит UAH


-- Депозитні програми

INSERT INTO DepositPrograms (ProgramName, InterestRate, DurationMonths) VALUES
('Гнучкий 3 місяці', 4.50, 3),
('Стандартний 6 місяців', 6.00, 6),
('Преміум 12 місяців', 9.00, 12);



-- Депозити

INSERT INTO Deposits (ClientId, DepositProgramId, Amount, StartDate, EndDate, CurrencyId) VALUES
(2, 2, 1000.00, '2025-04-01', DATEADD(month, 6, '2025-04-01'), 1), -- Коваль 6m UAH
(4, 3, 3000.00, '2025-01-10', DATEADD(month, 12, '2025-01-10'), 3), -- Мельник 12m EUR
(5, 1, 5000.00, '2025-08-01', DATEADD(month, 3, '2025-08-01'), 1);  -- Бондаренко 3m UAH


-- Посади

INSERT INTO Positions (PositionName) VALUES
('Teller'),
('Branch Manager'),
('Credit Officer'),
('IT Specialist'),
('Compliance Officer');


-- Працівники (6 осіб)
INSERT INTO BankEmployees (LastName, FirstName, MiddleName, BirthDate, Phone) VALUES
('Литвин', 'Анатолій', 'Петрович', '1978-04-04', '+380444441111'),
('Кузьмук', 'Наталія', 'Миколаївна', '1985-10-12', '+380444442222'),
('Романюк', 'Василь', NULL, '1990-02-28', '+380444443333'),
('Савченко', 'Олександр', 'Ігорович', '1982-11-15', '+380444444444'),
('Фролова', 'Марина', 'Володимирівна', '1994-06-21', '+380444445555'),
('Даниленко', 'Ігор', 'Олексійович', '1987-09-09', '+380444446666');


-- Історія посад працівників
INSERT INTO EmployeePositions (EmployeeId, PositionId, StartDate, EndDate) VALUES
(1, 2, '2017-03-01', NULL), -- Анатолій Branch Manager
(2, 1, '2019-07-15', NULL), -- Наталія Teller
(3, 3, '2021-05-20', NULL), -- Василь Credit Officer
(4, 4, '2018-09-01', NULL), -- Олександр IT Specialist
(5, 5, '2022-01-10', NULL), -- Марина Compliance Officer
(6, 1, '2020-11-01', NULL); -- Ігор Teller


-- Відділення банку
INSERT INTO BankBranches (Address) VALUES
('м. Київ, вул. Хрещатик, 10'),
('м. Львів, просп. Свободи, 5');

-- Типи транзакцій
INSERT INTO TransactionTypes (TransactionTypeName) VALUES
('Переказ'),
('Поповнення'),
('Зняття коштів'),
('Платіж'),
('Зарплата');


-- Транзакції (приблизно 10 записів)

INSERT INTO Transactions (FromAccountId, ToAccountId, Amount, TransactionTypeId, TransactionDate, Purpose, Status, CurrencyId) VALUES
(1, 3, 1200.00, 1, '2025-09-10 09:30:00', 'Переказ за послуги', 'Виконано', 1),   -- Олег -> Катерина UAH
(6, 1, 500.00, 1, '2025-09-05 14:00:00', 'Повернення боргу', 'Виконано', 1),       -- Сергій -> Олег UAH
(8, 3, 75000.00, 1, '2025-08-20 11:15:00', 'Оплата постачальнику', 'Виконано', 1), -- АгроТрейд -> Катерина UAH
(5, 9, 200.00, 3, '2025-07-12 10:00:00', 'Готівковий зняття', 'Виконано', 3),      -- Ірина EUR withdrawal
(2, 10, 300.00, 1, '2025-06-30 16:45:00', 'Міжрахунковий переказ', 'Виконано', 2), -- Олег USD -> Сергій USD
(3, 4, 100000.00, 1, '2025-05-22 09:00:00', 'Переказ по угоді', 'Виконано', 1),    -- Катерина -> Петренко UAH
(10, 6, 1200.00, 5, '2025-09-01 08:00:00', 'Виплата заробітної плати', 'Виконано', 2), -- Сергій USD salary
(4, 1, 450.00, 4, '2025-04-15 12:30:00', 'Оплата комунальних', 'Виконано', 1),    -- Петренко -> Олег
(1, 8, 25000.00, 1, '2025-03-20 13:00:00', 'Інвестування в бізнес', 'Виконано', 1), -- Олег -> АгроТрейд
(7, 2, 50.00, 1, '2025-02-10 09:10:00', 'Мікропереказ', 'Виконано', 2);          -- Гнатюк USD -> Олег USD

-- Комісії (для частини транзакцій)

INSERT INTO Commissions (TransactionId, CommissionAmount) VALUES
(1, 12.00),
(3, 150.00),
(6, 200.00),
(9, 60.00);
SELECT * FROM Clients;
SELECT * FROM AccountTypes;
SELECT * FROM Currencies;
SELECT * FROM BankAccounts
SELECT * FROM CardTypes;
SELECT * FROM DepositPrograms;
SELECT * FROM Deposits;
SELECT * FROM Positions;
SELECT * FROM BankEmployees;
SELECT * FROM EmployeePositions;
SELECT * FROM BankBranches;
SELECT * FROM TransactionTypes;
SELECT * FROM Transactions;
SELECT * FROM Commissions;

/*
SELECT ClientId, LastName, FirstName FROM Clients;
SELECT AccountId, ClientId, AccountNumber FROM BankAccounts;

DELETE FROM BankAccounts;
DELETE FROM Clients;

DBCC CHECKIDENT (Clients, RESEED, 0);
 
 DBCC CHECKIDENT (BankAccounts, RESEED, 0);
 */
 /*
USE master;
GO
ALTER DATABASE BankSystem SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
GO
DROP DATABASE BankSystem;
GO*/


INSERT INTO Transactions (FromAccountId, ToAccountId, Amount)
VALUES (999, 3, 100.00);
