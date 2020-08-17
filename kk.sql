select * from data
select * from [Schedule]

select * from (
select s1 from [Schedule] union
select s2 from [Schedule] union
select s3 from [Schedule] union
select s4 from [Schedule] union
select s5 from [Schedule] union
select s6 from [Schedule] ) T,data  where s1 is not null order by s1

select *,datediff(MI,CONVERT(nvarchar(8),[1],108),CONVERT(nvarchar(8),S1,108)),datediff(MI,CONVERT(nvarchar(8),[2],108),CONVERT(nvarchar(8),S2,108)) from (select Actual,ROW_NUMBER() OVER(PARTITION BY Em ORDER BY Actual) AS no1  from [data]) 
 T pivot(max(Actual) for no1 in ([1],[2],[3],[4])) a,[Schedule]
 select CONVERT(nvarchar(8),getdate(),108)

USE [ProgramPlatform]
GO
/****** Object:  StoredProcedure [dbo].[ComputDay]    Script Date: 2020/08/13 16:02:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[ComputDay]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	  Declare  @In1D int
	  Declare  @Out1D int
	  Declare  @In2D int
	  Declare  @Out2D int
	select @In1D=DATEDIFF(MI,CONVERT(nvarchar(8),cardday.In1,108),CONVERT(nvarchar(8),Schedule.In1,108)), @Out1D=DATEDIFF(MI,CONVERT(nvarchar(8),Schedule.Out1,108),CONVERT(nvarchar(8),cardday.Out1,108))  from cardday,Schedule
	select @In1D,@Out1D, * from cardday,Schedule
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	
END


USE [ProgramPlatform]
GO
/****** Object:  StoredProcedure [dbo].[ComputDay]    Script Date: 2020/08/14 13:38:29 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[ComputDay]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	  Declare  @In1D int
	    Declare  @Out1D int
	  Declare  @In2D int
	  Declare  @Out2D int
	  Declare  @In3D int
	  Declare  @Out3D int
	  	  Declare  @In4D int
	  Declare  @Out4D int
	  declare @emp nvarchar(20)
	  --Ö±½Ó¸³Öµ
	  select @emp=empno from CardDay where EmpNo=1
	  select @emp 
	  select * from CardDay,Schedule   where CardDay.ScheduleId=Schedule.ScheduleId and CardDay='2020-08-13' and EmpNo='1'

	
	   select     case when CardDay.In1 is null then 0 else 1 end+case when CardDay.IN2 is null then 0 else 1 end+case when CardDay.In3 is null then 0 else 1 end+ case when CardDay.Out1 is null then 0 else 1 end+case when CardDay.Out2 is null then 0 else 1 end+case when CardDay.Out3 is null then 0 else 1 end 
	   -case when Schedule.In1 is null then 0 else 1 end-case when Schedule.IN2 is null then 0 else 1 end-case when Schedule.In3 is null then 0 else 1 end- case when Schedule.Out1 is null then 0 else 1 end-case when Schedule.Out2 is null then 0 else 1 end-case when Schedule.Out3 is null then 0 else 1 end 
	  from CardDay,Schedule   where CardDay.ScheduleId=Schedule.ScheduleId and CardDay='2020-08-13' and EmpNo='1'

	select  @In1D =datediff(S,CONVERT(nvarchar(8),CardDay.In1,108),CONVERT(nvarchar(8),Schedule.In1,108))  ,@Out1D=datediff(S,CONVERT(nvarchar(8),Schedule.Out1,108),CONVERT(nvarchar(8),CardDay.OUT1,108)),@In2D =datediff(S,CONVERT(nvarchar(8),CardDay.IN2,108),CONVERT(nvarchar(8),Schedule.In2,108)) ,@Out2D=datediff(S,CONVERT(nvarchar(8),Schedule.Out2,108),CONVERT(nvarchar(8),CardDay.OUT2,108)),@Out3D=datediff(S,CONVERT(nvarchar(8), Schedule.In3,108),CONVERT(nvarchar(8),CardDay.In3,108))
 from CardDay,Schedule   where CardDay.ScheduleId=Schedule.ScheduleId and CardDay='2020-08-13' and EmpNo='1'
 select @In1D,@Out1D,@In2D,@Out2D,@In3D,@Out3D 


SELECT @IN1D/1800+case when @In1D%1800=0 then 0 else 1 end 	
	-- SET NOCOUNT ON added to prevent extra result sets from
	 -- Declare  @In1D int=NULL 
	  Declare @Late int=20
	  select case when  @IN1D<@Late and  @IN1D>-50 then 0 else 1 end

END
USE [ProgramPlatform]
GO
/****** Object:  StoredProcedure [dbo].[ComputDay]    Script Date: 2020/08/17 15:49:57 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[ComputDay]
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
declare @KQDay datetime='2020-7-5'
declare @EmpNo nvarchar(20)
select @KI1=In1,@KO1=Out1,@KI2=In2,@KO2=Out2,@KI3=In3,@KO3=Out3,@KI4=In4,@KO4=Out4,@KI5=In5,@KO5=Out5 from KaoqinDay where KQDay=@KQDay and EmpNo=@EmpNo 

select @SI1=dateadd(dd,DATEDIFF(dd,In1,@KQDay),In1),@SO1=dateadd(dd,DATEDIFF(dd,Out1,@KQDay),Out1),@SI2=dateadd(dd,DATEDIFF(dd,In2,@KQDay),In2),@SO2=dateadd(dd,DATEDIFF(dd,Out2,@KQDay),Out2),@SI3=dateadd(dd,DATEDIFF(dd,In3,@KQDay),In3),@SO3=dateadd(dd,DATEDIFF(dd,Out3,@KQDay),Out3) FROM Schedule where ScheduleId='1'
select @SI1=[1],@SO1=[2],@SI2=[3],@SO2=[4],@SI3=[5],@SO3=[6],@SI4=[7],@SO4=[8],@SI5=[9],@SO5=[10] from(
select QJStart,ROW_NUMBER() OVER( ORDER BY QJStart) AS no1  from(
select QJStart  from QingJia where EmpNo='1202001' and QJType=0 union
select QJEnd  from QingJia where EmpNo='1202001' and QJType=0 union
select @SI1 union
select @SO1 union
select @SI2 union
select @SO2 union
select @SI3 union
select @SO3) T1) T2 pivot(max(QJStart) for no1 in ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10])) a

if(@KO1-@SI1>0)
begin 
	set @KO1=@SI1
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
--	  --Ö±½Ó¸³Öµ
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


