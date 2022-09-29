create or replace view DWH.CDM_DATA.vw__seller_weekly_data as (
  
with point__target_by_week as (
  with convert_quarter__to_week as (
    select distinct REGION, LAZ_QUARTER, CALENDER_QUARTER, CALENDER_WEEK
    from DWH.CDM_DATA.VW__LAZADA_CALENDER_BY_REGION
  )
  

  select a.year, a.quarter, a.region, a.type, "MAX POINT"
  , a.metrics, a.is_positive, a.excellent_criteria, a.EXCELLENT_POINTS, a.good_criteria, a.GOOD_POINTS, a.poor_point
  , b.CALENDER_WEEK
  , case when is_positive = 1 then EXCELLENT_CRITERIA else 1-EXCELLENT_CRITERIA end as EXCELLENT_CRITERIA_reverse
  , case when is_positive = 1 then GOOD_CRITERIA else 1-GOOD_CRITERIA end as GOOD_CRITERIA_reverse
  
  from DWH.CDM_DATA.POINT_TARGET a 
  left join convert_quarter__to_week b on a.region = b.region and a.quarter = b.LAZ_QUARTER  
  )

, score__region_level as (
  select 
  year
  , week
  , country as region
  , "SELLER NAME" as seller_name
  , trim("SELLER SHORT CODE") as seller_short_code
  , METRICS_INPUT
  , METRICS_MAPPING
  
  , sum( case when METRICS_MAPPING in ('GMV (USD)') then value end) as gmv_usd
  , sum( case when METRICS_MAPPING in ('Units') then value end) as units
  , avg( case when METRICS_MAPPING not in ('Units','GMV (USD)') then value end) as avg_value
  
  from dwh.cdm_data.cdm__weekly_data
  where true 
//      and country = 'SG'
//        and week = 37
  group by 1,2,3,4,5,6,7
)

, raw_data as (
select 
  a.year, b.quarter, a.week, b.CALENDER_WEEK, a.region
, seller_name
, seller_short_code
, a.METRICS_MAPPING
, a.avg_value
, case when IS_POSITIVE = 0 then ( 1 - a.avg_value ) else a.avg_value end as avg_value_reverse
, b.type, "MAX POINT"
, b.metrics
, b.IS_POSITIVE
, EXCELLENT_CRITERIA, EXCELLENT_CRITERIA_reverse,EXCELLENT_POINTS
, GOOD_CRITERIA, GOOD_CRITERIA_reverse, GOOD_POINTS
, POOR_POINT
 

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
    with get_unique_value as (
    select 
    trim("SELLER SHORT CODE") as seller_short_code

    , ARRAY_UNIQUE_AGG(cbds) cbds
    , ARRAY_UNIQUE_AGG(wh) wh
    , ARRAY_UNIQUE_AGG(cs) cs
    , ARRAY_UNIQUE_AGG(company) company
    , ARRAY_UNIQUE_AGG("BUSINESS DIVISION") division
    , ARRAY_UNIQUE_AGG("BUSINESS CLUSTER") cluster
    , ARRAY_UNIQUE_AGG("SYNAGIE CATEGORY") category

    from DWH.CDM_DATA.CDM__SELLER_CODE_MAPPING
    group by 1
    )
  
  select 
    SELLER_SHORT_CODE
  , ARRAY_TO_STRING(CBDS,', ') as CBDS
  , ARRAY_TO_STRING(wh,', ') wh
  , ARRAY_TO_STRING(cs,', ') cs
  , ARRAY_TO_STRING(company,', ') company
  , ARRAY_TO_STRING(division,', ') division
  , ARRAY_TO_STRING(cluster,', ') cluster
  , ARRAY_TO_STRING(category,', ') category

  from get_unique_value
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
, CBDS, WH, CS, COMPANY, DIVISION, CLUSTER, CATEGORY
  
from raw_data a 
left join get_seller_info b on a.seller_short_code = b.seller_short_code
)
