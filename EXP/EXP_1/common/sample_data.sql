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
