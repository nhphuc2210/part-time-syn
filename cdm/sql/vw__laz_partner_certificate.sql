create or replace view DWH.CDM_DATA.VW__LAZ_PARTNER_CERTIFICATE as (

with point_ne as (
select year, quarter, region, type, QTD_POINT as metric_value
from DWH.CDM_DATA.VW__REGION_QTD_POINT
)

, certificate_target as (
select to_date(start_date,'dd/mm/yyyy') as start_date
, to_date(END_DATE,'dd/mm/yyyy') as END_DATE
, YEAR
, QUARTER
, REGION
, "TOTAL POINTS"
, "QTD GMV"
, "# LAZ MALL"
, CERTIFICATION
from DWH.CDM_DATA.CERTIFICATE_TARGET
)


, raw_transform_certificate_target as (
        select distinct year, quarter, region
              , "TOTAL POINTS" as target_total_point
              , "QTD GMV" as target_qtd_gmv
              , "# LAZ MALL" as target_laz_mall
    
        from certificate_target
)


, transformed_target as (
          select distinct year, quarter, region, 'Target Total Points' as TYPE, target_total_point as metric_value
          from raw_transform_certificate_target
          where target_total_point is not null
union all 
          select distinct year, quarter, region, 'Target QTD GMV' as TYPE, target_qtd_gmv as metric_value
          from raw_transform_certificate_target
          where target_qtd_gmv is not null
union all 
          select distinct year, quarter, region, 'Target # Laz Mall' as TYPE, target_laz_mall as metric_value
          from raw_transform_certificate_target
          where target_laz_mall is not null
)


, raw_data as (
select 
  a.year, b.LAZ_QUARTER
, a.COUNTRY as region
, a.METRICS_MAPPING

, sum(VALUE) as metric_value
from dwh.cdm_data.cdm__weekly_data a 
left join DWH.CDM_DATA.VW__LAZADA_CALENDER_BY_REGION b on a.COUNTRY = b.region and week = CALENDER_WEEK
where true 
    and metrics_mapping in ('Units','GMV (USD)')
group by 1,2,3,4
)


, sales_ne as (
  select year, LAZ_QUARTER as quarter, region, METRICS_MAPPING as type, metric_value
  from raw_data
  )


, consolidated as (
            select year, cast(quarter as int) as quarter, region, type, metric_value from point_ne
union all   select year, cast(quarter as int) as quarter, region, type, metric_value from sales_ne
union all   (select YEAR, cast(quarter as int) as quarter, REGION, 'Total Points' TYPE, sum(METRIC_VALUE) as METRIC_VALUE from point_ne group by 1,2,3,4)  
union all   select year, cast(quarter as int) as quarter, region, type, metric_value from transformed_target
union all   (select year, quarter, region, '# Stores' as type, count(distinct SELLER_SHORT_CODE) metric_value from DWH.CDM_DATA.vw__seller_weekly_data group by 1,2,3,4)  
  )
  

  
  
  select year, cast(quarter as varchar) as quarter, region, type, metric_value
  from consolidated a 

  )
  
  select * from DWH.CDM_DATA.VW__LAZ_PARTNER_CERTIFICATE
  
  
  