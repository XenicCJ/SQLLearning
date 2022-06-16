/*
学习内容：
	基础篇：Mysql概述、SQl、函数、约束、多表查询、事物
    进阶篇：存储引擎、索引、SQL优化、视图、存储过程、触发器、锁、InnoDB核心、Mysql管理
    运维篇：日志、主从复制、分库分表、读写分离
*/
/*
数据库相关概念：
	数据库（Database，DB）：存储数据的仓库，数据有组织地进行存储
    数据库管理系统（Database Management System，DBMS）：操作和管理数据库的大型软件
    SQL（Structured Query Language）：操作关系型数据库的编程语言，定义了一套操作关系型数据库的统一标准
*/
/*
主流DBMS：
	ORACLE、Mysql、SQL Server、PostgreSQL，它们都以SQL为编程语言
*/
/*
Mysql的安装与连接：
	略
*/
/*
关系型数据库：
	建立在关系模型基础上，由多张相互连接的二维表组成的数据库
数据模型：
	客户端连接DBMS，DBMS创建和操作数据库，数据库中存储数据表，MySQL数据库服务器包含DBMS和数据库
*/
/*
SQL通用语法：
	SQl语句可以单行或多行书写，以分号结尾
    SQL语句可以使用空格和缩进增强可读性
    MySQL数据库的SQL不区分大小写
    单行注释使用--或#（MySQL特有），多行注释使用斜杠和星号
*/
/*
SQL分类：
	DDL，Data Definition Language，定义数据库对象（数据库、表、字段）
    DML，Data Management Language，对数据库表中数据进行增删改
    DQL，Data Query Language，查询数据库中表的数据
    DCL，Data Control Language，创建数据库用户、控制数据库访问权限
*/