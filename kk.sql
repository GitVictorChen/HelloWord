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
