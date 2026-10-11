"""Course tasks, their SQL and independently specified expected sample results."""


def step(sql, rows=None, error=0):
    return dict(sql=sql.strip(), expected_rows=rows, expected_error=error)


def task(title, analysis, *steps):
    return dict(title=title, analysis=analysis, steps=list(steps))


def change(sql, affected):
    return step(sql + '\nSELECT ROW_COUNT() AS affected_rows;', [[str(affected)]])


COUNTS = """SELECT 'Category' AS table_name,COUNT(*) AS rows_count FROM Category
UNION ALL SELECT 'Supplier',COUNT(*) FROM Supplier
UNION ALL SELECT 'Student',COUNT(*) FROM Student
UNION ALL SELECT 'Goods',COUNT(*) FROM Goods
UNION ALL SELECT 'SaleBill',COUNT(*) FROM SaleBill;"""

LAB2 = [
 task('将五张表的样本数据导入数据库',
      '按父表、子表的依赖顺序导入。各表行数依次为 3、5、5、4、6。'),
 task('将雀巢咖啡改名为雀巢咖啡条装', '修改了 GN0002 的商品名，影响 1 行。',
      change("UPDATE Goods SET GoodsName='雀巢咖啡条装' WHERE GoodsName='雀巢咖啡';",1),
      step("SELECT GoodsNO,GoodsName FROM Goods WHERE GoodsNO='GN0002';",[['GN0002','雀巢咖啡条装']])),
 task('将所有商品的售价提升百分之五', '更新四件商品，DECIMAL(10,2) 保存两位小数。',
      change('UPDATE Goods SET SalePrice=ROUND(SalePrice*1.05,2);',4),
      step('SELECT GoodsNO,SalePrice FROM Goods ORDER BY GoodsNO;',
           [['GN0001','3.68'],['GN0002','6.09'],['GN0005','20.79'],['GN0007','157.50']])),
 task('将类别号 CN005 改为 CN004',
      '直接修改被 GN0007 引用的父表主码，返回 ERROR 1451。外键采用默认 RESTRICT，不允许留下无效引用；类别号保持 CN005。若业务确需变更，可设计 ON UPDATE CASCADE，或在事务内新增父记录、迁移子表引用后删除旧父记录。',
      step("UPDATE Category SET CategoryNO='CN004' WHERE CategoryNO='CN005';",error=1451),
      step("SELECT CategoryNO FROM Category WHERE CategoryNO IN ('CN004','CN005');",[['CN005']])),
 task('将 2020 年销售总数量小于三的商品售价打八折',
      '“销售数量”按该商品 2020 年合计销量理解，只包含该年确有销售记录的商品。GN0001 的年销量为 5，不打折；GN0005 为 1，按前题提升后的售价计算，结果为 16.63。',
      change("""UPDATE Goods AS g
JOIN (SELECT GoodsNO FROM SaleBill
      WHERE HappenTime >= '2020-01-01' AND HappenTime < '2021-01-01'
      GROUP BY GoodsNO HAVING SUM(Number)<3) AS t
  ON t.GoodsNO=g.GoodsNO
SET g.SalePrice=ROUND(g.SalePrice*0.8,2);""",1),
      step('SELECT GoodsNO,SalePrice FROM Goods ORDER BY GoodsNO;',
           [['GN0001','3.68'],['GN0002','6.09'],['GN0005','16.63'],['GN0007','157.50']])),
 task('将久润食品供应商品的库存数量清零', 'Number 在 Goods 中表示库存，GN0002 的库存改为 0，销售记录数量保持不变。',
      change("""UPDATE Goods AS g JOIN Supplier AS s
  ON s.SupplierNO=g.SupplierNO
SET g.Number=0 WHERE s.SupplierName='久润食品';""",1),
      step("SELECT GoodsNO,Number FROM Goods WHERE GoodsNO='GN0002';",[['GN0002','0']])),
 task('删除购买优乐美奶茶且数量低于三的销售记录', '删除 S02、S03 各购买 1 件的记录，S01 购买 3 件的记录保留。',
      change("""DELETE b FROM SaleBill AS b JOIN Goods AS g
  ON g.GoodsNO=b.GoodsNO
WHERE g.GoodsName='优乐美奶茶' AND b.Number<3;""",2),
      step("SELECT SNO,Number FROM SaleBill WHERE GoodsNO='GN0001';",[['S01','3']])),
 task('删除 2018 年以前生产的商品并处理外键引用',
      'GN0002 尚有两条销售记录，直接删除返回 ERROR 1451。正确处理是先删除对应销售记录，再删除商品；两个动作放在同一事务中，商品与销售记录一起提交。',
      step("DELETE FROM Goods WHERE ProductTime<'2018-01-01';",error=1451),
      step("""START TRANSACTION;
DELETE b FROM SaleBill AS b JOIN Goods AS g ON g.GoodsNO=b.GoodsNO
WHERE g.ProductTime<'2018-01-01';
DELETE FROM Goods WHERE ProductTime<'2018-01-01';
COMMIT;"""),
      step('SELECT GoodsNO FROM Goods ORDER BY GoodsNO;',[['GN0001'],['GN0005'],['GN0007']])),
 task('删除卡夫食品供应商品的销售记录', '前题操作后，卡夫食品对应剩余 GN0001/S01 一条销售记录，删除成功。',
      change("""DELETE b FROM SaleBill AS b
JOIN Goods AS g ON g.GoodsNO=b.GoodsNO
JOIN Supplier AS s ON s.SupplierNO=g.SupplierNO
WHERE s.SupplierName='卡夫食品';""",1)),
 task('删除 ACC 学院学生的销售记录', '删除张小红购买 GN0005 的剩余记录，影响 1 行；不删除学生本身。',
      change("""DELETE b FROM SaleBill AS b JOIN Student AS s
ON s.SNO=b.SNO WHERE s.College='ACC';""",1)),
 task('按引用顺序删除所有销售记录和商品', '先删除 SaleBill，再删除 Goods。此时销售表已空，商品表剩余 3 行，事务提交后两表均空。',
      step('START TRANSACTION;\nDELETE FROM SaleBill;\nDELETE FROM Goods;\nCOMMIT;'),
      step('SELECT (SELECT COUNT(*) FROM SaleBill) AS sales,\n       (SELECT COUNT(*) FROM Goods) AS goods;', [['0','0']])),
 task('删除 1997 年以前出生的学生', '1996 年出生的伍民被删除，剩余 4 名学生。此时销售表已空，不会发生外键冲突。',
      change('DELETE FROM Student WHERE BirthYear<1997;',1),
      step('SELECT SNO,SName,BirthYear FROM Student ORDER BY SNO;',
           [['S01','李明','1999'],['S02','徐好','1998'],['S04','闵红','1997'],['S05','张小红','1997']])),
]

