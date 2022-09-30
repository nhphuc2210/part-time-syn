create or replace view DWH.CDM_DATA.vw__region__weekly_data as (
  
with point__target_by_week as (
select * 
  from dwh.cdm_data.vw__target_point_by_week
)

, score__region_level as (
  select 
  year
  , week
  , country as region
//  , "SELLER NAME" as seller_name
//  , trim("SELLER SHORT CODE") as seller_short_code
  , METRICS_INPUT
  , METRICS_MAPPING
  
  , sum( case when METRICS_MAPPING in ('GMV (USD)') then value end) as gmv_usd
  , sum( case when METRICS_MAPPING in ('Units') then value end) as units
  , avg( case when METRICS_MAPPING not in ('Units','GMV (USD)') then value end) as avg_value
  
  from dwh.cdm_data.cdm__weekly_data
  where true 
//      and country = 'SG'
//        and week = 37
  group by 1,2,3,4,5
)

  
  , raw_data as (
    select 
  a.year, b.quarter, a.week, b.CALENDER_WEEK, a.region
//, seller_name
//, seller_short_code
, a.METRICS_MAPPING
, a.avg_value
, case when IS_POSITIVE = 0 then ( 1 - a.avg_value ) else a.avg_value end as avg_value_reverse
, b.type, "MAX POINT"
, b.metrics
, b.IS_POSITIVE
, EXCELLENT_CRITERIA, EXCELLENT_CRITERIA_reverse,EXCELLENT_POINTS
, GOOD_CRITERIA, GOOD_CRITERIA_reverse, GOOD_POINTS
, POOR_POINT
, TYPE_OF_METRIC 

from score__region_level a 
left join point__target_by_week b 
    on a.year = b.year
    and a.week = b.CALENDER_WEEK 
    and a.region = b.region
    and a.METRICS_MAPPING = b.METRICS
where true 
    and b.metrics is not null -- remove GMV_USD and Units in Metrics
)


, get_seller_info as (
select * from DWH.CDM_DATA.VW__SELLER_INFO
)

  
select 
  a.*
, ZEROIFNULL(
  case  when AVG_VALUE_REVERSE >= EXCELLENT_CRITERIA_reverse then EXCELLENT_POINTS
        when AVG_VALUE_REVERSE >= GOOD_CRITERIA_reverse then GOOD_POINTS
        else POOR_POINT end
    ) as get_point__week

,   case  when AVG_VALUE_REVERSE >= EXCELLENT_CRITERIA_reverse then 'Excellent'
        when AVG_VALUE_REVERSE >= GOOD_CRITERIA_reverse then 'Good'
       else 'Poor' end as rank_by__week
//, CBDS, WH, CS, COMPANY, DIVISION, CLUSTER, CATEGORY
  
from raw_data a 
//left join get_seller_info b on a.seller_short_code = b.seller_short_code
)
