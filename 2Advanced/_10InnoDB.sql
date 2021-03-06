#InnoDB引擎

#InnoDB逻辑存储结构
-- 1). 表空间
-- 表空间是InnoDB存储引擎逻辑结构的最高层， 如果用户启用了参数 innodb_file_per_table(在
-- 8.0版本中默认开启) ，则每张表都会有一个表空间（xxx.ibd），一个mysql实例可以对应多个表空
-- 间，用于存储记录、索引等数据。
-- 2). 段
-- 段，分为数据段（Leaf node segment）、索引段（Non-leaf node segment）、回滚段
-- （Rollback segment），InnoDB是索引组织表，数据段就是B+树的叶子节点， 索引段即为B+树的
-- 非叶子节点。段用来管理多个Extent（区）。
-- 3). 区
-- 区，表空间的单元结构，每个区的大小为1M。 默认情况下， InnoDB存储引擎页大小为16K， 即一
-- 个区中一共有64个连续的页。
-- 4). 页
-- 页，是InnoDB 存储引擎磁盘管理的最小单元，每个页的大小默认为 16KB。为了保证页的连续性，
-- InnoDB 存储引擎每次从磁盘申请 4-5 个区。
-- 5). 行
-- 行，InnoDB 存储引擎数据是按行进行存放的。
-- 在行中，默认有两个隐藏字段：
-- Trx_id：每次对某条记录进行改动时，都会把对应的事务id赋值给trx_id隐藏列。
-- Roll_pointer：每次对某条引记录进行改动时，都会把旧的版本写入到undo日志中，然后这个
-- 隐藏列就相当于一个指针，可以通过它来找到该记录修改前的信息。

#InnoDB-架构-概述
#MySQL5.5 版本开始，默认使用InnoDB存储引擎，它擅长事务处理，具有崩溃恢复特性，在日常开发中使用非常广泛。下面是InnoDB架构图，左侧为内存结构，右侧为磁盘结构、

#InnoDB-架构-内存结构
-- 在左侧的内存结构中，主要分为这么四大块儿： Buffer Pool、Change Buffer、Adaptive
-- Hash Index、Log Buffer。 接下来介绍一下这四个部分。
-- 1). Buffer Pool
-- InnoDB存储引擎基于磁盘文件存储，访问物理硬盘和在内存中进行访问，速度相差很大，为了尽可能
-- 弥补这两者之间的I/O效率的差值，就需要把经常使用的数据加载到缓冲池中，避免每次访问都进行磁
-- 盘I/O。
-- 在InnoDB的缓冲池中不仅缓存了索引页和数据页，还包含了undo页、插入缓存、自适应哈希索引以及
-- InnoDB的锁信息等等。
-- 缓冲池 Buffer Pool，是主内存中的一个区域，里面可以缓存磁盘上经常操作的真实数据，在执行增
-- 删改查操作时，先操作缓冲池中的数据（若缓冲池没有数据，则从磁盘加载并缓存），然后再以一定频
-- 率刷新到磁盘，从而减少磁盘IO，加快处理速度。
-- 缓冲池以Page页为单位，底层采用链表数据结构管理Page。根据状态，将Page分为三种类型：
-- • free page：空闲page，未被使用。
-- • clean page：被使用page，数据没有被修改过。
-- • dirty page：脏页，被使用page，数据被修改过，也中数据与磁盘的数据产生了不一致。
-- 在专用服务器上，通常将多达80％的物理内存分配给缓冲池 。参数设置： show variables
-- like 'innodb_buffer_pool_size';
-- 2). Change Buffer
-- Change Buffer，更改缓冲区（针对于非唯一二级索引页），在执行DML语句时，如果这些数据Page
-- 没有在Buffer Pool中，不会直接操作磁盘，而会将数据变更存在更改缓冲区 Change Buffer
-- 中，在未来数据被读取时，再将数据合并恢复到Buffer Pool中，再将合并后的数据刷新到磁盘中。
-- Change Buffer的意义是什么呢?
-- 先来看一幅图，这个是二级索引的结构图：
-- 与聚集索引不同，二级索引通常是非唯一的，并且以相对随机的顺序插入二级索引。同样，删除和更新
-- 可能会影响索引树中不相邻的二级索引页，如果每一次都操作磁盘，会造成大量的磁盘IO。有了
-- ChangeBuffer之后，我们可以在缓冲池中进行合并处理，减少磁盘IO。
-- 3). Adaptive Hash Index
-- 自适应hash索引，用于优化对Buffer Pool数据的查询。MySQL的innoDB引擎中虽然没有直接支持
-- hash索引，但是给我们提供了一个功能就是这个自适应hash索引。因为前面我们讲到过，hash索引在
-- 进行等值匹配时，一般性能是要高于B+树的，因为hash索引一般只需要一次IO即可，而B+树，可能需
-- 要几次匹配，所以hash索引的效率要高，但是hash索引又不适合做范围查询、模糊匹配等。
-- InnoDB存储引擎会监控对表上各索引页的查询，如果观察到在特定的条件下hash索引可以提升速度，
-- 则建立hash索引，称之为自适应hash索引。
-- 自适应哈希索引，无需人工干预，是系统根据情况自动完成。
-- 参数： adaptive_hash_index
-- 4). Log Buffer
-- Log Buffer：日志缓冲区，用来保存要写入到磁盘中的log日志数据（redo log 、undo log），
-- 默认大小为 16MB，日志缓冲区的日志会定期刷新到磁盘中。如果需要更新、插入或删除许多行的事
-- 务，增加日志缓冲区的大小可以节省磁盘 I/O。
-- 参数:
-- innodb_log_buffer_size：缓冲区大小
-- innodb_flush_log_at_trx_commit：日志刷新到磁盘时机，取值主要包含以下三个：
-- 1: 日志在每次事务提交时写入并刷新到磁盘，默认值。
-- 0: 每秒将日志写入并刷新到磁盘一次。
-- 2: 日志在每次事务提交后写入，并每秒刷新到磁盘一次。

