create or replace view dwh.cdm_data.vw__sales_seller_weekly_data as (
with raw_data as (
select 
  YEAR, WEEK, COUNTRY AS REGION, "SELLER NAME" AS SELLER_NAME , "SELLER SHORT CODE" AS SELLER_SHORT_CODE
,   SUM(CASE WHEN METRICS_MAPPING = 'Units' then value end) as units
,   sum(case when METRICS_MAPPING = 'GMV (USD)' then value end ) as GMV_USD 
  
from DWH.CDM_DATA.CDM__WEEKLY_DATA
where METRICS_MAPPING in ('Units','GMV (USD)')
group by 1,2,3,4,5
)

select b.*, a.units, a.gmv_usd, YEAR, WEEk
from raw_data a 
left join DWH.CDM_DATA.VW__SELLER_INFO b on a.region = b.region and a.SELLER_SHORT_CODE = b.SELLER_SHORT_CODE
  )