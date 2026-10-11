USE SuperMarket_EXP_3;

-- TASK 1: 查询全部商品信息
SELECT * FROM Goods ORDER BY GoodsNO;


-- TASK 2: 查询类别 cn002 的商品
SELECT * FROM Goods WHERE CategoryNO='cn002' ORDER BY GoodsNO;


-- TASK 3: 查询类别 cn001 或 cn002 的商品
SELECT * FROM Goods WHERE CategoryNO IN ('cn001','cn002')
ORDER BY GoodsNO;


-- TASK 4: 查询 cn005 且进价大于二十的商品
SELECT * FROM Goods WHERE CategoryNO='cn005' AND InPrice>20;


-- TASK 5: 查询库存数量小于十的商品
SELECT GoodsNO,SupplierNO,GoodsName,Number
FROM Goods WHERE Number<10 ORDER BY GoodsNO;


-- TASK 6: 查询有购买记录的学生学号
SELECT DISTINCT SNO FROM SaleBill ORDER BY SNO;


-- TASK 7: 查询 IT 专业学生学号姓名和年龄
SELECT SNO,SName,YEAR(CURRENT_DATE())-BirthYear AS Age
FROM Student WHERE Major='IT' ORDER BY SNO;


-- TASK 8: 查询年龄二十二至二十四的学生
SELECT SNO,SName,College,Major,YEAR(CURRENT_DATE())-BirthYear AS Age
FROM Student WHERE YEAR(CURRENT_DATE())-BirthYear BETWEEN 22 AND 24
ORDER BY SNO;


-- TASK 9: 查询姓张的学生
SELECT SNO,SName,College FROM Student WHERE SName LIKE '张%'
ORDER BY SNO;


-- TASK 10: 查询库存二十以上商品并按数量降序
SELECT * FROM Goods WHERE Number>=20 ORDER BY Number DESC,GoodsNO;


-- TASK 11: 查询库存十以内商品并按类别和库存排序
SELECT GoodsNO,GoodsName,CategoryNO,Number FROM Goods
WHERE Number<=10 ORDER BY CategoryNO ASC,Number DESC,GoodsNO;


-- TASK 12: 查询库存数量排名前三的商品
SELECT * FROM Goods ORDER BY Number DESC,GoodsNO LIMIT 3;


-- TASK 13: 查询 cn001 库存最大的商品
SELECT GoodsNO,GoodsName,Number FROM Goods
WHERE CategoryNO='cn001' AND Number=(
  SELECT MAX(Number) FROM Goods WHERE CategoryNO='cn001')
ORDER BY GoodsNO;


-- TASK 14: 统计 MIS 专业学生人数
SELECT COUNT(*) AS StudentCount FROM Student WHERE Major='MIS';


-- TASK 15: 按学院统计二十岁以上人数
SELECT College,COUNT(*) AS StudentCount FROM Student
WHERE YEAR(CURRENT_DATE())-BirthYear>20
GROUP BY College ORDER BY College;


-- TASK 16: 统计 2018 年各商品销量
SELECT GoodsNO,SUM(Number) AS SaleTotal FROM SaleBill
WHERE HappenTime>='2018-01-01' AND HappenTime<'2019-01-01'
GROUP BY GoodsNO ORDER BY GoodsNO;


-- TASK 17: 查询学生人数在三人以上的学院
SELECT College,COUNT(*) AS StudentCount FROM Student
GROUP BY College HAVING COUNT(*)>=3 ORDER BY College;


-- TASK 18: 查询 2019 年购买总数超过五的学生
SELECT SNO,SUM(Number) AS BuyTotal FROM SaleBill
WHERE HappenTime>='2019-01-01' AND HappenTime<'2020-01-01'
GROUP BY SNO HAVING SUM(Number)>5 ORDER BY SNO;


-- TASK 19: 查询咖啡类商品平均售价
SELECT CAST(AVG(g.SalePrice) AS DECIMAL(10,2)) AS AvgPrice
FROM Goods AS g JOIN Category AS c ON c.CategoryNO=g.CategoryNO
WHERE c.CategoryName='咖啡';


-- TASK 20: 查询与张小红同学院的学生
SELECT SNO,SName,College FROM Student WHERE College IN
(SELECT College FROM Student WHERE SName='张小红') ORDER BY SNO;


