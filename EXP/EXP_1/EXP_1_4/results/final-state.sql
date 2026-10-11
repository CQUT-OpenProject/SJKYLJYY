-- MySQL dump 10.13  Distrib 8.4.11, for macos27.0 (arm64)
--
-- Host: localhost    Database: SuperMarket_EXP_4
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
-- Current Database: `SuperMarket_EXP_4`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `SuperMarket_EXP_4` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `SuperMarket_EXP_4`;

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
INSERT INTO `Goods` VALUES ('GN0001','sup001','CN001','优乐美奶茶',2.5,3.50,100,'2019-12-20'),('GN0002','sup002','CN001','雀巢咖啡',4.0,5.80,50,'2017-06-08'),('GN0005','sup003','CN002','飘柔洗发水',15.0,19.80,65,'2019-05-29'),('GN0007','sup005','CN005','小绵羊被套',120.0,150.00,28,'2019-11-22');
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
INSERT INTO `SaleBill` VALUES ('GN0001','S01','2020-06-09',3),('GN0001','S02','2020-05-03',1),('GN0001','S03','2020-04-07',1),('GN0002','S02','2018-05-08',2),('GN0002','S05','2019-06-26',2),('GN0005','S05','2020-06-01',1);
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
INSERT INTO `Student` VALUES ('S01','李明',1999,'男','CS','IT','wx001'),('S02','徐慧慧',1998,'女','CS','MIS','wx002'),('S03','伍民',1996,'男','CS','MIS','wx003'),('S04','闵红',1997,'女','ACC','AC','wx004'),('S05','张小红',1997,'女','ACC','AC','wx005'),('s10','周瑜',1999,NULL,'CS','IT','wx010');
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

--
-- Temporary view structure for view `v_age`
--

DROP TABLE IF EXISTS `v_age`;
/*!50001 DROP VIEW IF EXISTS `v_age`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_age` AS SELECT
 1 AS `SNO`,
 1 AS `SName`,
 1 AS `College`,
 1 AS `Major`,
 1 AS `Age`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_com`
--

DROP TABLE IF EXISTS `v_com`;
/*!50001 DROP VIEW IF EXISTS `v_com`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_com` AS SELECT
 1 AS `College`,
 1 AS `StudentCount`,
 1 AS `AvgAge`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_goods`
--

DROP TABLE IF EXISTS `v_goods`;
/*!50001 DROP VIEW IF EXISTS `v_goods`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_goods` AS SELECT
 1 AS `CategoryNO`,
 1 AS `CategoryName`,
 1 AS `GoodsCount`,
 1 AS `AvgPrice`,
 1 AS `MinStock`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_mis`
--

DROP TABLE IF EXISTS `v_mis`;
/*!50001 DROP VIEW IF EXISTS `v_mis`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_mis` AS SELECT
 1 AS `SNO`,
 1 AS `SName`,
 1 AS `BirthYear`,
 1 AS `Gender`,
 1 AS `College`,
 1 AS `Major`,
 1 AS `WeiXin`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_s_consume`
--

DROP TABLE IF EXISTS `v_s_consume`;
/*!50001 DROP VIEW IF EXISTS `v_s_consume`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_s_consume` AS SELECT
 1 AS `SNO`,
 1 AS `SName`,
 1 AS `College`,
 1 AS `GoodsKinds`,
 1 AS `CostTotal`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_ssg`
--

DROP TABLE IF EXISTS `v_ssg`;
/*!50001 DROP VIEW IF EXISTS `v_ssg`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_ssg` AS SELECT
 1 AS `SNO`,
 1 AS `SName`,
 1 AS `GoodsName`,
 1 AS `SalePrice`,
 1 AS `Number`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_su_good`
--

DROP TABLE IF EXISTS `v_su_good`;
/*!50001 DROP VIEW IF EXISTS `v_su_good`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_su_good` AS SELECT
 1 AS `SupplierNO`,
 1 AS `SupplierName`,
 1 AS `Phone`,
 1 AS `Address`,
 1 AS `GoodsCount`,
 1 AS `StockTotal`,
 1 AS `AvgInPrice`*/;
