#触发器-介绍
-- 触发器是与表有关的数据库对象，指在insert/update/delete之前(BEFORE)或之后(AFTER)，触
-- 发并执行触发器中定义的SQL语句集合。触发器的这种特性可以协助应用在数据库端确保数据的完整性
-- , 日志记录 , 数据校验等操作 。
-- 使用别名OLD和NEW来引用触发器中发生变化的记录内容，这与其他的数据库是相似的。现在触发器还
-- 只支持行级触发，不支持语句级触发。
#触发器-三种触发器
-- INSERT 型触发器 NEW 表示将要或者已经新增的数据
-- UPDATE 型触发器 OLD 表示修改之前的数据 , NEW 表示将要或已经修改后的数据
-- DELETE 型触发器 OLD 表示将要或者已经删除的数据

#触发器-语法
#创建触发器
-- CREATE TRIGGER trigger_name
-- BEFORE/AFTER INSERT/UPDATE/DELETE
-- ON tbl_name FOR EACH ROW -- 行级触发器
-- BEGIN
-- trigger_stmt ;
-- END;
#查看触发器
-- SHOW TRIGGERS ;
SHOW TRIGGERS ;
#删除触发器
-- DROP TRIGGER [schema_name.]trigger_name ; -- 如果没有指定 schema_name，默认为当前数据库 。
#触发器实践
#创建一张日志表user_logs，记录对tb_user表进行的增删改操作日志
#创建表，准备日志表结构
create table if not exists user_logs(
id int(11) not null auto_increment,
operation varchar(20) not null comment '操作类型, insert/update/delete',
operate_time datetime not null comment '操作时间',
operate_id int(11) not null comment '操作的ID',
operate_params varchar(500) comment '操作参数',
primary key(`id`)
)engine=innodb default charset=utf8;
select * from user_logs;
#创建插入数据触发器并测试
drop trigger if exists test.tb_user_insert_trigger;
delimiter $$
create trigger tb_user_insert_trigger
after insert on tb_user for each row
begin
	insert into user_logs(operation,operate_time,operate_id,operate_params) 
    values('insert',now(),new.id,concat('id=',new.id,'name=',new.name,'phone=',new.phone,'email=',new.email,'profession=',new.profession,'age=',new.age,'gender=',new.gender,'status=',new.status,'createtime=',new.createtime));
end;$$
insert into tb_user values (null,'李华','18181818181','181818181818@qq.com','经济科学',22,'女','2',now());
#创建修改数据触发器并测试
drop trigger if exists test.tb_user_update_trigger;
delimiter $$
create trigger tb_user_update_trigger
after update on tb_user for each row
begin
	insert into user_logs(operation,operate_time,operate_id,operate_params) 
    values('update',now(),new.id,concat(
		'old data: ','id=',old.id,'name=',old.name,'phone=',old.phone,'email=',old.email,'profession=',old.profession,'age=',old.age,'gender=',old.gender,'status=',old.status,'createtime=',old.createtime,
        'new data: ','id=',new.id,'name=',new.name,'phone=',new.phone,'email=',new.email,'profession=',new.profession,'age=',new.age,'gender=',new.gender,'status=',new.status,'createtime=',new.createtime));
end;$$
update tb_user set gender='1',phone='18123456789',email='18123456789@qq.com' where id=26;
#创建删除数据触发器并测试
drop trigger if exists test.tb_user_delete_trigger;
delimiter $$
create trigger tb_user_delete_trigger
after delete on tb_user for each row
begin
	insert into user_logs(operation,operate_time,operate_id,operate_params) 
    values('delete',now(),old.id,concat('id=',old.id,'name=',old.name,'phone=',old.phone,'email=',old.email,'profession=',old.profession,'age=',old.age,'gender=',old.gender,'status=',old.status,'createtime=',old.createtime));
end;$$
delete from tb_user where id=26;