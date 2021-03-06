USE [KaoqinPr]
GO
/****** Object:  StoredProcedure [dbo].[Process]    Script Date: 2020/08/05 13:48:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[Process]
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--备份前一天处理结果
  delete from WorkTime 
--更新最新刷卡数据到表carddata
delete from carddata 
 insert into carddata(EmpNo,CardId,ActDate)
SELECT case left(right([ECID],2),1) when 0 then left([ECID],7) else left([ECID],8) end
      ,[ECID]
      ,[EDate]
  FROM [10.1.2.88].[MarketFood].[dbo].[OldDate]
  where EDate >=convert(nvarchar(10),dateadd(d,-21,GETDATE()),120) and MIden in(
  select Miden  from [10.1.2.88].[MarketFood].[dbo].machine where MType=2 or MType=4) and LEN(ECID)=10

 delete  carddata  from (select emp_code,att_date,DATEADD(HH,-1,in1) as StartTime,DATEADD(HH,1,out1) as  EndTime  FROM [10.1.2.68].[HRLinkInterface].[dbo].[emp_ats_checklist_interface]  where out1 is not null and in2 is null) T
 where EmpNo=T.emp_code and ActDate between T.Starttime and T.EndTime 
  delete  carddata  from (select emp_code,att_date,DATEADD(HH,-1,in1) as StartTime,DATEADD(HH,1,out2) as  EndTime  FROM [10.1.2.68].[HRLinkInterface].[dbo].[emp_ats_checklist_interface]  where out2 is not null and in3 is null) T
 where EmpNo=T.emp_code and ActDate between T.Starttime and T.EndTime 
  delete  carddata  from (select emp_code,att_date,DATEADD(HH,-1,in1) as StartTime,DATEADD(HH,1,out3) as  EndTime  FROM [10.1.2.68].[HRLinkInterface].[dbo].[emp_ats_checklist_interface]  where out3 is not null) T
 where EmpNo=T.emp_code and ActDate between T.Starttime and T.EndTime 

--delete  carddata  from 
--(select b.emp_code,b.att_date,convert(nvarchar(10),b.att_date ,120) + ' 00:00:00'  as Starttime , dateadd(DD,1,convert(nvarchar(10),b.att_date ,120) + ' 00:00:00' ) as EndTime  from [10.1.2.67].[hrlink].[dbo].[v_cus_ats_ats_class_info] a,[10.1.2.68].[HRLinkInterface].[dbo].[emp_ats_checklist_interface] b,[10.1.2.67].[hrlink].[dbo].[v_cus_ats_emp_class_setting] c
--where a.class_code=c.class_code and b.emp_code=c.emp_code and b.att_date=c.shift_dt and c.shift_dt<convert(nvarchar(10),GETDATE(),120) and c.shift_dt>DATEADD(d,-22,getdate()) and a.class_code  in('TSZM02','TSBC01','__rest')) T
--where EmpNo=T.emp_code and ActDate between T.Starttime and T.EndTime 
 --插入所有变动打卡人员
insert into carddata(EmpNo,ActDate) select emp_code,in1 as ActDate from [10.1.2.68].[HRLinkInterface].[dbo].[emp_ats_checklist_interface] where att_date >=convert(nvarchar(10),dateadd(d,-21,GETDATE()),120) and in1 is not null
insert into carddata(EmpNo,ActDate) select emp_code,out1 as ActDate from [10.1.2.68].[HRLinkInterface].[dbo].[emp_ats_checklist_interface]   where att_date >=convert(nvarchar(10),dateadd(d,-21,GETDATE()),120) and out1 is not null
insert into carddata(EmpNo,ActDate) select emp_code,in2 as ActDate from [10.1.2.68].[HRLinkInterface].[dbo].[emp_ats_checklist_interface]   where att_date >=convert(nvarchar(10),dateadd(d,-21,GETDATE()),120) and in2 is not null
insert into carddata(EmpNo,ActDate) select emp_code,out2 as ActDate from [10.1.2.68].[HRLinkInterface].[dbo].[emp_ats_checklist_interface]   where att_date >=convert(nvarchar(10),dateadd(d,-21,GETDATE()),120) and out2 is not null
insert into carddata(EmpNo,ActDate) select emp_code,in3 as ActDate from [10.1.2.68].[HRLinkInterface].[dbo].[emp_ats_checklist_interface]   where att_date >=convert(nvarchar(10),dateadd(d,-21,GETDATE()),120) and in3 is not null
insert into carddata(EmpNo,ActDate) select emp_code,out3 as ActDate from [10.1.2.68].[HRLinkInterface].[dbo].[emp_ats_checklist_interface]   where att_date >=convert(nvarchar(10),dateadd(d,-21,GETDATE()),120) and out3 is not null
--更新排班情况
delete from WorkShedule
insert into WorkShedule(EmpNo,CheckDate,Class_code)
select emp_code,shift_dt,class_code  FROM [10.1.2.67].[hrlink].[dbo].[v_cus_ats_emp_class_setting] where shift_dt<convert(nvarchar(10),GETDATE(),120) and shift_dt>DATEADD(d,-22,getdate())
--更新考勤HRLINK的处理结果
delete from ActWork
insert into ActWork(EmpNo,CheckDate,Act_Work_Hours)
select emp_code,att_dt,Act_Work_Hours from  [10.1.2.67].[hrlink].[dbo].[v_cus_ats_checklist_into] where att_dt<convert(nvarchar(10),GETDATE(),120) and att_dt>DATEADD(d,-22,getdate()) 
--生产结果(未处理)
delete from WorkTime
insert into WorkTime(EmpNo,CheckDate,WorkHour,Class_code)
select a.EmpNo,a.CheckDate ,b.Act_Work_Hours,A.Class_code   from WorkShedule a left join ActWork b on a.EmpNo=b.EmpNo and a.CheckDate=b.CheckDate
--生成日处理排班
delete from DayShedule
insert into DayShedule(EmpNo,RealDate,StartTime,EndTime,class_code)
select b.EmpNo ,b.CheckDate,dateadd(hh,-1,convert(nvarchar(10),b.CheckDate ,120) + ' ' +a.start_time),
case when  a.start_time <a.end_time  then dateadd(hh,1,convert(nvarchar(10),b.CheckDate ,120) + ' ' +a.end_time) else dateadd(hh,1,convert(nvarchar(10),DATEADD(d,1,b.CheckDate ),120)+ ' ' +a.end_time) end ,a.class_code 
	from [10.1.2.67].[hrlink].[dbo].[v_cus_ats_ats_class_info] a,(select a.*,b.Act_Work_Hours  from WorkShedule a left join ActWork b on a.EmpNo=b.EmpNo and a.CheckDate=b.CheckDate where Act_Work_Hours is null or (datediff(d,'2019-1-6',A.CheckDate)%7=0 and a.Class_code in(select SheduleId  from SheduleDefine where SType='N' ))) b
	 where a.class_code=b.class_code and a.class_code not in('TSZM02','TSBC01','__rest')
insert into DayShedule(EmpNo,RealDate,StartTime,EndTime,class_code)
select b.EmpNo ,b.CheckDate,convert(nvarchar(10),b.CheckDate ,120),dateadd(d,1,convert(nvarchar(10),b.CheckDate ,120)) ,a.class_code 
	from [10.1.2.67].[hrlink].[dbo].[v_cus_ats_ats_class_info] a,(select a.*,b.Act_Work_Hours  from WorkShedule a left join ActWork b on a.EmpNo=b.EmpNo and a.CheckDate=b.CheckDate where Act_Work_Hours is null) b
	 where a.class_code=b.class_code and a.class_code in('TSZM02','TSBC01','__rest')
update DayShedule set MorStart=dateadd(DD,datediff(D,'2019-1-1',RealDate),ClassTime.MorStart),MorEnd=dateadd(DD,datediff(D,'2019-1-1',RealDate),ClassTime.MorEnd),AftStart=dateadd(DD,datediff(D,'2019-1-1',RealDate),ClassTime.AftStart),AftEnd=dateadd(DD,datediff(D,'2019-1-1',RealDate),ClassTime.AftEnd),NightStart=dateadd(DD,datediff(D,'2019-1-1',RealDate),ClassTime.NightStart),NightEnd=dateadd(DD,datediff(D,'2019-1-1',RealDate),ClassTime.NightEnd)  FROM ClassTime where DayShedule.Class_Code=ClassTime.Class_Code 
update DayShedule set StartTime=DATEADD(d,1,StartTime),EndTime=DATEADD(d,1,EndTime) WHERE class_code='BA_Y05'
--处理部分数据
update WorkTime set WorkDay =1 from CardData b  where WorkTime.EmpNo=b.EmpNo AND  ActDate between convert(nvarchar(10),WorkTime.CheckDate,120) + ' 01:30:00' and convert(nvarchar(10),WorkTime.CheckDate,120) + ' 15:30:00' 
update WorkTime set WorkDay=0 where WorkDay is null
update WorkTime set WorkDay=0 from [10.1.2.68].[HRLinkInterface].[dbo].[emp_ats_checklist_interface] b where WorkTime.empno=b.emp_code and worktime.CheckDate=b.att_date   and b.out1 is  null
--处理剩余部分的数据
IF OBJECT_ID('tempdb.dbo.#tempemployees','U') IS NOT NULL DROP TABLE dbo.#tempemployees
SELECT AutoId ,EmpNo,CheckDate INTO dbo.#tempemployees from WorkTime where WorkHour  is null   order by EmpNo,CheckDate 
DECLARE
	@AutoId as bigint,
     @EmpNo  AS NVARCHAR(20),
     @CheckDate AS date
 WHILE EXISTS(SELECT AutoId FROM dbo.#tempemployees)
 BEGIN
     -- 也可以使用top 1
     SET ROWCOUNT 1
     SELECT @AutoId= AutoId , @EmpNo= EmpNo ,@CheckDate= CheckDate  FROM dbo.#tempemployees
	 SET ROWCOUNT 0
	 exec DayProcess @EmpNo,@CheckDate 
     DELETE FROM dbo.#tempemployees WHERE AutoId=@AutoId
 END

 DROP TABLE dbo.#tempemployees
  --计算周日加班
 IF OBJECT_ID('tempdb.dbo.#tempemployees2','U') IS NOT NULL DROP TABLE dbo.#tempemployees2
SELECT AutoId ,EmpNo,CheckDate INTO dbo.#tempemployees2 from WorkTime where   datediff(d,'2019-1-6',CheckDate)%7=0 and Class_code in(select SheduleId  from SheduleDefine where SType='N' ) order by EmpNo,CheckDate 
 WHILE EXISTS(SELECT AutoId FROM dbo.#tempemployees2)
 BEGIN
     -- 也可以使用top 1
     SET ROWCOUNT 1
     SELECT @AutoId= AutoId , @EmpNo= EmpNo ,@CheckDate= CheckDate  FROM dbo.#tempemployees2
	 SET ROWCOUNT 0
	 exec Day7NProcess @EmpNo,@CheckDate 
     DELETE FROM dbo.#tempemployees2 WHERE AutoId=@AutoId
 END

 --计算周日加班
 DROP TABLE dbo.#tempemployees2
END

