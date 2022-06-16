#SQL优化
#插入数据
#主键优化
#order by优化
#group by优化
#limit优化
#count优化
#update优化

#SQL优化-插入数据insert
#批量插入
#每次使用insert都会对数据库有额外操作，如多次事务提交，多次与数据库的网络连接等等，单条insert语句插入多条数据只提交一次，建立一次连接
#手动提交事务
#每次使用insert都会对数据库有额外操作，如多次事务提交，多次与数据库的网络连接等等，手动提交事务插入多条数据只提交一次，建立一次连接
#主键顺序插入
#若大量数据插入，乱序主键产生页分裂现象，因此性能更低
#大批量插入数据
#如果一次性需要插入大批量数据(比如: 几百万的记录)，使用insert语句插入性能较低，此时可以使用MySQL数据库提供的load指令进行插入
-- 客户端连接服务端时，加上参数 -–local-infile
-- mysql –-local-infile -u root -p
-- 设置全局参数local_infile为1，开启从本地加载文件导入数据的开关
-- set global local_infile = 1;
-- 执行load指令将准备好的数据，加载到表结构中
-- load data local infile '/root/sql1.log' into table tb_user fields terminated by ',' lines terminated by '\n' ;

#SQL优化-主键优化
#数据组织方式
#在InnoDB存储引擎中，表数据都是根据主键顺序组织存放的，这种存储方式的表称为索引组织表（index organized table iot）
#页分裂
#页可以为空，也可以填充一半，也可以填充100%。每个页包含了2-N行数据(如果一行数据过大，会行溢出)，根据主键排列。
#页合并
#当删除一项纪录时，实际上纪录并没有被物理删除，只是纪录被标记为删除并且它的空间被标记为可被其他纪录声明使用，当页中删除的纪录达到MERGE_THRESHOLD（默认为页的50%），innoDB会开始寻找最靠近的页前后看看是否可以将两个页合并以优化空间使用
#主键设计原则
#满足业务需求的情况下，尽量降低主键的长度。
#插入数据时，尽量选择顺序插入，选择使用AUTO_INCREMENT自增主键。
#尽量不要使用UUID做主键或者是其他自然主键，如身份证号。
#业务操作时，避免对主键的修改。

#SQL优化-order by优化
#MySQL的排序，有两种方式：
#Using filesort : 通过表的索引或全表扫描，读取满足条件的数据行，然后在排序缓冲区sort buffer中完成排序操作，所有不是通过索引直接返回排序结果的排序都叫 FileSort 排序。
#Using index : 通过有序索引顺序扫描直接返回有序数据，这种情况即为 using index，不需要额外排序，操作效率高。
SHOW INDEX FROM tb_user ;
drop index tb_user_name_index on tb_user;
drop index idx_phone_name on tb_user;
#没有通过索引排序的查询,不使用覆盖索引时也会导致filesort排序
explain select * from tb_user order by age;
explain select * from tb_user order by phone;
#创建联合索引并使用索引排序，若相反则是反向扫描索引
create index idx_age_phone on tb_user(age,phone);
explain select id,age,phone from tb_user order by age,phone;
explain select id,age,phone from tb_user order by age desc,phone desc;
#索引排序部分生效的情况，顺序不相同
explain select id,age,phone from tb_user order by age ,phone desc;
explain select id,age,phone from tb_user order by phone,age;
#创建指定字段排序方式的索引，使得适应查询时排序方式
create index idx_age_phone_desc on tb_user(age,phone desc);
explain select id,age,phone from tb_user order by age ,phone desc;
explain select id,age,phone from tb_user order by age desc,phone ;
#order by优化原则:
#A. 根据排序字段建立合适的索引，多字段排序时，也遵循最左前缀法则。
#B. 尽量使用覆盖索引。
#C. 多字段排序, 一个升序一个降序，此时需要注意联合索引在创建时的规则（ASC/DESC）。
#D. 如果不可避免的出现filesort，大数据量排序时，可以适当增大排序缓冲区大小sort_buffer_size(默认256k)。

#SQL优化-group by优化
#分组操作，我们主要来看看索引对于分组操作的影响
SHOW INDEX FROM tb_user ;
drop index  idx_age_phone_desc on tb_user;
#有索引时也会使分组查询的效率更高
explain select profession ,count(*) from tb_user group by profession;
explain select profession ,age,count(*) from tb_user group by age;
explain select profession ,age,count(*) from tb_user group by profession,age;
explain select profession ,age,count(*) from tb_user where profession = '英语' group by age;

#SQL优化-limit优化
#在数据量比较大时，如果进行limit分页查询，在查询时，越往后，分页查询效率越低
#优化思路: 一般分页查询时，通过创建 覆盖索引 能够比较好地提高性能，可以通过覆盖索引加子查询形式进行优化
explain select * from tb_sku t , (select id from tb_sku order by id limit 2000000,10) a where t.id = a.id;

#SQL优化-count优化
#在之前的测试中，我们发现，如果数据量很大，在执行count操作时，是非常耗时的
#MyISAM 引擎把一个表的总行数存在了磁盘上，因此执行 count(*) 的时候会直接返回这个数，效率很高； 但是如果是带条件的count，MyISAM也慢。
#InnoDB 引擎就麻烦了，它执行 count(*) 的时候，需要把数据一行一行地从引擎里面读出来，然后累积计数。
#如果说要大幅度提升InnoDB表的count效率，主要的优化思路：自己计数(可以借助于redis这样的数据库进行,但是如果是带条件的count又比较麻烦了)。
#count的用法
#count() 是一个聚合函数，对于返回的结果集，一行行地判断，如果 count 函数的参数不是NULL，累计值就加 1，否则不加，最后返回累计值。
#用法：count（*）、count（主键）、count（字段）、count（数字）
-- count(主键)
-- InnoDB 引擎会遍历整张表，把每一行的 主键id 值都取出来，返回给服务层。
-- 服务层拿到主键后，直接按行进行累加(主键不可能为null)
-- count(字段)
-- 没有not null 约束 : InnoDB 引擎会遍历整张表把每一行的字段值都取出
-- 来，返回给服务层，服务层判断是否为null，不为null，计数累加。
-- 有not null 约束：InnoDB 引擎会遍历整张表把每一行的字段值都取出来，返
-- 回给服务层，直接按行进行累加。
-- count(数字)
-- InnoDB 引擎遍历整张表，但不取值。服务层对于返回的每一行，放一个数字“1”
-- 进去，直接按行进行累加。
-- count(*)
-- InnoDB引擎并不会把全部字段取出来，而是专门做了优化，不取值，服务层直接
-- 按行进行累加。
#尽量使用count(*),count(1)

#SQL优化-update优化
#InnoDB的行锁是针对索引加的锁，不是针对记录加的锁 ,并且该索引不能失效，否则会从行锁升级为表锁 。
#所以在更新时尽量以索引字段为条件