#InnoDB-架构-磁盘结构
-- 1). System Tablespace
-- 系统表空间是更改缓冲区的存储区域。如果表是在系统表空间而不是每个表文件或通用表空间中创建
-- 的，它也可能包含表和索引数据。(在MySQL5.x版本中还包含InnoDB数据字典、undolog等)
-- 参数：innodb_data_file_path
-- 系统表空间，默认的文件名叫 ibdata1。
-- 2). File-Per-Table Tablespaces
-- 如果开启了innodb_file_per_table开关 ，则每个表的文件表空间包含单个InnoDB表的数据和索
-- 引 ，并存储在文件系统上的单个数据文件中。
-- 开关参数：innodb_file_per_table ，该参数默认开启。
-- 那也就是说，我们没创建一个表，都会产生一个表空间文件，如图：
-- 3). General Tablespaces
-- 通用表空间，需要通过 CREATE TABLESPACE 语法创建通用表空间，在创建表时，可以指定该表空
-- 间。
-- A. 创建表空间
-- B. 创建表时指定表空间
-- 4). Undo Tablespaces
-- 撤销表空间，MySQL实例在初始化时会自动创建两个默认的undo表空间（初始大小16M），用于存储
-- undo log日志。
-- 5). Temporary Tablespaces
-- InnoDB 使用会话临时表空间和全局临时表空间。存储用户创建的临时表等数据。
-- 6). Doublewrite Buffer Files
-- 1 CREATE TABLESPACE ts_name ADD DATAFILE 'file_name' ENGINE = engine_name;
-- 1 CREATE TABLE xxx ... TABLESPACE ts_name;
-- 双写缓冲区，innoDB引擎将数据页从Buffer Pool刷新到磁盘前，先将数据页写入双写缓冲区文件
-- 中，便于系统异常时恢复数据。
-- 7). Redo Log
-- 重做日志，是用来实现事务的持久性。该日志文件由两部分组成：重做日志缓冲（redo log
-- buffer）以及重做日志文件（redo log）,前者是在内存中，后者在磁盘中。当事务提交之后会把所
-- 有修改信息都会存到该日志中, 用于在刷新脏页到磁盘时,发生错误时, 进行数据恢复使用。
-- 以循环方式写入重做日志文件，涉及两个文件：
-- 前面我们介绍了InnoDB的内存结构，以及磁盘结构，那么内存中我们所更新的数据，又是如何到磁盘
-- 中的呢？ 此时，就涉及到一组后台线程，接下来，就来介绍一些InnoDB中涉及到的后台线程。

