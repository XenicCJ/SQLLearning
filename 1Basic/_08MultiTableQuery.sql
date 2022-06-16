#多表查询
#概述：项目开发中，在进行数据库表结构设计时，会根据业务需求和模块关系，分析并设计表结构，由于业务间相互关联，各个表结构之间存在各种联系，这些联系分为三种：一对多，多对多，一对一
#一对多关系：一张表的一条数据对应另一张表的多条数据，例如员工与部门的关系
#多对多关系：一张表的多条数据对应另一张表的多条数据，例如学生与课程的关系。实现可考虑增加中间表。
#一对一关系：一张表的一条数据对应另一张表的一条数据，例如身份证和人的关系，用户和用户详情的关系。实现时将单表拆分，增加外键关联。

#多表查询概述
#从多张表中查询数据
#笛卡尔乘积：在数学中，两个集合的所有组合情况，多表查询时要消除无效的笛卡尔积

#演示
#数据准备
-- 创建dept表，并插入数据
create table dept(
id int auto_increment comment 'ID' primary key,
name varchar(50) not null comment '部门名称'
)comment '部门表';
INSERT INTO dept (id, name) VALUES (1, '研发部'), (2, '市场部'),(3, '财务部'), (4,
'销售部'), (5, '总经办'), (6, '人事部');
-- 创建emp表，并插入数据
create table emp(
id int auto_increment comment 'ID' primary key,
name varchar(50) not null comment '姓名',
age int comment '年龄',
job varchar(20) comment '职位',
salary int comment '薪资',
entrydate date comment '入职时间',
managerid int comment '直属领导ID',
dept_id int comment '部门ID'
)comment '员工表';
-- 添加外键
alter table emp add constraint fk_emp_dept_id foreign key (dept_id) references
dept(id);
INSERT INTO emp (id, name, age, job,salary, entrydate, managerid, dept_id)
VALUES
(1, '金庸', 66, '总裁',20000, '2000-01-01', null,5),
(2, '张无忌', 20, '项目经理',12500, '2005-12-05', 1,1),
(3, '杨逍', 33, '开发', 8400,'2000-11-03', 2,1),
(4, '韦一笑', 48, '开发',11000, '2002-02-05', 2,1),
(5, '常遇春', 43, '开发',10500, '2004-09-07', 3,1),
(6, '小昭', 19, '程序员鼓励师',6600, '2004-10-12', 2,1),
(7, '灭绝', 60, '财务总监',8500, '2002-09-12', 1,3),
(8, '周芷若', 19, '会计',4800, '2006-06-02', 7,3),
(9, '丁敏君', 23, '出纳',5250, '2009-05-13', 7,3),
(10, '赵敏', 20, '市场部总监',12500, '2004-10-12', 1,2),
(11, '鹿杖客', 56, '职员',3750, '2006-10-03', 10,2),
(12, '鹤笔翁', 19, '职员',3750, '2007-05-09', 10,2),
(13, '方东白', 19, '职员',5500, '2009-02-12', 10,2),
(14, '张三丰', 88, '销售总监',14000, '2004-10-12', 1,4),
(15, '俞莲舟', 38, '销售',4600, '2004-10-12', 14,4),
(16, '宋远桥', 40, '销售',4600, '2004-10-12', 14,4),
(17, '陈友谅', 42, null,2000, '2011-10-12', 1,null);
create table salgrade(
grade int,
losal int,
hisal int
) comment '薪资等级表';
insert into salgrade values (1,0,3000);
insert into salgrade values (2,3001,5000);
insert into salgrade values (3,5001,8000);
insert into salgrade values (4,8001,10000);
insert into salgrade values (5,10001,15000);
insert into salgrade values (6,15001,20000);
insert into salgrade values (7,20001,25000);
insert into salgrade values (8,25001,30000);

#笛卡尔乘积查询:
select * from dept,emp;

#多表查询分类
#连接查询
#	内连接：查询多个集合交集的部分
#	外连接：左外连接查询左表所有数据与交集数据，右外连接查询右表所有数据与交集数据
#	自连接：表与自身的连接查询，必须使用表别名
# 子查询、内部查询、嵌套查询：将一个查询结果作为另一个查询的数据源或判断条件

