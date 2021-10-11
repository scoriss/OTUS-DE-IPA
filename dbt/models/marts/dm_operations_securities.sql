WITH sec_main AS (
	SELECT 
		secid, 
		sum(amount) as amount_, 
		round(sum(amount*price),2) as total_buy, 
		round(sum(amount*price)/sum(amount),2) as avg_price, 
		round(sum(commission),2) as commission, 
		round(sum(nkd),2) as nkd  
	FROM {{ ref('operations') }} 
	WHERE operation='buy'
	GROUP BY secid
),
sec_payment AS (
	SELECT 
		secid,
		operation_name as payment_type,
		round(sum(price), 2) as total_payment, 
		round(sum(tax), 2) as tax 
	FROM {{ ref('operations') }}
	WHERE operation in ('dividend', 'coupon')
	GROUP BY secid, payment_type
)
SELECT 
	m.secid, 
	m.amount_ as amount, 
	m.total_buy, 
	m.avg_price, 
	m.commission, 
	m.nkd,
	p.payment_type, 
	p.total_payment, 
	p.tax
FROM sec_main m
	LEFT JOIN sec_payment p  ON m.secid = p.secid



