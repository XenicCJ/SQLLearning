#索引概述
#索引是帮助mysql高效获取数据的数据结构（有序）。在数据之外，数据库系统还维护着满足特定查找算法的数据结构，这些数据结构以某种方式引用数据，这样就可以在这些数据结构上实现高级查询算法，这种数据结构就是索引
#有无索引的区别：无索引时数据库查找数据进行全表扫描。有索引时数据库根据索引的树结构或其他数据结构进行查找数据，效率高
#优缺点：
#优点：提高数据查询的效率，降低磁盘IO成本。降低数据排序成本，降低cpu消耗。
#缺点：索引数据结构需要占用空间，增删改时需要维护索引，降低效率。

#索引结构概述
#MySQL的索引是在存储引擎层实现的，不同的存储引擎有不同的索引结构
#B+Tree索引 最常见的索引类型，大部分引擎都支持 B+ 树索引
#Hash索引 底层数据结构是用哈希表实现的, 只有精确匹配索引列的查询才有效, 不支持范围查询
#R-tree(空间索引）空间索引是MyISAM引擎的一个特殊索引类型，主要用于地理空间数据类型，通常使用较少
#Full-text(全文索引)是一种通过建立倒排索引,快速匹配文档的方式。类似于Lucene,Solr,ES
#注意： 我们平常所说的索引，如果没有特别指明，都是指B+树结构组织的索引。
#InnoDB：B+Tree、5.6版本后Full-Text
#MyISAM：B+Tree、R-tree、Full-Text
#memory：B+Tree、Hash

#索引结构-二叉树
#普通二叉树缺点：顺序插入时产生单向链表，大数据量时层级深，检索速度较慢
#红黑树缺点：大数据量时层级深，检索速度较慢

#B-Tree
#B-Tree：B-Tree，B树是一种多叉路衡查找树，相对于二叉树，B树每个节点可以有多个分支，即多叉。以一颗最大度数（max-degree）为5(5阶)的b-tree为例，那这个B树每个节点最多存储4个key，5个指针
#我们可以通过一个数据结构可视化的网站来简单演示一下。 https://www.cs.usfca.edu/~galles/visualization/BTree.html
#特点：
#5阶的B树，每一个节点最多存储4个key，对应5个指针。
#一旦节点存储的key数量到达5，就会裂变，中间元素向上分裂。
#在B树中，非叶子节点和叶子节点都会存放数据。

#B+Tree
#B+Tree是B-Tree的变种
#B+Tree 与 B-Tree相比，主要有以下三点区别：
#所有的数据都会出现在叶子节点。
#叶子节点形成一个单向链表。
#非叶子节点仅仅起到索引数据作用，具体的数据都是在叶子节点存放的。
#演示网站： https://www.cs.usfca.edu/~galles/visualization/BPlusTree.html
#MySQL索引数据结构对经典的B+Tree进行了优化。在原B+Tree的基础上，增加一个指向相邻叶子节点的链表指针，就形成了带有顺序指针的B+Tree，提高区间访问的性能，利于排序。

#Hash
#哈希索引就是采用一定的hash算法，将键值换算成新的hash值，映射到对应的槽位上，然后存储在hash表中。
#如果两个(或多个)键值，映射到一个相同的槽位上，他们就产生了hash冲突（也称为hash碰撞），可以通过链表来解决。
-- 特点
-- A. Hash索引只能用于对等比较(=，in)，不支持范围查询（between，>，< ，...）
-- B. 无法利用索引完成排序操作
-- C. 查询效率高，通常(不存在hash冲突的情况)只需要一次检索就可以了，效率通常要高于B+tree索引
#MySQL中，支持hash索引的是Memory存储引擎。 而InnoDB中具有自适应hash功能，hash索引是InnoDB存储引擎根据B+Tree索引在指定条件下自动构建的。

#数据结构思考 为什么InnoDB选择使用B+Tree索引结构？
#相比红黑树，大数据量时B+Tree层级较少，效率较高
#相比b树，b+树种非叶子节点只保存索引数据而不保存指向数据的指针，而数据只存放在叶子节点，所以一页中可以存放的节点更多，同样的大数据量情况下b+树的层级也就会比b树更低了，b+树的效率更高也更稳定
#相比hash表，b+树可用于对数据进行排序和范围查找

#索引分类
#在MySQL数据库，将索引的具体类型主要分为以下几类：主键索引、唯一索引、常规索引、全文索引
#主键索引：针对表中主键创建的索引，默认自动创建，只可以有一个，关键字primary
#唯一索引：避免同一个表中某数据列的值重复，可以有多个，关键字unique
#常规索引：快速定位特定数据，可以有多个
#全文索引：查找的是文本中的关键字，而不是比较索引中的关键词，可以有多个，关键字fulltext
#而在在InnoDB存储引擎中，根据索引的存储形式，又可以分为以下两种
#聚集索引（Clustered index）将数据存储与索引放到了一块，索引结构的叶子节点保存了行数据，必须有且只有一个
#二级索引（Secondary Index）将数据与索引分开存储，索引结构的叶子节点关联的是对应主键，可以有多个
#聚集索引选取规则：若存在主键，则主键为聚集索引。若不存在主键，则使用第一个unique索引作为聚集索引。若无主键无合适的unique索引，则innodb自动生成rowid作为隐藏聚集索引
#执行sql语句查询时在索引中搜索的过程，通过非主键字段查找时会进行回表查询

#思考
-- 以下两条SQL语句，那个执行效率高? 为什么?
-- A. select * from user where id = 10 ;
-- B. select * from user where name = 'Arm' ;
-- 备注: id为主键，name字段创建的有索引；
#A语句直接走聚集索引查找数据，B语句先通过name的二级索引找到主键，再回表查询聚集索引查找数据，所以A更快。
-- InnoDB主键索引的B+tree高度为多高呢?
#一页16k，一个指针6B，假设一行数据1k，一个bigint主键8B。8B*n+（n+1）*6B=16KB，n≈1170，度数约为1171，子节点一页16行数据。高度为2，最多1171*16行数据，高度为3，最多1171^2*16行数据，以此类推。

#索引的语法
#创建索引，单列索引，联合\组合索引
#CREATE [ UNIQUE | FULLTEXT ] INDEX index_name ON table_name (index_col_name,... ) ;
#查看索引
#SHOW INDEX FROM table_name ;
#删除索引
#DROP INDEX index_name ON table_name ;

#索引语法练习案例
#A. name字段为姓名字段，该字段的值可能会重复，为该字段创建索引。
create index tb_user_name_index on tb_user(name);
#B. phone手机号字段的值，是非空，且唯一的，为该字段创建唯一索引。
create unique index tb_user_phone_index on tb_user(phone);
#C. 为profession、age、status创建联合索引。
create index tb_user_proagestat_index on tb_user(profession,age,status);
#D. 为email建立合适的索引来提升查询效率。
create index tb_user_email_index on tb_user(email);
#删除某个索引
drop index tb_user_age_index on tb_user;
#完成上述的需求之后，我们再查看tb_user表的所有的索引数据。
show index from tb_user;

#性能分析-sql执行频次
#MySQL 客户端连接成功后，通过 show [session|global] status 命令可以提供服务器状态信息。通过如下指令，可以查看当前数据库的INSERT、UPDATE、DELETE、SELECT的访问频次
show global status like 'com_______';

#性能分析-慢查询日志
#慢查询日志记录了所有执行时间超过指定参数（long_query_time，单位：秒，默认10秒）的所有SQL语句的日志。
#MySQL的慢查询日志默认没有开启。，我们可以查看一下系统变量 slow_query_log。
show variables like 'slow_query_log';
#如果要开启慢查询日志，需要在MySQL的配置文件（/etc/my.cnf）中配置如下信息:
-- # 开启MySQL慢日志查询开关
-- slow_query_log=1
-- # 设置慢日志的时间为2秒，SQL语句执行时间超过2秒，就会视为慢查询，记录慢查询日志
-- long_query_time=2

#性能分析-profile详情
#show profiles 能够在做SQL优化时帮助我们了解时间都耗费到哪里去了。通过have_profiling参数，能够看到当前MySQL是否支持profile操作
select @@have_profiling ;
#默认profile功能是关闭的，可以通过下列语句查看是否打开
select @@profiling;
#以下语句打开profiling功能
set profiling=1;
#开关已经打开了，接下来，我们所执行的SQL语句，都会被MySQL记录，并记录执行时间消耗到哪儿去了。
#查看每一条sql的耗时情况
show profiles;
#查看指定query_id的sql语句各个阶段的耗时情况
#show profile for query query_id;
show profile for query 8;
#查看指定query_id的sql语句各个阶段的cpu使用情况
#show profile cpu for query query_id;
show profile cpu for query 8;

