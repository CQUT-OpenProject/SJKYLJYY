USE SuperMarket_EXP_4;

-- TASK 1: 定义 MIS 专业学生视图 V_MIS 并查询
CREATE VIEW V_MIS AS SELECT * FROM Student WHERE Major='MIS';

SELECT SNO,SName,Major FROM V_MIS ORDER BY SNO;


-- TASK 2: 定义学生购买商品信息视图 V_SSG 并查询
CREATE VIEW V_SSG AS
SELECT s.SNO,s.SName,g.GoodsName,g.SalePrice,b.Number
FROM Student AS s JOIN SaleBill AS b ON b.SNO=s.SNO
JOIN Goods AS g ON g.GoodsNO=b.GoodsNO;

SELECT * FROM V_SSG ORDER BY SNO,GoodsName;


-- TASK 3: 定义学生年龄视图 V_AGE 并查询
CREATE VIEW V_AGE AS SELECT SNO,SName,College,Major,
YEAR(CURRENT_DATE())-BirthYear AS Age FROM Student;

SELECT SNO,SName,Age FROM V_AGE ORDER BY SNO;


-- TASK 4: 定义学院人数及平均年龄视图 V_COM 并查询
CREATE VIEW V_COM AS SELECT College,COUNT(*) AS StudentCount,
CAST(AVG(YEAR(CURRENT_DATE())-BirthYear) AS DECIMAL(6,2)) AS AvgAge
FROM Student GROUP BY College;

SELECT * FROM V_COM ORDER BY College;


-- TASK 5: 定义学生购买种类及消费总额视图 V_S_CONSUME
CREATE VIEW V_S_CONSUME AS
SELECT s.SNO,s.SName,s.College,COUNT(DISTINCT b.GoodsNO) AS GoodsKinds,
CAST(COALESCE(SUM(b.Number*g.SalePrice),0) AS DECIMAL(12,2)) AS CostTotal
FROM Student AS s LEFT JOIN SaleBill AS b ON b.SNO=s.SNO
LEFT JOIN Goods AS g ON g.GoodsNO=b.GoodsNO
GROUP BY s.SNO,s.SName,s.College;

SELECT * FROM V_S_CONSUME ORDER BY SNO;


-- TASK 6: 定义类别商品总数平均售价及最小库存视图 V_GOODS
CREATE VIEW V_GOODS AS
SELECT c.CategoryNO,c.CategoryName,COUNT(g.GoodsNO) AS GoodsCount,
CAST(AVG(g.SalePrice) AS DECIMAL(10,2)) AS AvgPrice,
MIN(g.Number) AS MinStock
FROM Category AS c LEFT JOIN Goods AS g ON g.CategoryNO=c.CategoryNO
GROUP BY c.CategoryNO,c.CategoryName;

SELECT * FROM V_GOODS ORDER BY CategoryNO;


-- TASK 7: 定义供应商商品数库存和平均进价视图 V_SU_GOOD
CREATE VIEW V_SU_GOOD AS
SELECT s.SupplierNO,s.SupplierName,s.Number AS Phone,s.Address,
COUNT(g.GoodsNO) AS GoodsCount,SUM(g.Number) AS StockTotal,
CAST(AVG(g.InPrice) AS DECIMAL(10,2)) AS AvgInPrice
FROM Supplier AS s JOIN Goods AS g ON g.SupplierNO=s.SupplierNO
GROUP BY s.SupplierNO,s.SupplierName,s.Number,s.Address
HAVING AVG(g.InPrice)>10;

SELECT SupplierNO,SupplierName,GoodsCount,StockTotal,AvgInPrice
FROM V_SU_GOOD ORDER BY SupplierNO;


-- TASK 8: 通过 V_COM 查询平均年龄十九以上的学院
SELECT * FROM V_COM WHERE AvgAge>19 ORDER BY College;


-- TASK 9: 通过 V_S_CONSUME 查询消费总额超过二百的学生
SELECT * FROM V_S_CONSUME WHERE CostTotal>200 ORDER BY SNO;


-- TASK 10: 通过 V_SU_GOOD 查询库存总数小于五十的供应商
SELECT SupplierName,Phone,Address FROM V_SU_GOOD
WHERE StockTotal<50 ORDER BY SupplierNO;


-- TASK 11: 通过 V_MIS 插入宋江并查询
INSERT INTO V_MIS (SNO,SName,BirthYear,College,Major,WeiXin)
VALUES ('s09','宋江',2000,'CS','MIS','wx009');
SELECT ROW_COUNT() AS affected_rows;

SELECT SNO,SName,Major FROM V_MIS WHERE SNO='s09';


-- TASK 12: 通过 V_MIS 插入周瑜并查询
INSERT INTO V_MIS (SNO,SName,BirthYear,College,Major,WeiXin)
VALUES ('s10','周瑜',1999,'CS','IT','wx010');
SELECT ROW_COUNT() AS affected_rows;

SELECT SNO,SName,Major FROM V_MIS WHERE SNO='s10';

SELECT SNO,SName,Major FROM Student WHERE SNO='s10';


-- TASK 13: 通过 V_MIS 将 s01 的姓名改为李欢欢
UPDATE V_MIS SET SName='李欢欢' WHERE SNO='s01';
SELECT ROW_COUNT() AS affected_rows;

SELECT SNO,SName,Major FROM Student WHERE SNO='s01';


-- TASK 14: 通过 V_MIS 将 s02 的姓名改为徐慧慧
UPDATE V_MIS SET SName='徐慧慧' WHERE SNO='s02';
SELECT ROW_COUNT() AS affected_rows;

SELECT SNO,SName FROM V_MIS WHERE SNO='s02';


-- TASK 15: 通过 V_SSG 将力神咖啡售价改为十元
UPDATE V_SSG SET SalePrice=10 WHERE GoodsName='力神咖啡';
SELECT ROW_COUNT() AS affected_rows;

SELECT GoodsName,SalePrice FROM V_SSG WHERE GoodsName='力神咖啡';


-- TASK 16: 通过 V_MIS 删除 s09
DELETE FROM V_MIS WHERE SNO='s09';
SELECT ROW_COUNT() AS affected_rows;

SELECT SNO FROM Student WHERE SNO='s09';


-- TASK 17: 通过 V_MIS 删除 s10
DELETE FROM V_MIS WHERE SNO='s10';
SELECT ROW_COUNT() AS affected_rows;

SELECT SNO,SName,Major FROM Student WHERE SNO='s10';
