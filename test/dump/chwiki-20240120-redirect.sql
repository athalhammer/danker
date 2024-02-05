-- MySQL dump 10.19  Distrib 10.3.38-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: db1166    Database: chwiki
-- ------------------------------------------------------
-- Server version	10.4.26-MariaDB-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `redirect`
--

DROP TABLE IF EXISTS `redirect`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `redirect` (
  `rd_from` int(8) unsigned NOT NULL DEFAULT 0,
  `rd_namespace` int(11) NOT NULL DEFAULT 0,
  `rd_title` varbinary(255) NOT NULL DEFAULT '',
  `rd_interwiki` varbinary(32) DEFAULT NULL,
  `rd_fragment` varbinary(255) DEFAULT NULL,
  PRIMARY KEY (`rd_from`),
  KEY `rd_ns_title` (`rd_namespace`,`rd_title`,`rd_from`)
) ENGINE=InnoDB DEFAULT CHARSET=binary;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `redirect`
--

/*!40000 ALTER TABLE `redirect` DISABLE KEYS */;
INSERT INTO `redirect` VALUES (1518,0,'Usuario_Discusión:Javier_Carro','es',''),(1594,0,'User:Sirius_Zwarts_Bot','en',''),(1934,2,'Bastique','',''),(1942,0,'User:GHe','en',''),(2034,0,'user_talk:purodha','ksh',''),(2058,3,'Multichill','',''),(2139,10,'Funas','',''),(2148,10,'Funas','',''),(2228,0,'Fanohge_Chamoru','',''),(2238,0,'Hånom','',''),(2325,0,'Hågat','',''),(2356,0,'Hågat','',''),(2384,0,'Tutuhan','',''),(2385,0,'Tutuhan','',''),(2386,0,'Yoña','',''),(2387,0,'Assan-Ma\'ina','',''),(2388,0,'Barigåda','',''),(2389,0,'Chalan_Pågu-Otdot','',''),(2390,0,'Dedidu','',''),(2391,0,'Inalåhan','',''),(2392,0,'Malesso\'','',''),(2393,0,'Mongmong-To\'to-Maite','',''),(2394,0,'Sinahåña','',''),(2395,0,'Talo\'fo\'fo\'','',''),(2396,0,'Tamuneng','',''),(2398,0,'Yigu','',''),(2428,0,'Islas_Mariånas','',''),(2434,0,'Fanhaluman','',''),(2435,1,'Fanhaluman','',''),(2441,4,'Fanhaluman_komunida','',''),(2442,4,'Fanhaluman_komunida','',''),(2449,0,'User:Brunoy_Anastasiya_Seryozhenko','m',''),(2462,0,'Hånom','',''),(2465,0,'Tåsi','',''),(2466,0,'Tåsi','',''),(2483,0,'Notte_Mariånas','',''),(2484,0,'Farallon_de_Pajaros','',''),(2485,0,'Islas_Mariånas','',''),(2486,0,'Luta','',''),(2487,0,'Aguiguan','',''),(2488,0,'Aguiguan','',''),(2489,0,'Barigåda','',''),(2491,0,'Tini\'an','',''),(2494,0,'Si_Sirena','',''),(2499,0,'Anatåhån','',''),(2502,0,'Guåhan','',''),(2506,3,'SpBot','',''),(2542,10,'Documentation','',''),(2546,0,'Leonardo_da_Vinci','',''),(2548,0,'Fetnando_Magallanes','',''),(2549,0,'Fetnando_Magallanes','',''),(2550,0,'Militåt','',''),(2553,0,'Pås','',''),(2558,0,'Matematika','',''),(2559,0,'Matematika','',''),(2568,0,'Johann_Sebastian_Bach','',''),(2569,0,'Johann_Sebastian_Bach','',''),(2577,0,'Såkkan','',''),(2578,0,'Såkkan','',''),(2579,0,'Såkkan','',''),(2580,0,'Såkkan','',''),(2581,0,'Såkkan','',''),(2582,0,'Såkkan','',''),(2583,0,'Såkkan','',''),(2584,0,'Såkkan','',''),(2590,4,'Fanhaluman_komunida','',''),(2595,2,'WikiDreamer','',''),(2597,2,'WikiDreamer','',''),(2639,3,'とある白い猫','',''),(2663,2,'JaynFM','',''),(2664,2,'JaynFM','',''),(2671,2,'WikimediaNotifier','',''),(2679,0,'Brukardiskusjon:Harald_Khan','nn',''),(2696,0,'User:Julian_Mendez','en',''),(2697,0,'User_talk:Julian_Mendez','en',''),(2699,0,'User_talk:Synthebot','en',''),(2715,0,'Käyttäjä:Kallerna','fi',''),(2731,0,'Korisnik:Seha','bs',''),(2802,0,'User_talk:Erwin','m',''),(2806,4,'Fanhaluman_komunida','',''),(2837,14,'China','',''),(2867,0,'Fanhaluman','',''),(2988,0,'Pichilemu,_Chile','',''),(2992,0,'Pichilemu,_Chile','',''),(3001,10,'Naan_muna\'sesetbi','',''),(3002,11,'Naan_muna\'sesetbi','',''),(3003,0,'user:טבעת-זרם','en',''),(3010,0,'Pichilemu,_Chile','',''),(3021,0,'Nohi_Dhoir_Khroilehski','',''),(3030,2,'BOTijo','',''),(3040,2,'Vanished_user_24kwjf10h32h','',''),(3041,3,'Vanished_user_24kwjf10h32h','',''),(3063,0,'Nohi_Dhoir_Khroilehski','',''),(3069,2,'Diego_Grez_Bot','',''),(3072,0,'Dong_Hoi','',''),(3100,0,'Nohi_Dhoir_Khroilehski','',''),(3104,0,'Fetnando_Magallanes','',''),(3105,1,'Fetnando_Magallanes','',''),(3116,0,'Ho_Chi_Minh','',''),(3117,0,'Dangkulo','',''),(3120,2,'Fr33kman','',''),(3124,2,'Magister_Mathematicae','',''),(3181,0,'Santa_Rita','',''),(3192,3,'Tjmoel','',''),(3193,3,'Tjmoel','',''),(3219,3,'Wikitanvir','',''),(3321,3,'Crochet.david','',''),(3336,2,'とある白い猫','',''),(3337,3,'とある白い猫','',''),(3385,3,'Caypartis','',''),(3395,2,'Der_Buckesfelder','',''),(3396,3,'Der_Buckesfelder','',''),(3448,0,'Banovci_(Nijemci)','',''),(3501,0,'User:JohnnyWiki','en',''),(3544,2,'Vogone','',''),(3629,0,'User_talk:DeltaQuad','m',''),(3631,0,'User_talk:محمد_شعیب','ur',''),(3632,0,'User_talk:محمد_شعیب','ur',''),(3650,3,'Addshore','',''),(3693,0,'User:QuiteUnusual','m',''),(3694,0,'User_talk:QuiteUnusual','m',''),(3696,0,'Usuario_Discusión:Kizar','es',''),(3741,0,'User:Liuxinyu970226','d',''),(3848,2,'Rxy','',''),(3894,2,'Jalexander-WMF','',''),(3909,2,'-revi','',''),(3910,3,'-revi','',''),(3925,2,'Allan_Aguilar','',''),(3926,3,'Allan_Aguilar','',''),(3943,3,'Sir_Lestaty_de_Lioncourt','',''),(3944,3,'Sir_Lestaty_de_Lioncourt','',''),(3972,2,'*SM*','',''),(3973,3,'*SM*','',''),(3975,0,'User_talk:Unapersona','m',''),(3985,2,'Caliburn','',''),(3986,3,'Caliburn','',''),(3988,2,'Vanished_user_24kwjf10h32h','',''),(4079,2,'Azariv-WMF','',''),(4116,2,'Vanished_user_24kwjf10h32h','',''),(4117,3,'Vanished_user_24kwjf10h32h','',''),(4123,3,'Avicennasis','',''),(4253,10,'Infobox_country','',''),(4255,10,'Native_name','',''),(4340,10,'Citation_Style_documentation','',''),(4504,10,'Max','',''),(4610,2,'Razr_Nation','',''),(4615,0,'Notte_Mariånas','',''),(4619,2,'SimmeD','',''),(4863,0,'User:Nhóm_Thông_tin_Wikimedia','m',''),(4864,2,'SimmeD','',''),(4882,2,'OMT5500','',''),(4887,2,'~riley','',''),(4897,0,'User_talk:HakanIST','m',''),(4916,4,'Fanhaluman_komunida','',''),(4918,2,'V(g)','',''),(4919,3,'V(g)','',''),(4941,2,'Codeks','',''),(4955,0,'Ludwig_van_Beethoven','',''),(4969,0,'Estados_Unidus','',''),(5091,3,'*Youngjin','',''),(5121,0,'Mandala','',''),(5128,3,'Stïnger','',''),(5131,0,'Topolino','',''),(5195,2,'OMT5500','',''),(5202,0,'Pottugés','',''),(5226,2,'Vanished_user_24kwjf10h32h','',''),(5227,3,'123uhjsakddsa89321l3','',''),(5228,2,'Lofty_abyss','',''),(5233,2,'Expósito','',''),(5254,2,'Waldyrious','',''),(5258,2,'Yethrosh','',''),(5259,3,'Yethrosh','',''),(5322,0,'User_talk:Killarnee','meta',''),(5344,3,'Ameisenigel','',''),(5353,3,'Klaas_van_Buiten','',''),(5370,2,'Mazbel','',''),(5375,0,'Estados_Unidus','',''),(5386,2,'AmandaNP','',''),(5387,3,'AmandaNP','',''),(5389,2,'Ainz_Ooal_Gown/minerva.js','',''),(5428,0,'Guåhan','',''),(5429,14,'Guåhan','',''),(5430,10,'Guåhan','',''),(5431,0,'Unibetsedåt_Guåhan','',''),(5432,0,'Unibetsedåt_Guåhan','',''),(5436,0,'User_talk:InternetArchiveBot','meta',''),(5437,2,'Snævar','',''),(5486,3,'Relly_Komaruzaman','',''),(5593,2,'MarcGarver','',''),(5594,3,'MarcGarver','',''),(5608,2,'Brubaker610','',''),(5652,0,'Kongrés_Internasional_Matematikawan_2026','',''),(5667,0,'David_Woodard','',''),(5668,2,'Alextejthompson','',''),(5746,0,'Lengguåhi','',''),(5793,0,'Listan_åttikulu_siha_na_debidi_para_u_guaha_gi_Wikipedia_Chamoru','',''),(5838,0,'Fino\'_Refaluwasch','','');
/*!40000 ALTER TABLE `redirect` ENABLE KEYS */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-01-20 10:15:16
