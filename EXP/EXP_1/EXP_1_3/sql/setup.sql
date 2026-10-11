CREATE DATABASE SuperMarket_EXP_3 CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE SuperMarket_EXP_3;
-- 供实验二至四使用的原始结构；由运行脚本选择独立数据库。
CREATE TABLE Category (
  CategoryNO VARCHAR(8) PRIMARY KEY,
  CategoryName VARCHAR(30) NOT NULL,
  Descriptions VARCHAR(200)
) ENGINE=InnoDB;
CREATE TABLE Supplier (
  SupplierNO VARCHAR(8) PRIMARY KEY,
  SupplierName VARCHAR(60) NOT NULL,
  Address VARCHAR(100) NOT NULL,
  Number VARCHAR(20) NOT NULL
) ENGINE=InnoDB;
CREATE TABLE Student (
  SNO VARCHAR(8) PRIMARY KEY,
  SName VARCHAR(30) NOT NULL,
  BirthYear SMALLINT NOT NULL,
  Gender VARCHAR(2) DEFAULT NULL,
  College VARCHAR(10) NOT NULL,
  Major VARCHAR(10) NOT NULL,
  WeiXin VARCHAR(40),
  CONSTRAINT uq_student_weixin UNIQUE (WeiXin)
) ENGINE=InnoDB;
-- 视图插入题没有提供性别，允许 NULL，避免虚构学生性别。
CREATE TABLE Goods (
  GoodsNO VARCHAR(8) PRIMARY KEY,
  SupplierNO VARCHAR(8) NOT NULL,
  CategoryNO VARCHAR(8) NOT NULL,
  GoodsName VARCHAR(60) NOT NULL,
  InPrice DECIMAL(10,1) NOT NULL,
  SalePrice DECIMAL(10,2) NOT NULL,
  Number INT NOT NULL,
  ProductTime DATE NOT NULL,
  CONSTRAINT fk_goods_supplier FOREIGN KEY (SupplierNO)
    REFERENCES Supplier (SupplierNO),
  CONSTRAINT fk_goods_category FOREIGN KEY (CategoryNO)
    REFERENCES Category (CategoryNO)
) ENGINE=InnoDB;
CREATE TABLE SaleBill (
  GoodsNO VARCHAR(8) NOT NULL,
  SNO VARCHAR(8) NOT NULL,
  HappenTime DATE NOT NULL,
  Number INT NOT NULL,
  PRIMARY KEY (GoodsNO, SNO),
  CONSTRAINT fk_salebill_goods FOREIGN KEY (GoodsNO)
    REFERENCES Goods (GoodsNO),
  CONSTRAINT fk_salebill_student FOREIGN KEY (SNO)
    REFERENCES Student (SNO),
  CONSTRAINT chk_salebill_range CHECK (Number BETWEEN 0 AND 100)
) ENGINE=InnoDB;

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
