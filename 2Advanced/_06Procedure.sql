#存储过程-介绍
#存储过程是事先经过编译并存储在数据库中的一段 SQL 语句的集合，调用存储过程可以简化应用开发
#人员的很多工作，减少数据在数据库和应用服务器之间的传输，对于提高数据处理的效率是有好处的。
#存储过程思想上很简单，就是数据库 SQL 语言层面的代码封装与重用。

#存储过程-特点
#封装，复用 -----------------------> 可以把某一业务SQL封装在存储过程中，需要用到的时候直接调用即可。
#可以接收参数，也可以返回数据 --------> 再存储过程中，可以传递参数，也可以接收返回值。
#减少网络交互，效率提升 -------------> 如果涉及到多条SQL，每执行一次都是一次网络传输。 而如果封装在存储过程中，我们只需要网络交互一次可能就可以了。

#存储过程-基本语法
#存储过程-创建
-- delimiter $$
-- CREATE PROCEDURE 存储过程名称 ([ 参数列表 ])
-- BEGIN
-- -- SQL语句
-- END ;$$
delimiter $$
create procedure p1()
begin
	select count(*) from student;
end;$$
#存储过程-调用
-- CALL 名称 ([ 参数 ]);
call p1();
#存储过程-查看
-- SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = '数据库名'; -- 查询指定数据库的存储过程及状态信息
-- SHOW CREATE PROCEDURE 存储过程名称 ; -- 查询某个存储过程的定义
SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_SCHEMA = 'test';
show create procedure p1;
#存储过程-删除
-- DROP PROCEDURE [ IF EXISTS ] 存储过程名称 ；
drop procedure if exists p1;

#存储过程-变量
#在MySQL中变量分为三种类型: 系统变量、用户定义变量、局部变量

#存储过程-系统变量
#系统变量 是MySQL服务器提供，不是用户定义的，属于服务器层面。分为全局变量（GLOBAL）、会话变量（SESSION）。
#存储过程-查看系统变量
#SHOW [ SESSION | GLOBAL ] VARIABLES ; -- 查看所有系统变量
#SHOW [ SESSION | GLOBAL ] VARIABLES LIKE '......'; -- 可以通过LIKE模糊匹配方式查找变量
#SELECT @@[SESSION | GLOBAL]系统变量名; -- 查看指定变量的值
show session variables;
show global variables like 'auto%';
select @@global.autocommit;
#存储过程-设置系统变量
#SET [ SESSION | GLOBAL ] 系统变量名 = 值 ;
#SET @@[SESSION | GLOBAL]系统变量名 = 值 ;
set global autocommit=1;
set @@global.autocommit=1;
#注意:
#如果没有指定SESSION/GLOBAL，默认是SESSION，会话变量。
#mysql服务重新启动之后，所设置的全局参数会失效，要想不失效，可以在 /etc/my.cnf 中配置。
#A. 全局变量(GLOBAL): 全局变量针对于所有的会话。
#B. 会话变量(SESSION): 会话变量针对于单个会话，在另外一个会话窗口就不生效了。

#存储过程-用户变量
#存储过程-用户变量赋值
#SET @var_name = expr [, @var_name = expr] ... ;
#SET @var_name := expr [, @var_name := expr] ... ;
#SELECT @var_name := expr [, @var_name := expr] ... ;
#SELECT 字段名 INTO @var_name FROM 表名;
set @myvar:='hello world';
select @myvar;
select name into @myvar from student where id=1;
#存储过程-用户变量使用
# SELECT @var_name ;
select @myvar;
#注意: 用户定义的变量无需对其进行声明或初始化，只不过获取到的值为NULL。
select @nullvar;

#存储过程-局部变量
#局部变量 是根据需要定义的在局部生效的变量，访问之前，需要DECLARE声明。可用作存储过程内的局部变量和输入参数，局部变量的范围是在其内声明的BEGIN ... END块。
#存储过程-局部变量声明
#DECLARE 变量名 变量类型 [DEFAULT ... ] ;
#变量类型就是数据库字段类型：INT、BIGINT、CHAR、VARCHAR、DATE、TIME等。
#存储过程-局部变量赋值
#SET 变量名 = 值 ;
#SET 变量名 := 值 ;
#SELECT 字段名 INTO 变量名 FROM 表名 ... ;
#存储过程-局部变量实践
drop procedure if exists p2;
delimiter $$
create procedure p2()
begin	
	declare stucount int default 0;
	select count(*) into stucount from student;
    select stucount;
end;$$
call p2();

