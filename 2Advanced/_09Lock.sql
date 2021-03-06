#锁简介
-- 锁是计算机协调多个进程或线程并发访问某一资源的机制。在数据库中，除传统的计算资源（CPU、
-- RAM、I/O）的争用以外，数据也是一种供许多用户共享的资源。如何保证数据并发访问的一致性、有
-- 效性是所有数据库必须解决的一个问题，锁冲突也是影响数据库并发访问性能的一个重要因素。从这个
-- 角度来说，锁对数据库而言显得尤其重要，也更加复杂。
#锁的分类
-- MySQL中的锁，按照锁的粒度分，分为以下三类：
-- 全局锁：锁定数据库中的所有表。
-- 表级锁：每次操作锁住整张表。
-- 行级锁：每次操作锁住对应的行数据。

#锁-全局锁
-- 全局锁就是对整个数据库实例加锁，加锁后整个实例就处于只读状态，后续的DML的写语句，DDL语
-- 句，已经更新操作的事务提交语句都将被阻塞。
-- 其典型的使用场景是做全库的逻辑备份，对所有的表进行锁定，从而获取一致性视图，保证数据的完整
-- 性。
-- 对数据库进行进行逻辑备份之前，先对整个数据库加上全局锁，一旦加了全局锁之后，其他的DDL、
-- DML全部都处于阻塞状态，但是可以执行DQL语句，也就是处于只读状态，而数据备份就是查询操作。
-- 那么数据在进行逻辑备份的过程中，数据库中的数据就是不会发生变化的，这样就保证了数据的一致性
-- 和完整性。
#锁-全局锁语法
#加全局锁
#flush tables with read lock ;
#数据备份
#mysqldump -uroot –p1234 itcast > itcast.sql
#释放锁
#unlock tables ;

#数据备份案例
flush tables with read lock ;
-- 进行备份
unlock tables ;

#全局锁的问题
-- 数据库中加全局锁，是一个比较重的操作，存在以下问题：
-- 如果在主库上备份，那么在备份期间都不能执行更新，业务基本上就得停摆。
-- 如果在从库上备份，那么在备份期间从库不能执行主库同步过来的二进制日志（binlog），会导
-- 致主从延迟。
#在InnoDB引擎中，我们可以在备份时加上参数 --single-transaction 参数来完成不加锁的一致性数据备份。
#mysqldump --single-transaction -uroot –p123456 itcast > itcast.sql

#锁-表级锁
#表级锁，每次操作锁住整张表。锁定粒度大，发生锁冲突的概率最高，并发度最低。应用在MyISAM、InnoDB、BDB等存储引擎中。
#对于表级锁，主要分为以下三类：
-- 表锁
-- 元数据锁（meta data lock，MDL）
-- 意向锁

#锁-表级锁-表锁
#表锁分类
-- 表共享读锁（read lock）：自己和其他客户端都是可读不可写
-- 表独占写锁（write lock）：自己可以读可以写，其他客户端不可读不可写
#表锁语法
-- 加锁：lock tables 表名... read/write。
-- 释放锁：unlock tables / 客户端断开连接 。

#锁-表级锁-元数据锁
-- meta data lock , 元数据锁，简写MDL。
-- MDL加锁过程是系统自动控制，无需显式使用，在访问一张表的时候会自动加上。MDL锁主要作用是维
-- 护表元数据的数据一致性，在表上有活动事务的时候，不可以对元数据进行写入操作。为了避免DML与
-- DDL冲突，保证读写的正确性。
-- 这里的元数据，大家可以简单理解为就是一张表的表结构。 也就是说，某一张表涉及到未提交的事务
-- 时，是不能够修改这张表的表结构的。
-- 在MySQL5.5中引入了MDL，当对一张表进行增删改查的时候，加MDL读锁(共享)；当对表结构进行变
-- 更操作的时候，加MDL写锁(排他)。
#我们可以通过下面的SQL，来查看数据库中的元数据锁的情况
select object_type,object_schema,object_name,lock_type,lock_duration from performance_schema.metadata_locks ;

#锁-表级锁-意向锁
#为了避免DML在执行时，加的行锁与表锁的冲突，在InnoDB中引入了意向锁，使得表锁不用检查每行数据是否加锁，使用意向锁来减少表锁的检查。
#意向锁的分类
#意向共享锁(IS): 由语句select ... lock in share mode添加 。 与 表锁共享锁(read)兼容，与表锁排他锁(write)互斥。
#意向排他锁(IX): 由insert、update、delete、select...for update添加 。与表锁共享锁(read)及排他锁(write)都互斥，意向锁之间不会互斥。
#查看意向锁：
#可以通过以下SQL，查看意向锁及行锁的加锁情况
select object_schema,object_name,index_name,lock_type,lock_mode,lock_data from performance_schema.data_locks;

#锁-行级锁介绍
#行级锁，每次操作锁住对应的行数据。锁定粒度最小，发生锁冲突的概率最低，并发度最高。应用在InnoDB存储引擎中。
#InnoDB的数据是基于索引组织的，行锁是通过对索引上的索引项加锁来实现的，而不是对记录加的锁。
#行级锁分类
-- 行锁（Record Lock）：锁定单个行记录的锁，防止其他事务对此行进行update和delete。在RC、RR隔离级别下都支持。
-- 间隙锁（Gap Lock）：锁定索引记录间隙（不含该记录），确保索引记录间隙不变，防止其他事务在这个间隙进行insert，产生幻读。在RR隔离级别下都支持。
-- 临键锁（Next-Key Lock）：行锁和间隙锁组合，同时锁住数据，并锁住数据前面的间隙Gap。在RR隔离级别下支持。

#行锁
-- InnoDB实现了以下两种类型的行锁：
-- 共享锁（S）：允许一个事务去读一行，阻止其他事务获得相同数据集的排它锁。
-- 排他锁（X）：允许获取排他锁的事务更新数据，阻止其他事务获得相同数据集的共享锁和排他锁。

-- 默认情况下，InnoDB在 REPEATABLE READ事务隔离级别运行，InnoDB使用 next-key 锁进行搜索和索引扫描，以防止幻读。
-- 针对唯一索引进行检索时，对已存在的记录进行等值匹配时，将会自动优化为行锁。
-- InnoDB的行锁是针对于索引加的锁，不通过索引条件检索数据，那么InnoDB将对表中的所有记录加锁，此时 就会升级为表锁。
#可以通过以下SQL，查看意向锁及行锁的加锁情况
select object_schema,object_name,index_name,lock_type,lock_mode,lock_data from performance_schema.data_locks;

#锁-行级锁-间隙锁，临键锁
-- 默认情况下，InnoDB在 REPEATABLE READ事务隔离级别运行，InnoDB使用 next-key 锁进行搜索和索引扫描，以防止幻读。
-- 索引上的等值查询(唯一索引)，给不存在的记录加锁时, 优化为间隙锁 。
-- 索引上的等值查询(非唯一普通索引)，向右遍历时最后一个值不满足查询需求时，next-keylock 退化为间隙锁。
-- 索引上的范围查询(唯一索引)--会访问到不满足条件的第一个值为止。
#注意：间隙锁唯一目的是防止其他事务插入间隙。间隙锁可以共存，一个事务采用的间隙锁不会阻止另一个事务在同一间隙上采用间隙锁。