#InnoDB-架构-后台线程
-- 在InnoDB的后台线程中，分为4类，分别是：Master Thread 、IO Thread、Purge Thread、
-- Page Cleaner Thread。
-- 1). Master Thread
-- 核心后台线程，负责调度其他线程，还负责将缓冲池中的数据异步刷新到磁盘中, 保持数据的一致性，
-- 还包括脏页的刷新、合并插入缓存、undo页的回收 。
-- 2). IO Thread
-- 在InnoDB存储引擎中大量使用了AIO来处理IO请求, 这样可以极大地提高数据库的性能，而IO
-- Thread主要负责这些IO请求的回调。
-- 我们可以通过以下的这条指令，查看到InnoDB的状态信息，其中就包含IO Thread信息。
-- 3). Purge Thread
-- 主要用于回收事务已经提交了的undo log，在事务提交之后，undo log可能不用了，就用它来回
-- 收。
-- 4). Page Cleaner Thread
-- 协助 Master Thread 刷新脏页到磁盘的线程，它可以减轻 Master Thread 的工作压力，减少阻
-- 塞。

#InnoDB 架构-事务
-- 1). 事务
-- 事务 是一组操作的集合，它是一个不可分割的工作单位，事务会把所有的操作作为一个整体一起向系
-- 统提交或撤销操作请求，即这些操作要么同时成功，要么同时失败。
-- 2). 特性
-- 1 show engine innodb status \G;
-- • 原子性（Atomicity）：事务是不可分割的最小操作单元，要么全部成功，要么全部失败。
-- • 一致性（Consistency）：事务完成时，必须使所有的数据都保持一致状态。
-- • 隔离性（Isolation）：数据库系统提供的隔离机制，保证事务在不受外部并发操作影响的独立环
-- 境下运行。
-- • 持久性（Durability）：事务一旦提交或回滚，它对数据库中的数据的改变就是永久的。
-- 那实际上，我们研究事务的原理，就是研究MySQL的InnoDB引擎是如何保证事务的这四大特性的。
-- 而对于这四大特性，实际上分为两个部分。 其中的原子性、一致性、持久化，实际上是由InnoDB中的
-- 两份日志来保证的，一份是redo log日志，一份是undo log日志。 而持久性是通过数据库的锁，
-- 加上MVCC来保证的。
-- 我们在讲解事务原理的时候，主要就是来研究一下redolog，undolog以及MVCC。

#InnoDB-架构-redolog
-- 重做日志，记录的是事务提交时数据页的物理修改，是用来实现事务的持久性。
-- 该日志文件由两部分组成：重做日志缓冲（redo log buffer）以及重做日志文件（redo log
-- file）,前者是在内存中，后者在磁盘中。当事务提交之后会把所有修改信息都存到该日志文件中, 用
-- 于在刷新脏页到磁盘,发生错误时, 进行数据恢复使用。
-- 如果没有redolog，可能会存在什么问题的？ 我们一起来分析一下。
-- 我们知道，在InnoDB引擎中的内存结构中，主要的内存区域就是缓冲池，在缓冲池中缓存了很多的数
-- 据页。 当我们在一个事务中，执行多个增删改的操作时，InnoDB引擎会先操作缓冲池中的数据，如果
-- 缓冲区没有对应的数据，会通过后台线程将磁盘中的数据加载出来，存放在缓冲区中，然后将缓冲池中
-- 的数据修改，修改后的数据页我们称为脏页。 而脏页则会在一定的时机，通过后台线程刷新到磁盘
-- 中，从而保证缓冲区与磁盘的数据一致。 而缓冲区的脏页数据并不是实时刷新的，而是一段时间之后
-- 将缓冲区的数据刷新到磁盘中，假如刷新到磁盘的过程出错了，而提示给用户事务提交成功，而数据却
-- 没有持久化下来，这就出现问题了，没有保证事务的持久性。
-- 那么，如何解决上述的问题呢？ 在InnoDB中提供了一份日志 redo log，接下来我们再来分析一
-- 下，通过redolog如何解决这个问题。
-- 有了redolog之后，当对缓冲区的数据进行增删改之后，会首先将操作的数据页的变化，记录在redo
-- log buffer中。在事务提交时，会将redo log buffer中的数据刷新到redo log磁盘文件中。
-- 过一段时间之后，如果刷新缓冲区的脏页到磁盘时，发生错误，此时就可以借助于redo log进行数据
-- 恢复，这样就保证了事务的持久性。 而如果脏页成功刷新到磁盘 或 或者涉及到的数据已经落盘，此
-- 时redolog就没有作用了，就可以删除了，所以存在的两个redolog文件是循环写的。
-- 那为什么每一次提交事务，要刷新redo log 到磁盘中呢，而不是直接将buffer pool中的脏页刷新
-- 到磁盘呢 ?
-- 因为在业务操作中，我们操作数据一般都是随机读写磁盘的，而不是顺序读写磁盘。 而redo log在
-- 往磁盘文件中写入数据，由于是日志文件，所以都是顺序写的。顺序写的效率，要远大于随机写。 这
-- 种先写日志的方式，称之为 WAL（Write-Ahead Logging）。

