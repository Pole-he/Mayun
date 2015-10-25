/*
SQLyog Ultimate v11.24 (32 bit)
MySQL - 5.6.11 : Database - mayun
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`mayun` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `mayun`;

/*Table structure for table `tb_message` */

DROP TABLE IF EXISTS `tb_message`;

CREATE TABLE `tb_message` (
  `id` bigint(32) NOT NULL AUTO_INCREMENT,
  `from_user_id` bigint(32) DEFAULT NULL,
  `content` text CHARACTER SET utf8mb4,
  `code_url` varchar(255) CHARACTER SET utf8 DEFAULT NULL COMMENT '二维码URL',
  `link_url` varchar(255) CHARACTER SET utf8 DEFAULT NULL COMMENT '资源URL',
  `to_username` varchar(100) CHARACTER SET utf8 DEFAULT NULL,
  `to_mobile` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `tb_message` */

insert  into `tb_message`(`id`,`from_user_id`,`content`,`code_url`,`link_url`,`to_username`,`to_mobile`) values (1,1,'这是内容','123456','http://7xnrd6.com1.z0.glb.clouddn.com/Fm6OYJNao6z5_C3r-JtzK_skcFpu','哈哈','1234569988'),(2,1,'这是内容','123456','http://7xnrd6.com1.z0.glb.clouddn.com/Fm6OYJNao6z5_C3r-JtzK_skcFpu','哈哈','1234569988'),(3,1,'这是内容','123456',NULL,'哈哈','1234569988'),(4,1,'这是内容','123456',NULL,'哈哈','1234569988'),(5,3,'☀☁☁☁☁☁\n☁☁✈✈☁☁\n☁✈☁☁✈☁\n✈☁☁☁☁✈\n☁☁✈✈☁☁\n☁✈☁☁✈☁\n✈☁☁☁☁✈\n☁☁✈✈☁☁\n☁✈☁☁✈☁\n✈☁☁☁☁✈\n☁☁✈✈☁☁\n☁✈☁☁✈☁\n✈☁☁☁☁✈\n☁☁☁☁☁☁\n☁  全程高能  ☁\n☁☁☁☁☁☁\n','http://weixin.qq.com/r/cHVbQ2LEvD-DrSYg9yBi',NULL,'陈龙浩','13349932328'),(7,1,'这是内容','123456',NULL,'哈哈','1234569988'),(8,1,'这是内容','123456',NULL,'哈哈','1234569988'),(9,1,'这是内容','123456',NULL,'哈哈','1234569988'),(10,1,'这是内容','123456',NULL,'哈哈','1234569988'),(11,1,'个咯了接我','http://weixin.qq.com/r/cHVbQ2LEvD-DrSYg9yBi',NULL,'鲍泽','15007184046'),(12,3,'☀☁☁☁☁☁\n☁☁✈✈☁☁\n☁✈☁☁✈☁\n✈☁☁☁☁✈\n☁☁✈✈☁☁\n☁✈☁☁✈☁\n✈☁☁☁☁✈\n☁☁✈✈☁☁\n☁✈☁☁✈☁\n✈☁☁☁☁✈\n☁☁✈✈☁☁\n☁✈☁☁✈☁\n✈☁☁☁☁✈\n☁☁☁☁☁☁\n☁  全程高能  ☁\n☁☁☁☁☁☁\n','http://weixin.qq.com/r/cHVbQ2LEvD-DrSYg9yBi',NULL,'鲍泽','15007184046'),(13,3,':sob::heart_eyes::heart_eyes::heart_eyes::heart_eyes::sweat::stuck_out_tongue_winking_eye:','http://weixin.qq.com/r/cHVbQ2LEvD-DrSYg9yBi',NULL,'蔡明星','15007184046'),(14,4,'哈哈','http://weixin.qq.com/r/cHVbQ2LEvD-DrSYg9yBi',NULL,'何飞','15007184046'),(15,4,'哈哈','http://weixin.qq.com/r/cHVbQ2LEvD-DrSYg9yBi',NULL,'何飞','15007184046'),(16,4,'哈哈','http://weixin.qq.com/r/cHVbQ2LEvD-DrSYg9yBi',NULL,'何飞','15007184046'),(17,4,'哈哈','http://weixin.qq.com/r/cHVbQ2LEvD-DrSYg9yBi',NULL,'何飞','15007184046'),(18,4,'哈哈','http://weixin.qq.com/r/cHVbQ2LEvD-DrSYg9yBi',NULL,'何飞','15007184046'),(19,3,'?','http://weixin.qq.com/r/cHVbQ2LEvD-DrSYg9yBi',NULL,'宝马销售','15007184046'),(20,4,'哥','http://weixin.qq.com/r/cHVbQ2LEvD-DrSYg9yBi',NULL,'何飞','15007184046'),(21,3,'????','http://weixin.qq.com/r/cHVbQ2LEvD-DrSYg9yBi',NULL,'锤子','15007184046'),(22,4,'可能','http://weixin.qq.com/r/cHVbQ2LEvD-DrSYg9yBi',NULL,'何飞','15007184046'),(23,3,'哈哈','http://weixin.qq.com/r/cHVbQ2LEvD-DrSYg9yBi',NULL,'Eric','15926269672'),(24,3,'???????','http://weixin.qq.com/r/cHVbQ2LEvD-DrSYg9yBi',NULL,'鲍泽','15007184046'),(25,4,'蛋糕','http://qr.weibo.cn/g/1q87tj',NULL,'何飞','15007184046'),(26,4,'哈哈','http://qr.weibo.cn/g/1q87tj',NULL,'叶松','13476107753');

/*Table structure for table `tb_resource` */

DROP TABLE IF EXISTS `tb_resource`;

CREATE TABLE `tb_resource` (
  `id` bigint(32) NOT NULL AUTO_INCREMENT,
  `message_id` bigint(32) DEFAULT NULL,
  `link_url` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `type` int(2) DEFAULT NULL COMMENT '文件类型0：图片1：视频',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=41 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `tb_resource` */

insert  into `tb_resource`(`id`,`message_id`,`link_url`,`type`) values (1,3,'http://7xnrd6.com1.z0.glb.clouddn.com/Fm6OYJNao6z5_C3r-JtzK_skcFpu',NULL),(2,3,'http://7xnrd6.com1.z0.glb.clouddn.com/Fm6OYJNao6z5_C3r-JtzK_skcFpu',NULL),(3,4,'http://7xnrd6.com1.z0.glb.clouddn.com/Fm6OYJNao6z5_C3r-JtzK_skcFpu',NULL),(4,4,'http://7xnrd6.com1.z0.glb.clouddn.com/Fm6OYJNao6z5_C3r-JtzK_skcFpu',NULL),(5,5,'http://7xnrd6.com1.z0.glb.clouddn.com/FmO5PfNou2HYtLGWMNnQSSFDu_CO',NULL),(6,5,'http://7xnrd6.com1.z0.glb.clouddn.com/FugXsdvsbogoEhNGFDw3nZASohRB',NULL),(7,5,'http://7xnrd6.com1.z0.glb.clouddn.com/Fhg9JS4diCI9y_pjv6DqIQsjvo14',NULL),(8,5,'http://7xnrd6.com1.z0.glb.clouddn.com/FnFBaZ_sClc2XXW0lYkqhcUj-XDS',NULL),(9,5,'http://7xnrd6.com1.z0.glb.clouddn.com/Fsroj18E7m7vWY41WlgRQk6yvayJ',NULL),(10,5,'http://7xnrd6.com1.z0.glb.clouddn.com/罗莱家纺_高清.mp4',NULL),(11,6,'http://7xnrd6.com1.z0.glb.clouddn.com/FsH7m5M0S6Yl5ri-XNtQ-lO_dm51',NULL),(12,6,'http://7xnrd6.com1.z0.glb.clouddn.com/FoH2vdUMjHUrjqtniqa9WmGROSvr',NULL),(13,7,'http://7xnrd6.com1.z0.glb.clouddn.com/Fm6OYJNao6z5_C3r-JtzK_skcFpu',NULL),(14,7,'http://7xnrd6.com1.z0.glb.clouddn.com/FmXvvuHkt5hoi_vI2iyvH0Qi7caw',NULL),(15,8,'http://7xnrd6.com1.z0.glb.clouddn.com/Fm6OYJNao6z5_C3r-JtzK_skcFpu',NULL),(16,8,'http://7xnrd6.com1.z0.glb.clouddn.com/FmXvvuHkt5hoi_vI2iyvH0Qi7caw',NULL),(17,9,'http://7xnrd6.com1.z0.glb.clouddn.com/Fm6OYJNao6z5_C3r-JtzK_skcFpu',NULL),(18,9,'http://7xnrd6.com1.z0.glb.clouddn.com/FmXvvuHkt5hoi_vI2iyvH0Qi7caw',NULL),(19,10,'http://7xnrd6.com1.z0.glb.clouddn.com/Fm6OYJNao6z5_C3r-JtzK_skcFpu',0),(20,10,'http://7xnrd6.com1.z0.glb.clouddn.com/FmXvvuHkt5hoi_vI2iyvH0Qi7caw',1),(21,11,'http://7xnrd6.com1.z0.glb.clouddn.com/FiNXfz7JcO5DSVWVDj6twhRpdJzs',0),(22,11,'http://7xnrd6.com1.z0.glb.clouddn.com/FhH2f0GUQkBSKRZbEECyDhiu9gJq',1),(23,12,'http://7xnrd6.com1.z0.glb.clouddn.com/FiC5qp8gW8cqTXut2iEanultd-bf',0),(24,12,'http://7xnrd6.com1.z0.glb.clouddn.com/Fr2CdQsDoJD0y7ihFCqfKUFQMv-J',1),(25,13,'http://7xnrd6.com1.z0.glb.clouddn.com/FkuuqzlPasa63TXvxJXyUFUnumHK',0),(26,14,'http://7xnrd6.com1.z0.glb.clouddn.com/lg66ZS341k5TF0_VTdi7fuDnA1fB',0),(27,15,'http://7xnrd6.com1.z0.glb.clouddn.com/ltbLsutRQearad5pFrqzdiux_rnz',0),(28,16,'http://7xnrd6.com1.z0.glb.clouddn.com/luR9Phb1sFS7hNhOoXj8zhvTqlVZ',0),(29,17,'http://7xnrd6.com1.z0.glb.clouddn.com/Fli36za0LSprBinGWR5l5iLjS9aM',0),(30,18,'http://7xnrd6.com1.z0.glb.clouddn.com/Fli36za0LSprBinGWR5l5iLjS9aM',0),(31,19,'http://7xnrd6.com1.z0.glb.clouddn.com/FpmDabzVxz6eWH3JtmLk6VDnlFQB',0),(32,21,'http://7xnrd6.com1.z0.glb.clouddn.com/FtOyEqjseMj90XCSoe-hMFpLvHjB',0),(33,22,'http://7xnrd6.com1.z0.glb.clouddn.com/FhiOqAtWcRPgE2Qa4PUWPY4FX7Z3',0),(34,23,'http://7xnrd6.com1.z0.glb.clouddn.com/Fur0pf_FFwWlMZM3V0a3rWXdxSrt',0),(35,23,'http://7xnrd6.com1.z0.glb.clouddn.com/FtbU4bYINaYrIQSxNbe4MwamF7ad',0),(36,23,'http://7xnrd6.com1.z0.glb.clouddn.com/Fl0N0Mt9U9_wbnZjeNjWREAEgnms',0),(37,23,'http://7xnrd6.com1.z0.glb.clouddn.com/FgzdCnQ3AwgxK88GBozwO0uzkCzd',0),(38,24,'http://7xnrd6.com1.z0.glb.clouddn.com/FpmDabzVxz6eWH3JtmLk6VDnlFQB',0),(39,25,'http://7xnrd6.com1.z0.glb.clouddn.com/FqmbA8zc13dv0QMNxeWmcXBBv-fb',0),(40,26,'http://7xnrd6.com1.z0.glb.clouddn.com/Fricvm2kT-hA82jApsg9dsa-0Do7',0);

/*Table structure for table `tb_user` */

DROP TABLE IF EXISTS `tb_user`;

CREATE TABLE `tb_user` (
  `id` bigint(32) NOT NULL AUTO_INCREMENT,
  `username` varchar(50) CHARACTER SET utf8 DEFAULT NULL,
  `avatar` varchar(200) CHARACTER SET utf8 DEFAULT NULL,
  `auth_token` varchar(200) CHARACTER SET utf8 DEFAULT NULL,
  `mobile` varchar(20) CHARACTER SET utf8 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `tb_user` */

insert  into `tb_user`(`id`,`username`,`avatar`,`auth_token`,`mobile`) values (1,'叶松','123456','20151024','13476107753'),(2,'yesong002','1222','789456','13476107753'),(3,'ノ 今せ〞╅','http://qzapp.qlogo.cn/qzapp/100577807/BFB3BB67A6297C536BAF19E8830B9E12/100','15465AF551FA4D27B4FC287847AA3A7C','15007184046'),(4,'1oo﹪゛沉淀ら','http://q.qlogo.cn/qqapp/100577807/C011A8AA6FC09A52B2CAB60B8DD4D6F9/100','A28E4BAFFDF1994C13E13D6D2706C6FD','15926269672');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
