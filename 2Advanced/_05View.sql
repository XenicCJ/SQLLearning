#视图
#视图（View）是一种虚拟存在的表。视图中的数据并不在数据库中实际存在，行和列数据来自定义视图的查询中使用的表，并且是在使用视图时动态生成的。
#通俗的讲，视图只保存了查询的SQL逻辑，不保存查询结果。所以我们在创建视图的时候，主要的工作就落在创建这条SQL查询语句上。
#创建视图
#CREATE [OR REPLACE] VIEW 视图名称[(列名列表)] AS SELECT语句 [ WITH [CASCADED | LOCAL ] CHECK OPTION ]
create or replace view stu_v_1  (ID,NAME) as select id, name from student where id<=10;
#查询视图
#查看创建视图语句：SHOW CREATE VIEW 视图名称;
#查看视图数据：SELECT * FROM 视图名称 ...... ;
show create view stu_v_1;
select * from stu_v_1;
select * from stu_v_1 where id=3;
#修改视图
#方式一：CREATE [OR REPLACE] VIEW 视图名称[(列名列表)] AS SELECT语句 [ WITH[ CASCADED | LOCAL ] CHECK OPTION ]
#方式二：ALTER VIEW 视图名称[(列名列表)] AS SELECT语句 [ WITH [ CASCADED |LOCAL ] CHECK OPTION ]
create or replace view stu_v_1  (ID,NAME,NO) as select id, name,no from student where id<=10;
alter view stu_v_1 (ID,NAME) as select id, name from student where id<=10;
#删除视图
#DROP VIEW [IF EXISTS] 视图名称 [,视图名称] ...
drop view if exists stu_v_1;
#查看所有视图列表
select * from information_schema.VIEWS;

#视图-检查选项
#视图插入数据时，会一一检查级联的所有前置视图的检查选项
#视图-检查选项cascaded
#当使用WITH CHECK OPTION子句创建视图时，MySQL会通过视图检查正在更改的每个行，例如 插入，更新，删除，以使其符合视图的定义。 
#MySQL允许基于另一个视图创建视图，它还会检查依赖视图中的规则以保持一致性。
#为了确定检查的范围，mysql提供了两个选项： CASCADED 和 LOCAL，默认值为 CASCADED 。
#cascaded级联
#级联检查选项意味着除非前置视图遇到了local，否则会一直检查
#v2视图是基于v1视图的，如果在v2视图创建的时候指定了检查选项为 cascaded，但是v1视图创建时未指定检查选项。 则在执行检查时，不仅会检查v2，还会级联检查v2的关联视图v1。判定层次无限。
create or replace view v1  (ID,NAME) as select id, name from student where id<=30;
insert into v1 values(25,'XiaoMing');
create or replace view v2  (ID,NAME) as select id, name from v1 where id>=11 with cascaded check option;
insert into v2 values(5,'XiaoMing2');
insert into v2 values(40,'XiaoMing2');
insert into v2 values(19,'XiaoMing2');
create or replace view v3  (ID,NAME) as select id, name from v2 where id>=15;
insert into v3 values(4,'XiaoMing2');
insert into v3 values(15,'XiaoMing2');
insert into v3 values(46,'XiaoMing2');

#视图-检查选项local本地
#local意味着只检查当前视图选项，只有在前置检查选项出现了local或cascaded，才会相应地检查前置视图条件
#local本地
#比如，v2视图是基于v1视图的，如果在v2视图创建的时候指定了检查选项为 local ，但是v1视图创建时未指定检查选项。 则在执行检查时，知会检查v2，不会检查v2的关联视图v1。判定层次无限。
create or replace view v4  (ID,NAME) as select id, name from v3 where id>=8 with local check option;
insert into v4 values(13,'XiaoMing2');

#视图-更新及作用
#要使视图可更新，视图中的行与基础表中的行之间必须存在一对一的关系。如果视图包含以下任何一项，则该视图不可更新：
#A. 聚合函数或窗口函数（SUM()、 MIN()、 MAX()、 COUNT()等）
#B. DISTINCT
#C. GROUP BY
#D. HAVING
#E. UNION 或者 UNION ALL
#1). 简单
#视图不仅可以简化用户对数据的理解，也可以简化他们的操作。那些被经常使用的查询可以被定义为视图，从而使得用户不必为以后的操作每次指定全部的条件。
#2). 安全
#数据库可以授权，但不能授权到数据库特定行和特定的列上。通过视图用户只能查询和修改他们所能见到的数据
#3). 数据独立
#视图可帮助用户屏蔽真实表结构变化带来的影响。

#视图-案例练习
#1). 为了保证数据库表的安全性，开发人员在操作tb_user表时，只能看到的用户的基本字段，屏蔽手机号和邮箱两个字段。
create or replace view tb_user_basic as select id,name,profession,age,gender,status,createtime from tb_user;
select * from tb_user_basic;
#2). 查询每个学生所选修的课程（三张表联查），这个功能在很多的业务中都有使用到，为了简化操作，定义一个视图。
create or replace view view_student_course(stu_name,cos_name) as select s.name,c.name from student s, student_course sc,course c where s.id=sc.studentid and sc.courseid=c.id order by s.name;
select * from view_student_course;