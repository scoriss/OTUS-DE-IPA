WITH comm_nkd_tax as (
	SELECT 'commission' as operation, toUInt8(0) as is_income, sum(commission) as total FROM {{ ref('operations') }}
	UNION ALL
	SELECT 'nkd' as operation, toUInt8(0) as is_income, sum(nkd) as total FROM {{ ref('operations') }}
	UNION ALL
	SELECT 'tax' as operation, toUInt8(0) as is_income, sum(tax) as total FROM {{ ref('operations') }}
),
main_operations as (
	SELECT 
		operation, 
		multiIf((operation='coupon' OR operation='dividend' OR operation='pay_in'), toUInt8(1), toUInt8(0)) as is_income, 		
		SUM(total) as total FROM {{ ref('operations') }}
	GROUP BY operation
),
all_operations as (
	SELECT * FROM main_operations
	UNION ALL
	SELECT * FROM comm_nkd_tax
)
SELECT
	operation, 
	multiIf(
		operation='pay_in', 'Пополнение', 
		operation='buy', 'Покупка', 
		operation='commission', 'Комиссия', 
		operation='coupon', 'Купон', 
		operation='dividend', 'Дивиденд', 
		operation='nkd', 'НКД', 
		operation='tax', 'Налог',
		'Другое'
	) as operation_name, 		
	is_income,
	if(is_income=1, 'Доход', 'Расход') as is_income_name,  
	total
FROM all_operations