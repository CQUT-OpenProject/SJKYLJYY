-- MySQL dump 10.13  Distrib 8.4.11, for macos27.0 (arm64)
--
-- Host: localhost    Database: SuperMarket_EXP_2
-- ------------------------------------------------------
-- Server version	8.4.11

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `SuperMarket_EXP_2`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `SuperMarket_EXP_2` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `SuperMarket_EXP_2`;

--
-- Table structure for table `Category`
--

DROP TABLE IF EXISTS `Category`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Category` (
  `CategoryNO` varchar(8) NOT NULL,
  `CategoryName` varchar(30) NOT NULL,
  `Descriptions` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`CategoryNO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Category`
--

LOCK TABLES `Category` WRITE;
/*!40000 ALTER TABLE `Category` DISABLE KEYS */;
INSERT INTO `Category` VALUES ('CN001','咖啡','速溶咖啡，袋装咖啡，咖啡粉'),('CN002','洗发水','袋装、瓶装洗发水'),('CN005','床上用品','被套，枕套，床单');
/*!40000 ALTER TABLE `Category` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Goods`
--

DROP TABLE IF EXISTS `Goods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Goods` (
  `GoodsNO` varchar(8) NOT NULL,
  `SupplierNO` varchar(8) NOT NULL,
  `CategoryNO` varchar(8) NOT NULL,
  `GoodsName` varchar(60) NOT NULL,
  `InPrice` decimal(10,1) NOT NULL,
  `SalePrice` decimal(10,2) NOT NULL,
  `Number` int NOT NULL,
  `ProductTime` date NOT NULL,
  PRIMARY KEY (`GoodsNO`),
  KEY `fk_goods_supplier` (`SupplierNO`),
  KEY `fk_goods_category` (`CategoryNO`),
  CONSTRAINT `fk_goods_category` FOREIGN KEY (`CategoryNO`) REFERENCES `Category` (`CategoryNO`),
  CONSTRAINT `fk_goods_supplier` FOREIGN KEY (`SupplierNO`) REFERENCES `Supplier` (`SupplierNO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Goods`
--

LOCK TABLES `Goods` WRITE;
/*!40000 ALTER TABLE `Goods` DISABLE KEYS */;
/*!40000 ALTER TABLE `Goods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `SaleBill`
--

DROP TABLE IF EXISTS `SaleBill`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `SaleBill` (
  `GoodsNO` varchar(8) NOT NULL,
  `SNO` varchar(8) NOT NULL,
  `HappenTime` date NOT NULL,
  `Number` int NOT NULL,
  PRIMARY KEY (`GoodsNO`,`SNO`),
  KEY `fk_salebill_student` (`SNO`),
  CONSTRAINT `fk_salebill_goods` FOREIGN KEY (`GoodsNO`) REFERENCES `Goods` (`GoodsNO`),
  CONSTRAINT `fk_salebill_student` FOREIGN KEY (`SNO`) REFERENCES `Student` (`SNO`),
  CONSTRAINT `chk_salebill_range` CHECK ((`Number` between 0 and 100))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `SaleBill`
--

LOCK TABLES `SaleBill` WRITE;
/*!40000 ALTER TABLE `SaleBill` DISABLE KEYS */;
/*!40000 ALTER TABLE `SaleBill` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Student`
--

DROP TABLE IF EXISTS `Student`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Student` (
  `SNO` varchar(8) NOT NULL,
  `SName` varchar(30) NOT NULL,
  `BirthYear` smallint NOT NULL,
  `Gender` varchar(2) DEFAULT NULL,
  `College` varchar(10) NOT NULL,
  `Major` varchar(10) NOT NULL,
  `WeiXin` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`SNO`),
  UNIQUE KEY `uq_student_weixin` (`WeiXin`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Student`
--

LOCK TABLES `Student` WRITE;
/*!40000 ALTER TABLE `Student` DISABLE KEYS */;
INSERT INTO `Student` VALUES ('S01','李明',1999,'男','CS','IT','wx001'),('S02','徐好',1998,'女','CS','MIS','wx002'),('S04','闵红',1997,'女','ACC','AC','wx004'),('S05','张小红',1997,'女','ACC','AC','wx005');
/*!40000 ALTER TABLE `Student` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Supplier`
--

DROP TABLE IF EXISTS `Supplier`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Supplier` (
  `SupplierNO` varchar(8) NOT NULL,
  `SupplierName` varchar(60) NOT NULL,
  `Address` varchar(100) NOT NULL,
  `Number` varchar(20) NOT NULL,
  PRIMARY KEY (`SupplierNO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Supplier`
--

LOCK TABLES `Supplier` WRITE;
/*!40000 ALTER TABLE `Supplier` DISABLE KEYS */;
INSERT INTO `Supplier` VALUES ('sup001','卡夫食品','广东佛山','12348768900'),('sup002','久润食品','广东东莞','13248768901'),('sup003','飞鹤食品','重庆解放碑','12648768901'),('sup004','南山日化','重庆南坪','11648768903'),('sup005','缙云日化','重庆北碚','19648768903');
/*!40000 ALTER TABLE `Supplier` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed
