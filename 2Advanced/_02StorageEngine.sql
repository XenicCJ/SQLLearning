#存储引擎

#MySQl体系结构
#存储引擎简介
#存储引擎特点
#存储引擎选择

#MySQl体系结构
-- 1). 连接层
-- 最上层是一些客户端和链接服务，包含本地sock 通信和大多数基于客户端/服务端工具实现的类似于
-- TCP/IP的通信。主要完成一些类似于连接处理、授权认证、及相关的安全方案。在该层上引入了线程
-- 池的概念，为通过认证安全接入的客户端提供线程。同样在该层上可以实现基于SSL的安全链接。服务
-- 器也会为安全接入的每个客户端验证它所具有的操作权限。
-- 2). 服务层
-- 第二层架构主要完成大多数的核心服务功能，如SQL接口，并完成缓存的查询，SQL的分析和优化，部
-- 分内置函数的执行。所有跨存储引擎的功能也在这一层实现，如 过程、函数等。在该层，服务器会解
-- 析查询并创建相应的内部解析树，并对其完成相应的优化如确定表的查询的顺序，是否利用索引等，
-- 最后生成相应的执行操作。如果是select语句，服务器还会查询内部的缓存，如果缓存空间足够大，
-- 这样在解决大量读操作的环境中能够很好的提升系统的性能。
-- 3). 引擎层
-- 存储引擎层， 存储引擎真正的负责了MySQL中数据的存储和提取，服务器通过API和存储引擎进行通
-- 信。不同的存储引擎具有不同的功能，这样我们可以根据自己的需要，来选取合适的存储引擎。数据库
-- 中的索引是在存储引擎层实现的。
-- 4). 存储层
-- 数据存储层， 主要是将数据(如: redolog、undolog、数据、索引、二进制日志、错误日志、查询
-- 日志、慢查询日志等)存储在文件系统之上，并完成与存储引擎的交互。

-- 和其他数据库相比，MySQL有点与众不同，它的架构可以在多种不同场景中应用并发挥良好作用。主要
-- 体现在存储引擎上，插件式的存储引擎架构，将查询处理和其他的系统任务以及数据的存储提取分离。
-- 这种架构可以根据业务的需求和实际需要选择合适的存储引擎。

#存储引擎简介
#存储引擎是存储数据、建立索引、更新查询等技术的实现方式，存储引擎是基于表而不是基于库的，所以存储引擎也被称为表类型

#查询建表语句，默认存储引擎是InnoDB
show create table emp;

#建表时指定存储引擎
-- CREATE TABLE 表名(
-- 字段1 字段1类型 [ COMMENT 字段1注释 ] ,
-- ......
-- 字段n 字段n类型 [COMMENT 字段n注释 ]
-- ) ENGINE = 存储引擎名称 [ COMMENT 表注释 ] ;

#查看数据库支持的存储引擎
show engines;

#建表my_myisam，并指定myisam存储引擎
create table my_myisam(
	id int,
    name varchar(10)
)engine=MyISAM;

#建表my_memory，并指定memory存储引擎
create table my_memory(
	id int,
    name varchar(10)
)engine=memory;

#InnoDB存储引擎简介
#介绍：InnoDB是一种兼顾高性能和高可靠性的通用存储引擎，mysql5.5之后innodb是默认的存储引擎
#特点：1.DML操作遵循ACID模型，支持事务 2.行级锁，提高并发访问性能 3.支持外键约束，保证数据的完整性正确性。
#xxx.ibd xxx代表表名，innodb引擎的每张表都会对应这样一个表空间文件，存储该表的表结构（frm，sdi）、数据和索引。参数innodb_file_per_table

#是否每一张表对应一个表空间文件
show variables like 'innodb_file_per_table';

#逻辑存储结构
#TableSpace表空间、Segment段、Extent区1m、Page页16k、Row行、标志与字段

#myisam
#myism是mysql早期默认引擎
#特点：不支持事务，不支持外键，支持表锁，不支持行锁，访问速度快
#xxx.sdi存储表结构数据 xxx.MYD存储数据 xxx.MYI存储索引 JSON格式

#Memory
#memory引擎的表数据是存储在内存中的，由于受到硬件特点和断电问题影响，只能将其作为临时表或缓存使用
#特点：内存存放，默认hash索引
#文件：xxx.sdi存储表结构信息

#innodb和myisam区别
-- InnoDB引擎与MyISAM引擎的区别 ?
-- ①. InnoDB引擎, 支持事务, 而MyISAM不支持。
-- ②. InnoDB引擎, 支持行锁和表锁, 而MyISAM仅支持表锁, 不支持行锁。
-- ③. InnoDB引擎, 支持外键, 而MyISAM是不支持的。

#存储引擎的选择
#在选择存储引擎时，应该根据应用系统的特点选择合适的存储引擎。对于复杂的应用系统，还可以根据实际情况选择多种存储引擎进行组合。
-- InnoDB: 是Mysql的默认存储引擎，支持事务、外键。如果应用对事务的完整性有比较高的要
-- 求，在并发条件下要求数据的一致性，数据操作除了插入和查询之外，还包含很多的更新、删除操
-- 作，那么InnoDB存储引擎是比较合适的选择。

-- MyISAM ： 如果应用是以读操作和插入操作为主，只有很少的更新和删除操作，并且对事务的完
-- 整性、并发性要求不是很高，那么选择这个存储引擎是非常合适的。

-- MEMORY：将所有数据保存在内存中，访问速度快，通常用于临时表及缓存。MEMORY的缺陷就是
-- 对表的大小有限制，太大的表无法缓存在内存中，而且无法保障数据的安全性。

