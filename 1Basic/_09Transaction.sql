#事务
#事务是一组操作的集合，它是一个不可分割的工作单位。事务会把所有的操作所谓一个整体一起向系统提交或撤销操作请求，即这些操作要么同时成功，要么同时失败。
#开启事务，（抛异常，回滚事务），提交事务
#默认mysql的事务是自动提交的，即执行一条DML语句，Mysql会立即隐式提交事务，默认情况下每条sql语句都是事务

#事务的操作
#查看、设置事务提交方式（在workbench中通过上方的设置来开关autocommit）
show variables like 'autocommit';
select @@global.autocommit;
select @@session.autocommit;
set @@session.autocommit=0;
set @@global.autocommit=0;
set @@session.autocommit=1;
set @@global.autocommit=1;
#开始事务
start transaction;
begin;
#提交事务
commit;
#回滚事务
rollback;

#数据准备
use test;
drop table if exists account;
create table account(
id int primary key AUTO_INCREMENT comment 'ID',
name varchar(10) comment '姓名',
money double(10,2) comment '余额'
) comment '账户表';
insert into account(name, money) VALUES ('张三',2000), ('李四',2000);
commit;

#没有事务的转账操作，张三给李四转账1000
#查询张三的余额
select * from account where name='张三';
#将张三余额减1000
update account set money=money-1000 where name='张三';
#将李四余额加1000
update account set money=money+1000 where name='李四';

#模拟转账异常程序，执行这段操作时张三的钱少了，但是李四的钱没变多
select * from account where name='张三';
update account set money=money-1000 where name='张三';程序出现异常
update account set money=money+1000 where name='李四';

#有事务的转账程序
SELECT * FROM test.account;
start transaction;
select * from account where name='张三';
update account set money=money-1000 where name='张三';
update account set money=money+1000 where name='李四';
commit;
rollback;

#事务的四大特性（ACID
#原子性（Autoicity）：事务是不可分割的最小操作单元，要么全部成功要么全部失败
#一致性（Consistency）：事务完成时，必须使所有数据保持一致状态
#隔离性（Isolation）：数据库系统提供的隔离机制，保证事务在不受外部并发影响的独立环境下运行
#持久性（Durability）：事务一旦提交或回滚，它对数据库中的数据的改变就是公开的，默认存储在C:\ProgramData\MySQL\MySQL Server 8.0\Data

#并发事务的问题
#脏读：一个事务读到另外一个事务还没有提交的数据。只读取已提交数据可以解决。read committed
#不可重复读：一个事务先后读取同一条记录，但两次读取的数据不同，称之为不可重复读。在事务开始时记录此时的数据库时间节点可以解决。repeatable read
#幻读：一个事务按照条件查询数据时，没有对应的数据行，但是在插入数据时，又发现这行数据已经存在，好像出现了幻影。串行化执行事务可以解决。serializable

#事务隔离级别
#read uncommitted：会出现脏读，不可重复读，幻读
#read committed(Oracle默认)：会出现不可重复读，幻读
#repeatable read(mysql默认)：会出现幻读
#serializable：不会出现问题
#查看事务隔离级别
select @@transaction_isolation;
#设置事务隔离级别
#set [session|global] transaction isolation level [read uncommited|read committed|repeatable read|serializable];
set session transaction isolation level repeatable read;
#事务隔离级别越高，数据越安全，但是性能越低。