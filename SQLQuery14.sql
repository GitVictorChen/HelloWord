USE [KaoqinPr]
GO
/****** Object:  StoredProcedure [dbo].[DayProcess]    Script Date: 2020/08/05 13:48:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[DayProcess]
	-- Add the parameters for the stored procedure here
	 @EmpNoOut nvarchar(10),
	 @CheckDateOut date
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	declare @MorStart datetime
	declare @MorEnd datetime
	declare @AftStart datetime
	declare @AftEnd datetime
	declare @NightStart datetime
	declare @NightEnd datetime
	declare @CountTemp int=0
	declare @Sum1 as decimal(5,2)
	declare @Sum2 as decimal(5,2)

	declare @deltb table 
	(
		AutoID int 
	)
	declare @DateTimeTemp  datetime
	declare @EmpNoTemp     nvarchar(20)=''  
	declare @AutoIdTemp bigint
	--赋值上班的几个卡点
select @MorStart=MorStart,@MorEnd=MorEnd,@AftStart=AftStart ,@AftEnd=AftEnd,@NightStart=NightStart,@NightEnd=NightEnd   from DayShedule where empno=@EmpNoOut and RealDate=@CheckDateOut
	if OBJECT_ID(N'tempdb.dbo.#temp',N'U') is not null 
	drop table #temp 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		select *  into #temp 
             from (
                   select autoid,a.EmpNo,ActDate,0 as Step,0 as Flag,0 as OrderId from CardData a,DayShedule b where a.EmpNo=@EmpNoOut and a.empno=b.EmpNo and b.RealDate=@CheckDateOut and ActDate >=b.StartTime and a.actdate<b.EndTime 
                    ) as q  order by actdate 
	
	select @CountTemp=isnull(count(*),0) from #temp 
	if(@CountTemp<=1)
		begin
			update WorkTime set WorkHour=0 where EmpNo=@EmpNoOut and CheckDate=@CheckDateOut
			return
		end
	DECLARE MyCursor CURSOR  
    FOR select AutoID,EmpNo,ActDate from  #temp order by actdate    
	--打开一个游标    
	OPEN MyCursor
	--循环一个游标
	DECLARE @AutoID int ,@EmpNo nvarchar(20),@CheckDate datetime
		FETCH NEXT FROM  MyCursor INTO @AutoID,@EmpNo,@CheckDate
	--以下循环去重复
	WHILE @@FETCH_STATUS =0
		BEGIN
			--  print cast(@AutoID as  nvarchar)+' '+ @ICCardID +'  '+convert(nvarchar, @SFDateTime ,23)

			   if (@DateTimeTemp is null) 
				   begin   
						set @DateTimeTemp=@CheckDate
						 set @EmpNoTemp =@EmpNo
				   end
			   else
				  begin
					 if (DATEDIFF(SS,@DateTimeTemp,@CheckDate)>300) 
						 begin

							  set @DateTimeTemp=@CheckDate 
							  set @EmpNoTemp =@EmpNo
						 end
					else
						 begin
							 insert into @deltb(AutoID) values(@AutoID)
						 end
				 end 

			   FETCH NEXT FROM  MyCursor INTO @AutoID,@EmpNo,@CheckDate
		END  
		--关闭游标
	CLOSE MyCursor
	--释放资源
	DEALLOCATE MyCursor

		delete from  #temp where AutoID in (select AutoID from @deltb )
		  --循环去重复结束

	select @CountTemp=isnull(count(*),0) from #temp --打卡一次
	if @CountTemp=1
	begin
		update WorkTime set WorkHour=0 where EmpNo=@EmpNoOut and CheckDate=@CheckDateOut
		return
	end
	else

	update #temp set orderid=b.OrderId from( select AutoId,ROW_NUMBER() over(order by actdate) as orderId from #temp) as b where #temp.autoid=b.AutoId 
	select @CountTemp=count(*) from #temp 
	if(@CountTemp%2=1)
	begin
		update #temp set ActDate =@MorStart where  OrderId in(select min(OrderId) from #temp) and DATEDIFF(S,ActDate,@MorStart)<900 AND DATEDIFF(S,ActDate,@MorStart)>0
		update #temp set ActDate =@AftStart where  OrderId in(select min(OrderId) from #temp) and DATEDIFF(S,ActDate,@AftStart)<900 AND DATEDIFF(S,ActDate,@AftStart)>0
	    update #temp set ActDate =@NightStart where  OrderId in(select min(OrderId) from #temp) and DATEDIFF(S,ActDate,@NightStart)<900 AND DATEDIFF(S,ActDate,@NightStart)>0
		update #temp set ActDate =@MorEnd where  OrderId in(select MAX(OrderId) from #temp) and DATEDIFF(S,@MorEnd,ActDate)<900 AND DATEDIFF(S,@MorEnd,ActDate)>0
		update #temp set ActDate =@AftEnd where  OrderId in(select MAX(OrderId) from #temp) and DATEDIFF(S,@AftEnd,ActDate)<900 AND DATEDIFF(S,@AftEnd,ActDate)>0
		update #temp set ActDate =@NightEnd where  OrderId in(select MAX(OrderId) from #temp) and DATEDIFF(S,@NightEnd,ActDate)<900 AND DATEDIFF(S,@NightEnd,ActDate)>0
		select @Sum1=sum(sum1) from(
		select datediff(S,min(actdate),max(actdate))/60/15*0.25 as Sum1 ,max(actdate) as mmax,min(actdate) as mmin from #temp  )  as q2
	end
	else
	begin
	update #temp set ActDate =@MorStart where  DATEDIFF(S,ActDate,@MorStart)<900 AND DATEDIFF(S,ActDate,@MorStart)>0 and OrderId%2=1
	update #temp set ActDate =@AftStart where   DATEDIFF(S,ActDate,@AftStart)<900 AND DATEDIFF(S,ActDate,@AftStart)>0 and OrderId%2=1
	update #temp set ActDate =@NightStart where   DATEDIFF(S,ActDate,@NightStart)<900 AND DATEDIFF(S,ActDate,@NightStart)>0 and OrderId%2=1
	update #temp set ActDate =@MorEnd where DATEDIFF(S,@MorEnd,ActDate)<900 AND DATEDIFF(S,@MorEnd,ActDate)>0 and OrderId%2=0
	update #temp set ActDate =@AftEnd where   DATEDIFF(S,@AftEnd,ActDate)<900 AND DATEDIFF(S,@AftEnd,ActDate)>0 and OrderId%2=0
    update #temp set ActDate =@NightEnd where   DATEDIFF(S,@NightEnd,ActDate)<900 AND DATEDIFF(S,@NightEnd,ActDate)>0 and OrderId%2=0
	select @Sum1=SUM(sum2) from(
	select a.*,b.ActDate AS ACT2,datediff(S,a.actdate,b.actdate)/60/15*0.25 as sum2,ROW_NUMBER() over(order by a.actdate)%2  as OddId from #temp a,#temp b where a.OrderId =b.OrderId -1 -- order by a.ActDate 
	) as q3 where q3.OddId=1
	end
	update WorkTime set WorkHour=isnull(@Sum1,0) where EmpNo=@EmpNoOut and CheckDate=@CheckDateOut
END
