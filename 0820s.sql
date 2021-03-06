USE [ProgramPlatform]
GO
/****** Object:  View [dbo].[vwEmployee]    Script Date: 2020/08/20 16:49:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwEmployee]
AS
SELECT   dbo.Employee.EmpNo, dbo.Employee.EmpName, dbo.Employee.Sex, dbo.Employee.JobID, dbo.Employee.DptID, 
                dbo.Employee.JoinDay, dbo.Employee.LeaveDay, dbo.Employee.Address, dbo.Employee.Home, dbo.Employee.Related, 
                dbo.Employee.BandName, dbo.Employee.BandNo, dbo.Employee.ManId, dbo.Employee.Tel, dbo.Employee.LevelID, 
                dbo.Employee.Allowance, dbo.Employee.Photo, dbo.Department.DptName, dbo.Factory.FacName, 
                dbo.SalaryLevel.LevelName, dbo.SalaryLevel.BaseSalary, dbo.JobName.JobName
FROM      dbo.Employee LEFT OUTER JOIN
                dbo.Department ON dbo.Employee.DptID = dbo.Department.DptID INNER JOIN
                dbo.Factory ON dbo.Department.FacNo = dbo.Factory.FacNo INNER JOIN
                dbo.SalaryLevel ON dbo.Employee.LevelID = dbo.SalaryLevel.LevelID INNER JOIN
                dbo.JobName ON dbo.Employee.JobID = dbo.JobName.JobId
GO
/****** Object:  View [dbo].[vwEmployeePB]    Script Date: 2020/08/20 16:49:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vwEmployeePB]
AS
SELECT   dbo.Employee.EmpNo, dbo.Employee.EmpName, dbo.Employee.Sex, dbo.Employee.JobID, dbo.Employee.DptID, 
                dbo.Employee.JoinDay, dbo.Employee.LeaveDay, dbo.PaiBanPerson.KQDay, dbo.PaiBanPerson.ScheduleID, 
                dbo.Department.FacNo
FROM      dbo.Employee INNER JOIN
                dbo.PaiBanPerson ON dbo.Employee.EmpNo = dbo.PaiBanPerson.EmpNo INNER JOIN
                dbo.Department ON dbo.Employee.DptID = dbo.Department.DptID
GO
/****** Object:  StoredProcedure [dbo].[BuildKQDay]    Script Date: 2020/08/20 16:49:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[BuildKQDay]
@StartDay datetime,
@EndDay datetime,
@FacNo	nvarchar(20)=NULL,
@DptNo nvarchar(20)=NULL,
@EmpNo nvarchar(150)=NULL
	-- Add the parameters for the stored procedure here
AS
BEGIN
declare @ProceeDay date

set @ProceeDay=@StartDay
while(datediff(dd,@EndDay,@ProceeDay)<=0)
begin

	if @EmpNo is NULL
		begin 
			if(@DptNo is NULL)
				begin
					if(@FacNo is NULL)--三个条件都为空
						begin
							delete from KaoqinDay from vwEmployeePB where vwEmployeePB.KQDay=@ProceeDay 
							and vwEmployeePB.KQDay=KaoqinDay.KQDay and vwEmployeePB.EmpNo=KaoqinDay.EmpNo and vwEmployeePB.LeaveDay is null
							insert into KaoqinDay(EmpNo,KQDay,ScheduleID,IN1,OUT1,IN2,OUT2,IN3,OUT3,IN4,OUT4,IN5,OUT5)
							select vwEmployeePB.EmpNo,vwEmployeePB.KQDay,vwEmployeePB.ScheduleID,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10] from vwEmployeePB left join(
							select * from(
							SELECT *,ROW_NUMBER() OVER(PARTITION BY EmpNo ORDER BY CardDate) AS no1 FROM 
							(
							select EmpNo,CardDate ,
							CASE WHEN DATEDIFF(MI,lag(CardDate)over(partition by EmpNo order by CardDate ),CardDate) <3 THEN 0 ELSE 1 END AS FLAG 
							from CardData where datediff(S,@ProceeDay,CardDate)>=0 and datediff(S,dateadd(d,1,@ProceeDay),CardDate)<0 
							) t WHERE FLAG=1)T2 pivot(max(CardDate) for no1 in ([1] ,[2],[3],[4],[5],[6],[7],[8],[9],[10])) a) T3 on vwEmployeePB.EmpNo=T3.EmpNo 
							where vwEmployeePB.LeaveDay is null and  vwEmployeePB.KQDay=@ProceeDay 
						end
						else--有厂别
						begin
							delete from KaoqinDay from vwEmployeePB where vwEmployeePB.KQDay=@ProceeDay 
							and vwEmployeePB.KQDay=KaoqinDay.KQDay and vwEmployeePB.EmpNo=KaoqinDay.EmpNo and vwEmployeePB.FacNo=@FacNo and vwEmployeePB.LeaveDay is null
							insert into KaoqinDay(EmpNo,KQDay,ScheduleID,IN1,OUT1,IN2,OUT2,IN3,OUT3,IN4,OUT4,IN5,OUT5)
							select vwEmployeePB.EmpNo,vwEmployeePB.KQDay,vwEmployeePB.ScheduleID,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10] from vwEmployeePB left join(
							select * from(
							SELECT *,ROW_NUMBER() OVER(PARTITION BY EmpNo ORDER BY CardDate) AS no1 FROM 
							(
							select EmpNo,CardDate ,
							CASE WHEN DATEDIFF(MI,lag(CardDate)over(partition by EmpNo order by CardDate ),CardDate) <3 THEN 0 ELSE 1 END AS FLAG 
							from CardData where datediff(S,@ProceeDay,CardDate)>=0 and datediff(S,dateadd(d,1,@ProceeDay),CardDate)<0 
							) t WHERE FLAG=1)T2 pivot(max(CardDate) for no1 in ([1] ,[2],[3],[4],[5],[6],[7],[8],[9],[10])) a) T3 on vwEmployeePB.EmpNo=T3.EmpNo 
							where vwEmployeePB.LeaveDay is null and  vwEmployeePB.KQDay=@ProceeDay and vwEmployeePB.FacNo=@FacNo
						end
				end
				else--有部门
				begin
					delete from KaoqinDay from vwEmployeePB where vwEmployeePB.KQDay=@ProceeDay 
					and vwEmployeePB.KQDay=KaoqinDay.KQDay and vwEmployeePB.EmpNo=KaoqinDay.EmpNo and vwEmployeePB.DptID=@DptNo	 and vwEmployeePB.LeaveDay is null
					insert into KaoqinDay(EmpNo,KQDay,ScheduleID,IN1,OUT1,IN2,OUT2,IN3,OUT3,IN4,OUT4,IN5,OUT5)
					select vwEmployeePB.EmpNo,vwEmployeePB.KQDay,vwEmployeePB.ScheduleID,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10] from vwEmployeePB left join(
					select * from(
					SELECT *,ROW_NUMBER() OVER(PARTITION BY EmpNo ORDER BY CardDate) AS no1 FROM 
					(
					select EmpNo,CardDate ,
					CASE WHEN DATEDIFF(MI,lag(CardDate)over(partition by EmpNo order by CardDate ),CardDate) <3 THEN 0 ELSE 1 END AS FLAG 
					from CardData where datediff(S,@ProceeDay,CardDate)>=0 and datediff(S,dateadd(d,1,@ProceeDay),CardDate)<0 
					) t WHERE FLAG=1)T2 pivot(max(CardDate) for no1 in ([1] ,[2],[3],[4],[5],[6],[7],[8],[9],[10])) a) T3 on vwEmployeePB.EmpNo=T3.EmpNo 
					where vwEmployeePB.LeaveDay is null and  vwEmployeePB.KQDay=@ProceeDay and vwEmployeePB.DptID=@DptNo		
				end
		end
	else
		Begin--查工号
			delete from KaoqinDay from vwEmployeePB where vwEmployeePB.KQDay=@ProceeDay 
			and vwEmployeePB.KQDay=KaoqinDay.KQDay and vwEmployeePB.EmpNo=KaoqinDay.EmpNo and vwEmployeePB.EmpNo in(@EmpNo)			
			insert into KaoqinDay(EmpNo,KQDay,ScheduleID,IN1,OUT1,IN2,OUT2,IN3,OUT3,IN4,OUT4,IN5,OUT5)
			select vwEmployeePB.EmpNo,vwEmployeePB.KQDay,vwEmployeePB.ScheduleID,[1],[2],[3],[4],[5],[6],[7],[8],[9],[10] from vwEmployeePB left join(
			select * from(
			SELECT *,ROW_NUMBER() OVER(PARTITION BY EmpNo ORDER BY CardDate) AS no1 FROM 
			(
			select EmpNo,CardDate ,
			CASE WHEN DATEDIFF(MI,lag(CardDate)over(partition by EmpNo order by CardDate ),CardDate) <3 THEN 0 ELSE 1 END AS FLAG 
			from CardData where datediff(S,@ProceeDay,CardDate)>=0 and datediff(S,dateadd(d,1,@ProceeDay),CardDate)<0 
			) t WHERE FLAG=1)T2 pivot(max(CardDate) for no1 in ([1] ,[2],[3],[4],[5],[6],[7],[8],[9],[10])) a) T3 on vwEmployeePB.EmpNo=T3.EmpNo 
			where vwEmployeePB.LeaveDay is null and  vwEmployeePB.KQDay=@ProceeDay and vwEmployeePB.EmpNo in(@EmpNo)
		end
	set @ProceeDay=dateadd(dd,1,@ProceeDay)

	
end
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	
END
GO
/****** Object:  StoredProcedure [dbo].[ComputAll]    Script Date: 2020/08/20 16:49:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ComputAll]
@StartDay datetime,
@EndDay datetime,
@FacNo	nvarchar(20)=NULL,
@DptNo nvarchar(20)=NULL,
@EmpNo nvarchar(20)=NULL
	-- Add the parameters for the stored procedure here
AS
BEGIN
DECLARE	 @AutoId as bigint, @EmpNoT  AS NVARCHAR(20), @CheckDate AS date

	if @EmpNo is NULL
		begin 
			if(@DptNo is NULL)
				begin
					if(@FacNo is NULL)--三个条件都为空
						begin
							exec BuildKQDay @StartDay,@EndDay
							IF OBJECT_ID('tempdb.dbo.#tempemployees','U') IS NOT NULL DROP TABLE dbo.#tempemployees
							SELECT ROW_NUMBER() OVER( ORDER BY EmpNo) as AutoId ,EmpNo,KQDay INTO dbo.#tempemployees from vwEmployeePB where LeaveDay  is null   order by EmpNo,KQDay 
							 WHILE EXISTS(SELECT AutoId FROM dbo.#tempemployees)
							 BEGIN
								 -- 也可以使用top 1
								 SET ROWCOUNT 1
								 SELECT @AutoId= AutoId , @EmpNoT= EmpNo ,@CheckDate= KQDay  FROM dbo.#tempemployees
								 SET ROWCOUNT 0
								 exec ComputDay @CheckDate,@EmpNoT
								 DELETE FROM dbo.#tempemployees WHERE AutoId=@AutoId
							 END

							 DROP TABLE dbo.#tempemployees
						end
						else--有厂别
						begin
							exec BuildKQDay @StartDay,@EndDay,@FacNo
							IF OBJECT_ID('tempdb.dbo.#tempemployeesF','U') IS NOT NULL DROP TABLE dbo.#tempemployeesF
							SELECT ROW_NUMBER() OVER( ORDER BY EmpNo) as AutoId ,EmpNo,KQDay INTO dbo.#tempemployeesF from vwEmployeePB where LeaveDay  is null and FacNo=@FacNo  order by EmpNo,KQDay 
							 WHILE EXISTS(SELECT AutoId FROM dbo.#tempemployeesF)
							 BEGIN
								 -- 也可以使用top 1
								 SET ROWCOUNT 1
								 SELECT @AutoId= AutoId , @EmpNoT= EmpNo ,@CheckDate= KQDay  FROM dbo.#tempemployeesF
								 SET ROWCOUNT 0
								 exec ComputDay @CheckDate,@EmpNoT
								 DELETE FROM dbo.#tempemployeesF WHERE AutoId=@AutoId
							 END

							 DROP TABLE dbo.#tempemployeesF

						end
				end
				else--有部门
				begin
					exec BuildKQDay @StartDay,@EndDay,NULL,@DptNo
					IF OBJECT_ID('tempdb.dbo.#tempemployeesD','U') IS NOT NULL DROP TABLE dbo.#tempemployeesD
					SELECT ROW_NUMBER() OVER( ORDER BY EmpNo) as AutoId ,EmpNo,KQDay INTO dbo.#tempemployeesD from vwEmployeePB where LeaveDay  is null and DptID=@DptNo  order by EmpNo,KQDay 
						WHILE EXISTS(SELECT AutoId FROM dbo.#tempemployeesD)
						BEGIN
							-- 也可以使用top 1
							SET ROWCOUNT 1
							SELECT @AutoId= AutoId , @EmpNoT= EmpNo ,@CheckDate= KQDay  FROM dbo.#tempemployeesD
							SET ROWCOUNT 0
							exec ComputDay @CheckDate,@EmpNoT
							DELETE FROM dbo.#tempemployeesD WHERE AutoId=@AutoId
						END

						DROP TABLE dbo.#tempemployeesD
				end
		end
	else
		Begin--查工号
			exec BuildKQDay @StartDay,@EndDay,NULL,NULL,@EmpNo
			IF OBJECT_ID('tempdb.dbo.#tempemployeesE','U') IS NOT NULL DROP TABLE dbo.#tempemployeesE
			SELECT ROW_NUMBER() OVER( ORDER BY EmpNo) as AutoId ,EmpNo,KQDay INTO dbo.#tempemployeesE from vwEmployeePB where LeaveDay  is null and EmpNo=@EmpNo  order by EmpNo,KQDay 
			WHILE EXISTS(SELECT AutoId FROM dbo.#tempemployeesE)
			BEGIN
				-- 也可以使用top 1
				SET ROWCOUNT 1
				SELECT @AutoId= AutoId , @EmpNoT= EmpNo ,@CheckDate= KQDay  FROM dbo.#tempemployeesE
				SET ROWCOUNT 0
				exec ComputDay @CheckDate,@EmpNoT
				DELETE FROM dbo.#tempemployeesE WHERE AutoId=@AutoId
			END

			DROP TABLE dbo.#tempemployeesE
		end
	
END
GO
/****** Object:  StoredProcedure [dbo].[ComputDay]    Script Date: 2020/08/20 16:49:53 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ComputDay]
 @KQDay datetime,
 @EmpNo nvarchar(20)
	-- Add the parameters for the stored procedure here
AS
BEGIN
declare @SI1 datetime=NULL
declare @SO1 datetime=NULL
declare @SI2 datetime=NULL
declare @SO2 datetime=NULL
declare @SI3 datetime=NULL
declare @SO3 datetime=NULL
declare @SI4 datetime=NULL
declare @SO4 datetime=NULL
declare @SI5 datetime=NULL
declare @SO5 datetime=NULL
declare @SHour numeric(5,1)=0
declare @SType smallint=0
declare @KI1 datetime=NULL
declare @KO1 datetime=NULL
declare @KI2 datetime=NULL
declare @KO2 datetime=NULL
declare @KI3 datetime=NULL
declare @KO3 datetime=NULL
declare @KI4 datetime=NULL
declare @KO4 datetime=NULL
declare @KI5 datetime=NULL
declare @KO5 datetime=NULL
declare @ScheduleId nvarchar(10)
declare @WorkHour numeric(5,1)=0
declare @LateTime smallint=0
declare @LateHour numeric(5,1)=0
declare @ExtraHour numeric(5,1)=0
declare @EarlyTime smallint=0
declare @EarlyHour numeric(5,1)=0
declare @QJHour numeric(5,1)=0

select @KI1=In1,@KO1=Out1,@KI2=In2,@KO2=Out2,@KI3=In3,@KO3=Out3,@KI4=In4,@KO4=Out4,@KI5=In5,@KO5=Out5,@ScheduleId=ScheduleId from KaoqinDay where KQDay=@KQDay and EmpNo=@EmpNo 
select @SType=ScheduleType,@SHour=ScheduleHour,@SI1=dateadd(dd,DATEDIFF(dd,In1,@KQDay),In1),@SO1=dateadd(dd,DATEDIFF(dd,Out1,@KQDay),Out1),@SI2=dateadd(dd,DATEDIFF(dd,In2,@KQDay),In2),@SO2=dateadd(dd,DATEDIFF(dd,Out2,@KQDay),Out2),@SI3=dateadd(dd,DATEDIFF(dd,In3,@KQDay),In3),@SO3=dateadd(dd,DATEDIFF(dd,Out3,@KQDay),Out3) FROM Schedule where ScheduleId=@ScheduleId
if exists(select EmpNo from QingJia where EmpNo=@EmpNo and QJType=1 and DATEDIFF(DD,QJStart,@KQDay)>=0 AND DATEDIFF(DD,QJEnd,@KQDay)<=0 )
begin
	if(@KI1 is not null)
	begin
		update KaoqinDay set  EXFlag=1,CheckFlag=0,WorkHour=@WorkHour,ExtraHour=@ExtraHour,LateTime=@LateTime,LateHour=@LateHour,EarlyTime=@EarlyTime,EarlyHour=@EarlyHour,QingJiaHour=@QJHour,QingJiaDay=0  where KQDay=@KQDay and EmpNo=@EmpNo 
		return 0;
	end
	else
	begin
		update KaoqinDay set  EXFlag=0,CheckFlag=1,WorkHour=@WorkHour,ExtraHour=@ExtraHour,LateTime=@LateTime,LateHour=@LateHour,EarlyTime=@EarlyTime,EarlyHour=@EarlyHour,QingJiaHour=@QJHour,QingJiaDay=1 where KQDay=@KQDay and EmpNo=@EmpNo 
		return 0;
	end
end
if(@SType=3 or @SType=4)
begin
	if(@KI1 is not null)
	begin
		update KaoqinDay set  EXFlag=1,CheckFlag=0,IsWork=0,WorkHour=@WorkHour,ExtraHour=@ExtraHour,LateTime=@LateTime,LateHour=@LateHour,EarlyTime=@EarlyTime,EarlyHour=@EarlyHour,QingJiaHour=@QJHour,QingJiaDay=0  where KQDay=@KQDay and EmpNo=@EmpNo 
		return 0;
	end
	else
	begin
		update KaoqinDay set  EXFlag=0,CheckFlag=1,WorkHour=@SHour,IsWork=case when @SHour>0 then 1 else 0 end ,ExtraHour=@ExtraHour,LateTime=@LateTime,LateHour=@LateHour,EarlyTime=@EarlyTime,EarlyHour=@EarlyHour,QingJiaHour=@QJHour,QingJiaDay=0 where KQDay=@KQDay and EmpNo=@EmpNo 
		return 0;
	end
end
else
begin
	select @SI1=[1],@SO1=[2],@SI2=[3],@SO2=[4],@SI3=[5],@SO3=[6],@SI4=[7],@SO4=[8],@SI5=[9],@SO5=[10] from(
	select QJStart,ROW_NUMBER() OVER( ORDER BY QJStart) AS no1  from(
	select QJStart  from QingJia where EmpNo=@EmpNo and QJType=0 and DATEDIFF(DD,QJStart,@KQDay)=0 union
	select QJEnd  from QingJia where EmpNo=@EmpNo and QJType=0 and  DATEDIFF(DD,QJStart,@KQDay)=0 union
	select @SI1 union
	select @SO1 union
	select @SI2 union
	select @SO2 union
	select @SI3 union
	select @SO3) T1 WHERE  QJStart IS NOT NULL AND T1.QJStart NOT IN
	(SELECT M1.QJStart  from
	(select @SI1 as QJStart union
	select @SO1 union
	select @SI2 union
	select @SO2 union
	select @SI3 union
	select @SO3 ) M1 ,(select QJStart  from QingJia where EmpNo=@EmpNo and QJType=0  and DATEDIFF(DD,QJStart,@KQDay)=0 union
	select QJEnd  from QingJia where EmpNo=@EmpNo and QJType=0  and DATEDIFF(DD,QJStart,@KQDay)=0 ) M2 WHERE M1.QJStart=M2.QJStart) 
	) T2 pivot(max(QJStart) for no1 in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10])) a
	
	if( (case when @SI1 is null then 0 else 1 end+case when @SI2 is null then 0 else 1 end+case when @SI3 is null then 0 else 1 end+case when @SI4 is null then 0 else 1 end+case when @SI5 is null then 0 else 1 end
			+case when @SO1 is null then 0 else 1 end+case when @SO2 is null then 0 else 1 end+case when @SO3 is null then 0 else 1 end+case when @SO4 is null then 0 else 1 end+case when @SO5 is null then 0 else 1 end
			-case when @KI1 is null then 0 else 1 end-case when @KI2 is null then 0 else 1 end-case when @KI3 is null then 0 else 1 end-case when @KI4 is null then 0 else 1 end-case when @KI5 is null then 0 else 1 end
			-case when @KO1 is null then 0 else 1 end-case when @KO2 is null then 0 else 1 end-case when @KO3 is null then 0 else 1 end-case when @KO4 is null then 0 else 1 end-case when @KO5 is null then 0 else 1 end) <>0 or 
			ABS(DATEDIFF(SS,@SI1,@KI1))>7200 OR ABS(DATEDIFF(SS,@SI2,@KI2))>7200 OR ABS(DATEDIFF(SS,@SI3,@KI3))>7200 OR ABS(DATEDIFF(SS,@SI4,@KI4))>7200 OR ABS(DATEDIFF(SS,@SI5,@KI5))>7200 OR
			ABS(DATEDIFF(SS,@SO1,@KO1))>7200 OR ABS(DATEDIFF(SS,@SO2,@KO2))>7200 OR ABS(DATEDIFF(SS,@SO3,@KO3))>7200 OR ABS(DATEDIFF(SS,@SO4,@KO4))>7200 OR ABS(DATEDIFF(SS,@SO5,@KO5))>7200
			)
	begin
			update KaoqinDay set  EXFlag=1,CheckFlag=0,WorkHour=@WorkHour,ExtraHour=@ExtraHour,LateTime=@LateTime,LateHour=@LateHour,EarlyTime=@EarlyTime,EarlyHour=@EarlyHour,QingJiaHour=@QJHour,QingJiaDay=0   where KQDay=@KQDay and EmpNo=@EmpNo 
	end
	else
	begin
		--process moring card
		if(@KI1>@SI1)
		begin 
			set @LateHour=(datediff(S,@SI1,@KI1)/1800+case when datediff(S,@SI1,@KI1)%1800=0 then 0 else 1 end)*0.5
			set @LateTime=1
		end
		if(@KO1<@SO1)
		begin 
			set @EarlyHour=(datediff(S,@KO1,@SO1)/1800+case when datediff(S,@KO1,@SO1)%1800=0 then 0 else 1 end)*0.5
			set @EarlyTime=1
		end
		--process afternoon card
		if(@KI2>@SI2)
		begin 
			set @LateHour=@LateHour+(datediff(S,@SI2,@KI2)/1800+case when datediff(S,@SI2,@KI2)%1800=0 then 0 else 1 end)*0.5
			set @LateTime=@LateTime+1
		end
		if(@KO2<@SO2)
		begin 
			set @EarlyHour=@EarlyHour+(datediff(S,@KO2,@SO2)/1800+case when datediff(S,@KO2,@SO2)%1800=0 then 0 else 1 end)*0.5
			set @EarlyTime=@EarlyTime+1
		end
		--process night card
		if(@KI3>@SI3)
		begin 
			set @LateHour=@LateHour+(datediff(S,@SI3,@KI3)/1800+case when datediff(S,@SI3,@KI3)%1800=0 then 0 else 1 end)*0.5
			set @LateTime=@LateTime+1
		end
		if(@KO3<@SO3)
		begin 
			set @EarlyHour=@EarlyHour+(datediff(S,@KO3,@SO3)/1800+case when datediff(S,@KO3,@SO3)%1800=0 then 0 else 1 end)*0.5
			set @EarlyTime=@EarlyTime+1
		end
		--process other1 card
		if(@KI4>@SI4)
		begin 
			set @LateHour=@LateHour+(datediff(S,@SI4,@KI4)/1800+case when datediff(S,@SI4,@KI4)%1800=0 then 0 else 1 end)*0.5
			set @LateTime=@LateTime+1
		end
		if(@KO4<@SO4)
		begin 
			set @EarlyHour=@EarlyHour+(datediff(S,@KO4,@SO4)/1800+case when datediff(S,@KO4,@SO4)%1800=0 then 0 else 1 end)*0.5
			set @EarlyTime=@EarlyTime+1
		end
		--process other2 card
		if(@KI5>@SI5)
		begin 
			set @LateHour=@LateHour+(datediff(S,@SI5,@KI5)/1800+case when datediff(S,@SI5,@KI5)%1800=0 then 0 else 1 end)*0.5
			set @LateTime=@LateTime+1
		end
		if(@KO5<@SO5)
		begin 
			set @EarlyHour=@EarlyHour+(datediff(S,@KO5,@SO5)/1800+case when datediff(S,@KO5,@SO5)%1800=0 then 0 else 1 end)*0.5
			set @EarlyTime=@EarlyTime+1
		end
		if exists(select QJStart  from QingJia where EmpNo=@EmpNo and QJType=0 and DATEDIFF(DD,QJStart,@KQDay)=0)
		begin
			select @QJHour=sum((datediff(S,QJStart,QJEnd)/1800+case when datediff(S,QJStart,QJEnd)%1800=0 then 0 else 1 end)*0.5) from QingJia where EmpNo=@EmpNo and QJType=0 and DATEDIFF(DD,QJStart,@KQDay)=0
		end
		--compute workhour
		set @WorkHour=isnull((datediff(S,@SI1,@SO1)/1800+case when datediff(S,@SI1,@SO1)%1800=0 then 0 else 1 end)*0.5,0)+isnull((datediff(S,@SI2,@SO2)/1800+case when datediff(S,@SI2,@SO2)%1800=0 then 0 else 1 end)*0.5,0)+isnull((datediff(S,@SI3,@SO3)/1800+case when datediff(S,@SI3,@SO3)%1800=0 then 0 else 1 end)*0.5,0)
			+isnull((datediff(S,@SI4,@SO4)/1800+case when datediff(S,@SI4,@SO4)%1800=0 then 0 else 1 end)*0.5,0)+isnull((datediff(S,@SI5,@SO5)/1800+case when datediff(S,@SI5,@SO5)%1800=0 then 0 else 1 end)*0.5,0)
		if(@WorkHour>11)
		begin
			set @ExtraHour =@WorkHour-11
			set @WorkHour=11
		end
		update KaoqinDay set  EXFlag=0,CheckFlag=1,WorkHour=@WorkHour,IsWork=case when @WorkHour>0 then 1 else 0 end,ExtraHour=@ExtraHour,LateTime=@LateTime,LateHour=@LateHour,EarlyTime=@EarlyTime,EarlyHour=@EarlyHour,QingJiaHour=@QJHour,QingJiaDay=0   where KQDay=@KQDay and EmpNo=@EmpNo 
	end

end

END

GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Employee"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 248
               Right = 192
            End
            DisplayFlags = 280
            TopColumn = 8
         End
         Begin Table = "Department"
            Begin Extent = 
               Top = 120
               Left = 278
               Bottom = 260
               Right = 423
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Factory"
            Begin Extent = 
               Top = 21
               Left = 465
               Bottom = 238
               Right = 608
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "SalaryLevel"
            Begin Extent = 
               Top = 20
               Left = 649
               Bottom = 160
               Right = 802
            End
            DisplayFlags = 280
            TopColumn = 1
         End
         Begin Table = "JobName"
            Begin Extent = 
               Top = 95
               Left = 685
               Bottom = 216
               Right = 830
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwEmployee'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane2', @value=N'Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwEmployee'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=2 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwEmployee'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Employee"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 233
               Right = 192
            End
            DisplayFlags = 280
            TopColumn = 5
         End
         Begin Table = "PaiBanPerson"
            Begin Extent = 
               Top = 6
               Left = 230
               Bottom = 224
               Right = 384
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "Department"
            Begin Extent = 
               Top = 6
               Left = 422
               Bottom = 146
               Right = 567
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwEmployeePB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwEmployeePB'
GO
