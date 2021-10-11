{{
    config (
      engine='MergeTree()',
      order_by='operation_date, operation, secid'
    )
}}

select  
  dt_datetime as operation_date, 
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
from {{ source('initial_data', 'src_ipa_dataset') }}
