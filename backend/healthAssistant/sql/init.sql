/*
SQLyog Community v13.1.6 (64 bit)
MySQL - 8.0.42 : Database - health_assistant
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`health_assistant` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `health_assistant`;

/*Table structure for table `assessment` */

DROP TABLE IF EXISTS `assessment`;

CREATE TABLE `assessment` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL COMMENT '量表名称',
  `code` varchar(50) NOT NULL COMMENT '量表编码',
  `category` varchar(50) NOT NULL COMMENT '分类',
  `question_count` int NOT NULL DEFAULT '0' COMMENT '题量',
  `time_cost` varchar(50) DEFAULT NULL COMMENT '预计用时',
  `version` varchar(20) DEFAULT 'v1.0' COMMENT '版本',
  `risk_rule` varchar(255) DEFAULT NULL COMMENT '高风险规则',
  `status` tinyint NOT NULL DEFAULT '0' COMMENT '状态 0下架 1已上架 2草稿',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `assessment` */

insert  into `assessment`(`id`,`name`,`code`,`category`,`question_count`,`time_cost`,`version`,`risk_rule`,`status`,`created_at`,`updated_at`) values 
(1,'GAD-7 焦虑自评量表','SCALE_GAD7','焦虑',7,'约 3 分钟','v2.1','总分 ≥ 15 触发',1,'2026-10-31 23:40:29','2026-11-02 21:44:36'),
(2,'PHQ-9 抑郁自评量表','SCALE_PHQ9','抑郁',9,'约 4 分钟','v2.0','第 9 题 > 0',1,'2026-10-31 23:40:29','2026-10-31 23:40:29'),
(3,'情绪状态自评量表','SCALE_EMOTION','情绪',12,'约 5 分钟','v0.9',NULL,2,'2026-10-31 23:40:29','2026-10-31 23:40:29');

/*Table structure for table `chat_audit` */

DROP TABLE IF EXISTS `chat_audit`;