#存储过程-if
#存储过程-if语法
-- IF 条件1 THEN
-- .....
-- ELSEIF 条件2 THEN -- 可选
-- .....
-- ELSE -- 可选
-- .....
-- END IF;
#在if条件判断的结构中，ELSE IF 结构可以有多个，也可以没有。 ELSE结构可以有，也可以没有
#存储过程-if实践
#根据定义的分数score变量，判定当前分数对应的分数等级
drop procedure if exists p3;
delimiter $$
create procedure p3()
begin
	declare score int default 120;
    declare level varchar(20);
    
    if score<60 && score >=0 then
		set level:='不合格';
	elseif score<=90 then
		set level:='合格';
	elseif score <=100 then
		set level:='优秀';
	else
		set level:='无效成绩';
	end if;
    
	select level;
end;$$
call p3();

#存储过程-参数介绍
#参数的类型，主要分为以下三种：IN、OUT、INOUT。 具体的含义如下
#in 该类参数作为输入，也就是需要调用时传入值 默认
#out 该类参数作为输出，也就是该参数可以作为返回值
#inout 既可以作为输入参数，也可以作为输出参数
-- CREATE PROCEDURE 存储过程名称 ([ IN/OUT/INOUT 参数名 参数类型 ])
-- BEGIN
-- -- SQL语句
-- END ;
#存储过程-参数案例
#根据传入参数score，判定当前分数对应的分数等级，并返回。
drop procedure if exists p4;
delimiter $$
create procedure p4(in score int,out level varchar(20))
begin
    if score<60 and score >=0 then
		set level:='不合格';
	elseif score<=90 then
		set level:='合格';
	elseif score <=100 then
		set level:='优秀';
	else
		set level:='无效成绩';
	end if;
end;$$
set @score=100;
call p4(@score,@level);
select @level;
#将传入的200分制的分数，进行换算，换算成百分制，然后返回。
drop procedure if exists p5;
delimiter $$
create procedure p5(inout score int)
begin
	if score<0 or score>200 then
		set score=null;
	end if;
    set score=score/2;
end;$$
set @score=180;
call p5(@score);
select @score;

#存储过程-case介绍
#case结构及作用，和我们在基础篇中所讲解的流程控制函数很类似。有两种语法格式
#语法1
-- 含义： 当case_value的值为 when_value1时，执行statement_list1，当值为 when_value2时，
-- 执行statement_list2， 否则就执行 statement_list
-- CASE case_value
-- WHEN when_value1 THEN statement_list1
-- [ WHEN when_value2 THEN statement_list2] ...
-- [ ELSE statement_list ]
-- END CASE;
#语法2
-- 含义： 当条件search_condition1成立时，执行statement_list1，当条件search_condition2成
-- 立时，执行statement_list2， 否则就执行 statement_list
-- CASE
-- WHEN search_condition1 THEN statement_list1
-- [WHEN search_condition2 THEN statement_list2] ...
-- [ELSE statement_list]
-- END CASE;
#存储过程-case案例
#根据传入的月份，判定月份所属的季节（要求采用case结构）。1-3月份，为第一季度4-6月份，为第二季度7-9月份，为第三季度10-12月份，为第四季度
drop procedure if exists p6;
delimiter $$
create procedure p6(in month int, out season varchar(20))
begin
	case
    when month between 1 and 3 then 
		set season='first season';
    when month between 4 and 6 then 
		set season='second season';
    when month between 7 and 9 then 
		set season='third season';
    when month between 10 and 12 then 
		set season='fourth season';
    else 
		set season=null;
    end case;
end;$$
set @month=9;
call p6(@month,@season);
select concat('input month is: ',@month," season is: ",@season);

#存储过程-while介绍
#while 循环是有条件的循环控制语句。满足条件后，再执行循环体中的SQL语句。具体语法为
#-- 先判定条件，如果条件为true，则执行逻辑，否则，不执行逻辑
-- WHILE 条件 DO
-- SQL逻辑...
-- END WHILE;
#存储过程-while案例
#计算从1累加到n的值，n为传入的参数值
drop procedure if exists p7;
delimiter $$
create procedure p7(in n int, out ret int)
begin
	set ret=0;
    while n>0 do
		set ret=n+ret;
        set n=n-1;
	end while;
end;$$
set @n=100;
call p7(@n,@ret);
select concat('n is: ',@n," ret is: ",@ret);

#存储过程-repeat介绍
#repeat是有条件的循环控制语句, 当满足until声明的条件的时候，则退出循环 。具体语法为
-- 先执行一次逻辑，然后判定UNTIL条件是否满足，如果满足，则退出。如果不满足，则继续下一次循环
-- REPEAT
-- SQL逻辑...
-- UNTIL 条件
-- END REPEAT;
#存储过程-repeat案例
#计算从1累加到n的值，n为传入的参数值。(使用repeat实现)
drop procedure if exists p8;
delimiter $$
create procedure p8(in n int, out ret int)
begin
	set ret=0;
    repeat
		set ret=n+ret;
        set n=n-1;
	until n<=0 
    end repeat;
end;$$
set @n=100;
call p8(@n,@ret);
select concat('n is: ',@n," ret is: ",@ret);