GOODS = [
 ['GN0001','sup001','CN001','优乐美奶茶','2.5','3.50','100','2019-12-20'],
 ['GN0002','sup002','CN001','雀巢咖啡','4.0','5.80','50','2017-06-08'],
 ['GN0005','sup003','CN002','飘柔洗发水','15.0','19.80','65','2019-05-29'],
 ['GN0007','sup005','CN005','小绵羊被套','120.0','150.00','28','2019-11-22'],
]
BUYERS=[['S01','李明','CS'],['S02','徐好','CS'],['S03','伍民','CS'],['S05','张小红','ACC']]
OLDEST=[['S03','伍民','CS'],['S04','闵红','ACC'],['S05','张小红','ACC']]
UNSOLD=[['GN0007','小绵羊被套','床上用品','150.00','28']]
LAB3 = [
 task('查询全部商品信息','返回原始样本中的 4 件商品。',step('SELECT * FROM Goods ORDER BY GoodsNO;',GOODS)),
 task('查询类别 cn002 的商品','排序规则不区分英文字母大小写，返回飘柔洗发水。',step("SELECT * FROM Goods WHERE CategoryNO='cn002' ORDER BY GoodsNO;",[GOODS[2]])),
 task('查询类别 cn001 或 cn002 的商品','IN 表达两种类别之一，返回 3 件商品。',step("SELECT * FROM Goods WHERE CategoryNO IN ('cn001','cn002')\nORDER BY GoodsNO;",GOODS[:3])),
 task('查询 cn005 且进价大于二十的商品','两个条件用 AND 连接，返回小绵羊被套。',step("SELECT * FROM Goods WHERE CategoryNO='cn005' AND InPrice>20;",[GOODS[3]])),
 task('查询库存数量小于十的商品','原始库存最小值为 28，因此返回空集。',step('SELECT GoodsNO,SupplierNO,GoodsName,Number\nFROM Goods WHERE Number<10 ORDER BY GoodsNO;',[])),
 task('查询有购买记录的学生学号','DISTINCT 去除同一学生多次购买产生的重复学号，返回 4 人。',step('SELECT DISTINCT SNO FROM SaleBill ORDER BY SNO;',[[x[0]] for x in BUYERS])),
 task('查询 IT 专业学生学号姓名和年龄','使用本次执行年份减出生年份得到年历年龄。只有李明属于 IT；当前年龄值见实际结果。',step("SELECT SNO,SName,YEAR(CURRENT_DATE())-BirthYear AS Age\nFROM Student WHERE Major='IT' ORDER BY SNO;",[['S01','李明','27']])),
 task('查询年龄二十二至二十四的学生','本次查询年份为 2026，样本学生年历年龄为 27～30，返回空集。没有把系统时间改成教学年份。',step('SELECT SNO,SName,College,Major,YEAR(CURRENT_DATE())-BirthYear AS Age\nFROM Student WHERE YEAR(CURRENT_DATE())-BirthYear BETWEEN 22 AND 24\nORDER BY SNO;',[])),
 task('查询姓张的学生','LIKE 的前缀匹配返回张小红。',step("SELECT SNO,SName,College FROM Student WHERE SName LIKE '张%'\nORDER BY SNO;",[['S05','张小红','ACC']])),
 task('查询库存二十以上商品并按数量降序','四件商品均满足条件，数量依次为 100、65、50、28。',step('SELECT * FROM Goods WHERE Number>=20 ORDER BY Number DESC,GoodsNO;',[GOODS[i] for i in [0,2,1,3]])),
 task('查询库存十以内商品并按类别和库存排序','按包含 10 理解“十以内”，当前样本没有满足条件的商品。',step('SELECT GoodsNO,GoodsName,CategoryNO,Number FROM Goods\nWHERE Number<=10 ORDER BY CategoryNO ASC,Number DESC,GoodsNO;',[])),
 task('查询库存数量排名前三的商品','使用 LIMIT 3，数量相同时以商品编码确定输出顺序。',step('SELECT * FROM Goods ORDER BY Number DESC,GoodsNO LIMIT 3;',[GOODS[i] for i in [0,2,1]])),
 task('查询 cn001 库存最大的商品','使用最大值子查询，若有并列最大值会全部返回。',step("""SELECT GoodsNO,GoodsName,Number FROM Goods
WHERE CategoryNO='cn001' AND Number=(
  SELECT MAX(Number) FROM Goods WHERE CategoryNO='cn001')
ORDER BY GoodsNO;""",[['GN0001','优乐美奶茶','100']])),
 task('统计 MIS 专业学生人数','MIS 专业有徐好、伍民两人。',step("SELECT COUNT(*) AS StudentCount FROM Student WHERE Major='MIS';",[['2']])),
 task('按学院统计二十岁以上人数','先按年龄过滤，再按学院分组，ACC 为 2 人、CS 为 3 人。',step('SELECT College,COUNT(*) AS StudentCount FROM Student\nWHERE YEAR(CURRENT_DATE())-BirthYear>20\nGROUP BY College ORDER BY College;',[['ACC','2'],['CS','3']])),
 task('统计 2018 年各商品销量','按销售日期筛选，2018 年只有 GN0002 销售 2 件。',step("SELECT GoodsNO,SUM(Number) AS SaleTotal FROM SaleBill\nWHERE HappenTime>='2018-01-01' AND HappenTime<'2019-01-01'\nGROUP BY GoodsNO ORDER BY GoodsNO;",[['GN0002','2']])),
 task('查询学生人数在三人以上的学院','“三人以上”按包含 3 理解，CS 满足条件；HAVING 用于过滤分组结果。',step('SELECT College,COUNT(*) AS StudentCount FROM Student\nGROUP BY College HAVING COUNT(*)>=3 ORDER BY College;',[['CS','3']])),
 task('查询 2019 年购买总数超过五的学生','该年只有 S05 购买 2 件，因此返回空集。',step("SELECT SNO,SUM(Number) AS BuyTotal FROM SaleBill\nWHERE HappenTime>='2019-01-01' AND HappenTime<'2020-01-01'\nGROUP BY SNO HAVING SUM(Number)>5 ORDER BY SNO;",[])),
 task('查询咖啡类商品平均售价','按 CategoryName 判断类别；素材把奶茶也归在咖啡类，沿用该分类，平均价为 4.65。',step("SELECT CAST(AVG(g.SalePrice) AS DECIMAL(10,2)) AS AvgPrice\nFROM Goods AS g JOIN Category AS c ON c.CategoryNO=g.CategoryNO\nWHERE c.CategoryName='咖啡';",[['4.65']])),
 task('查询与张小红同学院的学生','题目没有排除本人，因此返回闵红和张小红。',step("SELECT SNO,SName,College FROM Student WHERE College IN\n(SELECT College FROM Student WHERE SName='张小红') ORDER BY SNO;",[['S04','闵红','ACC'],['S05','张小红','ACC']])),
 task('查询全部销售情况并按日期降序','销售记录连接商品及学生，按日期降序返回 6 条明细。',step("""SELECT g.GoodsNO,g.GoodsName,s.SName,b.HappenTime,b.Number
FROM SaleBill AS b JOIN Goods AS g ON g.GoodsNO=b.GoodsNO
JOIN Student AS s ON s.SNO=b.SNO
ORDER BY b.HappenTime DESC,g.GoodsNO,s.SNO;""",[
 ['GN0001','优乐美奶茶','李明','2020-06-09','3'],['GN0005','飘柔洗发水','张小红','2020-06-01','1'],
 ['GN0001','优乐美奶茶','徐好','2020-05-03','1'],['GN0001','优乐美奶茶','伍民','2020-04-07','1'],
 ['GN0002','雀巢咖啡','张小红','2019-06-26','2'],['GN0002','雀巢咖啡','徐好','2018-05-08','2']])),
 task('查询购买商品的学生','EXISTS 避免重复返回同一学生。',step('SELECT s.SNO,s.SName,s.College FROM Student AS s\nWHERE EXISTS (SELECT 1 FROM SaleBill AS b WHERE b.SNO=s.SNO)\nORDER BY s.SNO;',BUYERS)),
 task('查询购买咖啡类商品的学生','连接四表后 DISTINCT 去重，返回 4 人。',step("""SELECT DISTINCT s.SNO,s.SName,s.College FROM Student AS s
JOIN SaleBill AS b ON b.SNO=s.SNO
JOIN Goods AS g ON g.GoodsNO=b.GoodsNO
JOIN Category AS c ON c.CategoryNO=g.CategoryNO
WHERE c.CategoryName='咖啡' ORDER BY s.SNO;""",BUYERS)),
 task('用连接和子查询查询未出售商品','分别使用 LEFT JOIN 判空和 NOT EXISTS，两个结果相同，均为 GN0007。',
      step('SELECT g.GoodsNO,g.GoodsName,c.CategoryName,g.SalePrice,g.Number\nFROM Goods AS g JOIN Category AS c ON c.CategoryNO=g.CategoryNO\nLEFT JOIN SaleBill AS b ON b.GoodsNO=g.GoodsNO\nWHERE b.GoodsNO IS NULL ORDER BY g.GoodsNO;',UNSOLD),
      step('SELECT g.GoodsNO,g.GoodsName,c.CategoryName,g.SalePrice,g.Number\nFROM Goods AS g JOIN Category AS c ON c.CategoryNO=g.CategoryNO\nWHERE NOT EXISTS (SELECT 1 FROM SaleBill AS b\n                  WHERE b.GoodsNO=g.GoodsNO) ORDER BY g.GoodsNO;',UNSOLD)),
 task('查询买过 gn001 或 gn002 的学生','原题短商品号按素材映射为 GN0001、GN0002，OR 表达任意一种。',step("SELECT DISTINCT s.SNO,s.SName,s.College FROM Student AS s\nJOIN SaleBill AS b ON b.SNO=s.SNO\nWHERE b.GoodsNO IN ('GN0001','GN0002') ORDER BY s.SNO;",BUYERS)),
 task('查询同时买过 gn001 和 gn002 的学生','先限定两种商品，再要求去重商品数为 2，只有徐好同时购买。',step("""SELECT s.SNO,s.SName,s.College FROM Student AS s
JOIN SaleBill AS b ON b.SNO=s.SNO
WHERE b.GoodsNO IN ('GN0001','GN0002')
GROUP BY s.SNO,s.SName,s.College
HAVING COUNT(DISTINCT b.GoodsNO)=2 ORDER BY s.SNO;""",[['S02','徐好','CS']])),
 task('用相关子查询和派生表查询各学院年龄最大者','出生年份越小年龄越大；ACC 有两名并列，必须一起返回。两种实现结果一致。',
      step('SELECT s.SNO,s.SName,s.College FROM Student AS s\nWHERE s.BirthYear=(SELECT MIN(t.BirthYear) FROM Student AS t\n                   WHERE t.College=s.College) ORDER BY s.SNO;',OLDEST),
      step('SELECT s.SNO,s.SName,s.College FROM Student AS s\nJOIN (SELECT College,MIN(BirthYear) AS MinYear FROM Student\n      GROUP BY College) AS t\nON t.College=s.College AND t.MinYear=s.BirthYear ORDER BY s.SNO;',OLDEST)),
 task('统计每个商品的销售总量','LEFT JOIN 保留未出售商品，COALESCE 将其销售总量记为 0。',step('SELECT g.GoodsNO,g.GoodsName,COALESCE(SUM(b.Number),0) AS SaleTotal\nFROM Goods AS g LEFT JOIN SaleBill AS b ON b.GoodsNO=g.GoodsNO\nGROUP BY g.GoodsNO,g.GoodsName ORDER BY g.GoodsNO;',[
      ['GN0001','优乐美奶茶','5'],['GN0002','雀巢咖啡','4'],['GN0005','飘柔洗发水','1'],['GN0007','小绵羊被套','0']])),
 task('查询 2019 年购买总数超过五的学生姓名和学院','与第 18 项同一条件，连接 Student 增加姓名和学院，本样本返回空集。',step("SELECT s.SName,s.College,SUM(b.Number) AS BuyTotal\nFROM Student AS s JOIN SaleBill AS b ON b.SNO=s.SNO\nWHERE b.HappenTime>='2019-01-01' AND b.HappenTime<'2020-01-01'\nGROUP BY s.SNO,s.SName,s.College HAVING SUM(b.Number)>5\nORDER BY s.SNO;",[])),
 task('查询供应总数超过五十的供应商','“供应商品总数”按 Goods.Number 的库存数量求和，不按商品种类数计算。返回卡夫食品 100 件、飞鹤食品 65 件。',step("""SELECT s.SupplierNO,s.SupplierName,s.Address,SUM(g.Number) AS SupplyTotal
FROM Supplier AS s JOIN Goods AS g ON g.SupplierNO=s.SupplierNO
GROUP BY s.SupplierNO,s.SupplierName,s.Address
HAVING SUM(g.Number)>50 ORDER BY SupplyTotal DESC,s.SupplierNO;""",[
 ['sup001','卡夫食品','广东佛山','100'],['sup003','飞鹤食品','重庆解放碑','65']])),
]

