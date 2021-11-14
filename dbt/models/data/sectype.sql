{{
    config (
      engine='MergeTree()',
      order_by='sectype'
    )
}}

SELECT 
	sectype, 
	toLowCardinality(sectype_name) AS sectype_name,
	toLowCardinality(multiIf(
		(sectype in ('1', '2', 'D')), 'Акции', 
		(sectype in ('3', '4', '5', '6', '7', '8', 'C')), 'Облигации', 
		(sectype in ('9', 'A', 'B')), 'ПАИ', 
		(sectype in ('J', 'E')), 'Фонды', 
		sectype='F', 'Ипотечный сертификат', 
		'Другое')) as sectype_group 
FROM {{ ref('stg_sectype') }}