CREATE TABLE `chat_audit` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `session_id` varchar(50) NOT NULL COMMENT '会话ID',
  `user_name` varchar(50) NOT NULL COMMENT '用户姓名',
  `uid` varchar(50) DEFAULT NULL COMMENT '用户编号',
  `scene` varchar(50) DEFAULT NULL COMMENT '会话场景',
  `model` varchar(50) DEFAULT NULL COMMENT 'AI模型',
  `msg_count` int DEFAULT '0' COMMENT '消息数',
  `risk_level` varchar(20) DEFAULT '低危' COMMENT '风险等级',
  `rule_hit` varchar(255) DEFAULT NULL COMMENT '命中规则',
  `score` int DEFAULT '100' COMMENT '安全评分',
  `last_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '最近消息时间',
  `status` tinyint NOT NULL DEFAULT '2' COMMENT '状态: 1已通过, 2待复核, 3已复核',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_session_id` (`session_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='对话审计表';

/*Data for the table `chat_audit` */

insert  into `chat_audit`(`id`,`session_id`,`user_name`,`uid`,`scene`,`model`,`msg_count`,`risk_level`,`rule_hit`,`score`,`last_time`,`status`,`created_at`,`updated_at`) values 
(1,'CS-0087','张*雨','U-10238','睡眠建议','GPT-4o',18,'高危','敏感词命中 / 动作',62,'2026-11-04 13:52:35',3,'2026-11-04 13:52:35','2026-11-04 13:56:26'),
(2,'CS-0086','李*然','U-10521','饮食建议','GPT-4o-mini',12,'中危','用药剂量偏低',74,'2026-11-04 13:52:35',2,'2026-11-04 13:52:35','2026-11-04 13:52:35'),
(3,'CS-0085','王*博','U-10477','情绪安抚','Claude 3.5',26,'中危','情绪危机识别缺失',88,'2026-11-04 13:52:35',3,'2026-11-04 13:52:35','2026-11-04 13:52:35'),
(4,'CS-0084','陈*悦','U-11204','量表解读','GPT-4o',9,'低危',NULL,98,'2026-11-04 13:52:35',1,'2026-11-04 13:52:35','2026-11-04 13:52:35'),
(5,'CS-0083','刘*豪','U-10399','睡眠建议','GPT-4o',34,'中危','未提供就医建议',81,'2026-11-04 13:52:35',2,'2026-11-04 13:52:35','2026-11-04 13:52:35');

/*Table structure for table `food_library` */

DROP TABLE IF EXISTS `food_library`;

CREATE TABLE `food_library` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `name` varchar(100) NOT NULL COMMENT '食物名称',
  `code` varchar(50) NOT NULL COMMENT '食物编码',
  `category` varchar(50) NOT NULL COMMENT '分类',
  `calories` int NOT NULL COMMENT '热量(kcal)',
  `carbs` varchar(20) DEFAULT NULL COMMENT '碳水化合物',
  `protein` varchar(20) DEFAULT NULL COMMENT '蛋白质',
  `fat` varchar(20) DEFAULT NULL COMMENT '脂肪',
  `portion` varchar(50) DEFAULT NULL COMMENT '份量单位',
  `source` varchar(50) NOT NULL DEFAULT '官方库' COMMENT '来源',
  `status` tinyint NOT NULL DEFAULT '2' COMMENT '状态: 1上架, 2待审核, 0下架',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='食物库表';

/*Data for the table `food_library` */

insert  into `food_library`(`id`,`name`,`code`,`category`,`calories`,`carbs`,`protein`,`fat`,`portion`,`source`,`status`,`created_at`,`updated_at`) values 
(1,'燕麦片（生）','FD-100238','谷薯类',377,'66.9','15.0','6.7','100 g','官方库',1,'2026-11-02 21:46:06','2026-11-02 22:03:33'),
(2,'鸡胸肉（去皮）','FD-100512','肉类',118,'0.6','24.6','1.9','100 g','官方库',1,'2026-11-02 21:46:06','2026-11-02 21:46:06'),
(3,'三文鱼刺身','FD-101002','水产类',208,'0','20.4','13.4','100 g','AI 识别',1,'2026-11-02 21:46:06','2026-11-02 21:59:31'),
(4,'全麦吐司','FD-100864','谷薯类',246,'43.2','9.4','4.1','1片 · 35g','官方库',1,'2026-11-02 21:54:58','2026-11-02 21:54:58'),
(5,'苹果','FD-100731','水果类',53,'13.7','0.2','0.2','1个 · 200g','官方库',1,'2026-11-02 21:54:58','2026-11-02 21:54:58'),
(6,'红烧牛肉面','FD-101200','菜品',512,'68.4','24.1','15.8','1碗 · 650g','官方库',1,'2026-11-02 21:54:58','2026-11-02 21:54:58'),
(7,'燕麦拿铁','FD-101155','饮品类',156,'21.5','5.6','5.2','1杯 · 350ml','用户贡献',1,'2026-11-02 21:54:58','2026-11-02 21:59:33'),
(8,'牛油果','FD-101312','水果类',171,'7.4','2.0','15.3','1个 · 150g','官方库',1,'2026-11-02 21:54:58','2026-11-02 22:03:33'),
(9,'清蒸鲈鱼','FD-101420','水产类',105,'0','18.6','3.4','100 g','官方库',1,'2026-11-02 21:54:58','2026-11-02 21:54:58'),
(10,'炒青菜','FD-101521','菜品',85,'4.2','1.5','6.8','1份 · 200g','用户贡献',1,'2026-11-02 21:54:58','2026-11-02 21:54:58'),
(11,'蒙牛纯牛奶','FD-101602','饮品类',65,'4.8','3.2','3.6','1盒 · 250ml','官方库',1,'2026-11-02 21:54:58','2026-11-02 21:54:58'),
(12,'煎鸡蛋','FD-101700','菜品',199,'0.8','13.6','15.2','1个 · 50g','AI 识别',1,'2026-11-02 21:54:58','2026-11-02 21:59:35'),
(13,'玉米','FD-101801','谷薯类',112,'22.8','4.0','1.2','1根 · 200g','官方库',1,'2026-11-02 21:54:58','2026-11-02 22:03:33');

/*Table structure for table `prompt_template` */

DROP TABLE IF EXISTS `prompt_template`;

CREATE TABLE `prompt_template` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` varchar(100) NOT NULL COMMENT '模板名称',
  `code` varchar(50) NOT NULL COMMENT '模板编码',
  `category` varchar(50) NOT NULL COMMENT '分类',
  `model` varchar(50) DEFAULT 'GPT-4o' COMMENT '生效模型',
  `version` varchar(20) DEFAULT 'v1.0' COMMENT '版本',
  `tokens` varchar(20) DEFAULT '0' COMMENT 'Tokens 估算',
  `status` tinyint NOT NULL DEFAULT '2' COMMENT '状态: 1启用, 2待审核, 0停用',
  `updater` varchar(50) DEFAULT '系统' COMMENT '更新人',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `rule_category` varchar(32) DEFAULT NULL COMMENT '业务分类：sensitive/medicine/...',
  `level` varchar(16) DEFAULT NULL COMMENT '风险等级：high/medium/low',
  `scene` varchar(255) DEFAULT NULL COMMENT '适用场景，逗号分隔',
  `models` varchar(255) DEFAULT NULL COMMENT '生效模型，逗号分隔',
  `detect_type` varchar(32) DEFAULT NULL COMMENT '检测方式：keyword/semantic/llm',
  `combo_logic` text COMMENT '关键词组合 JSON',
  `keyword_input` text COMMENT '关键词/正则原始输入',
  `similarity_threshold` decimal(3,2) DEFAULT NULL COMMENT '语义相似度阈值',
  `hit_times` int DEFAULT '1' COMMENT '命中次数阈值',
  `exclude_conditions` varchar(255) DEFAULT NULL COMMENT '排除条件，逗号分隔',
  `actions` varchar(255) DEFAULT NULL COMMENT '处置动作，逗号分隔',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='提示词模板表';

/*Data for the table `prompt_template` */

insert  into `prompt_template`(`id`,`title`,`code`,`category`,`model`,`version`,`tokens`,`status`,`updater`,`created_at`,`updated_at`,`rule_category`,`level`,`scene`,`models`,`detect_type`,`combo_logic`,`keyword_input`,`similarity_threshold`,`hit_times`,`exclude_conditions`,`actions`) values 
(1,'识别焦虑情绪（基础）','PROMPT_SCALE_INTERPRET','量表解读','GPT-4o','v1.2','2.1k',1,'林小雨','2026-11-03 19:40:01','2026-11-03 19:40:01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL),
(2,'高风险词识别','PROMPT_CRISIS_DETECT','对话审计','Claude 3.5 Sonnet','v2.0','1.8k',1,'林小雨','2026-11-03 19:40:01','2026-11-03 19:40:01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL),
(3,'情绪判断与分类生成','PROMPT_EMOTION_TAG','对话审计','Qwen-72B','v1.1','1.2k',1,'周舟','2026-11-03 19:40:01','2026-11-03 19:40:01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL),
(4,'建议文案润色助手','PROMPT_SUGGEST_POLISH','文案生成','GPT-4o-mini','v1.0','2.5k',2,'陈默','2026-11-03 19:40:01','2026-11-03 19:40:01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL),
(5,'危机干预话术（高风险）','PROMPT_CRISIS_RESP','对话审计','GPT-4o','v1.0','3.2k',1,'林小雨','2026-11-03 19:40:01','2026-11-03 19:40:01',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL),
(6,'测试1','PROMPT_SLEEP_ADVICE','sleep','qwen-max','v1.0','0',2,'系统','2026-11-03 19:52:28','2026-11-03 19:52:28',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL),
(7,'敏感承诺 · 确定性疗效','R-1001','audit','GPT-4o','v1.0','1.2k',1,'系统','2026-11-04 14:15:27','2026-11-04 18:46:47','sensitive',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL),
(8,'用药剂量建议','R-1002','audit','GPT-4o','v1.0','1.5k',1,'系统','2026-11-04 14:15:27','2026-11-04 18:46:47','medicine',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL),
(9,'疾病诊断表述','R-1003','audit','Claude 3.5','v1.0','2.1k',1,'系统','2026-11-04 14:15:27','2026-11-04 18:46:47','diagnosis',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL),
(10,'情绪危机识别缺失','R-1004','audit','GPT-4o','v1.0','1.8k',1,'系统','2026-11-04 14:15:27','2026-11-04 18:46:47','emotion',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL),
(11,'绝对化用语','R-1005','audit','Qwen-72B','v1.0','0.9k',1,'系统','2026-11-04 14:15:27','2026-11-04 18:46:47','exaggerate',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL),
(12,'诱导消费表述','R-1006','audit','GPT-4o','v1.0','1.1k',0,'系统','2026-11-04 14:15:27','2026-11-04 18:46:47','exaggerate',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL),
(13,'未提供就医建议','R-1007','audit','GPT-4o','v1.0','1.4k',1,'系统','2026-11-04 14:15:27','2026-11-04 18:46:47','privacy',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL),
(14,'隐私信息索要','R-1008','audit','Claude 3.5','v1.0','1.9k',1,'系统','2026-11-04 14:15:27','2026-11-04 18:46:47','privacy',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL),
(15,'测试1','R-1009','audit','GPT-4o','v1.0','0',1,'系统',NULL,'2026-11-04 18:40:12','custom','high','consult,diet','all','semantic','{\"comboLogic\":\"治愈\",\"comboOp1\":\"极大概率\",\"comboLogic2\":\"根治\",\"comboOp2\":\"保证有效\",\"comboOp3\":\"一劳永逸\"}','1111',0.72,2,'quote,reprint','log,manual'),
(16,'测试2','R-1010','audit','GPT-4o','v1.0','0',1,'系统',NULL,'2026-11-04 18:40:13','custom','high','consult,diet','all','keyword','{\"comboLogic\":\"治愈\",\"comboOp1\":\"极大概率\",\"comboLogic2\":\"根治\",\"comboOp2\":\"保证有效\",\"comboOp3\":\"一劳永逸\"}','22',0.72,2,'quote,reprint','log,manual'),
(17,'测试3','R-1011','audit','GPT-4o','v1.0','0',1,'系统','2026-11-04 18:36:35','2026-11-04 18:41:26','custom','high','consult,diet','all','keyword','{\"comboLogic\":\"治愈\",\"comboOp1\":\"极大概率\",\"comboLogic2\":\"根治\",\"comboOp2\":\"保证有效\",\"comboOp3\":\"一劳永逸\"}','',0.72,2,'quote,reprint','log,manual'),
(18,'测试4','R-1012','audit','GPT-4o','v1.0','0',1,'系统','2026-11-04 19:00:19','2026-11-04 20:28:33','custom','high','consult,diet','all','keyword','{\"comboLogic\":\"治愈\",\"comboOp1\":\"极大概率\",\"comboLogic2\":\"根治\",\"comboOp2\":\"保证有效\",\"comboOp3\":\"一劳永逸\"}','',0.72,2,'quote,reprint','log,manual'),
(19,'测试5','R-1013','audit','GPT-4o','v1.0','0',1,'系统','2026-11-04 20:29:20','2026-11-04 20:29:20','custom','medium','consult,diet','all','keyword','{\"comboLogic\":\"治愈\",\"comboOp1\":\"极大概率\",\"comboLogic2\":\"根治\",\"comboOp2\":\"保证有效\",\"comboOp3\":\"一劳永逸\"}','',0.72,2,'quote,reprint','log,manual');

/*Table structure for table `push_template` */

DROP TABLE IF EXISTS `push_template`;

CREATE TABLE `push_template` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` varchar(100) NOT NULL COMMENT '模板标题',
  `code` varchar(50) NOT NULL COMMENT '模板编码',
  `event` varchar(50) NOT NULL COMMENT '触发事件',
  `channel` varchar(50) NOT NULL COMMENT '推送渠道',
  `target` varchar(50) NOT NULL COMMENT '目标人群',
  `status` tinyint NOT NULL DEFAULT '2' COMMENT '状态: 1启用, 2待审核, 0停用, 3草稿',
  `updater` varchar(50) DEFAULT NULL COMMENT '更新人',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='推送模板表';

/*Data for the table `push_template` */

insert  into `push_template`(`id`,`title`,`code`,`event`,`channel`,`target`,`status`,`updater`,`created_at`,`updated_at`) values 
(1,'测评报告生成通知','PUSH_REPORT_GEN','测评完成','站内信','测评用户',1,'林小雨','2026-11-03 19:25:40','2026-11-03 19:25:40'),
(2,'高风险关怀提醒','PUSH_HIGH_RISK','高风险预警','APP Push','高风险用户',1,'林小雨','2026-11-03 19:25:40','2026-11-03 19:25:40'),
(3,'每日健康打卡提醒','PUSH_DAILY_CHECKIN','计划未完成','站内信','全体用户',1,'周舟','2026-11-03 19:25:40','2026-11-03 19:25:40'),
(4,'连续未打卡挽留','PUSH_CHURN_INTERVENE','连续未打卡','APP Push','7 天未活跃',2,'周舟','2026-11-03 19:25:40','2026-11-03 19:25:40'),
(5,'会员权益领取通知','PUSH_VIP_BENEFIT','会员购买','企微','会员用户',1,'陈默','2026-11-03 19:25:40','2026-11-03 19:25:40'),
(6,'饮食记录温馨提示','PUSH_DIET_LOG','饮食记录','站内信','饮食计划用户',1,'周舟','2026-11-03 19:25:40','2026-11-03 19:25:40'),
(7,'系统升级通知','PUSH_SYS_UPGRADE','系统通知','站内信','全体用户',0,'系统','2026-11-03 19:25:40','2026-11-03 19:25:40');

/*Table structure for table `suggestion_template` */

DROP TABLE IF EXISTS `suggestion_template`;

CREATE TABLE `suggestion_template` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `title` varchar(100) NOT NULL COMMENT '文案标题',
  `code` varchar(50) NOT NULL COMMENT '文案编码',
  `scale_name` varchar(50) NOT NULL COMMENT '关联量表',
  `trigger_condition` varchar(255) DEFAULT NULL COMMENT '触发条件',
  `risk_level` varchar(20) NOT NULL COMMENT '风险等级: 高风险/中风险/低风险',
  `tone` varchar(50) DEFAULT NULL COMMENT '语气风格',
  `content` text NOT NULL COMMENT '文案内容(含占位符)',
  `status` tinyint NOT NULL DEFAULT '2' COMMENT '状态: 1启用, 2待审核, 0停用',
  `updater` varchar(50) DEFAULT NULL COMMENT '更新人',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='建议文案模板表';

/*Data for the table `suggestion_template` */

insert  into `suggestion_template`(`id`,`title`,`code`,`scale_name`,`trigger_condition`,`risk_level`,`tone`,`content`,`status`,`updater`,`created_at`,`updated_at`) values 
(1,'GAD-7 高分安抚文案','COPY_GAD7_HIGH','GAD-7 焦虑自评','总分 ≥ 13 且第 8 题 > 0','高风险','温和安抚','亲爱的{user_name}，您在{scale_name}中得分为{score}分，可能正面临较大的焦虑困扰。建议您尽快联系专业顾问，我们会一直陪伴您。',1,'林小雨','2026-11-03 16:34:23','2026-11-03 16:53:31'),
(2,'PHQ-9 中度抑郁建议','COPY_PHQ9_MID','PHQ-9 抑郁自评','总分 10 - 14','中风险','专业说明','您好{user_name}，根据测评结果，建议您保持规律作息，并尝试每日进行深呼吸练习。必要时可联系心理顾问。',1,'林小雨','2026-11-03 16:34:23','2026-11-03 16:34:23'),
(3,'危机干预紧急提示','COPY_PHQ9_CRISIS','PHQ-9 抑郁自评','第 9 题 > 0','高风险','危机干预','紧急提示：{user_name}，您的测评结果显示可能存在自伤风险，请立即拨打心理援助热线，或联系您的专属顾问。',1,'林小雨','2026-11-03 16:34:23','2026-11-03 16:34:23'),
(4,'测试1','11111','GAD-7','total gte 15 且 q7 gte 0','高风险','温和共情','测试1',1,'系统','2026-11-03 19:10:43','2026-11-03 19:15:58'),
(5,'测试2','22','GAD-7','total gte 15 且 q7 gte 0','高风险','温和共情','测试2',2,'系统','2026-11-03 19:15:49','2026-11-03 19:15:49');

/*Table structure for table `sys_admin` */

DROP TABLE IF EXISTS `sys_admin`;

CREATE TABLE `sys_admin` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL COMMENT '登录账号',
  `real_name` varchar(50) NOT NULL COMMENT '真实姓名',
  `password` varchar(100) NOT NULL COMMENT '密码(加密后)',
  `phone` varchar(20) NOT NULL COMMENT '手机号',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `role` varchar(50) NOT NULL COMMENT '角色标识(如: super_admin, content_ops)',
  `role_name` varchar(50) NOT NULL COMMENT '角色名称(如: 超级管理员)',
  `department` varchar(50) DEFAULT NULL COMMENT '所属部门',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态(1:启用, 0:停用, 2:待激活)',
  `last_login_time` datetime DEFAULT NULL COMMENT '最近登录时间',
  `last_login_ip` varchar(50) DEFAULT NULL COMMENT '最近登录IP',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='系统管理员表';

/*Data for the table `sys_admin` */

insert  into `sys_admin`(`id`,`username`,`real_name`,`password`,`phone`,`email`,`role`,`role_name`,`department`,`status`,`last_login_time`,`last_login_ip`,`created_at`,`updated_at`) values 
(1,'chenke','陈可','123456','13800006221','chenke@healthhub.cn','super_admin','超级管理员','运营中心',1,'2026-11-04 18:09:20','上海 · Chrome','2026-11-06 16:53:12','2026-11-06 16:59:13'),
(2,'linxy','林知远','123456','13800002343','linxy@healthhub.cn','content_ops','内容运营','内容运营组',1,'2026-11-04 18:08:41','杭州 · Safari','2026-11-06 16:53:12','2026-11-06 16:53:12'),
(3,'admin','系统管理员','123456','13900000000','admin@healthhub.cn','super_admin','超级管理员','技术部',1,NULL,NULL,'2026-11-06 16:53:12','2026-11-06 16:53:12'),
(4,'susuan','苏晚','123456','13800009880','susuan@healthhub.cn','content_ops','内容运营','风控合规组',1,NULL,NULL,'2026-11-06 16:53:12','2026-11-06 16:53:12'),
(5,'3525902928@qq.com','测试1','123456xx','13789302257',NULL,'super_admin','超级管理员','内容运营',1,NULL,NULL,'2026-11-07 22:18:08','2026-11-07 22:33:14'),
(6,'test01','测试用户','123456xx','13800000001',NULL,'test_role','测试角色','测试部',1,NULL,NULL,'2026-11-09 16:34:15','2026-11-09 16:41:38');

/*Table structure for table `sys_audit_log` */

DROP TABLE IF EXISTS `sys_audit_log`;

CREATE TABLE `sys_audit_log` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `log_code` varchar(32) NOT NULL COMMENT '日志编号(如 LOG-106402)',
  `operator_name` varchar(50) NOT NULL COMMENT '操作人姓名',
  `operator_account` varchar(50) DEFAULT NULL COMMENT '操作人账号',
  `operator_role` varchar(50) DEFAULT NULL COMMENT '操作人角色',
  `action` varchar(100) NOT NULL COMMENT '操作动作(如 复核结论变更)',
  `target` varchar(100) DEFAULT NULL COMMENT '操作对象',
  `change_summary` varchar(200) DEFAULT NULL COMMENT '变更摘要',
  `source_ip` varchar(50) DEFAULT NULL COMMENT '来源IP',
  `risk_level` varchar(20) DEFAULT 'normal' COMMENT '风险等级(danger/warning/normal)',
  `status` varchar(20) DEFAULT 'success' COMMENT '执行结果(success/fail)',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='审计日志表';

/*Data for the table `sys_audit_log` */

insert  into `sys_audit_log`(`id`,`log_code`,`operator_name`,`operator_account`,`operator_role`,`action`,`target`,`change_summary`,`source_ip`,`risk_level`,`status`,`created_at`) values 
(1,'LOG-106402','陈昕','chenke@healthhub.cn','内容运营主管','复核结论变更','CS-240612-0087','待复核 → 确认风险','10.12.31.24','danger','success','2026-11-09 16:52:27'),
(2,'LOG-106401','陈昕','chenke@healthhub.cn','内容运营主管','查看会话明文','CS-240612-0087','触发敏感查看 · 已水印','10.12.31.24','warning','success','2026-11-09 16:52:27'),
(3,'LOG-106400','系统任务','SYSTEM','定时任务','自动审计执行','AUD-06121-21','v4.2 扫描 186 条会话','-','normal','success','2026-11-09 16:52:27'),
(4,'LOG-1039','林知远','linxy@healthhub.cn','风控合规专员','审计规则变更','R-SLEEP-012','严重度 中 → 高 · 关键词 +3','10.12.40.7','danger','success','2026-11-09 16:52:27'),
(5,'LOG-1038','周敏','zhoumu@healthhub.cn','数据分析师','导出申请','EXP-0612-004','驳回：未填写导出用途','10.12.55.18','warning','fail','2026-11-09 16:52:27'),
(6,'LOG-1037','赵一鸣','zhaoym@healthhub.cn','内容编辑','角色权限变更','角色 R-02','新增权限「查看会话明文」','10.12.8.2','danger','success','2026-11-09 16:52:27');

/*Table structure for table `sys_role` */

DROP TABLE IF EXISTS `sys_role`;

CREATE TABLE `sys_role` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `role_code` varchar(50) NOT NULL COMMENT '角色标识(如 super_admin, content_ops)',
  `role_name` varchar(50) NOT NULL COMMENT '角色名称(如 超级管理员)',
  `category` varchar(20) DEFAULT 'custom' COMMENT '分类：system(系统内置) / custom(自定义)',
  `description` varchar(200) DEFAULT NULL COMMENT '角色描述',
  `status` tinyint DEFAULT '1' COMMENT '1启用 0停用',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_code` (`role_code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `sys_role` */

insert  into `sys_role`(`id`,`role_code`,`role_name`,`category`,`description`,`status`,`created_at`) values 
(1,'super_admin','超级管理员','system',NULL,1,'2026-11-08 18:00:25'),
(2,'content_ops','内容运营','system',NULL,1,'2026-11-08 18:00:25'),
(4,'test_role','测试角色','custom','仅用于测试，只有食物库和量表权限',1,'2026-11-09 16:33:59');

/*Table structure for table `sys_role_permission` */

DROP TABLE IF EXISTS `sys_role_permission`;

CREATE TABLE `sys_role_permission` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `role_code` varchar(50) NOT NULL COMMENT '对应 sys_admin.role 或 sys_role.role_code',
  `module_code` varchar(50) NOT NULL COMMENT '模块编码(如 user, scale)',
  `action_code` varchar(20) NOT NULL COMMENT '操作(如 view, edit, export, delete)',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_module_action` (`role_code`,`module_code`,`action_code`)
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `sys_role_permission` */

insert  into `sys_role_permission`(`id`,`role_code`,`module_code`,`action_code`) values 
(6,'content_ops','food','view'),
(3,'content_ops','scale','edit'),
(2,'content_ops','scale','view'),
(5,'content_ops','suggestion','edit'),
(4,'content_ops','suggestion','view'),
(1,'content_ops','user','view'),
(47,'super_admin','ai','delete'),
(48,'super_admin','ai','edit'),
(49,'super_admin','ai','export'),
(50,'super_admin','ai','view'),
(63,'super_admin','food','delete'),
(64,'super_admin','food','edit'),
(65,'super_admin','food','export'),
(66,'super_admin','food','view'),
(55,'super_admin','risk','delete'),
(56,'super_admin','risk','edit'),
(57,'super_admin','risk','export'),
(58,'super_admin','risk','view'),
(51,'super_admin','scale','delete'),
(52,'super_admin','scale','edit'),
(53,'super_admin','scale','export'),
(54,'super_admin','scale','view'),
(43,'super_admin','system','delete'),
(44,'super_admin','system','edit'),
(45,'super_admin','system','export'),
(46,'super_admin','system','view'),
(59,'super_admin','user','delete'),
(60,'super_admin','user','edit'),
(61,'super_admin','user','export'),
(62,'super_admin','user','view'),
(70,'test_role','food','view'),
(69,'test_role','scale','view'),
(71,'test_role','user','view');

/*Table structure for table `sys_user` */

DROP TABLE IF EXISTS `sys_user`;

CREATE TABLE `sys_user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_no` varchar(32) NOT NULL COMMENT '用户编号 (如: U6823***)',
  `nickname` varchar(64) NOT NULL COMMENT '昵称 (如: 张小满)',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像URL',
  `phone` varchar(20) NOT NULL COMMENT '手机号',
  `gender` tinyint DEFAULT '0' COMMENT '性别: 0-未知, 1-男, 2-女',
  `age` int DEFAULT NULL COMMENT '年龄',
  `register_time` datetime NOT NULL COMMENT '注册时间',
  `last_active_time` datetime DEFAULT NULL COMMENT '最近活跃时间',
  `record_days` int DEFAULT '0' COMMENT '记录天数',
  `test_count` int DEFAULT '0' COMMENT '测评次数',
  `status` tinyint DEFAULT '1' COMMENT '状态: 0-禁用, 1-正常, 2-高风险关注',
  `create_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  `is_deleted` tinyint(1) DEFAULT '0' COMMENT '逻辑删除: 0-未删除, 1-已删除',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_phone` (`phone`),
  KEY `idx_register_time` (`register_time`)
) ENGINE=InnoDB AUTO_INCREMENT=504 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户信息表';

/*Data for the table `sys_user` */

insert  into `sys_user`(`id`,`user_no`,`nickname`,`avatar`,`phone`,`gender`,`age`,`register_time`,`last_active_time`,`record_days`,`test_count`,`status`,`create_time`,`update_time`,`is_deleted`) values 
(1,'U010001','ZhouJing',NULL,'139****0001',2,50,'2026-09-14 17:47:09','2026-09-25 17:47:09',11,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(2,'U010002','LiJing',NULL,'186****0002',1,53,'2026-10-08 17:47:09','2026-11-02 17:47:09',25,5,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(3,'U010003','QianMin',NULL,'139****0003',2,38,'2025-12-21 17:47:09','2026-08-17 17:47:09',239,47,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(4,'U010004','ZhouLei',NULL,'139****0004',1,43,'2026-11-03 17:47:09','2026-11-11 17:47:09',8,1,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(5,'U010005','QianTao',NULL,'138****0005',1,29,'2026-08-29 17:47:09','2026-09-20 17:47:09',22,4,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(6,'U010006','WangWei',NULL,'186****0006',2,19,'2026-05-24 17:47:09','2026-08-07 17:47:09',75,15,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(7,'U010007','ZhengJuan',NULL,'138****0007',2,35,'2026-01-28 17:47:09','2026-03-10 17:47:09',41,8,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(8,'U010008','SunFang',NULL,'186****0008',2,45,'2026-05-03 17:47:09','2026-09-15 17:47:09',135,27,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(9,'U010009','QianYan',NULL,'138****0009',1,39,'2026-06-19 17:47:09','2026-06-22 17:47:09',3,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(10,'U010010','LiNa',NULL,'138****0010',2,52,'2026-03-16 17:47:09','2026-05-06 17:47:09',51,10,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(11,'U010011','ZhengYang',NULL,'186****0011',1,22,'2025-12-22 17:47:09','2026-11-07 17:47:09',320,64,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(12,'U010012','ZhaoTao',NULL,'139****0012',2,49,'2025-11-21 17:47:09','2026-05-21 17:47:09',181,36,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(13,'U010013','WuNa',NULL,'139****0013',1,49,'2026-10-01 17:47:09','2026-10-18 17:47:09',17,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(14,'U010014','ZhengYong',NULL,'186****0014',2,25,'2026-04-20 17:47:09','2026-09-14 17:47:09',147,29,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(15,'U010015','QianJing',NULL,'138****0015',1,22,'2026-10-12 17:47:09','2026-10-31 17:47:09',19,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(16,'U010016','ZhaoYan',NULL,'139****0016',2,47,'2026-06-09 17:47:09','2026-06-23 17:47:09',14,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(17,'U010017','LiuYong',NULL,'186****0017',2,19,'2025-12-23 17:47:09','2026-04-20 17:47:09',118,23,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(18,'U010018','WangYong',NULL,'138****0018',1,33,'2026-05-06 17:47:09','2026-09-20 17:47:09',137,27,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(19,'U010019','ZhengLi',NULL,'138****0019',2,55,'2026-07-30 17:47:09','2026-09-27 17:47:09',59,11,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(20,'U010020','WuTao',NULL,'186****0020',1,34,'2026-04-19 17:47:09','2026-07-10 17:47:09',82,16,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(21,'U010021','SunYan',NULL,'186****0021',1,57,'2026-06-14 17:47:09','2026-06-16 17:47:09',2,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(22,'U010022','LiuTao',NULL,'139****0022',2,43,'2026-10-30 17:47:09','2026-11-01 17:47:09',2,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(23,'U010023','ZhengLi',NULL,'186****0023',2,24,'2026-04-19 17:47:09','2026-11-12 17:47:09',207,41,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(24,'U010024','WuMin',NULL,'138****0024',1,52,'2026-02-10 17:47:09','2026-08-15 17:47:09',186,37,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(25,'U010025','QianFang',NULL,'138****0025',2,42,'2026-05-16 17:47:09','2026-07-19 17:47:09',64,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(26,'U010026','LiuJie',NULL,'139****0026',1,25,'2026-09-18 17:47:09','2026-09-30 17:47:09',12,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(27,'U010027','WangTao',NULL,'186****0027',2,47,'2026-04-08 17:47:09','2026-05-01 17:47:09',23,4,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(28,'U010028','SunFang',NULL,'186****0028',2,57,'2026-04-15 17:47:09','2026-07-22 17:47:09',98,19,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(29,'U010029','SunLi',NULL,'186****0029',1,18,'2026-08-28 17:47:09','2026-09-09 17:47:09',12,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(30,'U010030','LiuJuan',NULL,'139****0030',2,55,'2025-12-12 17:47:09','2026-11-05 17:47:09',328,65,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(31,'U010031','ZhouJun',NULL,'138****0031',2,39,'2025-12-03 17:47:09','2026-10-17 17:47:09',318,63,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(32,'U010032','ZhengLei',NULL,'138****0032',2,26,'2026-04-30 17:47:09','2026-05-26 17:47:09',26,5,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(33,'U010033','QianMin',NULL,'186****0033',2,38,'2026-05-23 17:47:09','2026-08-24 17:47:09',93,18,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(34,'U010034','SunTao',NULL,'139****0034',2,30,'2026-08-23 17:47:09','2026-09-17 17:47:09',25,5,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(35,'U010035','SunJing',NULL,'138****0035',2,53,'2026-09-26 17:47:09','2026-11-03 17:47:09',38,7,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(36,'U010036','WangMin',NULL,'138****0036',2,29,'2026-05-20 17:47:09','2026-06-06 17:47:09',17,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(37,'U010037','ZhengMin',NULL,'139****0037',1,44,'2026-08-22 17:47:09','2026-09-22 17:47:09',31,6,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(38,'U010038','ZhengWei',NULL,'138****0038',1,41,'2026-10-21 17:47:09','2026-10-22 17:47:09',1,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(39,'U010039','WuMin',NULL,'186****0039',1,22,'2026-09-23 17:47:09','2026-10-14 17:47:09',21,4,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(40,'U010040','ZhengJie',NULL,'186****0040',1,57,'2026-07-28 17:47:09','2026-10-06 17:47:09',70,14,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(41,'U010041','LiuJuan',NULL,'138****0041',2,44,'2026-08-12 17:47:09','2026-09-29 17:47:09',48,9,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(42,'U010042','WuJuan',NULL,'139****0042',2,41,'2026-03-16 17:47:09','2026-08-23 17:47:09',160,32,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(43,'U010043','LiuWei',NULL,'138****0043',1,47,'2026-01-15 17:47:09','2026-02-05 17:47:09',21,4,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(44,'U010044','ZhengJie',NULL,'138****0044',1,34,'2026-04-20 17:47:09','2026-07-20 17:47:09',91,18,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(45,'U010045','ZhaoTao',NULL,'139****0045',2,24,'2026-03-28 17:47:09','2026-11-05 17:47:09',222,44,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(46,'U010046','LiuJing',NULL,'186****0046',2,22,'2026-10-05 17:47:09','2026-10-15 17:47:09',10,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(47,'U010047','WuJing',NULL,'139****0047',2,53,'2026-07-04 17:47:09','2026-10-09 17:47:09',97,19,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(48,'U010048','QianTao',NULL,'138****0048',1,48,'2026-06-16 17:47:09','2026-08-07 17:47:09',52,10,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(49,'U010049','ZhangJuan',NULL,'186****0049',2,50,'2026-02-04 17:47:09','2026-09-15 17:47:09',223,44,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(50,'U010050','ZhaoWei',NULL,'139****0050',2,34,'2026-05-10 17:47:09','2026-06-22 17:47:09',43,8,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(51,'U010051','ZhengNa',NULL,'139****0051',2,20,'2026-01-17 17:47:09','2026-06-22 17:47:09',156,31,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(52,'U010052','SunJuan',NULL,'138****0052',2,35,'2026-09-04 17:47:09','2026-09-07 17:47:09',3,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(53,'U010053','ZhangYan',NULL,'139****0053',1,47,'2026-05-24 17:47:09','2026-09-18 17:47:09',117,23,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(54,'U010054','WangLi',NULL,'139****0054',2,24,'2025-12-13 17:47:09','2026-02-18 17:47:09',67,13,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(55,'U010055','QianJing',NULL,'138****0055',1,53,'2026-07-11 17:47:09','2026-09-05 17:47:09',56,11,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(56,'U010056','WangNa',NULL,'138****0056',2,34,'2026-10-14 17:47:09','2026-10-19 17:47:09',5,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(57,'U010057','QianLei',NULL,'139****0057',1,52,'2026-03-25 17:47:09','2026-10-15 17:47:09',204,40,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(58,'U010058','LiTao',NULL,'138****0058',2,26,'2026-08-11 17:47:09','2026-08-28 17:47:09',17,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(59,'U010059','WuTao',NULL,'186****0059',1,47,'2025-12-28 17:47:09','2026-01-09 17:47:09',12,2,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(60,'U010060','SunNa',NULL,'139****0060',2,45,'2026-05-27 17:47:09','2026-09-13 17:47:09',109,21,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(61,'U010061','ZhangLi',NULL,'139****0061',1,57,'2026-06-19 17:47:09','2026-07-25 17:47:09',36,7,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(62,'U010062','WangTao',NULL,'186****0062',2,21,'2026-09-29 17:47:09','2026-10-11 17:47:09',12,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(63,'U010063','ZhouNa',NULL,'186****0063',1,50,'2026-07-09 17:47:09','2026-08-25 17:47:09',47,9,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(64,'U010064','LiuNa',NULL,'139****0064',1,49,'2026-06-24 17:47:09','2026-09-24 17:47:09',92,18,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(65,'U010065','WuJing',NULL,'186****0065',2,19,'2026-09-11 17:47:09','2026-10-15 17:47:09',34,6,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(66,'U010066','ZhangNa',NULL,'138****0066',1,32,'2026-06-29 17:47:09','2026-09-22 17:47:09',85,17,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(67,'U010067','WuYan',NULL,'138****0067',1,20,'2025-12-27 17:47:09','2026-04-24 17:47:09',118,23,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(68,'U010068','QianYan',NULL,'186****0068',1,35,'2026-07-24 17:47:09','2026-09-15 17:47:09',53,10,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(69,'U010069','ZhouFang',NULL,'186****0069',2,25,'2026-03-03 17:47:09','2026-07-05 17:47:09',124,24,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(70,'U010070','ZhaoJun',NULL,'186****0070',2,31,'2026-07-06 17:47:09','2026-10-02 17:47:09',88,17,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(71,'U010071','ZhaoLi',NULL,'186****0071',2,23,'2025-12-19 17:47:09','2026-03-29 17:47:09',100,20,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(72,'U010072','WuMin',NULL,'139****0072',2,45,'2026-05-15 17:47:09','2026-08-07 17:47:09',84,16,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(73,'U010073','WuJuan',NULL,'138****0073',2,46,'2026-05-07 17:47:09','2026-07-02 17:47:09',56,11,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(74,'U010074','ZhouNa',NULL,'138****0074',1,26,'2026-01-19 17:47:09','2026-04-20 17:47:09',91,18,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(75,'U010075','ZhangYong',NULL,'139****0075',2,22,'2026-04-02 17:47:09','2026-09-24 17:47:09',175,35,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(76,'U010076','ZhengYong',NULL,'138****0076',2,33,'2026-05-16 17:47:09','2026-09-19 17:47:09',126,25,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(77,'U010077','ZhaoNa',NULL,'186****0077',2,54,'2026-05-07 17:47:09','2026-06-16 17:47:09',40,8,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(78,'U010078','LiTao',NULL,'186****0078',2,45,'2025-12-04 17:47:09','2026-06-18 17:47:09',196,39,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(79,'U010079','SunFang',NULL,'139****0079',2,36,'2026-01-07 17:47:09','2026-03-31 17:47:09',83,16,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(80,'U010080','ZhangYang',NULL,'186****0080',2,45,'2025-12-23 17:47:09','2026-09-20 17:47:09',271,54,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(81,'U010081','WangLei',NULL,'138****0081',1,22,'2026-01-11 17:47:09','2026-07-03 17:47:09',173,34,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(82,'U010082','WuJing',NULL,'139****0082',1,19,'2026-10-04 17:47:09','2026-10-24 17:47:09',20,4,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(83,'U010083','ZhengNa',NULL,'186****0083',2,51,'2026-03-18 17:47:09','2026-05-05 17:47:09',48,9,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(84,'U010084','ZhangYan',NULL,'186****0084',1,20,'2026-08-19 17:47:09','2026-10-24 17:47:09',66,13,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(85,'U010085','ZhengMin',NULL,'139****0085',1,42,'2026-04-28 17:47:09','2026-05-17 17:47:09',19,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(86,'U010086','WangTao',NULL,'138****0086',2,24,'2026-04-22 17:47:09','2026-06-30 17:47:09',69,13,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(87,'U010087','LiFang',NULL,'139****0087',2,53,'2026-02-15 17:47:09','2026-03-28 17:47:09',41,8,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(88,'U010088','ZhengYong',NULL,'186****0088',2,42,'2026-04-10 17:47:09','2026-09-06 17:47:09',149,29,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(89,'U010089','ZhangLi',NULL,'139****0089',1,30,'2025-11-23 17:47:09','2026-04-27 17:47:09',155,31,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(90,'U010090','ZhangMin',NULL,'139****0090',2,36,'2026-09-10 17:47:09','2026-10-13 17:47:09',33,6,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(91,'U010091','WangJun',NULL,'139****0091',1,51,'2026-08-09 17:47:09','2026-10-28 17:47:09',80,16,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(92,'U010092','ZhouYang',NULL,'186****0092',2,20,'2026-08-05 17:47:09','2026-08-16 17:47:09',11,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(93,'U010093','ZhouTao',NULL,'138****0093',2,18,'2026-03-26 17:47:09','2026-06-13 17:47:09',79,15,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(94,'U010094','LiuYan',NULL,'186****0094',1,46,'2025-12-16 17:47:09','2026-07-11 17:47:09',207,41,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(95,'U010095','LiYong',NULL,'186****0095',1,39,'2026-05-27 17:47:09','2026-09-01 17:47:09',97,19,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(96,'U010096','WangFang',NULL,'138****0096',1,38,'2026-06-16 17:47:09','2026-06-18 17:47:09',2,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(97,'U010097','SunYan',NULL,'139****0097',1,41,'2026-02-03 17:47:09','2026-03-18 17:47:09',43,8,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(98,'U010098','SunYang',NULL,'186****0098',1,18,'2026-03-29 17:47:09','2026-09-23 17:47:09',178,35,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(99,'U010099','LiJun',NULL,'186****0099',2,26,'2026-10-25 17:47:09','2026-11-06 17:47:09',12,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(100,'U010100','QianJing',NULL,'186****0100',2,42,'2026-11-11 17:47:09','2026-11-12 17:47:09',1,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(101,'U010101','ZhangLei',NULL,'186****0101',1,56,'2026-03-02 17:47:09','2026-08-24 17:47:09',175,35,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(102,'U010102','SunJing',NULL,'139****0102',2,21,'2026-04-18 17:47:09','2026-05-27 17:47:09',39,7,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(103,'U010103','ZhengJie',NULL,'186****0103',1,19,'2025-11-18 17:47:09','2026-11-01 17:47:09',348,69,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(104,'U010104','LiLei',NULL,'186****0104',2,40,'2026-10-31 17:47:09','2026-11-05 17:47:09',5,1,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(105,'U010105','ZhouYan',NULL,'139****0105',1,48,'2026-10-13 17:47:09','2026-10-24 17:47:09',11,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(106,'U010106','ZhouYan',NULL,'139****0106',2,29,'2026-10-31 17:47:09','2026-11-11 17:47:09',11,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(107,'U010107','ZhangLi',NULL,'139****0107',1,18,'2026-02-09 17:47:09','2026-05-21 17:47:09',101,20,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(108,'U010108','QianTao',NULL,'139****0108',1,20,'2026-06-26 17:47:09','2026-10-23 17:47:09',119,23,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(109,'U010109','LiuLi',NULL,'186****0109',1,50,'2026-06-06 17:47:09','2026-07-01 17:47:09',25,5,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(110,'U010110','WuJing',NULL,'139****0110',2,31,'2026-06-08 17:47:09','2026-08-17 17:47:09',70,14,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(111,'U010111','LiuJuan',NULL,'186****0111',2,57,'2026-07-16 17:47:09','2026-08-09 17:47:09',24,4,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(112,'U010112','ZhouNa',NULL,'139****0112',2,34,'2026-10-18 17:47:09','2026-10-23 17:47:09',5,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(113,'U010113','WangJun',NULL,'186****0113',2,31,'2025-11-14 17:47:09','2026-07-03 17:47:09',231,46,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(114,'U010114','LiuJun',NULL,'186****0114',1,40,'2026-03-31 17:47:09','2026-04-18 17:47:09',18,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(115,'U010115','WangTao',NULL,'186****0115',2,48,'2026-06-18 17:47:09','2026-11-10 17:47:09',145,29,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(116,'U010116','LiuJun',NULL,'139****0116',2,35,'2026-04-27 17:47:09','2026-09-28 17:47:09',154,30,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(117,'U010117','ZhouFang',NULL,'139****0117',2,47,'2026-06-22 17:47:09','2026-10-16 17:47:09',116,23,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(118,'U010118','LiuQiang',NULL,'186****0118',1,46,'2026-10-25 17:47:09','2026-10-29 17:47:09',4,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(119,'U010119','LiuQiang',NULL,'139****0119',1,39,'2025-12-25 17:47:09','2026-10-10 17:47:09',289,57,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(120,'U010120','QianWei',NULL,'138****0120',2,20,'2026-01-20 17:47:09','2026-04-15 17:47:09',85,17,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(121,'U010121','LiuJun',NULL,'138****0121',2,20,'2025-12-07 17:47:09','2026-01-06 17:47:09',30,6,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(122,'U010122','ZhouWei',NULL,'139****0122',2,38,'2026-10-05 17:47:09','2026-11-12 17:47:09',38,7,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(123,'U010123','ZhengJuan',NULL,'138****0123',1,47,'2026-02-21 17:47:09','2026-10-07 17:47:09',228,45,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(124,'U010124','LiuJun',NULL,'186****0124',1,36,'2026-05-13 17:47:09','2026-09-08 17:47:09',118,23,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(125,'U010125','ZhengYang',NULL,'186****0125',1,29,'2026-09-03 17:47:09','2026-09-26 17:47:09',23,4,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(126,'U010126','WangTao',NULL,'186****0126',1,47,'2026-04-26 17:47:09','2026-09-16 17:47:09',143,28,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(127,'U010127','ZhengNa',NULL,'138****0127',2,21,'2026-08-16 17:47:09','2026-10-16 17:47:09',61,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(128,'U010128','WuLi',NULL,'139****0128',1,26,'2026-09-18 17:47:09','2026-11-12 17:47:09',55,11,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(129,'U010129','ZhouLei',NULL,'139****0129',1,21,'2026-10-17 17:47:09','2026-11-03 17:47:09',17,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(130,'U010130','ZhangFang',NULL,'138****0130',2,29,'2026-10-29 17:47:09','2026-11-04 17:47:09',6,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(131,'U010131','ZhangQiang',NULL,'138****0131',2,23,'2026-09-27 17:47:09','2026-10-19 17:47:09',22,4,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(132,'U010132','ZhengTao',NULL,'139****0132',2,50,'2025-11-24 17:47:09','2026-05-05 17:47:09',162,32,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(133,'U010133','SunTao',NULL,'139****0133',1,52,'2026-06-09 17:47:09','2026-06-24 17:47:09',15,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(134,'U010134','LiMin',NULL,'138****0134',1,51,'2026-03-18 17:47:09','2026-10-30 17:47:09',226,45,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(135,'U010135','WuWei',NULL,'138****0135',1,25,'2026-05-30 17:47:09','2026-07-02 17:47:09',33,6,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(136,'U010136','WuFang',NULL,'186****0136',2,53,'2026-09-17 17:47:09','2026-11-06 17:47:09',50,10,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(137,'U010137','LiJuan',NULL,'186****0137',1,27,'2026-04-09 17:47:09','2026-06-24 17:47:09',76,15,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(138,'U010138','ZhaoLei',NULL,'186****0138',1,50,'2026-01-05 17:47:09','2026-06-08 17:47:09',154,30,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(139,'U010139','ZhaoYan',NULL,'186****0139',2,23,'2025-12-13 17:47:09','2026-03-24 17:47:09',101,20,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(140,'U010140','SunFang',NULL,'186****0140',2,18,'2026-04-02 17:47:09','2026-08-28 17:47:09',148,29,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(141,'U010141','WangJuan',NULL,'139****0141',1,21,'2026-06-30 17:47:09','2026-10-21 17:47:09',113,22,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(142,'U010142','LiuQiang',NULL,'139****0142',1,45,'2026-06-28 17:47:09','2026-07-14 17:47:09',16,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(143,'U010143','ZhaoWei',NULL,'138****0143',1,52,'2026-11-12 17:47:09','2026-11-12 17:47:09',0,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(144,'U010144','ZhouYan',NULL,'186****0144',1,57,'2026-04-21 17:47:09','2026-06-16 17:47:09',56,11,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(145,'U010145','QianTao',NULL,'139****0145',1,23,'2025-11-15 17:47:09','2026-05-28 17:47:09',194,38,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(146,'U010146','WangLei',NULL,'139****0146',1,37,'2026-09-24 17:47:09','2026-10-28 17:47:09',34,6,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(147,'U010147','ZhengTao',NULL,'139****0147',2,52,'2026-10-24 17:47:09','2026-10-26 17:47:09',2,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(148,'U010148','ZhangJun',NULL,'186****0148',1,47,'2026-05-18 17:47:09','2026-10-30 17:47:09',165,33,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(149,'U010149','WangYan',NULL,'138****0149',2,37,'2026-09-02 17:47:09','2026-10-10 17:47:09',38,7,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(150,'U010150','ZhengJun',NULL,'138****0150',1,23,'2026-07-04 17:47:09','2026-08-04 17:47:09',31,6,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(151,'U010151','LiLi',NULL,'139****0151',2,23,'2026-10-04 17:47:09','2026-10-17 17:47:09',13,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(152,'U010152','LiQiang',NULL,'138****0152',1,18,'2026-03-17 17:47:09','2026-06-05 17:47:09',80,16,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(153,'U010153','WangJie',NULL,'139****0153',2,54,'2026-10-05 17:47:09','2026-10-16 17:47:09',11,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(154,'U010154','LiuJie',NULL,'186****0154',2,39,'2026-09-19 17:47:09','2026-11-07 17:47:09',49,9,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(155,'U010155','LiuTao',NULL,'138****0155',2,50,'2026-11-09 17:47:09','2026-11-12 17:47:09',3,0,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(156,'U010156','ZhouJuan',NULL,'186****0156',1,48,'2025-12-30 17:47:09','2026-11-12 17:47:09',317,63,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(157,'U010157','WuJun',NULL,'186****0157',1,57,'2026-07-21 17:47:09','2026-07-30 17:47:09',9,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(158,'U010158','ZhaoLei',NULL,'138****0158',1,19,'2026-04-19 17:47:09','2026-10-01 17:47:09',165,33,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(159,'U010159','QianYang',NULL,'186****0159',2,48,'2026-09-16 17:47:09','2026-11-12 17:47:09',57,11,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(160,'U010160','WangLi',NULL,'186****0160',2,44,'2026-10-14 17:47:09','2026-10-29 17:47:09',15,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(161,'U010161','ZhengFang',NULL,'186****0161',2,38,'2026-06-27 17:47:09','2026-09-27 17:47:09',92,18,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(162,'U010162','ZhouJuan',NULL,'139****0162',1,51,'2026-03-14 17:47:09','2026-10-22 17:47:09',222,44,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(163,'U010163','ZhouTao',NULL,'138****0163',1,25,'2026-02-18 17:47:09','2026-05-09 17:47:09',80,16,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(164,'U010164','ZhaoQiang',NULL,'138****0164',1,47,'2026-09-11 17:47:09','2026-09-16 17:47:09',5,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(165,'U010165','QianYang',NULL,'186****0165',2,57,'2026-01-05 17:47:09','2026-01-11 17:47:09',6,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(166,'U010166','LiYan',NULL,'139****0166',2,38,'2025-12-17 17:47:09','2025-12-23 17:47:09',6,1,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(167,'U010167','LiuLi',NULL,'139****0167',2,51,'2026-07-26 17:47:09','2026-08-09 17:47:09',14,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(168,'U010168','ZhangJie',NULL,'138****0168',2,39,'2026-02-05 17:47:09','2026-03-22 17:47:09',45,9,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(169,'U010169','ZhouLei',NULL,'186****0169',1,52,'2026-07-13 17:47:09','2026-09-11 17:47:09',60,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(170,'U010170','QianTao',NULL,'186****0170',1,55,'2025-12-08 17:47:09','2026-04-18 17:47:09',131,26,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(171,'U010171','LiuWei',NULL,'138****0171',1,24,'2026-06-21 17:47:09','2026-11-04 17:47:09',136,27,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(172,'U010172','QianLi',NULL,'186****0172',1,30,'2026-03-08 17:47:09','2026-08-21 17:47:09',166,33,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(173,'U010173','LiYong',NULL,'139****0173',1,39,'2026-08-02 17:47:09','2026-11-12 17:47:09',102,20,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(174,'U010174','LiuTao',NULL,'138****0174',1,36,'2026-01-27 17:47:09','2026-06-15 17:47:09',139,27,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(175,'U010175','SunFang',NULL,'186****0175',2,33,'2026-04-29 17:47:09','2026-11-09 17:47:09',194,38,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(176,'U010176','ZhouFang',NULL,'186****0176',1,29,'2026-06-16 17:47:09','2026-08-11 17:47:09',56,11,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(177,'U010177','ZhouQiang',NULL,'138****0177',2,36,'2026-08-23 17:47:09','2026-11-09 17:47:09',78,15,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(178,'U010178','ZhengJie',NULL,'186****0178',1,50,'2026-04-22 17:47:09','2026-10-09 17:47:09',170,34,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(179,'U010179','SunJie',NULL,'186****0179',1,52,'2026-08-11 17:47:09','2026-10-19 17:47:09',69,13,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(180,'U010180','WuFang',NULL,'139****0180',2,25,'2026-02-22 17:47:09','2026-09-10 17:47:09',200,40,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(181,'U010181','WuFang',NULL,'186****0181',2,42,'2026-08-06 17:47:09','2026-09-14 17:47:09',39,7,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(182,'U010182','ZhaoNa',NULL,'138****0182',2,23,'2026-08-28 17:47:09','2026-10-31 17:47:09',64,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(183,'U010183','SunYang',NULL,'139****0183',2,30,'2025-12-19 17:47:09','2026-02-20 17:47:09',63,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(184,'U010184','SunJing',NULL,'186****0184',2,36,'2026-05-26 17:47:09','2026-09-13 17:47:09',110,22,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(185,'U010185','ZhaoYong',NULL,'186****0185',1,22,'2026-02-21 17:47:09','2026-06-14 17:47:09',113,22,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(186,'U010186','WuLi',NULL,'186****0186',1,47,'2026-06-30 17:47:09','2026-07-10 17:47:09',10,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(187,'U010187','ZhaoWei',NULL,'139****0187',1,56,'2026-09-27 17:47:09','2026-10-22 17:47:09',25,5,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(188,'U010188','LiuFang',NULL,'139****0188',2,25,'2026-06-03 17:47:09','2026-08-13 17:47:09',71,14,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(189,'U010189','LiJing',NULL,'138****0189',1,41,'2026-05-15 17:47:09','2026-05-16 17:47:09',1,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(190,'U010190','ZhangJun',NULL,'186****0190',1,31,'2026-02-25 17:47:09','2026-05-13 17:47:09',77,15,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(191,'U010191','WuYong',NULL,'138****0191',2,36,'2026-01-01 17:47:09','2026-01-11 17:47:09',10,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(192,'U010192','LiuNa',NULL,'139****0192',1,41,'2026-11-12 17:47:09','2026-11-12 17:47:09',0,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(193,'U010193','ZhengQiang',NULL,'139****0193',1,27,'2026-10-09 17:47:09','2026-10-22 17:47:09',13,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(194,'U010194','WangJuan',NULL,'186****0194',1,30,'2025-11-25 17:47:09','2026-01-29 17:47:09',65,13,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(195,'U010195','ZhengMin',NULL,'186****0195',1,35,'2026-04-27 17:47:09','2026-11-12 17:47:09',199,39,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(196,'U010196','SunTao',NULL,'139****0196',1,26,'2025-12-14 17:47:09','2026-11-02 17:47:09',323,64,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(197,'U010197','QianMin',NULL,'138****0197',2,21,'2026-07-12 17:47:09','2026-07-26 17:47:09',14,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(198,'U010198','QianJing',NULL,'186****0198',1,39,'2026-08-17 17:47:09','2026-10-02 17:47:09',46,9,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(199,'U010199','ZhaoQiang',NULL,'139****0199',1,40,'2026-01-06 17:47:09','2026-09-09 17:47:09',246,49,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(200,'U010200','ZhaoLi',NULL,'186****0200',2,50,'2026-07-17 17:47:09','2026-07-26 17:47:09',9,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(201,'U010201','ZhaoJie',NULL,'138****0201',2,19,'2026-09-15 17:47:09','2026-11-11 17:47:09',57,11,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(202,'U010202','ZhangJuan',NULL,'138****0202',1,56,'2026-04-20 17:47:09','2026-06-25 17:47:09',66,13,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(203,'U010203','ZhaoNa',NULL,'138****0203',2,36,'2026-10-15 17:47:09','2026-11-05 17:47:09',21,4,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(204,'U010204','SunYan',NULL,'186****0204',1,55,'2026-07-03 17:47:09','2026-09-18 17:47:09',77,15,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(205,'U010205','LiJuan',NULL,'138****0205',2,38,'2026-02-04 17:47:09','2026-08-04 17:47:09',181,36,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(206,'U010206','LiNa',NULL,'139****0206',2,21,'2026-07-31 17:47:09','2026-10-25 17:47:09',86,17,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(207,'U010207','WuJing',NULL,'139****0207',1,41,'2026-08-29 17:47:09','2026-09-02 17:47:09',4,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(208,'U010208','ZhangYang',NULL,'186****0208',2,18,'2026-11-05 17:47:09','2026-11-10 17:47:09',5,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(209,'U010209','ZhengMin',NULL,'139****0209',1,42,'2026-04-17 17:47:09','2026-10-27 17:47:09',193,38,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(210,'U010210','SunJing',NULL,'138****0210',2,49,'2026-02-13 17:47:09','2026-03-12 17:47:09',27,5,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(211,'U010211','LiuNa',NULL,'138****0211',1,50,'2026-07-03 17:47:09','2026-10-07 17:47:09',96,19,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(212,'U010212','WangMin',NULL,'139****0212',1,35,'2026-05-04 17:47:09','2026-08-17 17:47:09',105,21,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(213,'U010213','QianYang',NULL,'186****0213',2,25,'2026-08-07 17:47:09','2026-10-03 17:47:09',57,11,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(214,'U010214','QianFang',NULL,'186****0214',1,53,'2026-09-20 17:47:09','2026-10-18 17:47:09',28,5,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(215,'U010215','QianJuan',NULL,'138****0215',1,18,'2026-10-26 17:47:09','2026-10-30 17:47:09',4,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(216,'U010216','LiYang',NULL,'138****0216',1,37,'2026-10-24 17:47:09','2026-10-31 17:47:09',7,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(217,'U010217','WangLei',NULL,'139****0217',2,37,'2026-04-15 17:47:09','2026-05-06 17:47:09',21,4,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(218,'U010218','ZhengYan',NULL,'186****0218',2,54,'2026-02-05 17:47:09','2026-07-16 17:47:09',161,32,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(219,'U010219','WangMin',NULL,'138****0219',2,56,'2026-07-22 17:47:09','2026-10-27 17:47:09',97,19,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(220,'U010220','ZhengFang',NULL,'186****0220',2,18,'2026-07-05 17:47:09','2026-08-30 17:47:09',56,11,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(221,'U010221','QianYong',NULL,'186****0221',1,30,'2026-10-28 17:47:09','2026-11-10 17:47:09',13,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(222,'U010222','SunLei',NULL,'138****0222',1,54,'2026-11-03 17:47:09','2026-11-06 17:47:09',3,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(223,'U010223','ZhangJun',NULL,'186****0223',1,56,'2026-07-07 17:47:09','2026-10-25 17:47:09',110,22,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(224,'U010224','WuYong',NULL,'139****0224',2,34,'2026-02-09 17:47:09','2026-03-21 17:47:09',40,8,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(225,'U010225','WuYang',NULL,'138****0225',1,21,'2025-11-23 17:47:09','2026-02-12 17:47:09',81,16,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(226,'U010226','ZhengJie',NULL,'139****0226',1,53,'2026-05-02 17:47:09','2026-08-27 17:47:09',117,23,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(227,'U010227','ZhouJie',NULL,'186****0227',2,40,'2026-10-20 17:47:09','2026-11-09 17:47:09',20,4,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(228,'U010228','ZhangLi',NULL,'139****0228',1,26,'2026-08-08 17:47:09','2026-08-21 17:47:09',13,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(229,'U010229','SunYang',NULL,'186****0229',1,18,'2026-05-18 17:47:09','2026-05-22 17:47:09',4,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(230,'U010230','LiuLei',NULL,'139****0230',2,35,'2026-02-22 17:47:09','2026-11-01 17:47:09',252,50,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(231,'U010231','ZhouWei',NULL,'139****0231',2,52,'2026-07-14 17:47:09','2026-08-28 17:47:09',45,9,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(232,'U010232','SunYong',NULL,'139****0232',2,41,'2026-10-09 17:47:09','2026-10-23 17:47:09',14,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(233,'U010233','SunLi',NULL,'138****0233',1,19,'2026-09-30 17:47:09','2026-10-08 17:47:09',8,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(234,'U010234','ZhangNa',NULL,'139****0234',1,32,'2026-03-14 17:47:09','2026-06-06 17:47:09',84,16,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(235,'U010235','ZhangFang',NULL,'186****0235',2,47,'2026-06-21 17:47:09','2026-10-18 17:47:09',119,23,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(236,'U010236','ZhouFang',NULL,'138****0236',1,46,'2026-06-22 17:47:09','2026-08-26 17:47:09',65,13,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(237,'U010237','ZhouNa',NULL,'138****0237',1,52,'2026-04-16 17:47:09','2026-06-28 17:47:09',73,14,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(238,'U010238','ZhengJun',NULL,'139****0238',2,26,'2026-09-24 17:47:09','2026-10-07 17:47:09',13,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(239,'U010239','ZhouQiang',NULL,'138****0239',2,39,'2025-12-13 17:47:09','2026-10-13 17:47:09',304,60,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(240,'U010240','WuTao',NULL,'186****0240',1,46,'2026-09-17 17:47:09','2026-11-02 17:47:09',46,9,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(241,'U010241','ZhaoJuan',NULL,'138****0241',1,22,'2026-08-26 17:47:09','2026-08-30 17:47:09',4,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(242,'U010242','ZhaoJuan',NULL,'186****0242',1,27,'2026-08-24 17:47:09','2026-08-30 17:47:09',6,1,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(243,'U010243','LiuFang',NULL,'138****0243',2,42,'2026-05-28 17:47:09','2026-07-21 17:47:09',54,10,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(244,'U010244','ZhengJing',NULL,'186****0244',2,31,'2026-04-10 17:47:09','2026-05-17 17:47:09',37,7,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(245,'U010245','WuWei',NULL,'139****0245',1,19,'2026-09-18 17:47:09','2026-11-09 17:47:09',52,10,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(246,'U010246','LiuJie',NULL,'186****0246',1,26,'2026-09-08 17:47:09','2026-10-10 17:47:09',32,6,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(247,'U010247','ZhangJie',NULL,'139****0247',2,30,'2026-04-20 17:47:09','2026-05-04 17:47:09',14,2,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(248,'U010248','ZhaoNa',NULL,'186****0248',2,32,'2025-12-18 17:47:09','2026-05-29 17:47:09',162,32,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(249,'U010249','SunTao',NULL,'138****0249',1,47,'2026-10-11 17:47:09','2026-10-17 17:47:09',6,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(250,'U010250','WuJun',NULL,'186****0250',1,36,'2025-12-18 17:47:09','2026-09-16 17:47:09',272,54,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(251,'U010251','WangJing',NULL,'138****0251',1,51,'2026-10-10 17:47:09','2026-10-13 17:47:09',3,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(252,'U010252','ZhaoJie',NULL,'139****0252',2,47,'2026-06-08 17:47:09','2026-10-16 17:47:09',130,26,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(253,'U010253','ZhouJuan',NULL,'138****0253',1,30,'2026-05-25 17:47:09','2026-07-24 17:47:09',60,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(254,'U010254','ZhouMin',NULL,'138****0254',2,54,'2026-05-14 17:47:09','2026-05-18 17:47:09',4,0,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(255,'U010255','ZhangQiang',NULL,'139****0255',2,38,'2026-06-07 17:47:09','2026-06-24 17:47:09',17,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(256,'U010256','ZhengJun',NULL,'138****0256',2,34,'2026-01-29 17:47:09','2026-08-22 17:47:09',205,41,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(257,'U010257','ZhengYan',NULL,'139****0257',1,21,'2026-07-10 17:47:09','2026-10-09 17:47:09',91,18,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(258,'U010258','WangLei',NULL,'186****0258',1,28,'2026-06-11 17:47:09','2026-08-14 17:47:09',64,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(259,'U010259','LiuTao',NULL,'186****0259',2,53,'2026-05-06 17:47:09','2026-11-12 17:47:09',190,38,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(260,'U010260','ZhengYong',NULL,'138****0260',1,26,'2026-02-09 17:47:09','2026-04-28 17:47:09',78,15,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(261,'U010261','QianJuan',NULL,'139****0261',1,43,'2026-01-26 17:47:09','2026-04-16 17:47:09',80,16,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(262,'U010262','SunNa',NULL,'186****0262',1,40,'2026-02-16 17:47:09','2026-03-13 17:47:09',25,5,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(263,'U010263','WangNa',NULL,'138****0263',1,46,'2026-01-31 17:47:09','2026-06-01 17:47:09',121,24,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(264,'U010264','SunJuan',NULL,'186****0264',2,26,'2026-08-28 17:47:09','2026-11-08 17:47:09',72,14,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(265,'U010265','SunQiang',NULL,'186****0265',2,44,'2026-01-14 17:47:09','2026-09-12 17:47:09',241,48,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(266,'U010266','LiuYong',NULL,'139****0266',2,37,'2026-04-27 17:47:09','2026-07-30 17:47:09',94,18,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(267,'U010267','LiuFang',NULL,'186****0267',2,20,'2026-04-06 17:47:09','2026-06-18 17:47:09',73,14,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(268,'U010268','ZhangFang',NULL,'138****0268',2,36,'2025-11-16 17:47:09','2026-06-19 17:47:09',215,43,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(269,'U010269','LiuJing',NULL,'138****0269',2,40,'2025-11-18 17:47:09','2026-08-17 17:47:09',272,54,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(270,'U010270','LiuWei',NULL,'139****0270',1,55,'2026-04-12 17:47:09','2026-04-27 17:47:09',15,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(271,'U010271','ZhaoNa',NULL,'139****0271',2,39,'2026-10-15 17:47:09','2026-10-27 17:47:09',12,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(272,'U010272','LiJuan',NULL,'186****0272',1,38,'2026-03-27 17:47:09','2026-05-09 17:47:09',43,8,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(273,'U010273','SunLei',NULL,'138****0273',1,42,'2026-05-29 17:47:09','2026-09-29 17:47:09',123,24,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(274,'U010274','WangYan',NULL,'139****0274',2,57,'2026-08-27 17:47:09','2026-09-01 17:47:09',5,1,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(275,'U010275','ZhengNa',NULL,'186****0275',1,47,'2026-04-22 17:47:09','2026-06-14 17:47:09',53,10,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(276,'U010276','WangLei',NULL,'186****0276',1,33,'2026-07-05 17:47:09','2026-08-22 17:47:09',48,9,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(277,'U010277','LiQiang',NULL,'138****0277',1,22,'2026-01-31 17:47:09','2026-08-27 17:47:09',208,41,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(278,'U010278','LiuMin',NULL,'186****0278',2,55,'2026-01-26 17:47:09','2026-07-10 17:47:09',165,33,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(279,'U010279','LiNa',NULL,'139****0279',2,21,'2026-05-21 17:47:09','2026-07-23 17:47:09',63,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(280,'U010280','SunFang',NULL,'139****0280',2,23,'2025-12-24 17:47:09','2026-05-20 17:47:09',147,29,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(281,'U010281','SunJie',NULL,'186****0281',1,56,'2026-09-16 17:47:09','2026-09-25 17:47:09',9,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(282,'U010282','WangYong',NULL,'139****0282',1,25,'2026-03-06 17:47:09','2026-08-15 17:47:09',162,32,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(283,'U010283','SunYong',NULL,'138****0283',2,21,'2026-11-03 17:47:09','2026-11-10 17:47:09',7,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(284,'U010284','ZhangYan',NULL,'186****0284',1,25,'2026-01-16 17:47:09','2026-03-05 17:47:09',48,9,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(285,'U010285','ZhengYang',NULL,'138****0285',1,21,'2026-04-11 17:47:09','2026-11-03 17:47:09',206,41,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(286,'U010286','WuLei',NULL,'139****0286',2,36,'2026-07-15 17:47:09','2026-09-26 17:47:09',73,14,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(287,'U010287','ZhangJie',NULL,'186****0287',2,45,'2026-10-09 17:47:09','2026-10-11 17:47:09',2,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(288,'U010288','WuYang',NULL,'138****0288',1,44,'2026-05-12 17:47:09','2026-10-21 17:47:09',162,32,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(289,'U010289','WangYong',NULL,'139****0289',1,57,'2026-11-12 17:47:09','2026-11-12 17:47:09',0,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(290,'U010290','ZhouJun',NULL,'186****0290',1,22,'2026-03-26 17:47:09','2026-08-11 17:47:09',138,27,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(291,'U010291','WuJun',NULL,'138****0291',2,38,'2026-09-30 17:47:09','2026-10-11 17:47:09',11,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(292,'U010292','WangLi',NULL,'139****0292',1,34,'2026-06-30 17:47:09','2026-09-22 17:47:09',84,16,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(293,'U010293','ZhouJuan',NULL,'139****0293',1,48,'2025-12-16 17:47:09','2026-09-02 17:47:09',260,52,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(294,'U010294','ZhangFang',NULL,'186****0294',2,37,'2026-09-29 17:47:09','2026-10-01 17:47:09',2,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(295,'U010295','LiuNa',NULL,'139****0295',1,52,'2026-06-02 17:47:09','2026-08-05 17:47:09',64,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(296,'U010296','QianTao',NULL,'138****0296',2,47,'2026-03-31 17:47:09','2026-07-02 17:47:09',93,18,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(297,'U010297','SunJuan',NULL,'138****0297',2,19,'2025-12-11 17:47:09','2026-06-03 17:47:09',174,34,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(298,'U010298','LiuQiang',NULL,'139****0298',2,35,'2026-09-02 17:47:09','2026-10-12 17:47:09',40,8,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(299,'U010299','LiMin',NULL,'138****0299',1,43,'2025-12-15 17:47:09','2026-05-18 17:47:09',154,30,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(300,'U010300','ZhaoMin',NULL,'138****0300',1,55,'2025-12-20 17:47:09','2026-10-04 17:47:09',288,57,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(301,'U010301','WangTao',NULL,'138****0301',2,41,'2026-08-06 17:47:09','2026-10-03 17:47:09',58,11,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(302,'U010302','ZhengLi',NULL,'186****0302',2,35,'2026-06-17 17:47:09','2026-09-19 17:47:09',94,18,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(303,'U010303','ZhengTao',NULL,'139****0303',2,23,'2026-03-31 17:47:09','2026-08-20 17:47:09',142,28,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(304,'U010304','ZhengJuan',NULL,'139****0304',1,33,'2026-07-18 17:47:09','2026-09-22 17:47:09',66,13,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(305,'U010305','QianYang',NULL,'139****0305',2,32,'2026-05-18 17:47:09','2026-08-30 17:47:09',104,20,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(306,'U010306','ZhengWei',NULL,'138****0306',1,53,'2026-08-08 17:47:09','2026-09-23 17:47:09',46,9,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(307,'U010307','ZhouYang',NULL,'138****0307',2,37,'2026-06-19 17:47:09','2026-09-14 17:47:09',87,17,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(308,'U010308','LiFang',NULL,'139****0308',1,29,'2026-11-08 17:47:09','2026-11-10 17:47:09',2,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(309,'U010309','LiYan',NULL,'139****0309',2,46,'2026-05-06 17:47:09','2026-07-08 17:47:09',63,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(310,'U010310','LiuYang',NULL,'186****0310',1,30,'2026-08-05 17:47:09','2026-09-05 17:47:09',31,6,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(311,'U010311','ZhengLei',NULL,'139****0311',1,25,'2026-11-05 17:47:09','2026-11-11 17:47:09',6,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(312,'U010312','ZhengJuan',NULL,'139****0312',1,48,'2026-05-04 17:47:09','2026-09-19 17:47:09',138,27,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(313,'U010313','WangMin',NULL,'138****0313',1,32,'2026-06-02 17:47:09','2026-10-18 17:47:09',138,27,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(314,'U010314','ZhengTao',NULL,'138****0314',1,49,'2026-08-21 17:47:09','2026-11-09 17:47:09',80,16,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(315,'U010315','ZhaoJuan',NULL,'139****0315',1,45,'2026-05-18 17:47:09','2026-06-27 17:47:09',40,8,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(316,'U010316','SunLi',NULL,'186****0316',2,56,'2026-02-26 17:47:09','2026-05-20 17:47:09',83,16,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(317,'U010317','WuJun',NULL,'138****0317',1,31,'2026-04-13 17:47:09','2026-07-29 17:47:09',107,21,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(318,'U010318','ZhengMin',NULL,'186****0318',1,35,'2026-01-01 17:47:09','2026-11-03 17:47:09',306,61,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(319,'U010319','ZhouJie',NULL,'139****0319',2,23,'2026-01-23 17:47:09','2026-07-04 17:47:09',162,32,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(320,'U010320','QianQiang',NULL,'138****0320',2,56,'2026-01-05 17:47:09','2026-07-16 17:47:09',192,38,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(321,'U010321','LiJun',NULL,'139****0321',1,53,'2026-06-22 17:47:09','2026-07-10 17:47:09',18,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(322,'U010322','QianFang',NULL,'138****0322',1,37,'2026-10-13 17:47:09','2026-11-07 17:47:09',25,5,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(323,'U010323','LiMin',NULL,'186****0323',1,55,'2025-12-29 17:47:09','2026-11-04 17:47:09',310,62,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(324,'U010324','QianYong',NULL,'138****0324',1,39,'2026-06-07 17:47:09','2026-06-26 17:47:09',19,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(325,'U010325','ZhangYan',NULL,'139****0325',1,33,'2026-02-15 17:47:09','2026-10-20 17:47:09',247,49,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(326,'U010326','ZhangMin',NULL,'138****0326',2,21,'2026-09-20 17:47:09','2026-09-21 17:47:09',1,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(327,'U010327','WuYang',NULL,'139****0327',1,21,'2026-08-30 17:47:09','2026-09-17 17:47:09',18,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(328,'U010328','ZhengFang',NULL,'138****0328',2,27,'2026-03-25 17:47:09','2026-08-18 17:47:09',146,29,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(329,'U010329','WuJie',NULL,'139****0329',2,30,'2026-01-20 17:47:09','2026-10-21 17:47:09',274,54,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(330,'U010330','LiuJuan',NULL,'138****0330',2,23,'2025-12-25 17:47:09','2026-01-27 17:47:09',33,6,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(331,'U010331','SunJie',NULL,'186****0331',1,34,'2026-08-31 17:47:09','2026-11-11 17:47:09',72,14,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(332,'U010332','ZhaoMin',NULL,'186****0332',2,19,'2026-09-14 17:47:09','2026-09-23 17:47:09',9,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(333,'U010333','WuLei',NULL,'186****0333',2,56,'2026-07-29 17:47:09','2026-09-13 17:47:09',46,9,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(334,'U010334','QianYan',NULL,'186****0334',1,48,'2025-11-15 17:47:09','2026-04-15 17:47:09',151,30,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(335,'U010335','ZhaoYan',NULL,'139****0335',2,43,'2025-12-02 17:47:09','2026-09-15 17:47:09',287,57,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(336,'U010336','ZhengNa',NULL,'138****0336',2,37,'2026-06-16 17:47:09','2026-10-29 17:47:09',135,27,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(337,'U010337','SunJun',NULL,'139****0337',1,46,'2026-02-20 17:47:09','2026-04-30 17:47:09',69,13,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(338,'U010338','WangYan',NULL,'186****0338',1,30,'2026-09-28 17:47:09','2026-11-05 17:47:09',38,7,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(339,'U010339','ZhaoLei',NULL,'138****0339',1,53,'2026-08-21 17:47:09','2026-09-11 17:47:09',21,4,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(340,'U010340','LiMin',NULL,'186****0340',1,19,'2026-04-14 17:47:09','2026-06-09 17:47:09',56,11,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(341,'U010341','ZhaoNa',NULL,'186****0341',2,27,'2026-09-29 17:47:09','2026-10-26 17:47:09',27,5,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(342,'U010342','ZhaoMin',NULL,'138****0342',1,45,'2026-01-04 17:47:09','2026-08-13 17:47:09',221,44,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(343,'U010343','WuYong',NULL,'186****0343',2,47,'2025-12-06 17:47:09','2026-08-13 17:47:09',250,50,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(344,'U010344','LiuYan',NULL,'186****0344',2,24,'2026-04-26 17:47:09','2026-08-08 17:47:09',104,20,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(345,'U010345','ZhangYang',NULL,'138****0345',2,44,'2025-11-19 17:47:09','2026-08-22 17:47:09',276,55,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(346,'U010346','ZhangJing',NULL,'139****0346',1,40,'2026-10-05 17:47:09','2026-10-25 17:47:09',20,4,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(347,'U010347','LiuTao',NULL,'139****0347',1,57,'2026-09-24 17:47:09','2026-10-11 17:47:09',17,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(348,'U010348','ZhaoQiang',NULL,'138****0348',2,31,'2025-11-17 17:47:09','2026-06-17 17:47:09',212,42,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(349,'U010349','ZhengFang',NULL,'139****0349',2,53,'2026-03-15 17:47:09','2026-06-30 17:47:09',107,21,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(350,'U010350','SunQiang',NULL,'139****0350',1,32,'2026-09-09 17:47:09','2026-10-17 17:47:09',38,7,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(351,'U010351','SunWei',NULL,'138****0351',1,30,'2026-08-15 17:47:09','2026-08-30 17:47:09',15,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(352,'U010352','LiWei',NULL,'139****0352',2,54,'2026-05-26 17:47:09','2026-07-29 17:47:09',64,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(353,'U010353','LiJie',NULL,'139****0353',1,48,'2026-10-07 17:47:09','2026-10-26 17:47:09',19,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(354,'U010354','ZhaoYong',NULL,'186****0354',2,46,'2026-03-05 17:47:09','2026-05-07 17:47:09',63,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(355,'U010355','ZhaoWei',NULL,'139****0355',1,45,'2026-11-11 17:47:09','2026-11-12 17:47:09',1,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(356,'U010356','SunLi',NULL,'138****0356',2,20,'2026-08-03 17:47:09','2026-08-22 17:47:09',19,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(357,'U010357','ZhaoJing',NULL,'139****0357',1,25,'2026-01-09 17:47:09','2026-03-12 17:47:09',62,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(358,'U010358','WangWei',NULL,'139****0358',2,51,'2026-03-09 17:47:09','2026-06-29 17:47:09',112,22,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(359,'U010359','ZhengYong',NULL,'138****0359',2,54,'2026-04-24 17:47:09','2026-10-06 17:47:09',165,33,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(360,'U010360','ZhouQiang',NULL,'186****0360',2,38,'2025-12-18 17:47:09','2026-11-11 17:47:09',328,65,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(361,'U010361','ZhaoJun',NULL,'138****0361',2,52,'2026-09-19 17:47:09','2026-10-20 17:47:09',31,6,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(362,'U010362','ZhouJun',NULL,'186****0362',1,34,'2026-01-29 17:47:09','2026-06-30 17:47:09',152,30,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(363,'U010363','ZhengJie',NULL,'186****0363',1,55,'2026-05-23 17:47:09','2026-10-16 17:47:09',146,29,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(364,'U010364','QianNa',NULL,'186****0364',1,55,'2026-05-02 17:47:09','2026-10-29 17:47:09',180,36,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(365,'U010365','WangJie',NULL,'186****0365',2,50,'2026-01-09 17:47:09','2026-04-25 17:47:09',106,21,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(366,'U010366','ZhouJuan',NULL,'139****0366',1,18,'2026-07-30 17:47:09','2026-08-20 17:47:09',21,4,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(367,'U010367','QianLei',NULL,'138****0367',1,24,'2026-05-20 17:47:09','2026-06-23 17:47:09',34,6,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(368,'U010368','SunYong',NULL,'139****0368',2,42,'2026-07-26 17:47:09','2026-09-18 17:47:09',54,10,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(369,'U010369','ZhouJing',NULL,'186****0369',1,50,'2025-12-08 17:47:09','2026-09-12 17:47:09',278,55,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(370,'U010370','WangQiang',NULL,'139****0370',2,57,'2026-06-26 17:47:09','2026-08-01 17:47:09',36,7,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(371,'U010371','QianYang',NULL,'139****0371',2,41,'2026-05-04 17:47:09','2026-05-14 17:47:09',10,2,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(372,'U010372','ZhouMin',NULL,'186****0372',2,22,'2026-08-30 17:47:09','2026-11-08 17:47:09',70,14,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(373,'U010373','LiuJun',NULL,'186****0373',2,54,'2026-06-30 17:47:09','2026-09-14 17:47:09',76,15,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(374,'U010374','ZhouQiang',NULL,'139****0374',2,51,'2026-07-13 17:47:09','2026-07-29 17:47:09',16,3,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(375,'U010375','LiuMin',NULL,'186****0375',1,44,'2026-05-12 17:47:09','2026-06-12 17:47:09',31,6,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(376,'U010376','LiuJie',NULL,'186****0376',1,39,'2026-05-28 17:47:09','2026-10-31 17:47:09',156,31,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(377,'U010377','ZhouJun',NULL,'186****0377',2,25,'2026-10-06 17:47:09','2026-10-13 17:47:09',7,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(378,'U010378','ZhangJuan',NULL,'139****0378',2,32,'2026-03-26 17:47:09','2026-07-08 17:47:09',104,20,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(379,'U010379','WangJuan',NULL,'138****0379',1,23,'2026-05-30 17:47:09','2026-08-15 17:47:09',77,15,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(380,'U010380','WuQiang',NULL,'186****0380',1,43,'2026-04-07 17:47:09','2026-04-27 17:47:09',20,4,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(381,'U010381','ZhaoMin',NULL,'138****0381',2,57,'2026-07-19 17:47:09','2026-09-01 17:47:09',44,8,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(382,'U010382','ZhouLi',NULL,'139****0382',1,26,'2026-01-10 17:47:09','2026-10-24 17:47:09',287,57,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(383,'U010383','WuFang',NULL,'138****0383',2,31,'2026-06-12 17:47:09','2026-10-08 17:47:09',118,23,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(384,'U010384','SunLi',NULL,'186****0384',1,52,'2026-05-29 17:47:09','2026-06-12 17:47:09',14,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(385,'U010385','ZhouQiang',NULL,'138****0385',2,34,'2026-06-12 17:47:09','2026-09-30 17:47:09',110,22,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(386,'U010386','LiuYong',NULL,'186****0386',1,56,'2026-09-11 17:47:09','2026-10-10 17:47:09',29,5,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(387,'U010387','LiuYang',NULL,'138****0387',2,39,'2026-01-08 17:47:09','2026-06-04 17:47:09',147,29,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(388,'U010388','ZhengQiang',NULL,'138****0388',1,51,'2026-10-11 17:47:09','2026-10-23 17:47:09',12,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(389,'U010389','LiLi',NULL,'139****0389',2,49,'2025-12-06 17:47:09','2026-09-01 17:47:09',269,53,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(390,'U010390','SunWei',NULL,'138****0390',1,24,'2026-04-13 17:47:09','2026-05-04 17:47:09',21,4,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(391,'U010391','LiuWei',NULL,'186****0391',2,21,'2026-02-08 17:47:09','2026-11-07 17:47:09',272,54,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(392,'U010392','ZhangFang',NULL,'138****0392',2,52,'2026-08-27 17:47:09','2026-10-18 17:47:09',52,10,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(393,'U010393','LiuMin',NULL,'138****0393',1,41,'2026-01-04 17:47:09','2026-08-06 17:47:09',214,42,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(394,'U010394','WuWei',NULL,'138****0394',2,19,'2026-04-30 17:47:09','2026-10-25 17:47:09',178,35,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(395,'U010395','WangLi',NULL,'139****0395',2,20,'2026-03-06 17:47:09','2026-10-04 17:47:09',212,42,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(396,'U010396','WangJie',NULL,'186****0396',2,27,'2026-10-01 17:47:09','2026-10-25 17:47:09',24,4,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(397,'U010397','SunJun',NULL,'186****0397',1,21,'2025-11-19 17:47:09','2026-06-01 17:47:09',194,38,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(398,'U010398','ZhangMin',NULL,'186****0398',1,20,'2026-04-11 17:47:09','2026-07-09 17:47:09',89,17,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(399,'U010399','WangYang',NULL,'186****0399',2,19,'2026-07-03 17:47:09','2026-10-09 17:47:09',98,19,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(400,'U010400','ZhangMin',NULL,'186****0400',2,21,'2025-11-16 17:47:09','2026-07-10 17:47:09',236,47,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(401,'U010401','LiJing',NULL,'139****0401',1,50,'2026-06-13 17:47:09','2026-07-20 17:47:09',37,7,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(402,'U010402','ZhangJie',NULL,'138****0402',1,26,'2026-11-08 17:47:09','2026-11-10 17:47:09',2,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(403,'U010403','LiuWei',NULL,'138****0403',1,38,'2026-03-04 17:47:09','2026-07-31 17:47:09',149,29,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(404,'U010404','ZhengJie',NULL,'138****0404',1,50,'2026-10-07 17:47:09','2026-11-07 17:47:09',31,6,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(405,'U010405','WangNa',NULL,'139****0405',2,39,'2025-12-14 17:47:09','2026-05-22 17:47:09',159,31,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(406,'U010406','WuWei',NULL,'138****0406',1,44,'2026-09-04 17:47:09','2026-09-29 17:47:09',25,5,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(407,'U010407','SunWei',NULL,'186****0407',2,33,'2026-05-31 17:47:09','2026-07-11 17:47:09',41,8,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(408,'U010408','ZhengJing',NULL,'186****0408',1,25,'2025-11-18 17:47:09','2026-01-26 17:47:09',69,13,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(409,'U010409','LiMin',NULL,'139****0409',1,50,'2026-07-10 17:47:09','2026-11-07 17:47:09',120,24,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(410,'U010410','WangQiang',NULL,'138****0410',2,46,'2026-02-18 17:47:09','2026-09-04 17:47:09',198,39,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(411,'U010411','ZhaoJing',NULL,'186****0411',1,27,'2026-08-23 17:47:09','2026-10-07 17:47:09',45,9,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(412,'U010412','SunLei',NULL,'186****0412',2,44,'2026-07-09 17:47:09','2026-09-20 17:47:09',73,14,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(413,'U010413','WangJun',NULL,'186****0413',2,18,'2025-12-13 17:47:09','2026-07-05 17:47:09',204,40,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(414,'U010414','ZhangQiang',NULL,'139****0414',1,52,'2026-01-23 17:47:09','2026-03-28 17:47:09',64,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(415,'U010415','ZhangLei',NULL,'186****0415',1,38,'2025-12-04 17:47:09','2026-06-22 17:47:09',200,40,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(416,'U010416','SunJie',NULL,'186****0416',1,42,'2026-02-06 17:47:09','2026-10-13 17:47:09',249,49,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(417,'U010417','ZhouLei',NULL,'139****0417',1,21,'2026-07-05 17:47:09','2026-10-13 17:47:09',100,20,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(418,'U010418','ZhaoTao',NULL,'139****0418',2,36,'2026-04-28 17:47:09','2026-07-05 17:47:09',68,13,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(419,'U010419','LiuNa',NULL,'186****0419',2,36,'2026-06-04 17:47:09','2026-09-24 17:47:09',112,22,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(420,'U010420','ZhaoWei',NULL,'138****0420',2,52,'2026-07-28 17:47:09','2026-08-13 17:47:09',16,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(421,'U010421','QianJing',NULL,'139****0421',2,19,'2026-11-01 17:47:09','2026-11-10 17:47:09',9,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(422,'U010422','ZhouFang',NULL,'139****0422',1,42,'2026-11-09 17:47:09','2026-11-10 17:47:09',1,0,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(423,'U010423','ZhouJing',NULL,'138****0423',1,20,'2026-03-20 17:47:09','2026-09-08 17:47:09',172,34,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(424,'U010424','ZhengLi',NULL,'138****0424',2,34,'2025-11-20 17:47:09','2026-10-07 17:47:09',321,64,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(425,'U010425','ZhaoTao',NULL,'139****0425',2,23,'2026-04-24 17:47:09','2026-06-23 17:47:09',60,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(426,'U010426','WangFang',NULL,'139****0426',1,18,'2026-09-15 17:47:09','2026-09-17 17:47:09',2,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(427,'U010427','ZhouWei',NULL,'139****0427',2,18,'2026-02-22 17:47:09','2026-05-16 17:47:09',83,16,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(428,'U010428','LiJie',NULL,'139****0428',2,33,'2026-06-17 17:47:09','2026-10-26 17:47:09',131,26,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(429,'U010429','QianQiang',NULL,'186****0429',2,25,'2026-02-09 17:47:09','2026-08-06 17:47:09',178,35,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(430,'U010430','ZhangYan',NULL,'138****0430',1,57,'2026-08-27 17:47:09','2026-11-04 17:47:09',69,13,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(431,'U010431','LiuYan',NULL,'186****0431',2,48,'2026-03-19 17:47:09','2026-09-01 17:47:09',166,33,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(432,'U010432','ZhangJie',NULL,'139****0432',2,38,'2026-07-22 17:47:09','2026-07-31 17:47:09',9,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(433,'U010433','LiuWei',NULL,'186****0433',1,19,'2026-01-23 17:47:09','2026-02-20 17:47:09',28,5,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(434,'U010434','LiJie',NULL,'138****0434',1,18,'2025-12-23 17:47:09','2026-09-13 17:47:09',264,52,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(435,'U010435','LiuLei',NULL,'186****0435',2,37,'2026-09-17 17:47:09','2026-10-11 17:47:09',24,4,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(436,'U010436','ZhouYang',NULL,'138****0436',2,35,'2025-11-18 17:47:09','2025-12-04 17:47:09',16,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(437,'U010437','LiuLei',NULL,'138****0437',2,35,'2026-10-28 17:47:09','2026-11-12 17:47:09',15,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(438,'U010438','QianNa',NULL,'138****0438',2,18,'2026-08-31 17:47:09','2026-10-15 17:47:09',45,9,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(439,'U010439','SunMin',NULL,'139****0439',1,39,'2026-10-16 17:47:09','2026-11-04 17:47:09',19,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(440,'U010440','ZhangJun',NULL,'138****0440',1,35,'2026-03-19 17:47:09','2026-07-22 17:47:09',125,25,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(441,'U010441','LiuMin',NULL,'186****0441',2,25,'2026-01-31 17:47:09','2026-07-23 17:47:09',173,34,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(442,'U010442','WuFang',NULL,'138****0442',2,57,'2026-10-08 17:47:09','2026-10-14 17:47:09',6,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(443,'U010443','ZhangLi',NULL,'139****0443',1,18,'2026-04-24 17:47:09','2026-08-19 17:47:09',117,23,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(444,'U010444','LiuYang',NULL,'186****0444',1,36,'2026-06-18 17:47:09','2026-08-17 17:47:09',60,12,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(445,'U010445','WuJun',NULL,'139****0445',1,23,'2026-04-04 17:47:09','2026-05-08 17:47:09',34,6,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(446,'U010446','LiuLei',NULL,'186****0446',2,48,'2026-06-29 17:47:09','2026-10-26 17:47:09',119,23,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(447,'U010447','ZhengTao',NULL,'139****0447',2,51,'2026-02-06 17:47:09','2026-11-10 17:47:09',277,55,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(448,'U010448','LiuJing',NULL,'186****0448',2,38,'2026-11-07 17:47:09','2026-11-11 17:47:09',4,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(449,'U010449','ZhouLei',NULL,'138****0449',1,50,'2026-01-29 17:47:09','2026-09-21 17:47:09',235,47,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(450,'U010450','SunYong',NULL,'138****0450',2,21,'2026-04-29 17:47:09','2026-07-24 17:47:09',86,17,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(451,'U010451','ZhengWei',NULL,'186****0451',1,41,'2026-09-19 17:47:09','2026-09-21 17:47:09',2,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(452,'U010452','LiWei',NULL,'139****0452',1,39,'2026-07-04 17:47:09','2026-09-04 17:47:09',62,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(453,'U010453','LiTao',NULL,'138****0453',2,32,'2026-08-19 17:47:09','2026-09-11 17:47:09',23,4,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(454,'U010454','ZhangJuan',NULL,'139****0454',1,39,'2026-08-04 17:47:09','2026-08-30 17:47:09',26,5,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(455,'U010455','LiNa',NULL,'186****0455',2,46,'2026-06-29 17:47:09','2026-08-31 17:47:09',63,12,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(456,'U010456','ZhengMin',NULL,'139****0456',1,53,'2026-10-25 17:47:09','2026-10-29 17:47:09',4,0,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(457,'U010457','LiJuan',NULL,'138****0457',2,37,'2026-06-21 17:47:09','2026-10-31 17:47:09',132,26,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(458,'U010458','SunYang',NULL,'186****0458',2,24,'2025-12-24 17:47:09','2026-03-21 17:47:09',87,17,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(459,'U010459','SunJie',NULL,'186****0459',2,36,'2025-12-03 17:47:09','2026-09-04 17:47:09',275,55,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(460,'U010460','WangQiang',NULL,'138****0460',2,57,'2026-01-26 17:47:09','2026-06-07 17:47:09',132,26,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(461,'U010461','SunQiang',NULL,'138****0461',1,54,'2026-08-24 17:47:09','2026-10-28 17:47:09',65,13,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(462,'U010462','LiuWei',NULL,'138****0462',1,51,'2026-01-26 17:47:09','2026-06-20 17:47:09',145,29,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(463,'U010463','ZhouYong',NULL,'186****0463',1,27,'2026-03-20 17:47:09','2026-05-03 17:47:09',44,8,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(464,'U010464','WangNa',NULL,'138****0464',1,57,'2025-12-24 17:47:09','2026-11-07 17:47:09',318,63,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(465,'U010465','QianYang',NULL,'186****0465',2,25,'2026-05-04 17:47:09','2026-05-15 17:47:09',11,2,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(466,'U010466','ZhaoYang',NULL,'138****0466',2,56,'2026-01-27 17:47:09','2026-09-14 17:47:09',230,46,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(467,'U010467','SunJun',NULL,'139****0467',2,25,'2026-08-27 17:47:09','2026-11-04 17:47:09',69,13,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(468,'U010468','ZhangYang',NULL,'186****0468',2,36,'2026-01-12 17:47:09','2026-05-21 17:47:09',129,25,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(469,'U010469','ZhangJuan',NULL,'139****0469',1,19,'2026-06-12 17:47:09','2026-06-14 17:47:09',2,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(470,'U010470','WuJuan',NULL,'186****0470',2,36,'2026-05-14 17:47:09','2026-07-25 17:47:09',72,14,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(471,'U010471','WangJun',NULL,'139****0471',1,44,'2026-07-27 17:47:09','2026-10-08 17:47:09',73,14,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(472,'U010472','WuJie',NULL,'186****0472',2,27,'2026-08-08 17:47:09','2026-09-15 17:47:09',38,7,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(473,'U010473','ZhangYong',NULL,'138****0473',2,42,'2025-12-28 17:47:09','2026-11-03 17:47:09',310,62,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(474,'U010474','LiuYan',NULL,'186****0474',1,37,'2026-04-24 17:47:09','2026-09-30 17:47:09',159,31,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(475,'U010475','WuJing',NULL,'139****0475',2,40,'2026-04-05 17:47:09','2026-09-07 17:47:09',155,31,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(476,'U010476','ZhangYan',NULL,'138****0476',1,41,'2026-10-10 17:47:09','2026-10-25 17:47:09',15,3,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(477,'U010477','ZhangYong',NULL,'186****0477',2,37,'2026-04-23 17:47:09','2026-07-04 17:47:09',72,14,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(478,'U010478','LiuWei',NULL,'138****0478',2,26,'2026-06-04 17:47:09','2026-07-28 17:47:09',54,10,0,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(479,'U010479','LiuTao',NULL,'139****0479',1,43,'2026-05-03 17:47:09','2026-08-31 17:47:09',120,24,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(480,'U010480','LiuJuan',NULL,'186****0480',2,56,'2026-01-24 17:47:09','2026-03-06 17:47:09',41,8,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(481,'U010481','LiuJuan',NULL,'139****0481',2,51,'2026-11-10 17:47:09','2026-11-11 17:47:09',1,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(482,'U010482','ZhengYong',NULL,'139****0482',2,36,'2026-09-27 17:47:09','2026-10-12 17:47:09',15,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(483,'U010483','ZhouYang',NULL,'186****0483',1,50,'2026-08-11 17:47:09','2026-10-30 17:47:09',80,16,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(484,'U010484','WangLei',NULL,'139****0484',1,36,'2026-08-02 17:47:09','2026-08-10 17:47:09',8,1,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(485,'U010485','QianLi',NULL,'138****0485',2,34,'2026-07-09 17:47:09','2026-10-16 17:47:09',99,19,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(486,'U010486','ZhangFang',NULL,'138****0486',2,38,'2026-10-25 17:47:09','2026-11-01 17:47:09',7,1,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(487,'U010487','LiuNa',NULL,'186****0487',2,49,'2026-11-05 17:47:09','2026-11-09 17:47:09',4,0,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(488,'U010488','ZhengWei',NULL,'138****0488',1,40,'2026-09-25 17:47:09','2026-10-17 17:47:09',22,4,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(489,'U010489','ZhengLei',NULL,'186****0489',2,54,'2026-04-07 17:47:09','2026-10-14 17:47:09',190,38,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(490,'U010490','WangWei',NULL,'139****0490',1,57,'2026-10-21 17:47:09','2026-11-09 17:47:09',19,3,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(491,'U010491','WangYan',NULL,'138****0491',2,18,'2025-12-25 17:47:09','2026-06-08 17:47:09',165,33,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(492,'U010492','WangYong',NULL,'139****0492',1,33,'2026-01-22 17:47:09','2026-03-14 17:47:09',51,10,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(493,'U010493','SunNa',NULL,'138****0493',2,32,'2026-05-25 17:47:09','2026-09-08 17:47:09',106,21,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(494,'U010494','LiuJun',NULL,'139****0494',1,54,'2026-03-09 17:47:09','2026-10-03 17:47:09',208,41,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(495,'U010495','WangJie',NULL,'186****0495',1,49,'2026-03-17 17:47:09','2026-09-28 17:47:09',195,39,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(496,'U010496','ZhengYong',NULL,'139****0496',2,50,'2026-05-16 17:47:09','2026-09-20 17:47:09',127,25,2,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(497,'U010497','ZhangYan',NULL,'186****0497',1,40,'2026-04-06 17:47:09','2026-05-12 17:47:09',36,7,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(498,'U010498','LiuJuan',NULL,'139****0498',2,43,'2025-12-25 17:47:09','2026-08-13 17:47:09',231,46,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(499,'U010499','ZhengJun',NULL,'186****0499',2,34,'2026-09-21 17:47:09','2026-10-23 17:47:09',32,6,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(500,'U010500','QianJing',NULL,'139****0500',1,32,'2025-12-04 17:47:09','2026-09-06 17:47:09',276,55,1,'2026-11-12 17:47:09','2026-11-12 17:47:09',0),
(501,'U010001','刘杰',NULL,'186****0001',1,33,'2026-07-28 17:47:28','2026-11-10 17:47:28',105,21,2,'2026-11-12 17:47:28','2026-11-12 17:47:28',0),
(502,'U010002','赵敏',NULL,'138****0002',2,36,'2026-11-03 17:47:28','2026-11-10 17:47:28',7,1,1,'2026-11-12 17:47:28','2026-11-12 17:47:28',0);

/*Table structure for table `user` */

DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `username` varchar(50) NOT NULL COMMENT '用户名',
  `password` varchar(255) NOT NULL COMMENT '密码',
  `nickname` varchar(50) DEFAULT NULL COMMENT '昵称',
  `email` varchar(100) DEFAULT NULL COMMENT '邮箱',
  `phone` varchar(20) DEFAULT NULL COMMENT '手机号',
  `gender` tinyint DEFAULT NULL COMMENT '性别 1男 2女',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `user_type` tinyint DEFAULT '1' COMMENT '1普通用户 2管理员',
  `status` tinyint DEFAULT '1' COMMENT '1正常 0禁用',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='用户表';

/*Data for the table `user` */

/*Table structure for table `warning_order` */

DROP TABLE IF EXISTS `warning_order`;

CREATE TABLE `warning_order` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '主键',
  `rule_id` bigint DEFAULT NULL COMMENT '关联的规则ID',
  `user_id` bigint NOT NULL COMMENT '触发预警的用户ID',
  `user_name` varchar(50) NOT NULL COMMENT '用户姓名(冗余字段，方便查询)',
  `uid` varchar(50) DEFAULT NULL COMMENT '用户编号',
  `source` varchar(50) NOT NULL COMMENT '来源 (量表/AI对话/指标)',
  `trigger_reason` varchar(255) NOT NULL COMMENT '触发原因',
  `risk_level` varchar(20) NOT NULL COMMENT '风险等级 (高危/中危/低危)',
  `trigger_time` datetime DEFAULT CURRENT_TIMESTAMP COMMENT '触发时间',
  `status` varchar(20) NOT NULL DEFAULT '待处理' COMMENT '状态 (待处理/跟进中/已闭环/已忽略)',
  `is_overdue` tinyint DEFAULT '0' COMMENT '是否超时 1是 0否',
  `remain_time` varchar(20) DEFAULT NULL COMMENT '剩余时间(仅前端展示用，如"22h")',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='预警记录表';

/*Data for the table `warning_order` */

insert  into `warning_order`(`id`,`rule_id`,`user_id`,`user_name`,`uid`,`source`,`trigger_reason`,`risk_level`,`trigger_time`,`status`,`is_overdue`,`remain_time`,`created_at`) values 
(1,NULL,1,'李静怡','U8821','量表','PHQ-9 得分 22 分，连续 3 次测评升高','高危','2024-06-12 09:24:00','待处理',1,NULL,'2026-10-31 18:59:58'),
(2,NULL,2,'王志强','U7745','AI 对话','对话中命中自伤倾向高危关键词','高危','2024-06-12 08:51:00','待处理',1,NULL,'2026-10-31 18:59:58'),
(3,NULL,3,'陈思远','U6521','指标','心率连续 2 天异常偏高（>110bpm）','高危','2024-06-12 07:30:00','待处理',0,'22h','2026-10-31 18:59:58'),
(4,NULL,4,'张雅琴','U9102','量表','GAD-7 焦虑得分 17 分（重度）','中危','2024-06-12 06:15:00','跟进中',0,'45h','2026-10-31 18:59:58'),
(5,NULL,5,'刘晓峰','U3387','量表','睡眠质量评分较上周下降 40%','中危','2024-06-11 22:48:00','跟进中',0,'39h','2026-10-31 18:59:58');

/*Table structure for table `warning_rule` */

DROP TABLE IF EXISTS `warning_rule`;

CREATE TABLE `warning_rule` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '规则ID',
  `name` varchar(100) NOT NULL COMMENT '规则名称',
  `description` varchar(255) DEFAULT NULL COMMENT '规则描述',
  `category` varchar(50) NOT NULL COMMENT '分类',
  `priority` varchar(10) NOT NULL COMMENT '优先级 P0/P1/P2',
  `status` tinyint NOT NULL DEFAULT '1' COMMENT '状态 1启用 0停用',
  `logic` varchar(10) NOT NULL DEFAULT 'AND' COMMENT '条件逻辑 AND/OR',
  `conditions_json` json NOT NULL COMMENT '触发条件 JSON 数组',
  `window_json` json DEFAULT NULL COMMENT '统计周期配置',
  `grading_json` json DEFAULT NULL COMMENT '风险分级配置',
  `notify_json` json DEFAULT NULL COMMENT '通知策略配置',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='预警规则表';

/*Data for the table `warning_rule` */

insert  into `warning_rule`(`id`,`name`,`description`,`category`,`priority`,`status`,`logic`,`conditions_json`,`window_json`,`grading_json`,`notify_json`,`created_at`,`updated_at`) values 
(1,'1测试','是11','psychology','P0',0,'AND','[{\"field\": \"gad7.total\", \"value\": \"1111\", \"operator\": \"gte\"}, {\"field\": \"gad7.delta\", \"value\": \"1111\", \"operator\": \"gte\"}]','{\"check_freq\": \"realtime\", \"consecutive\": 2, \"stat_period\": \"14d\"}','{\"level\": \"high\", \"escalate\": true, \"timer_rule\": \"all_day\", \"first_followup_hours\": 4}','{\"channels\": [\"wechat\", \"inner\"], \"receiver\": \"owner\", \"send_time\": \"immediate\", \"quiet_hours\": true}','2026-10-31 14:36:54','2026-10-31 14:49:00');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
