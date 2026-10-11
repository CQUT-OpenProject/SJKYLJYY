CREATE DATABASE SuperMarket_EXP_2 CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE SuperMarket_EXP_2;
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