-- TASK 21: 查询全部销售情况并按日期降序
SELECT g.GoodsNO,g.GoodsName,s.SName,b.HappenTime,b.Number
FROM SaleBill AS b JOIN Goods AS g ON g.GoodsNO=b.GoodsNO
JOIN Student AS s ON s.SNO=b.SNO
ORDER BY b.HappenTime DESC,g.GoodsNO,s.SNO;


-- TASK 22: 查询购买商品的学生
SELECT s.SNO,s.SName,s.College FROM Student AS s
WHERE EXISTS (SELECT 1 FROM SaleBill AS b WHERE b.SNO=s.SNO)
ORDER BY s.SNO;


-- TASK 23: 查询购买咖啡类商品的学生
SELECT DISTINCT s.SNO,s.SName,s.College FROM Student AS s
JOIN SaleBill AS b ON b.SNO=s.SNO
JOIN Goods AS g ON g.GoodsNO=b.GoodsNO
JOIN Category AS c ON c.CategoryNO=g.CategoryNO
WHERE c.CategoryName='咖啡' ORDER BY s.SNO;


-- TASK 24: 用连接和子查询查询未出售商品
SELECT g.GoodsNO,g.GoodsName,c.CategoryName,g.SalePrice,g.Number
FROM Goods AS g JOIN Category AS c ON c.CategoryNO=g.CategoryNO
LEFT JOIN SaleBill AS b ON b.GoodsNO=g.GoodsNO
WHERE b.GoodsNO IS NULL ORDER BY g.GoodsNO;

SELECT g.GoodsNO,g.GoodsName,c.CategoryName,g.SalePrice,g.Number
FROM Goods AS g JOIN Category AS c ON c.CategoryNO=g.CategoryNO
WHERE NOT EXISTS (SELECT 1 FROM SaleBill AS b
                  WHERE b.GoodsNO=g.GoodsNO) ORDER BY g.GoodsNO;


-- TASK 25: 查询买过 gn001 或 gn002 的学生
SELECT DISTINCT s.SNO,s.SName,s.College FROM Student AS s
JOIN SaleBill AS b ON b.SNO=s.SNO
WHERE b.GoodsNO IN ('GN0001','GN0002') ORDER BY s.SNO;


-- TASK 26: 查询同时买过 gn001 和 gn002 的学生
SELECT s.SNO,s.SName,s.College FROM Student AS s
JOIN SaleBill AS b ON b.SNO=s.SNO
WHERE b.GoodsNO IN ('GN0001','GN0002')
GROUP BY s.SNO,s.SName,s.College
HAVING COUNT(DISTINCT b.GoodsNO)=2 ORDER BY s.SNO;


-- TASK 27: 用相关子查询和派生表查询各学院年龄最大者
SELECT s.SNO,s.SName,s.College FROM Student AS s
WHERE s.BirthYear=(SELECT MIN(t.BirthYear) FROM Student AS t
                   WHERE t.College=s.College) ORDER BY s.SNO;

SELECT s.SNO,s.SName,s.College FROM Student AS s
JOIN (SELECT College,MIN(BirthYear) AS MinYear FROM Student
      GROUP BY College) AS t
ON t.College=s.College AND t.MinYear=s.BirthYear ORDER BY s.SNO;


-- TASK 28: 统计每个商品的销售总量
SELECT g.GoodsNO,g.GoodsName,COALESCE(SUM(b.Number),0) AS SaleTotal
FROM Goods AS g LEFT JOIN SaleBill AS b ON b.GoodsNO=g.GoodsNO
GROUP BY g.GoodsNO,g.GoodsName ORDER BY g.GoodsNO;


-- TASK 29: 查询 2019 年购买总数超过五的学生姓名和学院
SELECT s.SName,s.College,SUM(b.Number) AS BuyTotal
FROM Student AS s JOIN SaleBill AS b ON b.SNO=s.SNO
WHERE b.HappenTime>='2019-01-01' AND b.HappenTime<'2020-01-01'
GROUP BY s.SNO,s.SName,s.College HAVING SUM(b.Number)>5
ORDER BY s.SNO;


-- TASK 30: 查询供应总数超过五十的供应商
SELECT s.SupplierNO,s.SupplierName,s.Address,SUM(g.Number) AS SupplyTotal
FROM Supplier AS s JOIN Goods AS g ON g.SupplierNO=s.SupplierNO
GROUP BY s.SupplierNO,s.SupplierName,s.Address
HAVING SUM(g.Number)>50 ORDER BY SupplyTotal DESC,s.SupplierNO;
