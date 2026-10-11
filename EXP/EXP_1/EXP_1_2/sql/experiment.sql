USE SuperMarket_EXP_2;

-- TASK 1: 将五张表的样本数据导入数据库
-- 原始五表样本；销售商品号统一到 Goods 主码。
INSERT INTO Category (CategoryNO, CategoryName, Descriptions) VALUES
 ('CN001', '咖啡', '速溶咖啡，袋装咖啡，咖啡粉'),
 ('CN002', '洗发水', '袋装、瓶装洗发水'),
 ('CN005', '床上用品', '被套，枕套，床单');
INSERT INTO Supplier (SupplierNO, SupplierName, Address, Number) VALUES
 ('sup001', '卡夫食品', '广东佛山', '12348768900'),
 ('sup002', '久润食品', '广东东莞', '13248768901'),
 ('sup003', '飞鹤食品', '重庆解放碑', '12648768901'),
 ('sup004', '南山日化', '重庆南坪', '11648768903'),
 ('sup005', '缙云日化', '重庆北碚', '19648768903');
INSERT INTO Student (SNO, SName, BirthYear, Gender, College, Major, WeiXin) VALUES
 ('S01', '李明', 1999, '男', 'CS', 'IT', 'wx001'),
 ('S02', '徐好', 1998, '女', 'CS', 'MIS', 'wx002'),
 ('S03', '伍民', 1996, '男', 'CS', 'MIS', 'wx003'),
 ('S04', '闵红', 1997, '女', 'ACC', 'AC', 'wx004'),
 ('S05', '张小红', 1997, '女', 'ACC', 'AC', 'wx005');
INSERT INTO Goods
 (GoodsNO, SupplierNO, CategoryNO, GoodsName,
  InPrice, SalePrice, Number, ProductTime) VALUES
 ('GN0001', 'sup001', 'CN001', '优乐美奶茶', 2.5, 3.5, 100, '2019-12-20'),
 ('GN0002', 'sup002', 'CN001', '雀巢咖啡', 4, 5.8, 50, '2017-06-08'),
 ('GN0005', 'sup003', 'CN002', '飘柔洗发水', 15, 19.8, 65, '2019-05-29'),
 ('GN0007', 'sup005', 'CN005', '小绵羊被套', 120, 150, 28, '2019-11-22');
INSERT INTO SaleBill (GoodsNO, SNO, HappenTime, Number) VALUES
 ('GN0001', 'S01', '2020-06-09', 3),
 ('GN0001', 'S02', '2020-05-03', 1),
 ('GN0001', 'S03', '2020-04-07', 1),
 ('GN0002', 'S02', '2018-05-08', 2),
 ('GN0002', 'S05', '2019-06-26', 2),
 ('GN0005', 'S05', '2020-06-01', 1);

SELECT 'Category' AS table_name,COUNT(*) AS rows_count FROM Category
UNION ALL SELECT 'Supplier',COUNT(*) FROM Supplier
UNION ALL SELECT 'Student',COUNT(*) FROM Student
UNION ALL SELECT 'Goods',COUNT(*) FROM Goods
UNION ALL SELECT 'SaleBill',COUNT(*) FROM SaleBill;


-- TASK 2: 将雀巢咖啡改名为雀巢咖啡条装
UPDATE Goods SET GoodsName='雀巢咖啡条装' WHERE GoodsName='雀巢咖啡';
SELECT ROW_COUNT() AS affected_rows;

SELECT GoodsNO,GoodsName FROM Goods WHERE GoodsNO='GN0002';


-- TASK 3: 将所有商品的售价提升百分之五
UPDATE Goods SET SalePrice=ROUND(SalePrice*1.05,2);
SELECT ROW_COUNT() AS affected_rows;

SELECT GoodsNO,SalePrice FROM Goods ORDER BY GoodsNO;


-- TASK 4: 将类别号 CN005 改为 CN004
-- Expected MySQL error 1451
UPDATE Category SET CategoryNO='CN004' WHERE CategoryNO='CN005';

SELECT CategoryNO FROM Category WHERE CategoryNO IN ('CN004','CN005');


-- TASK 5: 将 2020 年销售总数量小于三的商品售价打八折
UPDATE Goods AS g
JOIN (SELECT GoodsNO FROM SaleBill
      WHERE HappenTime >= '2020-01-01' AND HappenTime < '2021-01-01'
      GROUP BY GoodsNO HAVING SUM(Number)<3) AS t
  ON t.GoodsNO=g.GoodsNO
SET g.SalePrice=ROUND(g.SalePrice*0.8,2);
SELECT ROW_COUNT() AS affected_rows;

SELECT GoodsNO,SalePrice FROM Goods ORDER BY GoodsNO;


-- TASK 6: 将久润食品供应商品的库存数量清零
UPDATE Goods AS g JOIN Supplier AS s
  ON s.SupplierNO=g.SupplierNO
SET g.Number=0 WHERE s.SupplierName='久润食品';
SELECT ROW_COUNT() AS affected_rows;

SELECT GoodsNO,Number FROM Goods WHERE GoodsNO='GN0002';


-- TASK 7: 删除购买优乐美奶茶且数量低于三的销售记录
DELETE b FROM SaleBill AS b JOIN Goods AS g
  ON g.GoodsNO=b.GoodsNO
WHERE g.GoodsName='优乐美奶茶' AND b.Number<3;
SELECT ROW_COUNT() AS affected_rows;

SELECT SNO,Number FROM SaleBill WHERE GoodsNO='GN0001';


-- TASK 8: 删除 2018 年以前生产的商品并处理外键引用
-- Expected MySQL error 1451
DELETE FROM Goods WHERE ProductTime<'2018-01-01';

START TRANSACTION;
DELETE b FROM SaleBill AS b JOIN Goods AS g ON g.GoodsNO=b.GoodsNO
WHERE g.ProductTime<'2018-01-01';
DELETE FROM Goods WHERE ProductTime<'2018-01-01';
COMMIT;

SELECT GoodsNO FROM Goods ORDER BY GoodsNO;


-- TASK 9: 删除卡夫食品供应商品的销售记录
DELETE b FROM SaleBill AS b
JOIN Goods AS g ON g.GoodsNO=b.GoodsNO
JOIN Supplier AS s ON s.SupplierNO=g.SupplierNO
WHERE s.SupplierName='卡夫食品';
SELECT ROW_COUNT() AS affected_rows;


-- TASK 10: 删除 ACC 学院学生的销售记录
DELETE b FROM SaleBill AS b JOIN Student AS s
ON s.SNO=b.SNO WHERE s.College='ACC';
SELECT ROW_COUNT() AS affected_rows;


-- TASK 11: 按引用顺序删除所有销售记录和商品
START TRANSACTION;
DELETE FROM SaleBill;
DELETE FROM Goods;
COMMIT;

SELECT (SELECT COUNT(*) FROM SaleBill) AS sales,
       (SELECT COUNT(*) FROM Goods) AS goods;


-- TASK 12: 删除 1997 年以前出生的学生
DELETE FROM Student WHERE BirthYear<1997;
SELECT ROW_COUNT() AS affected_rows;

SELECT SNO,SName,BirthYear FROM Student ORDER BY SNO;