#InnoDB架构-undolog
-- 回滚日志，用于记录数据被修改前的信息 , 作用包含两个 : 提供回滚(保证事务的原子性) 和
-- MVCC(多版本并发控制) 。
-- undo log和redo log记录物理日志不一样，它是逻辑日志。可以认为当delete一条记录时，undo
-- log中会记录一条对应的insert记录，反之亦然，当update一条记录时，它记录一条对应相反的
-- update记录。当执行rollback时，就可以从undo log中的逻辑记录读取到相应的内容并进行回滚。
-- Undo log销毁：undo log在事务执行时产生，事务提交时，并不会立即删除undo log，因为这些
-- 日志可能还用于MVCC。
-- Undo log存储：undo log采用段的方式进行管理和记录，存放在前面介绍的 rollback segment
-- 回滚段中，内部包含1024个undo log segment。

#InnoDB架构-MVCC-基本概念
-- 1). 当前读
-- 读取的是记录的最新版本，读取时还要保证其他并发事务不能修改当前记录，会对读取的记录进行加
-- 锁。对于我们日常的操作，如：select ... lock in share mode(共享锁)，select ...
-- for update、update、insert、delete(排他锁)都是一种当前读。
-- 测试：
-- 在测试中我们可以看到，即使是在默认的RR隔离级别下，事务A中依然可以读取到事务B最新提交的内
-- 容，因为在查询语句后面加上了 lock in share mode 共享锁，此时是当前读操作。当然，当我们
-- 加排他锁的时候，也是当前读操作。
-- 2). 快照读
-- 简单的select（不加锁）就是快照读，快照读，读取的是记录数据的可见版本，有可能是历史数据，
-- 不加锁，是非阻塞读。
-- • Read Committed：每次select，都生成一个快照读。
-- • Repeatable Read：开启事务后第一个select语句才是快照读的地方。
-- • Serializable：快照读会退化为当前读。
-- 测试:
-- 隐藏字段 含义
-- DB_TRX_ID 最近修改事务ID，记录插入这条记录或最后一次修改该记录的事务ID。
-- DB_ROLL_PTR
-- 回滚指针，指向这条记录的上一个版本，用于配合undo log，指向上一个版
-- 本。
-- DB_ROW_ID 隐藏主键，如果表结构没有指定主键，将会生成该隐藏字段。
-- 在测试中,我们看到即使事务B提交了数据,事务A中也查询不到。 原因就是因为普通的select是快照
-- 读，而在当前默认的RR隔离级别下，开启事务后第一个select语句才是快照读的地方，后面执行相同
-- 的select语句都是从快照中获取数据，可能不是当前的最新数据，这样也就保证了可重复读。
-- 3). MVCC
-- 全称 Multi-Version Concurrency Control，多版本并发控制。指维护一个数据的多个版本，
-- 使得读写操作没有冲突，快照读为MySQL实现MVCC提供了一个非阻塞读功能。MVCC的具体实现，还需
-- 要依赖于数据库记录中的三个隐式字段、undo log日志、readView。
-- 接下来，我们再来介绍一下InnoDB引擎的表中涉及到的隐藏字段 、undolog 以及 readview，从
-- 而来介绍一下MVCC的原理。

