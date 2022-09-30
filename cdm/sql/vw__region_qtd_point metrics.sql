create or replace view DWH.CDM_DATA.VW__REGION_QTD_POINT_METRICS as (

with
raw_data as (
select 
year, quarter,region
, metrics_mapping
, type_of_metric
, TYPE
, "MAX POINT"

, avg(avg_value) as avg_value
, avg(AVG_VALUE_REVERSE) as AVG_VALUE_REVERSE
, min(EXCELLENT_CRITERIA_reverse) as EXCELLENT_CRITERIA_reverse
, min(GOOD_CRITERIA_reverse) as GOOD_CRITERIA_reverse
, min(EXCELLENT_POINTS) as EXCELLENT_POINTS
, min(GOOD_POINTS) as GOOD_POINTS
, min(POOR_POINT) as POOR_POINT

from DWH.CDM_DATA.vw__region__weekly_data
group by 1,2,3,4,5,6,7
)

select a.*
, ZEROIFNULL(
  case  when AVG_VALUE_REVERSE >= EXCELLENT_CRITERIA_reverse then EXCELLENT_POINTS
        when AVG_VALUE_REVERSE >= GOOD_CRITERIA_reverse then GOOD_POINTS
        else POOR_POINT end
    ) as get_point__quater
,
  case  when AVG_VALUE_REVERSE >= EXCELLENT_CRITERIA_reverse then 'Excellent'
        when AVG_VALUE_REVERSE >= GOOD_CRITERIA_reverse then 'Good'
        else 'Poor' end
    as ranking
, concat(year,quarter, region,metrics_mapping) as _year_quarter_region_metrics
from raw_data a 

)