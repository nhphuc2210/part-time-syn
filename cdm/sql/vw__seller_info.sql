create or replace view dwh.cdm_data.vw__seller_info as (
  
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
      , ARRAY_UNIQUE_AGG("COUNTRY") region

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
    , substring(SELLER_SHORT_CODE,1,2) as region
  
    from get_unique_value
    where seller_short_code is not null or seller_short_code <> ''
)