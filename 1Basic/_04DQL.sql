#DQL,data query language,数据查询语言，用来查询数据库中的记录

#DQL语法，编写顺序
/*
select 字段列表--[[as] 别名]
from 表名列表
where 条件列表--比较运算符：>, >=, < ,<=, =, <>, !=, between...and..., in(...), like 占位符, is null 
			   逻辑运算符: and && or || not !
               分组前过滤
group by 分组字段列表
having 分组后条件列表--分组后过滤
order by 排序字段列表--升序asc，降序desc
limit 分页参数--起始索引从0开始，起始索引=（查询页码-1）*每页记录数，例如每页10条数据，第三页起始索引为20
*/

#DQL-基本查询

#查询多个字段
#select 字段1,字段2,... from 表名;
select id,workno,age from emp;

#查询所有字段
#select * from 表名
select * from emp;

#设置别名

#select 字段1 [as 别名1],字段2 [as 别名2],... from  表名;
select id as '编号', workaddress as '工作地点' from emp;
select id '编号', workaddress '工作地点' from emp;

#去除重复记录
#select distinct 字段列表 from 表名;
select distinct workaddress from emp;

#DQL条件查询

#语法
#select 字段列表 from 表名 where 条件列表;
#条件
#比较运算符：>, >=, < ,<=, =, <>, !=, between...and..., in(...), like 占位符, is null
#逻辑运算符: and && or || not !

#在以下练习前先创建表与数据

#1查询年龄等于80的员工信息
select  * from emp where age=80;
#2查询年龄小于20的员工信息
select  * from emp where age<20;
#3查询年龄小于等于20的员工信息
select  * from emp where age<=20;
#4查询没有身份证号的员工信息
select  * from emp where idcard is null;
#5查询有身份证号的员工信息
select  * from emp where idcard is not null;
#6查询年龄不等于80的员工信息
select  * from emp where age!=80;
#7查询性别为女且年龄小于40的员工信息
select  * from emp where gender='女' and age<40;
#8查询年龄在20（包含）到40（包含）之间的员工信息
select  * from emp where age between 20 and 40;
#9查询年龄等于10或20或30的员工信息
select  * from emp where age in (10,20,30);
#10查询工号为两个字的员工信息（_表示单个字符，%表示任意字符串）
select  * from emp where workno like '__';
#11查询身份证号第十位为1的员工信息
select  * from emp where idcard like '_________1%';

#DQL聚合函数
#将一列数据作为一个整体，进行纵向计算
#常见聚合函数：count统计数量，max最大值，min最小值，avg平均值，sum求和
#语法：select 聚合函数(字段列表) from 表名;

#在以下练习前先创建表与数据

#统计员工数量
select count(*) '员工总数' from emp;
select count(id) '员工总数' from emp;

#统计平均年龄
select avg(age) from emp;

#统计最大年龄
select max(age) from emp;

#统计最小年龄
select min(age) from emp;

#统计上海地区员工年龄总和
select sum(age) from emp where workaddress='上海';

#DQL分组查询
#语法: select 字段列表 from 表名[where 条件] group by 分组字段名 [having 分组后过滤条件];
#where对分组前的过滤，不满足的条件不参与分组，不对聚合函数进行判断。having对分组后的结果进行过滤，对聚合函数进行判断
#执行顺序：where-聚合函数-having
#分组后查询数据一般为聚合函数和分组字段，其他内容无意义

#在以下练习前先创建表与数据

#根据性别分组，统计男员工和女员工数量
select gender,count(*) from emp group by gender;

#根据性别分组，统计男员工和女员工平均年龄
select gender,avg(age) from emp group by gender;

#查询年龄小于50的员工，根据工作地址分组，获取员工数量大于等于3的工作地址
select workaddress, count(*) c from emp where age<=50 group by workaddress having c>=3;

#DQL排序查询
#语法: select 字段列表 from 表名 order by 字段1 排序方式, 字段2 排序方式, ...;
#排序方式 asc升序（默认值），desc降序。
#多字段排序时第一个字段值相同时才会判断第二个字段。

#在以下练习前先创建表与数据

#根据年龄对员工进行升序排序
select * from emp order by age;
select * from emp order by age asc;

#根据入职时间对员工降序排序
select * from emp order by entrydate desc;

#根据年龄对员工升序排序，在此基础上根据入职时间降序排序
select * from emp e order by e.age, e.entrydate desc;

#DQL分页查询
#语法： select 字段列表 from 表名 limit 起始索引, 查询记录数;
#起始索引从0开始，起始索引=（查询页码-1）*每页记录数，例如每页10条数据，第三页起始索引为20
#分页查询关键字不同数据库可能不一样
#查询第一页数据起始索引可以省略

#在以下练习前先创建表与数据

#查询第一页员工数据，一页10条数据
select * from emp limit 0,10;
select * from emp limit 10;

#查询第三页员工数据，一页5条数据
select * from emp limit 10,5;

#查询第四页员工数据，一页5条数据
select * from emp limit 15,5;

#DQL案例练习

#在以下练习前先创建表与数据

#查询年龄为17，18，19，22岁的员工信息
select * from emp where age in (17,18,19,22);

#查询性别为男，年龄在20到40岁（含）内工号为两位数的员工信息
select * from emp where gender='男' and age between 20 and 40 and workno like '__';

#统计员工表中小于40岁的男女员工人数
select gender, count(*) from emp where age<40 group by gender;

#查询年龄小于20岁员工的姓名和年龄，并按年龄升序，然后按入职时间降序排序
select name, age from emp where age<=20 order by age,entrydate desc;

#查询性别为男，年龄在15到40（含）以内的前五个员工信息，并按年龄升序，按入职时间升序排序
select * from emp where gender='男' and age between 15 and 40 order by age,entrydate limit 5

#DQL执行顺序
-- from 表名列表
-- where 条件列表
-- group by 分组字段列表
-- having 分组后条件列表
-- select 字段列表
-- order by 排序字段列表
-- limit 分页参数

#在以下练习前先创建表与数据

#查询年龄大于15的员工姓名年龄，并根据年龄升序排序， 取前8条数据
select e.name '姓名', e.age '年龄' from emp e where e.age>=15 order by '年龄' limit 8;