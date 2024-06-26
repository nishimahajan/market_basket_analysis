SELECT ROW_NUMBER() OVER (ORDER BY TransactionID) AS row_num, bakery.*
FROM bakery
LIMIT 10; -- see the first 10 rows of the table

SELECT * FROM bakeryitems;

ALTER TABLE bakery ADD COLUMN ItemID TEXT(10);
SET SQL_SAFE_UPDATES = 0;
UPDATE bakery b
LEFT JOIN bakeryitems i ON b.Items = i.ItemName
SET b.ItemID = i.ItemID;
SET SQL_SAFE_UPDATES = 1;

-- to check number of items for each transaction
SELECT TransactionID, COUNT(ItemID) AS NumberofItems
FROM bakery
GROUP BY TransactionID
HAVING COUNT(ItemID) >= 2;

-- to select transactions with atleast 2 items
SELECT OrderList.transactionID, bakery.ItemID
FROM 
	(SELECT TransactionID, COUNT(ItemID) AS NumberofItems
	FROM bakery
	GROUP BY TransactionID
	HAVING COUNT(ItemID) >= 2)
AS OrderList
JOIN bakery ON Orderlist.TransactionID = bakery.TransactionID;

-- cte to create item pairs
WITH Info AS
(SELECT OrderList.transactionID, bakery.ItemID
FROM 
	(SELECT TransactionID, COUNT(ItemID) AS NumberofItems
	FROM bakery
	GROUP BY TransactionID
	HAVING COUNT(ItemID) >= 2) 
AS OrderList
JOIN bakery ON Orderlist.TransactionID = bakery.TransactionID)
SELECT 
	Info1.TransactionID,
	Info1.ItemID AS Item1,
	Info2.ItemID AS Item2
FROM Info AS Info1
JOIN Info AS Info2 ON Info1.TransactionID = Info2.TransactionID
WHERE Info1.ItemID != Info2.ItemID AND Info1.ItemID < Info2.ItemID;

-- cte to create table with item pairs and frequency
CREATE TABLE frequency AS
WITH Info AS
(SELECT OrderList.transactionID, bakery.ItemID
FROM 
	(SELECT TransactionID, COUNT(ItemID) AS NumberofItems
	FROM bakery
	GROUP BY TransactionID
	HAVING COUNT(ItemID) >= 2) 
AS OrderList
JOIN bakery ON Orderlist.TransactionID = bakery.TransactionID)
SELECT 
	Info1.ItemID AS Item1,
	Info2.ItemID AS Item2,
    COUNT(*) AS Frequency
FROM Info AS Info1
JOIN Info AS Info2 ON Info1.TransactionID = Info2.TransactionID
WHERE Info1.ItemID != Info2.ItemID AND Info1.ItemID < Info2.ItemID
GROUP BY
	Info1.ItemID,
	Info2.ItemID
ORDER BY COUNT(*) DESC;


