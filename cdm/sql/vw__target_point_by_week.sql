create or replace view dwh.cdm_data.vw__target_point_by_week as (
with convert_quarter__to_week as (
    select distinct REGION, LAZ_QUARTER, CALENDER_QUARTER, CALENDER_WEEK
    from DWH.CDM_DATA.VW__LAZADA_CALENDER_BY_REGION
  )
  

  select a.year, a.quarter, a.region, a.type, "MAX POINT"
  , a.metrics, a.is_positive, a.excellent_criteria, a.EXCELLENT_POINTS, a.good_criteria, a.GOOD_POINTS, a.poor_point
  , b.CALENDER_WEEK
  , case when is_positive = 1 then EXCELLENT_CRITERIA else 1-EXCELLENT_CRITERIA end as EXCELLENT_CRITERIA_reverse
  , case when is_positive = 1 then GOOD_CRITERIA else 1-GOOD_CRITERIA end as GOOD_CRITERIA_reverse
  , TYPE_OF_METRIC
  from DWH.CDM_DATA.POINT_TARGET a 
  left join convert_quarter__to_week b on a.region = b.region and a.quarter = b.LAZ_QUARTER  
)