#性能分析-explain执行计划
#EXPLAIN 或者 DESC命令获取 MySQL 如何执行 SELECT 语句的信息，包括在 SELECT 语句执行过程中表如何连接和连接的顺序
#语法 直接在select语句之前加上关键字 explain / desc
#EXPLAIN SELECT 字段列表 FROM 表名 WHERE 条件 ;
explain select * from tb_user where id=1;
#执行计划各个字段意义
#id：select查询的序列号，表示查询中执行select子句或者是操作表的顺序(id相同，执行顺序从上到下；id不同，值越大，越先执行)。
#select_type：表示 SELECT 的类型，常见的取值有 SIMPLE（简单表，即不使用表连接或者子查询）、PRIMARY（主查询，即外层的查询）、UNION（UNION 中的第二个或者后面的查询语句）、SUBQUERY（SELECT/WHERE之后包含了子查询）等
#type：表示连接类型，性能由好到差的连接类型为NULL、system、const、eq_ref、ref、range、 index、all 越前面的性能越好。
#possible_key：显示可能应用在这张表上的索引，一个或多个。
#key：实际使用的索引，如果为NULL，则没有使用索引。
#key_len：表示索引中使用的字节数， 该值为索引字段最大可能长度，并非实际使用长度，在不损失精确性的前提下， 长度越短越好 。
#rows：MySQL认为必须要执行查询的行数，在innodb引擎的表中，是一个估计值，可能并不总是准确的。
#filtered：表示返回结果的行数占需读取行数的百分比， filtered 的值越大越好。
#id演示,id相同多条数据的情况
explain select * from student s,student_course sc, course c where s.id=sc.studentid and sc.courseid=c.id;
#id演示,id不同多条数据的情况，查询选修mysql课的学生(子查询)
explain select * from student s where s.id in (select sc.studentid from student_course sc where sc.courseid in(select c.id from course c where c.name='MySQL') );
#type演示，null情况,直接返回值
explain select 'a';
explain select now();
#type演示，const情况,有索引查询
explain select * from tb_user where id=1;
#type演示，ref情况，二级索引查询
explain select * from tb_user where name='白起';

#索引使用

#索引使用-验证索引效率
#未建立索引时执行语句查看时间
#大约0.3毫秒
SELECT * FROM test.tb_user where id='1';
show profiles;
#超过0.4毫秒
SELECT * FROM test.tb_user where age=52;
#对age添加索引后用时与id查询就差不多了
create index tb_user_age_index on tb_user(age);
#大约0.3毫秒
SELECT * FROM test.tb_user where age=52;

#索引使用-最左前缀法则
#如果索引了多列（联合索引），要遵守最左前缀法则。最左前缀法则指的是查询从索引的最左列开始，并且不跳过索引中的列。如果跳跃某一列，索引将会部分失效(后面的字段索引失效)。
#演示最左前缀法则
SHOW INDEX FROM tb_user ;
#按顺序包含多列索引正常走联合索引
explain select * from tb_user where profession ='城市规划' and age=52 and status='2';
#缺少后两个索引字段，也会走联合索引
explain select * from tb_user where profession ='城市规划' and age=52 ;
explain select * from tb_user where profession ='城市规划' ;
#查询条件顺序变动，也会走联合索引,因为最左前缀存在
explain select * from tb_user where status=2 and age=52 and  profession ='城市规划';
#最左前缀条件不存在，不会走联合索引
explain select * from tb_user where status=2 and age=52;
#status条件左边有条件缺失，部分字段走联合索引，其余字段不走联合索引
explain select * from tb_user where profession ='城市规划'  and status='2';

#索引使用-范围查询
#联合索引中，出现不包含等于的范围查询(>,<)，范围查询右侧的列索引失效。
#使用大于或小于，联合索引自此失效
explain select * from tb_user where profession ='城市规划' and age>51 and status='2';
#使用大于等于或小于等于，联合索引依然生效
explain select * from tb_user where profession ='城市规划' and age>=51 and status='2';

#索引使用-索引列运算
#在索引列上进行运算，索引将失效
#正常查询电话号码，走索引
explain select * from tb_user where phone='17799990001';
#对列进行运算，索引将失效
explain select * from tb_user where substring(phone,1,11)='17799990001';

#索引使用-字符串加引号
#字符串不加单引号，索引会失效
#搜索字符串不加引号，索引不生效
explain select * from tb_user where phone=17799990001;
#联合索引同理
explain select * from tb_user where profession ='城市规划' and age=52 and status='2';
explain select * from tb_user where profession ='城市规划' and age=52 and status=2;

#索引使用-模糊查询
#仅仅是尾部模糊匹配，索引依然生效，头部模糊匹配，索引将失效
#仅尾部模糊匹配，索引生效
explain select * from tb_user where profession like '城市%';
#仅头部及头部尾部都是模糊匹配，索引不生效
explain select * from tb_user where profession like '%市规划';
explain select * from tb_user where profession like '%市%';

#索引使用-or连接条件
#用or分割开来的条件，如果or前的条件有索引而后面没有索引，则两边的索引都不会生效
#or后方的条件没有索引，则所有索引都不会使用
explain select * from tb_user where id=10 or age =23;
explain select * from tb_user where phone like '17799990000' or age =23;
#若or两边的条件都有索引，则都走索引
explain select * from tb_user where phone like '17799990000' or profession like '城市%';

