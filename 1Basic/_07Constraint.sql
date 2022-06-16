#约束
#概念：约束是作用于表中字段的规则，限制表中数据具体值的特点
#目的：保证数据库中数据准确、有效性和完整性
#分类：
#not null：非空约束，不可为null
#unique：唯一约束，字段不可以重复
#primary key：主键约束，一行的唯一标识，非空唯一
#auto_increment: 自增，此关键字操作随数据库变化
#default：默认约束，若保存数据时未指定值，使用默认值替代
#check：检查约束，8.0.16版本更新，保证字段值满足某一条件
#foreign key：外键约束，让两张表之间的字段保持连接，保证数据一致性和完整性
#约束作用于字段，在创建和修改表时指定

#非外键约束的案例
use test;
drop table people;
create table if not exists people(
	id int primary key auto_increment comment 'primary key', #自增主键
    name varchar(10) not null unique comment 'a person\'s name', #非空唯一
    age int check(age between 1 and 120) comment 'a person\'s age', #检查范围
    status char(1) default(1) comment 'the status', #默认为1
    gender varchar(6) check(gender in ('male','female')) #检查特定值
)comment 'poeple information';
truncate people;
select * from people;

#正常插入三条数据
insert into people(name,age,status,gender) values('tom1',10,3,'female'),('tom2',12,2,'male'),('tom3',22,1,'male');
#一条默认status的数据
insert into people(name,age,gender) values('wow',100,'female');
#违反姓名唯一约束或非空约束
insert into people(name,age,status,gender) values('tom3',11,3,'male');
insert into people(name,age,status,gender) values(null,10,3,'male');
#违反年龄检查约束
insert into people(name,age,status,gender) values('wow',180,3,'male');

#添加与删除外键约束
#建表时语法：
-- create table 表名(
-- 	字段定义...
--     ...
--     [constraint] [外键名称] foreign key(外键字段名) references 主表(主表列名)
-- );
#修改表语法
#alter table 表名 add constraint 外键名称 foreign key(外键字段名) references 主表(主表列名);
#删除外键语法
#alter table 表名 drop foreign key 外键名称;

#数据准备
use test;
drop table if exists dept;
create table if not exists dept(
	id int auto_increment primary key,
    name varchar(50) not null
);
insert into dept(id,name) values(1,'研发部'),(2,'市场部'),(3,'财务部'),(4,'销售部'),(5,'总经办');
drop table if exists emp;
create table emp(
	id int auto_increment primary key comment '编号',
    name varchar(50) not null comment '姓名',
    age tinyint unsigned comment '年龄',
    job varchar(20),
    salary int,
    entrydate date comment '入职日期',
    managerid int ,
    dept_id int
)comment '员工表';
insert into emp(id,name,age,job,salary,entrydate,managerid,dept_id) values
	(1,'aaa',66,'总裁',20000,'2000-01-01',null,5),
    (2,'bbb',20,'项目经理',12500,'2005-01-01',1,1),
    (3,'ccc',33,'开发',8400,'2000-11-01',2,1),
    (4,'ddd',48,'开发',11000,'2002-02-01',2,1),
    (5,'eee',43,'开发',10500,'2004-09-01',3,1),
    (6,'fff',19,'程序员鼓励师',6600,'2004-10-01',2,1);
    
#添加外键
alter table emp add constraint fk_emp_dept_id foreign key(dept_id) references dept(id);

#删除父表内容测试
delete from dept where id=1;

#删除外键
alter table emp drop foreign key fk_emp_dept_id;

#外键约束的删除更新行为设置
#更新行为添加在对应语句的末尾
#no action默认，删除更新父表记录，若有对应外键记录，则不允许
#restrict 删除更新父表记录，若有对应外键记录，则不允许
#cascade 删除更新父表记录，若有对应外键记录，则也对外键记录同样操作
alter table emp add constraint fk_emp_dept_id foreign key(dept_id) references dept(id) on update cascade on delete cascade;
#set null 删除更新父表记录，若有对应外键记录，则将外键记录设为null
alter table emp add constraint fk_emp_dept_id foreign key(dept_id) references dept(id) on update set null on delete set null;
#set default 删除更新父表记录，若有对应外键记录，则将外键记录设为默认值（innodb不支持）

#cascade测试
update dept set id=6 where id=1;
select * from emp;
select * from dept;
delete from dept where id =6;

#set null测试
update dept set id=6 where id=1;
select * from dept;
select * from emp;
delete from dept where id =6;

