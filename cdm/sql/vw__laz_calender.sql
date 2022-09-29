create or replace view DWH.CDM_DATA.VW__LAZADA_CALENDER_BY_REGION(
	REGION,
	LAZ_QUARTER,
	CALENDER_QUARTER,
	CALENDER_WEEK
) as (
with sg_cal as (
select distinct
  'SG' as region 
  , case 
  when grass_date between date'2022-10-03' and date'2022-12-25' then 4
  when grass_date between date'2022-07-04' and date'2022-09-25' then 3
  end as laz_quarter
  , QUARTER as calender_quarter
  , week as calender_week
  
  from DWH.CDM_DATA.VW_DIM__GRASS_DATE
)
  
, my_cal as (
select distinct
  'MY' as region 
  , case 
  when grass_date between date'2022-10-03' and date'2022-12-25' then 4
  when grass_date between date'2022-07-04' and date'2022-10-02' then 3
  end as laz_quarter
  , QUARTER as calender_quarter
  , week as calender_week

  from DWH.CDM_DATA.VW_DIM__GRASS_DATE  
)  
  
, id_cal as (
select distinct
  'ID' as region 
  , case 
  when grass_date between date'2022-09-26' and date'2023-01-01' then 4
  when grass_date between date'2022-07-04' and date'2022-09-25' then 3
  end as laz_quarter
  , QUARTER as calender_quarter
  , week as calender_week

  from DWH.CDM_DATA.VW_DIM__GRASS_DATE  
)  
  
, th_cal as (
select distinct
  'TH' as region 
  , case 
  when grass_date between date'2022-09-26' and date'2022-12-25' then 4
  when grass_date between date'2022-07-27' and date'2022-09-25' then 3
  end as laz_quarter
  , QUARTER as calender_quarter
  , week as calender_week

  from DWH.CDM_DATA.VW_DIM__GRASS_DATE  
)  
  
  , vn_cal as (
select distinct
  'VN' as region 
  , case 
  when grass_date between date'2022-10-03' and date'2022-12-25' then 4
  when grass_date between date'2022-07-04' and date'2022-10-02' then 3
  end as laz_quarter
  , QUARTER as calender_quarter
  , week as calender_week

  from DWH.CDM_DATA.VW_DIM__GRASS_DATE  
)  

  select *
  from (
            select * from sg_cal
union all   select * from my_cal
union all   select * from id_cal
union all   select * from th_cal
union all   select * from vn_cal
    )
  where laz_quarter is not null
  
  );