#索引使用-数据分布影响
#若mysql评估使用索引会比全表扫描更慢，则不走索引,通常查询结果占表内总数据相对过大时会放弃使用索引
#两个被认为走索引比全表扫描更耗时的查询
explain select * from tb_user where phone >= '17799990011';
explain select * from tb_user where profession is not null;
#两个被认为走索引比全表扫描快的查询
explain select * from tb_user where phone >= '17799990022';
explain select * from tb_user where profession is null;

#索引使用-SQL提示
#SQL提示示优化数据库的一个中要手段，简单来说，就是在SQL语句中加入一些人为的提示来达到优化操作的目的
#1）use index ： 建议MySQL使用哪一个索引完成此次查询（仅仅是建议，mysql内部还会再次进行评估）。
#2). ignore index ： 忽略指定的索引。
#3). force index ： 强制使用索引。
#为profession添加索引
create index tb_user_pro on tb_user(profession);
drop index tb_user_pro on tb_user;
#虽然有独立的索引，但是还是走联合索引
explain select * from tb_user where profession ='城市规划';
#建议使用独立索引
explain select * from tb_user use index(tb_user_pro) where profession ='城市规划';
#命令不要使用一些索引
explain select * from tb_user ignore index(tb_user_pro,tb_user_proagestat_index) where profession ='城市规划';
explain select * from tb_user ignore index(tb_user_proagestat_index) where profession ='城市规划';
#命令强制使用一些索引
explain select * from tb_user force index(tb_user_pro) where profession ='城市规划';

#索引使用-覆盖索引
#尽量使用覆盖索引，减少select *。 那么什么是覆盖索引呢？ 覆盖索引是指 查询使用了索引，并且需要返回的列，在该索引中已经全部能够找到 。
SHOW INDEX FROM tb_user ;
#使用了索引但是不需要回表查询的一些例子,注意extra字段
explain select id,profession from tb_user where profession ='城市规划' and age>51 and status='2';
explain select id,profession,age from tb_user where profession ='城市规划' and age>51 and status='2';
explain select id,profession,age,status from tb_user where profession ='城市规划' and age>51 and status='2';
#使用了索引但是需要回表查询的例子,注意extra字段
explain select id,profession,age,status,gender from tb_user where profession ='城市规划' and age>51 and status='2';
#知识小贴士
#Extra的含义（可能会随版本不同而不同） 
#Using where; Using Index：查找使用了索引，但是需要的数据都在索引列中能找到，所以不需要回表查询数据
#Using index condition：查找使用了索引，但是需要回表查询数

#索引使用-前缀索引
#当字段类型为字符串（varchar，text，longtext等）时，有时候需要索引很长的字符串，这会让索引变得很大，查询时，浪费大量的磁盘IO， 影响查询效率。此时可以只将字符串的一部分前缀，建立索引，这样可以大大节约索引空间，从而提高索引效率。
#语法：create index idx_xxxx on table_name(column(n)) ;
#前缀长度的选择
#可以根据索引的选择性来决定，而选择性是指不重复的索引值（基数）和数据表的记录总数的比值，索引选择性越高则查询效率越高， 唯一索引的选择性是1，这是最好的索引选择性，性能也是最好的。
#语法：
select count(distinct email) / count(*) from tb_user ;
select count(distinct substring(email,1,5)) / count(*) from tb_user ;
#创建一个email的前缀索引
create index idx_email_5 on tb_user(email(5));
drop index tb_user_email_index on tb_user;
explain select * from tb_user where email like 'caocao666@qq.com';

#索引使用-单列索引与联合索引
#若查询条件中的多个字段都有单列索引，则只会走第一个单列索引
explain select * from tb_user where phone='17799990001' and name='曹操';
#在业务场景中，如果存在多个查询条件，考虑针对于查询字段建立索引时，建议建立联合索引，而非单列索引。
create index idx_phone_name on tb_user(phone,name);
explain select * from tb_user where phone='17799990001' and name='曹操';

#索引设计原则
-- 1). 针对于数据量较大，且查询比较频繁的表建立索引。
-- 2). 针对于常作为查询条件（where）、排序（order by）、分组（group by）操作的字段建立索引。
-- 3). 尽量选择区分度高的列作为索引，尽量建立唯一索引，区分度越高，使用索引的效率越高。
-- 4). 如果是字符串类型的字段，字段的长度较长，可以针对于字段的特点，建立前缀索引。
-- 5). 尽量使用联合索引，减少单列索引，查询时，联合索引很多时候可以覆盖索引，节省存储空间，避免回表，提高查询效率。
-- 6). 要控制索引的数量，索引并不是多多益善，索引越多，维护索引结构的代价也就越大，会影响增删改的效率。
-- 7). 如果索引列不能存储NULL值，请在创建表时使用NOT NULL约束它。当优化器知道每列是否包含NULL值时，它可以更好地确定哪个索引最有效地用于查询。