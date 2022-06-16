#DML DATA MANIPULATION LANGUAGE，数据操作语言，用来对数据库中表记录进行增删改操作
#添加数据，删除数据，修改数据

#DDL-添加数据

#给指定字段添加数据 
#insert into 表名(字段名1,字段名2...) values(值1,值2...);
insert into employees(id, workno,empname,gender,age,idcard,emptime) values(0,'100100','Jack','男',20,'123456199909090011','2020-01-01');

#给全部字段添加数据
#insert into 表名 values(值1,值2...);
insert into employees values(1,'101100','John','男',22,'123456199909090012','2019-01-01');

#批量添加数据
#insert into 表名(字段名1,字段名2...) values(值1，值2...),(值1，值2...)...;
#insert into 表名 values(值1，值2...),(值1，值2...)...;
insert into employees values(2,'111100','John1','女',22,'123452199909090012','2019-11-01'),(3,'101130','May','男',12,'123456499909090012','2018-01-01');

#DML-修改数据
#update 表名 set 字段名1=值1,字段名2=值2,...[where 条件];
update employees set empname='Mary',age=19 where id=2;
update employees set emptime='2019-09-09';

#DML-删除数据
#delete from 表名 [where 条件];
delete from employees where gender='女';
delete from employees;

#工具语句
use test;
DESC employees;
select * from employees;