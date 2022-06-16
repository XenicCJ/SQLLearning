#删除表
drop table if exists score;

#创建表
create table score(
	id int comment 'ID',
    name varchar(20) comment '姓名',
    math int comment '数学',
    english int comment '英语', 
    chinese int comment '语文'
)comment '成绩表';

#插入数据
insert into score values(1,'tom',67,88,95),(2,'rose',23,66,90),(3,'jack',56,98,76);