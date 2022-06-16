#DCL，Data Control Language，用来管理数据库用户，控制数据库访问

#DCL管理用户

#查询用户
#use mysql;
#select * from user;

#创建用户
#create user '用户名'@'主机名' identified by '密码';

#修改用户密码
#alter user '用户名'@'主机名' identified with mysql_native_password by '密码';

#删除用户
#drop user '用户名'@'主机名';
#主机名可以用%通配，用户与权限相关SQL主要由数据库管理员Database Administrator使用

#windows控制台登录数据库语法
#mysql -u 用户名 -p

#查询用户
use mysql;
select * from user;

#创建用户itcast，只可以在localhost访问，密码123456
create user 'itcast'@'localhost' identified by '123456';

#创建用户sean，可在任意主机访问，密码123456
create user 'sean'@'%' identified by '123456';

#修改用户sean的密码为1234
alter user 'sean'@'%' identified with mysql_native_password by '1234';

#删除itcast@localhost用户
drop user 'itcast'@'localhost';
drop user 'sean'@'%';

#DCL权限控制
#常用权限：All/ALL PRIVILEGES所有权限,SELECT查询数据,INSERT插入数据,UPDATE修改数据,DELETE删除数据,ALTER修改表,DROP删除数据库表视图,CREATE创建数据库表

#查询权限
#show grants for '用户名'@'主机名'
#授予权限
#grant 权限列表 on 数据库.表名 to '用户名'@'主机名'
#撤销权限
#revoke 权限列表 on 数据库名.表名 from '用户名'@'主机名'

#查询权限
show grants for 'itcast'@'localhost';

#授予权限
grant all privileges on test.* to 'itcast'@'localhost';

#撤销权限
revoke all privileges on test.* from 'itcast'@'localhost';