#存储过程-loop介绍
#LOOP 实现简单的循环，如果不在SQL逻辑中增加退出循环的条件，可以用其来实现简单的死循环。LOOP可以配合以下两个语句使用
#LEAVE ：配合循环使用，退出循环。
#ITERATE：必须用在循环中，作用是跳过当前循环剩下的语句，直接进入下一次循环。
-- [begin_label:] LOOP
-- SQL逻辑...
-- END LOOP [end_label];
-- LEAVE label; -- 退出指定标记的循环体
-- ITERATE label; -- 直接进入下一次循环
#存储过程-loop案例
#计算从1到n之间的偶数累加的值，n为传入的参数值。
drop procedure if exists p9;
delimiter $$
create procedure p9(in n int, out ret int)
begin
	set ret=0;
    evenadd: loop
		if n<=0 then 
			leave evenadd;
		end if;
        
        if n%2=0 then
			set ret=ret+n;
        end if;
        
        set n=n-1;
        
        iterate evenadd;
	end loop evenadd;
end;$$
set @n=6;
call p9(@n,@ret);
select concat('n is: ',@n," ret is: ",@ret);

#存储过程-cursor介绍
#游标（CURSOR）是用来存储查询结果集的数据类型 , 在存储过程和函数中可以使用游标对结果集进行循环的处理。游标的使用包括游标的声明、OPEN、FETCH 和 CLOSE，其语法分别如下
#声明游标
#DECLARE 游标名称 CURSOR FOR 查询语句 ;
#打开游标
#OPEN 游标名称 ;
#获取游标记录
#FETCH 游标名称 INTO 变量 [, 变量 ] ;
#关闭游标
#CLOSE 游标名称 ;
#存储过程-游标cursor案例
#根据传入的参数uage，来查询用户表tb_user中，所有的用户年龄小于等于uage的用户姓名（name）和专业（profession），并将用户的姓名和专业插入到所创建的一张新表(id,name,profession)中。
drop procedure if exists p10;
delimiter $$
create procedure p10(in uage int)
begin
	declare tname varchar(50);
    declare tprofession varchar(11);
	-- 获取查询数据游标
	declare tb_uage_young_cs cursor for select t.name,t.profession from tb_user t where t.age<=uage;
    
    -- 创建新表
    drop table if exists tb_user_young;
    create table tb_user_young(
		id int primary key auto_increment,
        name varchar(50),
        profession varchar(11)
    );
    
    -- 插入数据
    open tb_uage_young_cs;
    while true do
		fetch tb_uage_young_cs into tname,tprofession;
        insert into tb_user_young(name,profession) values(tname,tprofession);
	end while;
    close tb_uage_young_cs;
end;$$
set @uage=40;
call p10(@uage);
#上述的功能，虽然我们实现了，但是逻辑并不完善，而且程序执行完毕，获取不到数据，数据库还报错。 接下来，我们就需要来完成这个存储过程，并且解决这个问题。
#想解决这个问题，就需要通过MySQL中提供的 条件处理程序 Handler 来解决

#存储过程-条件处理程序handler介绍
#条件处理程序（Handler）可以用来定义在流程控制结构执行过程中遇到问题时相应的处理步骤。具体语法为
-- DECLARE handler_action HANDLER FOR condition_value [, condition_value]... statement ;
-- handler_action 的取值：
-- CONTINUE: 继续执行当前程序
-- EXIT: 终止执行当前程序
-- condition_value 的取值：
-- SQLSTATE sqlstate_value: 状态码，如 02000
-- SQLWARNING: 所有以01开头的SQLSTATE代码的简写
-- NOT FOUND: 所有以02开头的SQLSTATE代码的简写
-- SQLEXCEPTION: 所有没有被SQLWARNING 或 NOT FOUND捕获的SQLSTATE代码的简写
#具体的错误状态码，可以参考官方文档：
#https://dev.mysql.com/doc/refman/8.0/en/declare-handler.html
#https://dev.mysql.com/doc/mysql-errors/8.0/en/server-error-reference.html
#存储过程-条件处理程序handler案例
drop procedure if exists p10;
delimiter $$
create procedure p10(in uage int)
begin
	declare tname varchar(50);
    declare tprofession varchar(11);
	-- 获取查询数据游标
	declare tb_uage_young_cs cursor for select t.name,t.profession from tb_user t where t.age<=uage;
    #declare exit handler for SQLSTATE '02000' close tb_uage_young_cs;
    declare exit handler for NOT FOUND close tb_uage_young_cs;
    
    -- 创建新表
    drop table if exists tb_user_young;
    create table tb_user_young(
		id int primary key auto_increment,
        name varchar(50),
        profession varchar(11)
    );
    
    -- 插入数据
    open tb_uage_young_cs;
    while true do
		fetch tb_uage_young_cs into tname,tprofession;
        insert into tb_user_young(name,profession) values(tname,tprofession);
	end while;
    close tb_uage_young_cs;
end;$$
set @uage=40;
call p10(@uage);
select * from tb_user_young;