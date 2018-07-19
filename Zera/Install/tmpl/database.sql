-- MySQL dump 10.13  Distrib 5.7.17, for macos10.12 (x86_64)
--
-- Host: localhost    Database: zera_dev
-- ------------------------------------------------------
-- Server version	5.7.21

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `access_paths`
--

DROP TABLE IF EXISTS `access_paths`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `access_paths` (
  `url` varchar(145) NOT NULL,
  `workspace` varchar(5) DEFAULT NULL,
  `name` varchar(45) DEFAULT NULL,
  `description` varchar(254) DEFAULT NULL,
  PRIMARY KEY (`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `access_paths`
--

LOCK TABLES `access_paths` WRITE;
/*!40000 ALTER TABLE `access_paths` DISABLE KEYS */;
INSERT INTO `access_paths` VALUES ('/AdminBlog','Admin','Blog','Add, edit or delete Blog entries.'),('/AdminPages','Admin','Pages','Add, edit or delete wesite pages.'),('/AdminUsers','Admin','Users','Add, edit or delete website users.'),('/MKUsers','User','Users','Add, edit or delete users.');
/*!40000 ALTER TABLE `access_paths` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `category_id` int(11) NOT NULL,
  `parent_id` int(11) NOT NULL DEFAULT '0',
  `module` varchar(45) DEFAULT NULL,
  `category` varchar(45) DEFAULT NULL,
  `description` text,
  `sort_order` int(11),
  PRIMARY KEY (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
INSERT INTO `categories` VALUES (1,0,'Docs','Instalation',NULL),(2,0,'Docs','Quick Start',NULL),(3,0,'Docs','Advanced Guides',NULL),(4,0,'Docs','Reference',NULL),(5,0,'Docs','Contribute',NULL),(6,0,'Docs','FAQ',NULL);
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entries`
--

DROP TABLE IF EXISTS `entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `entries` (
  `entry_id` int(11) NOT NULL AUTO_INCREMENT,
  `module` varchar(45) DEFAULT NULL,
  `title` varchar(245) DEFAULT NULL,
  `keywords` varchar(245) DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  `added_by` int(11) DEFAULT NULL,
  `added_on` date DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_on` date DEFAULT NULL,
  `views` int(11) NOT NULL DEFAULT '0',
  `user_id` int(11) DEFAULT NULL,
  `active` int(1) DEFAULT '0',
  `url` varchar(245) DEFAULT NULL,
  `description` text,
  `content` mediumtext,
  `display_options` text,
  PRIMARY KEY (`entry_id`),
  FULLTEXT KEY `TKDD_FI` (`title`,`keywords`,`description`,`content`)
) ENGINE=MyISAM AUTO_INCREMENT=28 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entries`
--

LOCK TABLES `entries` WRITE;
/*!40000 ALTER TABLE `entries` DISABLE KEYS */;
/*!40000 ALTER TABLE `entries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `entries_categories`
--

DROP TABLE IF EXISTS `entries_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `entries_categories` (
  `category_id` int(11) NOT NULL,
  `entry_id` int(11) NOT NULL,
  `sort_order` int(11) DEFAULT NULL,
  PRIMARY KEY (`category_id`,`entry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `entries_categories`
--

LOCK TABLES `entries_categories` WRITE;
/*!40000 ALTER TABLE `entries_categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `entries_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menus`
--

DROP TABLE IF EXISTS `menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menus` (
  `module_key` varchar(45) NOT NULL,
  `group` varchar(45) DEFAULT NULL,
  `url` varchar(145) DEFAULT NULL,
  `name` varchar(45) DEFAULT NULL,
  `icon` varchar(245) DEFAULT NULL,
  `sort_order` int(2) DEFAULT NULL,
  PRIMARY KEY (`module_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menus`
--

LOCK TABLES `menus` WRITE;
/*!40000 ALTER TABLE `menus` DISABLE KEYS */;
INSERT INTO `menus` VALUES ('Blog','Admin','/AdminBlog','Blog',NULL,NULL),('Docs','Admin','/AdminDocs','Docs',NULL,NULL),('StaticPages','Admin','/AdminPages','Pages','',NULL);
/*!40000 ALTER TABLE `menus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` char(32) NOT NULL,
  `a_session` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions_msg`
--

DROP TABLE IF EXISTS `sessions_msg`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions_msg` (
  `session_id` char(32) NOT NULL,
  `date` datetime NOT NULL,
  `type` varchar(30) NOT NULL,
  `msg` text NOT NULL,
  PRIMARY KEY (`session_id`,`date`,`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions_msg`
--

LOCK TABLES `sessions_msg` WRITE;
/*!40000 ALTER TABLE `sessions_msg` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions_msg` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(145) DEFAULT NULL,
  `password` varchar(145) DEFAULT NULL,
  `name` varchar(145) DEFAULT NULL,
  `last_login_on` timestamp NULL DEFAULT NULL,
  `password_recovery_expires` datetime DEFAULT NULL,
  `password_recovery_key` varchar(45) DEFAULT NULL,
  `created_on` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `account_validated` int(1) DEFAULT '0',
  `is_admin` int(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email_U` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_access_paths`
--

DROP TABLE IF EXISTS `users_access_paths`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_access_paths` (
  `user_id` int(11) NOT NULL,
  `url` varchar(145) NOT NULL,
  PRIMARY KEY (`user_id`,`url`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_access_paths`
--

LOCK TABLES `users_access_paths` WRITE;
/*!40000 ALTER TABLE `users_access_paths` DISABLE KEYS */;
/*!40000 ALTER TABLE `users_access_paths` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

--
-- Table structure for table `banners_groups`
--
DROP TABLE IF EXISTS banners_groups;
CREATE TABLE `banners_groups` (
  `group_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `group_type` varchar(45) NOT NULL,
  PRIMARY KEY (`group_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

--
-- Table structure for table `banners_groups`
--
DROP TABLE IF EXISTS banners;
CREATE TABLE `banners` (
  `banner_id` int(11) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `name` varchar(45) NOT NULL,
  `url` varchar(250) NOT NULL,
  `media` varchar(150) DEFAULT NULL,
  `code` text,
  `active` int(1) NOT NULL,
  `publish_from` date DEFAULT NULL,
  `publish_to` date DEFAULT NULL,
  `sort_order` int(4) NOT NULL,
  PRIMARY KEY (`banner_id`)
) ENGINE=MyISAM AUTO_INCREMENT=13 DEFAULT CHARSET=utf8;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-04-27 16:28:10
