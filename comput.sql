USE [ProgramPlatform]
GO
/****** Object:  StoredProcedure [dbo].[ComputDay]    Script Date: 2020/08/18 13:05:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ComputDay]
 @KQDay datetime,
 @EmpNo nvarchar(20)
	-- Add the parameters for the stored procedure here
AS
BEGIN
declare @SI1 datetime
declare @SO1 datetime
declare @SI2 datetime
declare @SO2 datetime
declare @SI3 datetime
declare @SO3 datetime
declare @SI4 datetime
declare @SO4 datetime
declare @SI5 datetime
declare @SO5 datetime
declare @SHour numeric(5,1)
declare @SType smallint
declare @KI1 datetime
declare @KO1 datetime
declare @KI2 datetime
declare @KO2 datetime
declare @KI3 datetime
declare @KO3 datetime
declare @KI4 datetime
declare @KO4 datetime
declare @KI5 datetime
declare @KO5 datetime
declare @ScheduleId nvarchar(10)
declare @WorkHour numeric(5,1)=0
declare @LateTime smallint=0
declare @LateHour numeric(5,1)=0
declare @ExtraHour numeric(5,1)=0
declare @EarlyTime smallint=0
declare @EarlyHour numeric(5,1)=0
declare @QJHour numeric(5,1)=0

select @KI1=In1,@KO1=Out1,@KI2=In2,@KO2=Out2,@KI3=In3,@KO3=Out3,@KI4=In4,@KO4=Out4,@KI5=In5,@KO5=Out5,@ScheduleId=ScheduleId from KaoqinDay where KQDay=@KQDay and EmpNo=@EmpNo 
select @SI1=dateadd(dd,DATEDIFF(dd,In1,@KQDay),In1),@SO1=dateadd(dd,DATEDIFF(dd,Out1,@KQDay),Out1),@SI2=dateadd(dd,DATEDIFF(dd,In2,@KQDay),In2),@SO2=dateadd(dd,DATEDIFF(dd,Out2,@KQDay),Out2),@SI3=dateadd(dd,DATEDIFF(dd,In3,@KQDay),In3),@SO3=dateadd(dd,DATEDIFF(dd,Out3,@KQDay),Out3) FROM Schedule where ScheduleId=@ScheduleId
if exists(select EmpNo from QingJia where EmpNo=@EmpNo and QJType=1 and DATEDIFF(DD,QJStart,@KQDay)=0 )
begin
	if(@KI1 is not null)
	begin
		update KaoqinDay set  EXFlag=1 where KQDay=@KQDay and EmpNo=@EmpNo 
		return 0;
	end
	else
	begin
		update KaoqinDay set  EXFlag=0,CheckFlag=1,QingJiaDay=1 where KQDay=@KQDay and EmpNo=@EmpNo 
		return 0;
	end
end
if( case when @SI1 is null then 0 else 1 end+case when @SI2 is null then 0 else 1 end+case when @SI3 is null then 0 else 1 end+case when @SI4 is null then 0 else 1 end+case when @SI5 is null then 0 else 1 end
		+case when @SO1 is null then 0 else 1 end+case when @SO2 is null then 0 else 1 end+case when @SO3 is null then 0 else 1 end+case when @SO4 is null then 0 else 1 end+case when @SO5 is null then 0 else 1 end
		-case when @KI1 is null then 0 else 1 end-case when @KI2 is null then 0 else 1 end-case when @KI3 is null then 0 else 1 end-case when @KI4 is null then 0 else 1 end-case when @KI5 is null then 0 else 1 end
		-case when @KO1 is null then 0 else 1 end-case when @KO2 is null then 0 else 1 end-case when @KO3 is null then 0 else 1 end-case when @KO4 is null then 0 else 1 end-case when @KO5 is null then 0 else 1 end <>0 or 
		ABS(DATEDIFF(SS,@SI1,@KI1))>7200 OR ABS(DATEDIFF(SS,@SI2,@KI2))>7200 OR ABS(DATEDIFF(SS,@SI3,@KI3))>7200 OR ABS(DATEDIFF(SS,@SI4,@KI4))>7200 OR ABS(DATEDIFF(SS,@SI5,@KI5))>7200 OR
		ABS(DATEDIFF(SS,@SI1,@KO1))>7200 OR ABS(DATEDIFF(SS,@SI2,@KO2))>7200 OR ABS(DATEDIFF(SS,@SI3,@KO3))>7200 OR ABS(DATEDIFF(SS,@SI4,@KO4))>7200 OR ABS(DATEDIFF(SS,@SI5,@KO5))>7200
		)
begin
	print 1--Òì³£
end
ELSE
begin
	if(@SType=3 or @SType=4)
	begin
		print 1 --1
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
		select @SO3) T1 WHERE T1.QJStart NOT IN
		(SELECT M1.QJStart  from
		(select @SI1 as QJStart union
		select @SO1 union
		select @SI2 union
		select @SO2 union
		select @SI3 union
		select @SO3 ) M1 ,(select QJStart  from QingJia where EmpNo=@EmpNo and QJType=0  and DATEDIFF(DD,QJStart,@KQDay)=0 union
		select QJEnd  from QingJia where EmpNo=@EmpNo and QJType=0  and DATEDIFF(DD,QJStart,@KQDay)=0 ) M2 WHERE M1.QJStart=M2.QJStart) 
		) T2 pivot(max(QJStart) for no1 in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10])) a
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
		update KaoqinDay set  EXFlag=0,CheckFlag=1,WorkHour=@WorkHour,ExtraHour=@ExtraHour,LateTime=@LateTime,LateHour=@LateHour,EarlyTime=@EarlyTime,@EarlyHour=@EarlyHour,QingJiaHour=@QJHour   where KQDay=@KQDay and EmpNo=@EmpNo 
	end
end
--	  Declare  @In1D int
--	    Declare  @Out1D int
--	  Declare  @In2D int
--	  Declare  @Out2D int
--	  Declare  @In3D int
--	  Declare  @Out3D int
--	  	  Declare  @In4D int
--	  Declare  @Out4D int
--	  declare @emp nvarchar(20)
--	  --?¡À?¨®?3?¦Ì
--	  select @emp=empno from CardDay where EmpNo=1
--	  select @emp 
--	  select * from CardDay,Schedule   where CardDay.ScheduleId=Schedule.ScheduleId and CardDay='2020-08-13' and EmpNo='1'

	
--	   select     case when CardDay.In1 is null then 0 else 1 end+case when CardDay.IN2 is null then 0 else 1 end+case when CardDay.In3 is null then 0 else 1 end+ case when CardDay.Out1 is null then 0 else 1 end+case when CardDay.Out2 is null then 0 else 1 end+case when CardDay.Out3 is null then 0 else 1 end 
--	   -case when Schedule.In1 is null then 0 else 1 end-case when Schedule.IN2 is null then 0 else 1 end-case when Schedule.In3 is null then 0 else 1 end- case when Schedule.Out1 is null then 0 else 1 end-case when Schedule.Out2 is null then 0 else 1 end-case when Schedule.Out3 is null then 0 else 1 end 
--	  from CardDay,Schedule   where CardDay.ScheduleId=Schedule.ScheduleId and CardDay='2020-08-13' and EmpNo='1'

--	select  @In1D =datediff(S,CONVERT(nvarchar(8),CardDay.In1,108),CONVERT(nvarchar(8),Schedule.In1,108))  ,@Out1D=datediff(S,CONVERT(nvarchar(8),Schedule.Out1,108),CONVERT(nvarchar(8),CardDay.OUT1,108)),@In2D =datediff(S,CONVERT(nvarchar(8),CardDay.IN2,108),CONVERT(nvarchar(8),Schedule.In2,108)) ,@Out2D=datediff(S,CONVERT(nvarchar(8),Schedule.Out2,108),CONVERT(nvarchar(8),CardDay.OUT2,108)),@Out3D=datediff(S,CONVERT(nvarchar(8), Schedule.In3,108),CONVERT(nvarchar(8),CardDay.In3,108))
-- from CardDay,Schedule   where CardDay.ScheduleId=Schedule.ScheduleId and CardDay='2020-08-13' and EmpNo='1'
-- select @In1D,@Out1D,@In2D,@Out2D,@In3D,@Out3D 


--SELECT @IN1D/1800+case when @In1D%1800=0 then 0 else 1 end 	
--	-- SET NOCOUNT ON added to prevent extra result sets from
--	 -- Declare  @In1D int=NULL 
--	  Declare @Late int=20
--	  select case when  @IN1D<@Late and  @IN1D>-50 then 0 else 1 end
END

