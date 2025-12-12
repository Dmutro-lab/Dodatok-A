-- 1.¬ибрати вс≥ банк≥вськ≥ рахунки з ≥менами кл≥Їнт≥в, типом рахунку ≥ валютою
SELECT 
    c.LastName + ' ' + c.FirstName AS ClientName,
    a.AccountNumber,
    t.AccountTypeName,
    cur.CurrencyCode,
    a.Balance
FROM BankAccounts AS a
JOIN Clients AS c ON a.ClientId = c.ClientId
JOIN AccountTypes AS t ON a.AccountTypeId = t.AccountTypeId
JOIN Currencies AS cur ON a.CurrencyId = cur.CurrencyId
ORDER BY c.LastName;

--2.¬ибрати вс≥ активн≥ кредити кл≥Їнт≥в ≥з типом кредиту та валютою
SELECT 
    c.LastName + ' ' + c.FirstName AS ClientName,
    cr.CreditNumber,
    ct.CreditTypeName,
    cr.Amount,
    cr.InterestRate,
    cur.CurrencyName,
    cr.StartDate,
    cr.EndDate
FROM Credits AS cr
JOIN Clients AS c ON cr.ClientId = c.ClientId
JOIN CreditTypes AS ct ON cr.CreditTypeId = ct.CreditTypeId
JOIN Currencies AS cur ON cr.CurrencyId = cur.CurrencyId
WHERE cr.EndDate > GETDATE();

--3.¬ибрати вс≥ транзакц≥њ з ≥нформац≥Їю про в≥дправника ≥ отримувача
SELECT 
    tr.TransactionId,
    tr.TransactionDate,
    tr.Amount,
    cur.CurrencyCode,
    tt.TransactionTypeName,
    c1.LastName + ' ' + c1.FirstName AS Sender,
    c2.LastName + ' ' + c2.FirstName AS Receiver,
    tr.Purpose,
    tr.Status
FROM Transactions AS tr
JOIN TransactionTypes AS tt ON tr.TransactionTypeId = tt.TransactionTypeId
JOIN Currencies AS cur ON tr.CurrencyId = cur.CurrencyId
JOIN BankAccounts AS a1 ON tr.FromAccountId = a1.AccountId
JOIN BankAccounts AS a2 ON tr.ToAccountId = a2.AccountId
JOIN Clients AS c1 ON a1.ClientId = c1.ClientId
JOIN Clients AS c2 ON a2.ClientId = c2.ClientId
ORDER BY tr.TransactionDate DESC;

--4.¬ибрати вс≥ картки кл≥Їнт≥в з типом карти, рахунком ≥ валютою
SELECT 
    c.LastName + ' ' + c.FirstName AS ClientName,
    bc.CardNumber,
    ct.CardTypeName,
    ba.AccountNumber,
    cur.CurrencyCode,
    ba.Balance,
    bc.ExpirationDate
FROM BankCards AS bc
JOIN Clients AS c ON bc.ClientId = c.ClientId
JOIN CardTypes AS ct ON bc.CardTypeId = ct.CardTypeId
JOIN BankAccounts AS ba ON bc.AccountId = ba.AccountId
JOIN Currencies AS cur ON ba.CurrencyId = cur.CurrencyId
ORDER BY c.LastName;

--5. ¬ибрати депозити кл≥Їнт≥в ≥з програмою, в≥дсотком та валютою
SELECT 
    c.LastName + ' ' + c.FirstName AS ClientName,
    dp.ProgramName,
    dp.InterestRate AS ProgramRate,
    d.Amount,
    cur.CurrencyCode,
    d.StartDate,
    d.EndDate
FROM Deposits AS d
JOIN Clients AS c ON d.ClientId = c.ClientId
JOIN DepositPrograms AS dp ON d.DepositProgramId = dp.DepositProgramId
JOIN Currencies AS cur ON d.CurrencyId = cur.CurrencyId;

--6.ѕрац≥вники банку з назвами посад
SELECT 
    e.LastName + ' ' + e.FirstName AS EmployeeName,
    p.PositionName,
    ep.StartDate,
    ep.EndDate
FROM BankEmployees AS e
JOIN EmployeePositions AS ep ON e.EmployeeId = ep.EmployeeId
JOIN Positions AS p ON ep.PositionId = p.PositionId;


--«апит по кредитах Ц €ку суму кл≥Їнт сплачуЇ (основний борг + проценти)

SELECT 
    c.CreditId,
    cl.LastName + ' ' + cl.FirstName AS ClientName,
    ct.CreditTypeName,
    c.Amount AS Principal,
    c.InterestRate AS Rate,
    DATEDIFF(year, c.StartDate, c.EndDate) AS Years,
    c.Amount + (c.Amount * (c.InterestRate / 100) * DATEDIFF(year, c.StartDate, c.EndDate)) AS TotalToPay
FROM Credits c
JOIN Clients cl ON c.ClientId = cl.ClientId
JOIN CreditTypes ct ON c.CreditTypeId = ct.CreditTypeId;

--—к≥льки в≥дсотк≥в банк маЇ сплатити по депозитах
SELECT 
    d.DepositId,
    cl.LastName + ' ' + cl.FirstName AS ClientName,
    dp.ProgramName,
    d.Amount,
    dp.InterestRate,
    dp.DurationMonths,
    d.Amount * (dp.InterestRate / 100) * (dp.DurationMonths / 12.0) AS InterestToPay
FROM Deposits d
JOIN Clients cl ON d.ClientId = cl.ClientId
JOIN DepositPrograms dp ON d.DepositProgramId = dp.DepositProgramId;
 

 --як≥ депозити зак≥нчуютьс€ цього м≥с€ц€ 

 SELECT 
    d.DepositId,
    cl.LastName + ' ' + cl.FirstName AS ClientName,
    dp.ProgramName,
    d.Amount,
    d.EndDate
FROM Deposits d
JOIN Clients cl ON d.ClientId = cl.ClientId
JOIN DepositPrograms dp ON d.DepositProgramId = dp.DepositProgramId
WHERE MONTH(d.EndDate) = MONTH(GETDATE())
  AND YEAR(d.EndDate) = YEAR(GETDATE());
