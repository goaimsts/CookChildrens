

declare @facility	varchar(50)		= 'MEMMED'		--select * from aims.cod where TYPE='y' order by name 

declare @costCenters table(
	costCenterCode	varchar(50)
)
insert into @costCenters
(
    costCenterCode
)
select 
	[CODE]
from aims.cod 
where [TYPE] = 'a' 
	and 
	FACILITY = @facility
	and 
	[CODE] <> ''



--	PM Only
select 
	 facility.[NAME]										as [Facility]
	 ,cc.[code] + ' ' + cc.[NAME]							as [Cost Center]
	,count(distinct wko.WO_NUMBER)							as woCount
	,isnull(sum(	
			case when isnull(wct.RATE_MULTI,1.0) <= 1.0
				then wct.[HOURS]
				else 0
			 end ),0)										as [Hours-Reg]
	,isnull(sum(	case when isnull(wct.RATE_MULTI,1.0) > 1.0
				then wct.[HOURS]
				else 0
			 end ),0)										as [Hours-OT]
	,sum(isnull(
			case 
				when COSTING_TYPE = 'H' 
				then [hours] * CHG_RATE * RATE_MULTI
				else CHG_RATE
			 end,0)										)	as [Labor $]
	,sum(isnull((wcm.PART_QTY * wcm.PART_COST),0))			as [Material $]
	,'Report period: '
		+ convert(varchar(2),datepart(month,(dateadd(month,-1,getdate()))))
			+ '/1/'
			+ convert(char(4),datepart(yyyy,(dateadd(month,-1,getdate()))))
			+ ' and '
			+ convert(varchar(2),datepart(month,(getdate())))
			+ '/1/'
			+ convert(char(4),datepart(yyyy,getdate()))		as [ReportPeriod]
from aims.wko 
	left join aims.wct on wko.FACILITY = wct.FACILITY and wko.WO_NUMBER = wct.WO_NUMBER
		left join aims.emp on wct.EMPLOYEE = emp.EMPLOYEE
	left join aims.WCM on wko.FACILITY = wcm.FACILITY and wko.WO_NUMBER = wcm.WO_NUMBER
	left join aims.cod as facility on wko.FACILITY = facility.[CODE] and facility.[TYPE] = 'y'
	left join aims.cod as cc on wko.CHG_CTR = cc.[CODE] and wko.FACILITY = cc.FACILITY and cc.[TYPE] = 'a'
where 
	wko.CHG_CTR in (select costCenterCode from @costCenters)
	and 
	wko.WO_STATUS in ('CL','PS')
	and  
	wko.WO_TYPE = 'PM' 
	and
	convert(date,wko.STAT_DATETIME) between '1/1/2020' and '2/1/2020'
	--convert(date,wko.STAT_DATETIME) between 
	--									(
	--										convert(varchar(2),datepart(month,(dateadd(month,-1,getdate()))))
	--										+ '/1/'
	--										+ convert(char(4),datepart(yyyy,(dateadd(month,-1,getdate()))))
	--									)
	--									and 
	--									(
	--										convert(varchar(2),datepart(month,(getdate())))
	--										+ '/1/'
	--										+ convert(char(4),datepart(yyyy,getdate()))
	--									)
group by 
	  facility.[NAME]	
	 ,cc.[code]							
	 ,cc.[NAME]	 
	 ,wko.WO_TYPE 
order by cc.[code] + ' ' + cc.[NAME]






--	Non-PM
select 
	 facility.[NAME]										as [Facility]
	 ,cc.[code] + ' ' + cc.[NAME]							as [Cost Center]
	,count(distinct wko.WO_NUMBER)							as woCount
	,isnull(sum(	
			case when isnull(wct.RATE_MULTI,1.0) <= 1.0
				then wct.[HOURS]
				else 0
			 end ),0)										as [Hours-Reg]
	,isnull(sum(	case when isnull(wct.RATE_MULTI,1.0) > 1.0
				then wct.[HOURS]
				else 0
			 end ),0)										as [Hours-OT]
	,sum(isnull(
			case 
				when COSTING_TYPE = 'H' 
				then [hours] * CHG_RATE * RATE_MULTI
				else CHG_RATE
			 end,0)										)	as [Labor $]
	,sum(isnull((wcm.PART_QTY * wcm.PART_COST),0))			as [Material $]
	,'Report period: '
		+ convert(varchar(2),datepart(month,(dateadd(month,-1,getdate()))))
			+ '/1/'
			+ convert(char(4),datepart(yyyy,(dateadd(month,-1,getdate()))))
			+ ' and '
			+ convert(varchar(2),datepart(month,(getdate())))
			+ '/1/'
			+ convert(char(4),datepart(yyyy,getdate()))		as [ReportPeriod]
from aims.wko 
	left join aims.wct on wko.FACILITY = wct.FACILITY and wko.WO_NUMBER = wct.WO_NUMBER
		left join aims.emp on wct.EMPLOYEE = emp.EMPLOYEE
	left join aims.WCM on wko.FACILITY = wcm.FACILITY and wko.WO_NUMBER = wcm.WO_NUMBER
	left join aims.cod as facility on wko.FACILITY = facility.[CODE] and facility.[TYPE] = 'y'
	left join aims.cod as cc on wko.CHG_CTR = cc.[CODE] and wko.FACILITY = cc.FACILITY and cc.[TYPE] = 'a'
where 
	wko.CHG_CTR in (select costCenterCode from @costCenters)
	and 
	wko.WO_STATUS in ('CL','PS')
	and  
	wko.WO_TYPE <> 'PM' 
	and
	convert(date,wko.STAT_DATETIME) between '1/1/2020' and '2/1/2020'
	--convert(date,wko.STAT_DATETIME) between 
	--									(
	--										convert(varchar(2),datepart(month,(dateadd(month,-1,getdate()))))
	--										+ '/1/'
	--										+ convert(char(4),datepart(yyyy,(dateadd(month,-1,getdate()))))
	--									)
	--									and 
	--									(
	--										convert(varchar(2),datepart(month,(getdate())))
	--										+ '/1/'
	--										+ convert(char(4),datepart(yyyy,getdate()))
	--									)
group by 
	  facility.[NAME]	
	 ,cc.[code]							
	 ,cc.[NAME]	 
	 ,wko.WO_TYPE 
order by cc.[code] + ' ' + cc.[NAME]









--Report-friendly code
/*


--PM
select 
	 facility.[NAME]										as [Facility]
	 ,cc.[code] + ' ' + cc.[NAME]							as [Cost Center]
	,count(distinct wko.WO_NUMBER)							as woCount
	,isnull(sum(	
			case when isnull(wct.RATE_MULTI,1.0) <= 1.0
				then wct.[HOURS]
				else 0
			 end ),0)										as [Hours-Reg]
	,isnull(sum(	case when isnull(wct.RATE_MULTI,1.0) > 1.0
				then wct.[HOURS]
				else 0
			 end ),0)										as [Hours-OT]
	,sum(isnull(
			case 
				when COSTING_TYPE = 'H' 
				then [hours] * CHG_RATE * RATE_MULTI
				else CHG_RATE
			 end,0)										)	as [Labor $]
	,sum(isnull((wcm.PART_QTY * wcm.PART_COST),0))			as [Material $]
	,'Report period: '
		+ convert(varchar(2),datepart(month,(dateadd(month,-1,getdate()))))
			+ '/1/'
			+ convert(char(4),datepart(yyyy,(dateadd(month,-1,getdate()))))
			+ ' and '
			+ convert(varchar(2),datepart(month,(getdate())))
			+ '/1/'
			+ convert(char(4),datepart(yyyy,getdate()))		as [ReportPeriod]
from aims.wko 
	left join aims.wct on wko.FACILITY = wct.FACILITY and wko.WO_NUMBER = wct.WO_NUMBER
		left join aims.emp on wct.EMPLOYEE = emp.EMPLOYEE
	left join aims.WCM on wko.FACILITY = wcm.FACILITY and wko.WO_NUMBER = wcm.WO_NUMBER
	left join aims.cod as facility on wko.FACILITY = facility.[CODE] and facility.[TYPE] = 'y'
	left join aims.cod as cc on wko.CHG_CTR = cc.[CODE] and wko.FACILITY = cc.FACILITY and cc.[TYPE] = 'a'
where 
	wko.CHG_CTR in (@costCenters)
	and 
	wko.WO_STATUS in ('CL','PS')
	and  
	wko.WO_TYPE = 'PM' 
	and
	convert(date,wko.STAT_DATETIME) between 
										(
											convert(varchar(2),datepart(month,(dateadd(month,-1,getdate()))))
											+ '/1/'
											+ convert(char(4),datepart(yyyy,(dateadd(month,-1,getdate()))))
										)
										and 
										(
											convert(varchar(2),datepart(month,(getdate())))
											+ '/1/'
											+ convert(char(4),datepart(yyyy,getdate()))
										)
group by 
	  facility.[NAME]	
	 ,cc.[code]							
	 ,cc.[NAME]	 
	 ,wko.WO_TYPE 
order by cc.[code] + ' ' + cc.[NAME]



--	Non-PM
select 
	 facility.[NAME]										as [Facility]
	 ,cc.[code] + ' ' + cc.[NAME]							as [Cost Center]
	,count(distinct wko.WO_NUMBER)							as woCount
	,isnull(sum(	
			case when isnull(wct.RATE_MULTI,1.0) <= 1.0
				then wct.[HOURS]
				else 0
			 end ),0)										as [Hours-Reg]
	,isnull(sum(	case when isnull(wct.RATE_MULTI,1.0) > 1.0
				then wct.[HOURS]
				else 0
			 end ),0)										as [Hours-OT]
	,sum(isnull(
			case 
				when COSTING_TYPE = 'H' 
				then [hours] * CHG_RATE * RATE_MULTI
				else CHG_RATE
			 end,0)										)	as [Labor $]
	,sum(isnull((wcm.PART_QTY * wcm.PART_COST),0))			as [Material $]
	,'Report period: '
		+ convert(varchar(2),datepart(month,(dateadd(month,-1,getdate()))))
			+ '/1/'
			+ convert(char(4),datepart(yyyy,(dateadd(month,-1,getdate()))))
			+ ' and '
			+ convert(varchar(2),datepart(month,(getdate())))
			+ '/1/'
			+ convert(char(4),datepart(yyyy,getdate()))		as [ReportPeriod]
from aims.wko 
	left join aims.wct on wko.FACILITY = wct.FACILITY and wko.WO_NUMBER = wct.WO_NUMBER
		left join aims.emp on wct.EMPLOYEE = emp.EMPLOYEE
	left join aims.WCM on wko.FACILITY = wcm.FACILITY and wko.WO_NUMBER = wcm.WO_NUMBER
	left join aims.cod as facility on wko.FACILITY = facility.[CODE] and facility.[TYPE] = 'y'
	left join aims.cod as cc on wko.CHG_CTR = cc.[CODE] and wko.FACILITY = cc.FACILITY and cc.[TYPE] = 'a'
where 
	wko.CHG_CTR in (@costCenters)
	and 
	wko.WO_STATUS in ('CL','PS')
	and  
	wko.WO_TYPE <> 'PM' 
	and
	convert(date,wko.STAT_DATETIME) between 
										(
											convert(varchar(2),datepart(month,(dateadd(month,-1,getdate()))))
											+ '/1/'
											+ convert(char(4),datepart(yyyy,(dateadd(month,-1,getdate()))))
										)
										and 
										(
											convert(varchar(2),datepart(month,(getdate())))
											+ '/1/'
											+ convert(char(4),datepart(yyyy,getdate()))
										)
group by 
	  facility.[NAME]	
	 ,cc.[code]							
	 ,cc.[NAME]	 
	 ,wko.WO_TYPE 
order by cc.[code] + ' ' + cc.[NAME]

*/









--	Utility
/*

	select 
		WORK_TYPE 
		,count(WO_NUMBER)	as cntByType
	from aims.WCT 
	group by WORK_TYPE

	select distinct RATE_MULTI from aims.wct where WORK_TYPE = 'C' 
	select distinct RATE_MULTI from aims.wct where WORK_TYPE = 'I'
	select distinct RATE_MULTI from aims.wct where WORK_TYPE = 'O'

*/




--	QA
/*
select top 1
	wko.wo_number 
	,wko.STAT_DATETIME
	,wct.*
	,wcm.*
from aims.WKO
	join aims.WCT on wko.FACILITY = wct.FACILITY and wko.WO_NUMBER = wct.WO_NUMBER
	join aims.wcm on wko.FACILITY = wcm.FACILITY and wko.WO_NUMBER = wcm.WO_NUMBER
where wko.WO_STATUS = 'cl'
order by STAT_DATETIME desc

/*
update aims.wko 
set STAT_DATETIME = '10/15/2020'
where FACILITY = 'COOCHI' and WO_NUMBER = 478661
*/

select 
	wko.wo_number 
	,wko.STAT_DATETIME
	,wct.*
	,wcm.*
from aims.WKO
	join aims.WCT on wko.FACILITY = wct.FACILITY and wko.WO_NUMBER = wct.WO_NUMBER
	join aims.wcm on wko.FACILITY = wcm.FACILITY and wko.WO_NUMBER = wcm.WO_NUMBER
where wko.FACILITY = 'COOCHI' and wko.WO_NUMBER = 478661

*/