#内连接
#隐式内连接
#SELECT 字段列表 FROM 表1 , 表2 WHERE 条件 ... ;
#显式内连接
#SELECT 字段列表 FROM 表1 [ INNER ] JOIN 表2 ON 连接条件 ... ;

#隐式内连接与显示内连接查询示例,查询每个员工的姓名和对应部门：
select e.name,d.name from emp e,dept d where d.id=e.dept_id order by e.id;
select e.name,d.name from emp e inner join dept d on d.id=e.dept_id order by e.id;

#外连接查询语法：
#左外连接
#SELECT 字段列表 FROM 表1 LEFT [ OUTER ] JOIN 表2 ON 条件 ... ;
#右外连接
#SELECT 字段列表 FROM 表1 RIGHT [ OUTER ] JOIN 表2 ON 条件 ... ;

#使用左外连接，查询emp所有数据，和对应dept数据
select e.*,d.* from emp e left join dept d on e.dept_id=d.id; 

#使用右外连接，查询dept所有数据，和对应员工信息
select d.*,e.* from emp e right join dept d on e.dept_id=d.id; 

#自连接
#可以是内连接也可以是外连接
#SELECT 字段列表 FROM 表A 别名A JOIN 表A 别名B ON 条件 ... ;

#查询员工及其所属领导的名字
select e1.name '员工',e2.name '领导' from emp e1 join emp e2 on e1.managerid=e2.id;

#查询所有员工及其领导名字，如果员工没有领导也要查出来
select e1.name '员工',e2.name '领导' from emp e1 left join emp e2 on e1.managerid=e2.id;

#联合查询
#使用union或union all关键字将两次查询结果合并成一个新的数据集，添加all会不去重，联合查询中的多张结果表列数和对应字段类型必须一致
#SELECT 字段列表 FROM 表A ...
#UNION [ ALL ]
#SELECT 字段列表 FROM 表B ....;

#将薪资低于5000的员工和年龄大于50的员工查出来
select * from emp where salary<5000
union
select * from emp where age>50
order by id;

#子查询
#子查询、内部查询、嵌套查询：将一个查询结果作为另一个查询的数据源或判断条件
#SELECT * FROM t1 WHERE column1 = ( SELECT column1 FROM t2 );
#子查询外部语句可以是增删改查的任意一个
#子查询分类：
#	标量子查询，结果为单个值
#	列子查询，结果为一列
#	行子查询，结果为一行
#	表子查询，结果为多行多列
#子查询位置分为where后、from后、select后

#标量子查询一般用于大于小于等于的条件判断

#查询‘销售部’所有员工信息
select * from emp e where e.dept_id=(select d.id from dept d where d.name='销售部');

#查询在‘方东白’之后入职的员工信息
select * from emp e where e.entrydate>(select e.entrydate from emp e where e.name='方东白');

#列子查询一般用于in、not in、any 、some、all的条件判断

#查询销售部和市场部的所有员工信息
select e.* from emp e where e.dept_id in (select d.id from dept d where d.name in ('销售部','市场部'));

#查询比财务部所有人工资都高的员工信息
select * from emp where salary > all (select e.salary from emp e where e.dept_id in (select d.id from dept d where d.name in ('财务部')));

#查询比研发部中任意一人工资高的员工信息
select * from emp where salary > any (select e.salary from emp e where e.dept_id in (select d.id from dept d where d.name in ('研发部')));

#行子查询
#结果为一列
#常用操作符：=,<>,in,not in

#查询与张无忌的薪资和直属领导相同的员工信息
select * from emp where (salary,managerid) = (select salary,managerid from emp where name='张无忌');

#表子查询
#结果为多行多列
#常用操作符：in

#查询与鹿杖客或宋远桥职位与薪资相同的员工信息
select * from emp where (job,salary) in (select job,salary from emp where name in('鹿杖客','宋远桥'));

#查询入职日期是2006-01-01之后的员工信息及其部门信息
select * from (select e.*,d.name dept_name from emp e left join dept d on e.dept_id=d.id) t where t.entrydate>'2006-01-01';

#12个练习案例

