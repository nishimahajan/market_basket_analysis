CREATE TABLE FrequentItemsets (
	itempairs VARCHAR(255),
    frequency INT,
    support DOUBLE,
    confidenceofitem1 DOUBLE,
    confidenceofitem2 DOUBLE,
    lift DOUBLE
);

INSERT INTO FrequentItemsets
WITH total AS(
	SELECT COUNT(DISTINCT TransactionID) AS total_trans
	FROM bakery
),
ItemSupport AS (
  SELECT
    ItemID,
    COUNT(DISTINCT TransactionID) AS ItemCount,
    COUNT(DISTINCT TransactionID) /(SELECT total_trans FROM total) AS Support
  FROM bakery
  GROUP BY ItemID
),
PairSupport AS (
  SELECT
    a.ItemID AS ItemA,
    b.ItemID AS ItemB,
    COUNT(DISTINCT a.TransactionID) AS PairCount,
    COUNT(DISTINCT a.TransactionID) /(SELECT total_trans FROM total)  AS PairSupport
  FROM bakery a
  JOIN bakery b ON a.TransactionID = b.TransactionID AND a.ItemID < b.ItemID
  GROUP BY a.ItemID, b.ItemID
)
SELECT 
    CONCAT(PairSupport.ItemA, ',', PairSupport.ItemB) AS itempairs,
    PairSupport.PairCount AS frequency,
    PairSupport.PairSupport AS support,
    PairSupport.PairCount / ItemSupportA.ItemCount AS confidenceofitem1,
    PairSupport.PairCount / ItemSupportB.ItemCount AS confidenceofitem2,
    PairSupport.PairSupport / (ItemSupportA.Support * ItemSupportB.Support) AS lift
FROM PairSupport
JOIN ItemSupport AS ItemSupportA ON PairSupport.ItemA = ItemSupportA.ItemID
JOIN ItemSupport AS ItemSupportB ON PairSupport.ItemB = ItemSupportB.ItemID;

SELECT * 
FROM FrequentItemsets
WHERE support > 0.001
ORDER BY frequency DESC;

drop table frequentitemsets;