LAB4 = [
 task('定义 MIS 专业学生视图 V_MIS 并查询','采用简单单表视图，不加 WITH CHECK OPTION，便于观察后续插入 IT 学生的行为。初始可见徐好、伍民。',
      step("CREATE VIEW V_MIS AS SELECT * FROM Student WHERE Major='MIS';"),
      step('SELECT SNO,SName,Major FROM V_MIS ORDER BY SNO;',[['S02','徐好','MIS'],['S03','伍民','MIS']])),
 task('定义学生购买商品信息视图 V_SSG 并查询','视图将学生、销售和商品关联，返回 6 条记录；每列名称唯一。',
      step('CREATE VIEW V_SSG AS\nSELECT s.SNO,s.SName,g.GoodsName,g.SalePrice,b.Number\nFROM Student AS s JOIN SaleBill AS b ON b.SNO=s.SNO\nJOIN Goods AS g ON g.GoodsNO=b.GoodsNO;'),
      step('SELECT * FROM V_SSG ORDER BY SNO,GoodsName;')),
 task('定义学生年龄视图 V_AGE 并查询','年历年龄由当前年份减出生年份计算，当前年份为 2026。',
      step('CREATE VIEW V_AGE AS SELECT SNO,SName,College,Major,\nYEAR(CURRENT_DATE())-BirthYear AS Age FROM Student;'),
      step('SELECT SNO,SName,Age FROM V_AGE ORDER BY SNO;',[
           ['S01','李明','27'],['S02','徐好','28'],['S03','伍民','30'],['S04','闵红','29'],['S05','张小红','29']])),
 task('定义学院人数及平均年龄视图 V_COM 并查询','包含 GROUP BY 和聚合函数，属于不可更新视图。',
      step('CREATE VIEW V_COM AS SELECT College,COUNT(*) AS StudentCount,\nCAST(AVG(YEAR(CURRENT_DATE())-BirthYear) AS DECIMAL(6,2)) AS AvgAge\nFROM Student GROUP BY College;'),
      step('SELECT * FROM V_COM ORDER BY College;',[['ACC','2','29.00'],['CS','3','28.33']])),
 task('定义学生购买种类及消费总额视图 V_S_CONSUME','使用 COUNT(DISTINCT GoodsNO) 统计种类，数量乘当前商品售价计算消费额。样本没有保存历史成交价，因此不能把此值视为历史实付金额。未购买者消费额为 0。',
      step('CREATE VIEW V_S_CONSUME AS\nSELECT s.SNO,s.SName,s.College,COUNT(DISTINCT b.GoodsNO) AS GoodsKinds,\nCAST(COALESCE(SUM(b.Number*g.SalePrice),0) AS DECIMAL(12,2)) AS CostTotal\nFROM Student AS s LEFT JOIN SaleBill AS b ON b.SNO=s.SNO\nLEFT JOIN Goods AS g ON g.GoodsNO=b.GoodsNO\nGROUP BY s.SNO,s.SName,s.College;'),
      step('SELECT * FROM V_S_CONSUME ORDER BY SNO;',[
       ['S01','李明','CS','1','10.50'],['S02','徐好','CS','2','15.10'],['S03','伍民','CS','1','3.50'],
       ['S04','闵红','ACC','0','0.00'],['S05','张小红','ACC','2','31.40']])),
 task('定义类别商品总数平均售价及最小库存视图 V_GOODS','商品总数在本题按商品种类条数 COUNT(GoodsNO) 理解；平均价格和最小库存按对应商品计算。',
      step('CREATE VIEW V_GOODS AS\nSELECT c.CategoryNO,c.CategoryName,COUNT(g.GoodsNO) AS GoodsCount,\nCAST(AVG(g.SalePrice) AS DECIMAL(10,2)) AS AvgPrice,\nMIN(g.Number) AS MinStock\nFROM Category AS c LEFT JOIN Goods AS g ON g.CategoryNO=c.CategoryNO\nGROUP BY c.CategoryNO,c.CategoryName;'),
      step('SELECT * FROM V_GOODS ORDER BY CategoryNO;',[
       ['CN001','咖啡','2','4.65','50'],['CN002','洗发水','1','19.80','65'],['CN005','床上用品','1','150.00','28']])),
 task('定义供应商商品数库存和平均进价视图 V_SU_GOOD','按供应商聚合，平均进价超过 10 元者为飞鹤食品和缙云日化；同时保留联系方式，满足第 10 项查询。',
      step('CREATE VIEW V_SU_GOOD AS\nSELECT s.SupplierNO,s.SupplierName,s.Number AS Phone,s.Address,\nCOUNT(g.GoodsNO) AS GoodsCount,SUM(g.Number) AS StockTotal,\nCAST(AVG(g.InPrice) AS DECIMAL(10,2)) AS AvgInPrice\nFROM Supplier AS s JOIN Goods AS g ON g.SupplierNO=s.SupplierNO\nGROUP BY s.SupplierNO,s.SupplierName,s.Number,s.Address\nHAVING AVG(g.InPrice)>10;'),
      step('SELECT SupplierNO,SupplierName,GoodsCount,StockTotal,AvgInPrice\nFROM V_SU_GOOD ORDER BY SupplierNO;',[
       ['sup003','飞鹤食品','1','65','15.00'],['sup005','缙云日化','1','28','120.00']])),
 task('通过 V_COM 查询平均年龄十九以上的学院','两个学院均满足条件。',step('SELECT * FROM V_COM WHERE AvgAge>19 ORDER BY College;',[['ACC','2','29.00'],['CS','3','28.33']])),
 task('通过 V_S_CONSUME 查询消费总额超过二百的学生','最大消费额为 31.40，返回空集。',step('SELECT * FROM V_S_CONSUME WHERE CostTotal>200 ORDER BY SNO;',[])),
 task('通过 V_SU_GOOD 查询库存总数小于五十的供应商','返回缙云日化的名称、电话和地址。',step('SELECT SupplierName,Phone,Address FROM V_SU_GOOD\nWHERE StockTotal<50 ORDER BY SupplierNO;',[['缙云日化','19648768903','重庆北碚']])),
 task('通过 V_MIS 插入宋江并查询','宋江专业为 MIS，插入 1 行且在视图中可见。题目未给出性别，原始恢复结构允许 Gender 为空，不推测性别。',
      change("INSERT INTO V_MIS (SNO,SName,BirthYear,College,Major,WeiXin)\nVALUES ('s09','宋江',2000,'CS','MIS','wx009');",1),
      step("SELECT SNO,SName,Major FROM V_MIS WHERE SNO='s09';",[['s09','宋江','MIS']])),
 task('通过 V_MIS 插入周瑜并查询','没有 CHECK OPTION 时，IT 学生可通过可插入视图写入基表，但不满足 MIS 筛选，查询该视图看不到记录。',
      change("INSERT INTO V_MIS (SNO,SName,BirthYear,College,Major,WeiXin)\nVALUES ('s10','周瑜',1999,'CS','IT','wx010');",1),
      step("SELECT SNO,SName,Major FROM V_MIS WHERE SNO='s10';",[]),
      step("SELECT SNO,SName,Major FROM Student WHERE SNO='s10';",[['s10','周瑜','IT']])),
 task('通过 V_MIS 将 s01 的姓名改为李欢欢','S01 为 IT 专业，视图不可见，因此更新成功但影响 0 行，基表仍为李明。',
      change("UPDATE V_MIS SET SName='李欢欢' WHERE SNO='s01';",0),
      step("SELECT SNO,SName,Major FROM Student WHERE SNO='s01';",[['S01','李明','IT']])),
 task('通过 V_MIS 将 s02 的姓名改为徐慧慧','S02 为 MIS，修改影响 1 行，基表和视图均反映新姓名。',
      change("UPDATE V_MIS SET SName='徐慧慧' WHERE SNO='s02';",1),
      step("SELECT SNO,SName FROM V_MIS WHERE SNO='s02';",[['S02','徐慧慧']])),
 task('通过 V_SSG 将力神咖啡售价改为十元','原始素材没有力神咖啡，更新影响 0 行。这不表示连接视图不能更新；另用事务内临时商品和销售记录验证，单独修改 Goods.SalePrice 可以成功，补充数据随后回滚。',
      change("UPDATE V_SSG SET SalePrice=10 WHERE GoodsName='力神咖啡';",0),
      step("SELECT GoodsName,SalePrice FROM V_SSG WHERE GoodsName='力神咖啡';",[])),
 task('通过 V_MIS 删除 s09','宋江为 MIS，可见且没有被销售记录引用，删除影响 1 行，基表也不再存在。',
      change("DELETE FROM V_MIS WHERE SNO='s09';",1),
      step("SELECT SNO FROM Student WHERE SNO='s09';",[])),
 task('通过 V_MIS 删除 s10','周瑜属于 IT，不能从 MIS 视图匹配，因此删除影响 0 行，基表仍保留该学生。',
      change("DELETE FROM V_MIS WHERE SNO='s10';",0),
      step("SELECT SNO,SName,Major FROM Student WHERE SNO='s10';",[['s10','周瑜','IT']])),
]

LABS={2:LAB2,3:LAB3,4:LAB4}