#查询员工的姓名、年龄、职位、部门信息（隐式内连接）
select e.name,e.age,e.job,d.name from emp e ,dept d where e.dept_id=d.id;

#查询年龄小于30岁的员工的姓名、年龄、职位、部门信息（显式内连接）
select e.name,e.age,e.job,d.* from emp e join dept d on e.dept_id=d.id where e.age<30;

#查询拥有员工的部门ID、部门名称
#先查询有员工的部门id
select e.dept_id from emp e group by e.dept_id having count(*)>0;
#再整合查询
select * from dept d where d.id in (select e.dept_id from emp e group by e.dept_id having count(*)>0);

#查询所有年龄大于40岁的员工, 及其归属的部门名称; 如果员工没有分配部门, 也需要展示出（外连接）
#先外连接查询出员工和部门数据
select e.*,d.name dept_name from emp e left join dept d on e.dept_id=d.id where e.age>40;

#查询所有员工的工资等级
select e.*,s.grade 'salary level' from emp e left join salgrade s on e.salary between s.losal and s.hisal;

#查询 "研发部" 所有员工的信息及 工资等级
#先查询所有研发部的员工信息
select * from emp e where e.dept_id in (select d.id from dept d where d.name='研发部');
#然后联合查询
select e.*,s.grade 'salary level' from (select * from emp e where e.dept_id in (select d.id from dept d where d.name='研发部')) e left join salgrade s on e.salary between s.losal and s.hisal;

#查询 "研发部" 员工的平均工资
#先查询所有研发部的员工信息
select * from emp e where e.dept_id in (select d.id from dept d where d.name='研发部');
#再求平均工资
select avg(e.salary) from (select * from emp e where e.dept_id in (select d.id from dept d where d.name='研发部')) e; 

#查询工资比 "灭绝" 高的员工信息
#先求灭绝的工资
select e.salary from emp e where e.name='灭绝';
#然后查询工资比灭绝高的员工信息
select e.* from emp e where e.salary>(select e.salary from emp e where e.name='灭绝');

#查询比平均薪资高的员工信息
#先求平均工资
select avg(e.salary) from emp e;
#然后查找薪资比平均工资高的员工
select e.* from emp e where e.salary>(select avg(e.salary) from emp e);

#查询低于本部门平均工资的员工信息
#先查询各部门的平均工资
select e.dept_id,avg(e.salary) from emp e where dept_id is not null group by dept_id;
#将平均工资结果与员工表内连接，得出结果
select e.* from emp e join (select e.dept_id,avg(e.salary) avgs from emp e where dept_id is not null group by dept_id) t on e.dept_id=t.dept_id where e.salary<t.avgs;

#查询所有的部门信息, 并统计部门的员工人数
#先查询各个部门id对应人数
select e.dept_id, count(*) c from emp e group by e.dept_id;
#再查所有部门信息对应人数
select d.*,ifnull(t.c,0) from dept d left join (select e.dept_id, count(*) c from emp e group by e.dept_id) t on d.id=t.dept_id;

#最后一题数据准备
create table student(
id int auto_increment primary key comment '主键ID',
name varchar(10) comment '姓名',
no varchar(10) comment '学号'
) comment '学生表';
insert into student values (null, '黛绮丝', '2000100101'),(null, '谢逊',
'2000100102'),(null, '殷天正', '2000100103'),(null, '韦一笑', '2000100104');
create table course(
id int auto_increment primary key comment '主键ID',
name varchar(10) comment '课程名称'
) comment '课程表';
insert into course values (null, 'Java'), (null, 'PHP'), (null , 'MySQL') ,
(null, 'Hadoop');
create table student_course(
id int auto_increment comment '主键' primary key,
studentid int not null comment '学生ID',
courseid int not null comment '课程ID',
constraint fk_courseid foreign key (courseid) references course (id),
constraint fk_studentid foreign key (studentid) references student (id)
)comment '学生课程中间表';
insert into student_course values (null,1,1),(null,1,2),(null,1,3),(null,2,2),
(null,2,3),(null,3,4);

#查询所有学生的选课情况, 展示出学生名称, 学号, 课程名称
select s.name,s.no,c.name from student s,student_course sc, course c where sc.studentid=s.id and sc.courseid=c.id;