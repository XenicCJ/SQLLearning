#DDL，DATA MANAGMENT LANGUAGE数据库定义语言

#数据库操作

#查询所有数据库
#SHOW DATABASES;
SHOW DATABASES;

#查询当前数据库
#SELECT DATABASE();
SELECT DATABASE();

#创建数据库
#CREATE DATABASE [IF NOT EXISTS] 数据库名 [DEFAULT CHARSET 字符集] [COLLATE 排序规则];
CREATE DATABASE IF NOT EXISTS TEST DEFAULT CHARSET UTF8MB4 COLLATE UTF8MB4_GENERAL_CI;

#删除数据库
#DROP DATABASE [IF EXISTS] 数据库名;
DROP DATABASE IF EXISTS TEST;

#使用数据库
#USE 数据库名;
USE TEST;
USE SYS;

#DDL-表操作-查询

#查询当前数据库所有表
SHOW TABLES;

#查询表结构
#DESC 表名;
DESC employees;

#查询指定表的建表语句
#SHOW CREATE TABLE 表名;
SHOW CREATE TABLE employees;

#DDL-表操作-表创建

#创建新的表
/*
CREATE TABLE 表名(
	字段1 字段1类型 [COMMENT 字段1注释],
    字段2 字段2类型 [COMMENT 字段2注释],
    字段3 字段3类型 [COMMENT 字段3注释],
    ...
    字段n 字段n类型 [COMMENT 字段n注释]
)[COMMENT 表注释];
*/
CREATE TABLE STUDENTS(
	id int COMMENT "学生号码",
    name VARCHAR(20) COMMENT "名字",
    age int COMMENT "年龄",
    gender varchar(1) comment "性别"
)COMMENT "学生表";

#DDL-表操作-数据类型

#MySQL中数据类型有很多，主要分三类：数值类型、字符串类型、日期时间类型

#数值类型：tinyint、smallint、mediumint、int或integer、bigint、float、double、decimal,浮点数可以规定精度和标度
#字符串类型：char（主要用以定长字符串，性能相对好）、varchar（主要用以变长字符串，性能相对差）、tinyblob、tinytext、blob、text、mediumblob、mediumtext、longblob、longtext，blob存储二进制数据，text存储文本数据
#日期时间类型：date（日期值）、time（时间值）、year（年）、datetime（混合日期加时间）、timestamp（混合日期时间和时间戳）

#创建一个比较完整的员工表范例
create table employees(
	id int comment '编号',
    workno varchar(10) comment '工号',
    empname varchar(10) comment '姓名',
    gender char(1) comment '性别',
    age tinyint unsigned comment '年龄',
    idcard char(18) comment '身份证号',
    emptime date comment '入职时间'
)comment '员工基础信息表';

#DDL-表操作-修改

#添加字段
#alter table 表名 add 字段名 类型(长度) [comment 注释][约束]
alter table employers add nickname varchar(20) comment '昵称';

#修改数据类型
#alter table 表名 modify 字段名 新数据类型(长度);
#修改字段名和字段类型
#alter table 表名 change 旧字段名 新字段名 类型(长度) [comment 注释][约束];
alter  table employers change nickname username varchar(30) comment '用户名';

#删除字段
#alter table 表名 drop 字段名;
alter table employers drop username;

#修改表名
#alter table 表名 rename to 新表名;
alter table employers rename to emp;

#删除表
#drop table [if exists] 表名;
drop table if exists emp;

#删除表并重新创建该表
#truncate table 表名;
truncate table employees;