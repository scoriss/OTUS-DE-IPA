{{
    config (
      engine='MergeTree()',
      order_by=['operation_date','operation','secid'],
      partition_by='toYYYYMM(operation_date)'
    )
}}

select  
  toDateTime(dt_datetime, 'UTC') as operation_date, 
  operation,
	multiIf(
		operation='pay_in', 'Пополнение', 
		operation='buy', 'Покупка', 
		operation='commission', 'Комиссия', 
		operation='coupon', 'Купон', 
		operation='dividend', 'Дивиденд', 
		'Другое'
	) as operation_name, 		
  secid,
  amount,
  price,
  total,
  currency,
  commission,
  nkd,
  tax
from {{ ref('stg_ipa_dataset') }}
