-- 实验一：数据定义。仅用于不存在 SuperMarket 数据库的环境。
-- 不自动删除数据库，也不关闭外键检查。

-- TASK 1
CREATE DATABASE SuperMarket
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE SuperMarket;
SELECT DATABASE() AS current_database;

-- TASK 2
CREATE TABLE Goods (
  GoodsNO VARCHAR(8) NOT NULL,
  SupplierNO VARCHAR(8) NOT NULL,
  CategoryNO VARCHAR(8) NOT NULL,
  GoodsName VARCHAR(60) NOT NULL,
  InPrice FLOAT NOT NULL,
  SalePrice DECIMAL(10,2) NOT NULL,
  Number INT NOT NULL,
  ProductTime DATE NOT NULL,
  CONSTRAINT pk_goods PRIMARY KEY (GoodsNO)
) ENGINE=InnoDB;
-- 两个被引用表按原题在第 5、6 项创建，之后补充外键。
SHOW COLUMNS FROM Goods;

-- TASK 3
CREATE TABLE Student (
  SNO VARCHAR(8) NOT NULL,
  SName VARCHAR(30) NOT NULL,
  BirthYear SMALLINT NOT NULL,
  Gender VARCHAR(2) NOT NULL,
  College VARCHAR(10) NOT NULL,
  Major VARCHAR(10) NOT NULL,
  WeiXin VARCHAR(40),
  CONSTRAINT pk_student PRIMARY KEY (SNO),
  CONSTRAINT uq_student_weixin UNIQUE (WeiXin)
) ENGINE=InnoDB;
SHOW INDEX FROM Student;

-- TASK 4
CREATE TABLE SaleBill (
  GoodsNO VARCHAR(8) NOT NULL,
  SNO VARCHAR(8) NOT NULL,
  HappenTime DATE NOT NULL,
  Number INT NOT NULL,
  CONSTRAINT pk_salebill PRIMARY KEY (GoodsNO, SNO),
  CONSTRAINT fk_salebill_goods FOREIGN KEY (GoodsNO)
    REFERENCES Goods (GoodsNO),
  CONSTRAINT fk_salebill_student FOREIGN KEY (SNO)
    REFERENCES Student (SNO)
) ENGINE=InnoDB;
SHOW CREATE TABLE SaleBill;

-- TASK 5
CREATE TABLE Category (
  CategoryNO VARCHAR(8) NOT NULL,
  CategoryName VARCHAR(30) NOT NULL,
  Descriptions VARCHAR(200),
  CONSTRAINT pk_category PRIMARY KEY (CategoryNO)
) ENGINE=InnoDB;
SHOW COLUMNS FROM Category;

-- TASK 6
CREATE TABLE Supplier (
  SupplierNO VARCHAR(8) NOT NULL,
  SupplierName VARCHAR(60) NOT NULL,
  Address VARCHAR(100) NOT NULL,
  Number VARCHAR(20) NOT NULL,
  CONSTRAINT pk_supplier PRIMARY KEY (SupplierNO)
) ENGINE=InnoDB;
-- Supplier.Number 是电话，必须用字符串保存。
ALTER TABLE Goods
  ADD CONSTRAINT fk_goods_supplier FOREIGN KEY (SupplierNO)
    REFERENCES Supplier (SupplierNO),
  ADD CONSTRAINT fk_goods_category FOREIGN KEY (CategoryNO)
    REFERENCES Category (CategoryNO);
SELECT TABLE_NAME, CONSTRAINT_NAME, COLUMN_NAME,
       REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'SuperMarket'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

-- TASK 7
ALTER TABLE Goods ADD COLUMN QGperiod INT;
SHOW COLUMNS FROM Goods LIKE 'QGperiod';

-- TASK 8
ALTER TABLE Student DROP COLUMN BirthYear;
SHOW COLUMNS FROM Student;

-- TASK 9
ALTER TABLE SaleBill
  ADD CONSTRAINT chk_salebill_positive CHECK (Number > 0);
SELECT CONSTRAINT_NAME, CHECK_CLAUSE
FROM information_schema.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'SuperMarket';

-- TASK 10
ALTER TABLE Student DROP INDEX uq_student_weixin;
SHOW INDEX FROM Student;

-- TASK 11
ALTER TABLE Goods MODIFY COLUMN InPrice DECIMAL(10,1) NOT NULL;
SHOW COLUMNS FROM Goods LIKE 'InPrice';

-- TASK 12
ALTER TABLE SaleBill
  DROP CHECK chk_salebill_positive,
  ADD CONSTRAINT chk_salebill_range CHECK (Number BETWEEN 0 AND 100);
SELECT CONSTRAINT_NAME, CHECK_CLAUSE
FROM information_schema.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'SuperMarket';

-- TASK 13
CREATE UNIQUE INDEX uq_supplier_no ON Supplier (SupplierNO);
-- 主码已经唯一；本索引用于演示题目要求的创建与删除。
SHOW INDEX FROM Supplier;

-- TASK 14
-- Category 没有商品名 GoodsName，依素材按商品种类名 CategoryName 降序。
CREATE UNIQUE INDEX uq_category_no_name
  ON Category (CategoryNO ASC, CategoryName DESC);
SELECT INDEX_NAME, NON_UNIQUE, SEQ_IN_INDEX, COLUMN_NAME, COLLATION
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = 'SuperMarket' AND TABLE_NAME = 'Category'
ORDER BY INDEX_NAME, SEQ_IN_INDEX;

-- TASK 15
DROP INDEX uq_supplier_no ON Supplier;
SHOW INDEX FROM Supplier;