#InnoDB架构-隐藏字段
-- 当我们创建了上面的这张表，我们在查看表结构的时候，就可以显式的看到这三个字段。 实际上除了
-- 这三个字段以外，InnoDB还会自动的给我们添加三个隐藏字段及其含义分别是：
-- 而上述的前两个字段是肯定会添加的， 是否添加最后一个字段DB_ROW_ID，得看当前表有没有主键，
-- 如果有主键，则不会添加该隐藏字段。

#InnoDB架构-undolog日志
-- 回滚日志，在insert、update、delete的时候产生的便于数据回滚的日志。
-- 当insert的时候，产生的undo log日志只在回滚时需要，在事务提交后，可被立即删除。
-- 而update、delete的时候，产生的undo log日志不仅在回滚时需要，在快照读时也需要，不会立即
-- 被删除。

#InnoDB架构-readview
-- ReadView（读视图）是 快照读 SQL执行时MVCC提取数据的依据，记录并维护系统当前活跃的事务
-- （未提交的）id。
-- ReadView中包含了四个核心字段：
-- 而在readview中就规定了版本链数据的访问规则：
-- trx_id 代表当前undolog版本链对应事务ID。
-- 不同的隔离级别，生成ReadView的时机不同：
-- READ COMMITTED ：在事务中每一次执行快照读时生成ReadView。
-- REPEATABLE READ：仅在事务中第一次执行快照读时生成ReadView，后续复用该ReadView。

#InnoDB架构-原理分析-RC
-- RC隔离级别下，在事务中每一次执行快照读时生成ReadView。
-- 我们就来分析事务5中，两次快照读读取数据，是如何获取数据的?
-- 在事务5中，查询了两次id为30的记录，由于隔离级别为Read Committed，所以每一次进行快照读
-- 都会生成一个ReadView，那么两次生成的ReadView如下。
-- 那么这两次快照读在获取数据时，就需要根据所生成的ReadView以及ReadView的版本链访问规则，
-- 到undolog版本链中匹配数据，最终决定此次快照读返回的数据。
-- A. 先来看第一次快照读具体的读取过程：
-- 在进行匹配时，会从undo log的版本链，从上到下进行挨个匹配：
-- 先匹配 这条记录，这条记录对应的
-- trx_id为4，也就是将4带入右侧的匹配规则中。 ①不满足 ②不满足 ③不满足 ④也不满足 ，
-- 都不满足，则继续匹配undo log版本链的下一条。
-- 再匹配第二条 ，这条
-- 记录对应的trx_id为3，也就是将3带入右侧的匹配规则中。①不满足 ②不满足 ③不满足 ④也
-- 不满足 ，都不满足，则继续匹配undo log版本链的下一条。
-- 再匹配第三条 ，这条记
-- 录对应的trx_id为2，也就是将2带入右侧的匹配规则中。①不满足 ②满足 终止匹配，此次快照
-- 读，返回的数据就是版本链中记录的这条数据。
-- B. 再来看第二次快照读具体的读取过程:
-- 在进行匹配时，会从undo log的版本链，从上到下进行挨个匹配：
-- 先匹配 这条记录，这条记录对应的
-- trx_id为4，也就是将4带入右侧的匹配规则中。 ①不满足 ②不满足 ③不满足 ④也不满足 ，
-- 都不满足，则继续匹配undo log版本链的下一条。
-- 再匹配第二条 ，这条
-- 记录对应的trx_id为3，也就是将3带入右侧的匹配规则中。①不满足 ②满足 。终止匹配，此次
-- 快照读，返回的数据就是版本链中记录的这条数据。

#InnoDB架构-原理分析-RC
-- RR隔离级别下，仅在事务中第一次执行快照读时生成ReadView，后续复用该ReadView。 而RR 是可
-- 重复读，在一个事务中，执行两次相同的select语句，查询到的结果是一样的。
-- 那MySQL是如何做到可重复读的呢? 我们简单分析一下就知道了
-- 我们看到，在RR隔离级别下，只是在事务中第一次快照读时生成ReadView，后续都是复用该
-- ReadView，那么既然ReadView都一样， ReadView的版本链匹配规则也一样， 那么最终快照读返
-- 回的结果也是一样的。
-- 所以呢，MVCC的实现原理就是通过 InnoDB表的隐藏字段、UndoLog 版本链、ReadView来实现的。
-- 而MVCC + 锁，则实现了事务的隔离性。 而一致性则是由redolog 与 undolog保证。



