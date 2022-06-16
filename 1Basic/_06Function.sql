#函数是指一段可以直接被另一段程序调用的程序或代码

#常用字符串函数
#concat(s1,s2,...sn) 字符串拼接
select concat('hello ','world','!');
#lower(str) 转换小写
select lower('Hello');
#upper(str) 转换大写
select upper('Hello');
#lpad(str,n,pad) 用pad左填充，总长度n
select lpad('1',5,'0');
#rpad(str,n,pad) 用pad右填充，总长度n
select rpad('1',5,'0');
#trim(str) 删除头尾空格
select trim('  Hello World  ');
#substring(str,start,len) 取子串 索引从1开始
select substring('  Hello World  ',3,11);

#在以下练习前先创建DQL练习的表与数据

#将员工工号填充为6位数，头部加0
use test;
update emp e set e.workno=lpad(e.workno,6,'0');
select * from emp;

#常用数值函数
#ceil(x);向上取整
select ceil(1.1);
select ceil(-1.9);
#floor(x);向下取整
select  floor(1.9);
select  floor(-2.1);
#mod(x,y);返回x/y的模
select mod(100,9);
#rand();返回0-1内的随机数
select rand();
#round(x,y);对x四舍五入保留y位小数
select round(100.125,2);
select round(100.124,2);

#通过函数生成六位的验证码
select substring(lpad(round(rand()*1000000,0),6,0),1,6);

#常用日期函数
#curdate()当前日期
select curdate();
#curtime()当前时间
select curtime();
#now()当前日期时间
select now();
#year(date)获取年
select year(now());
#month(date)获取月
select month(now());
#day(date)获取日
select day(now());
#date_add(date,interval expr type)返回日期或时间值加时间间隔expr后的时间
select date_add(now(),interval 100 year);
#datediff(date1,date2)返回两个时间间隔天数
select datediff(curdate(),'2000-01-01');
select datediff(now(),'1996-05-29');

#在以下练习前先创建DQL练习的表与数据

#查询所有员工入职天数，以天数倒序排序
select *,datediff(now(),entrydate) workdays from emp order by workdays desc;

#常用流程控制函数
#if(value,t,f) 若value为true返回t否则f
select if(1=1,'nice','bad');
select if(1=2,'nice','bad');
#ifnull(value1,value2) 若value1不空返回value1否则value2
select ifnull(null,'bad');
select ifnull('','bad');
select ifnull('nice','bad');
#case when [val1] then [res1]...else [default] end 若val1为true返回res1...默认返回default
#case[expr] when [val1] then [res1]...else [default] end 若expr等于val1返回res1...默认返回default

#在以下练习前先创建DQL练习的表与数据

#查询emp表的员工工号和工作地址，如果是北京上海显示一线城市，其他显示其他城市
select workno,workaddress,case when workaddress in ('北京','上海') then '一线城市' else '二线城市' end '城市级别' from emp;

#在以下练习前先创建练习的表与数据
#展示班级同学的成绩级别，85或以上优秀，60或以上及格，否则不及格
select 
	*,
	case when math>=85 then '优秀' when math>=60 then '及格' else '不及格' end 'math level',
    case when english>=85 then '优秀' when english>=60 then '及格' else '不及格' end 'english level',
    case when chinese>=85 then '优秀' when chinese>=60 then '及格' else '不及格' end 'chinese level'
from score;