SET character_set_client = @saved_cs_client;

--
-- Current Database: `SuperMarket_EXP_4`
--

USE `SuperMarket_EXP_4`;

--
-- Final view structure for view `v_age`
--

/*!50001 DROP VIEW IF EXISTS `v_age`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_age` AS select `student`.`SNO` AS `SNO`,`student`.`SName` AS `SName`,`student`.`College` AS `College`,`student`.`Major` AS `Major`,(year(curdate()) - `student`.`BirthYear`) AS `Age` from `student` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_com`
--

/*!50001 DROP VIEW IF EXISTS `v_com`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_com` AS select `student`.`College` AS `College`,count(0) AS `StudentCount`,cast(avg((year(curdate()) - `student`.`BirthYear`)) as decimal(6,2)) AS `AvgAge` from `student` group by `student`.`College` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_goods`
--

/*!50001 DROP VIEW IF EXISTS `v_goods`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_goods` AS select `c`.`CategoryNO` AS `CategoryNO`,`c`.`CategoryName` AS `CategoryName`,count(`g`.`GoodsNO`) AS `GoodsCount`,cast(avg(`g`.`SalePrice`) as decimal(10,2)) AS `AvgPrice`,min(`g`.`Number`) AS `MinStock` from (`category` `c` left join `goods` `g` on((`g`.`CategoryNO` = `c`.`CategoryNO`))) group by `c`.`CategoryNO`,`c`.`CategoryName` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_mis`
--

/*!50001 DROP VIEW IF EXISTS `v_mis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_mis` AS select `student`.`SNO` AS `SNO`,`student`.`SName` AS `SName`,`student`.`BirthYear` AS `BirthYear`,`student`.`Gender` AS `Gender`,`student`.`College` AS `College`,`student`.`Major` AS `Major`,`student`.`WeiXin` AS `WeiXin` from `student` where (`student`.`Major` = 'MIS') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_s_consume`
--

/*!50001 DROP VIEW IF EXISTS `v_s_consume`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_s_consume` AS select `s`.`SNO` AS `SNO`,`s`.`SName` AS `SName`,`s`.`College` AS `College`,count(distinct `b`.`GoodsNO`) AS `GoodsKinds`,cast(coalesce(sum((`b`.`Number` * `g`.`SalePrice`)),0) as decimal(12,2)) AS `CostTotal` from ((`student` `s` left join `salebill` `b` on((`b`.`SNO` = `s`.`SNO`))) left join `goods` `g` on((`g`.`GoodsNO` = `b`.`GoodsNO`))) group by `s`.`SNO`,`s`.`SName`,`s`.`College` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_ssg`
--

/*!50001 DROP VIEW IF EXISTS `v_ssg`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_ssg` AS select `s`.`SNO` AS `SNO`,`s`.`SName` AS `SName`,`g`.`GoodsName` AS `GoodsName`,`g`.`SalePrice` AS `SalePrice`,`b`.`Number` AS `Number` from ((`student` `s` join `salebill` `b` on((`b`.`SNO` = `s`.`SNO`))) join `goods` `g` on((`g`.`GoodsNO` = `b`.`GoodsNO`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_su_good`
--

/*!50001 DROP VIEW IF EXISTS `v_su_good`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_su_good` AS select `s`.`SupplierNO` AS `SupplierNO`,`s`.`SupplierName` AS `SupplierName`,`s`.`Number` AS `Phone`,`s`.`Address` AS `Address`,count(`g`.`GoodsNO`) AS `GoodsCount`,sum(`g`.`Number`) AS `StockTotal`,cast(avg(`g`.`InPrice`) as decimal(10,2)) AS `AvgInPrice` from (`supplier` `s` join `goods` `g` on((`g`.`SupplierNO` = `s`.`SupplierNO`))) group by `s`.`SupplierNO`,`s`.`SupplierName`,`s`.`Number`,`s`.`Address` having (avg(`g`.`InPrice`) > 10) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed
