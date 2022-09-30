create or replace view dwh.cdm_data.vw__qtd_hit_rate__metric__region as (
  
with calender as (
select year, laz_quarter as quarter, region, min(calender_week) as start_week, max(calender_week) end_week
from DWH.CDM_DATA.VW__LAZADA_CALENDER_BY_REGION
where laz_quarter = 3
group by 1,2,3
)

, actual_data as (
select distinct
a.year, a.quarter, a.region,  max(week) as current_week
from DWH.CDM_DATA.VW__REGION__WEEKLY_DATA a 
where a.quarter = 3
group by 1,2,3
)

, calculation_period as (
select distinct
a.year, a.quarter, a.region, b.start_week, b.end_week, a.current_week
, current_week - start_week + 1 as passed_week
, end_week - current_week as remaining_week
, end_week - start_week + 1 as total_week_of_quarter

from actual_data a 
left join calender b on a.year = b.year and a.quarter = b.quarter and a.region = b.region 
)

, qtd_pfm__region__metrics as (
 select year, quarter, region, metrics_mapping
 , avg(AVG_VALUE) AVG_VALUE
 , avg(AVG_VALUE_REVERSE) AVG_VALUE_REVERSE
 , min(EXCELLENT_CRITERIA) EXCELLENT_CRITERIA
 , min(EXCELLENT_CRITERIA_REVERSE) EXCELLENT_CRITERIA_REVERSE
 
from DWH.CDM_DATA.VW__REGION__WEEKLY_DATA a 
where a.quarter = 3
group by 1,2,3,4
)

, temp_calculate__hitrate as (
select a.year, a.quarter, a.region, a.metrics_mapping
, a.avg_value
, a.AVG_VALUE_REVERSE
, a.EXCELLENT_CRITERIA
, a.EXCELLENT_CRITERIA_REVERSE

, start_week, end_week, current_week, passed_week, remaining_week, total_week_of_quarter

, case when AVG_VALUE_REVERSE >= EXCELLENT_CRITERIA_REVERSE then 9999
       else  (EXCELLENT_CRITERIA * total_week_of_quarter - avg_value * passed_week) / NULLIFZERO(remaining_week)
       end hit_rate

from qtd_pfm__region__metrics a
left join calculation_period b on a.year = b.year and a.quarter = b.quarter and a.region = b.region 
)

select *, 
case when hit_rate is null then 'Out of period'
    when hit_rate = 9999 then 'Achieved Target'
    when hit_rate <> 9999 and hit_rate >1 then 'Est. Under Target'
    else cast(hit_rate as varchar) end as hit_rate_final
from temp_calculate__hitrate

)




