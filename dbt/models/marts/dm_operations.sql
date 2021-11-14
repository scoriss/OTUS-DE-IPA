WITH shares_data AS (
	SELECT 
		secid, 
		boardid,
		board_title,
		market_id,
		sectype,
		sectype_name,
		sectype_group, 
		shortname,
		secname, 
		latname
	FROM {{ ref('shares') }}
),
bonds_data AS (
	SELECT 
		secid, 
		boardid,
		board_title,
		market_id,
		sectype,
		sectype_name,
		sectype_group, 
		shortname,
		secname, 
		latname
	FROM {{ ref('bonds') }}
),
securities AS (
	SELECT * FROM shares_data
	UNION ALL
	SELECT * FROM bonds_data
),
operations_date AS (
	SELECT * FROM {{ ref('operations') }}
),
dataset AS (
	SELECT 
		o.operation_date, 
		o.operation, 
		o.operation_name, 
		coalesce(o.secid, CAST('','Nullable(String)')) AS secid, 
		coalesce(s.shortname, CAST('','Nullable(String)')) AS shortname, 
		coalesce(s.secname, CAST('','Nullable(String)')) AS secname, 
		coalesce(s.latname, CAST('','Nullable(String)')) AS latname,
		o.amount, 
		o.price, 
		o.total, 
		o.currency, 
		o.commission, 
		o.nkd, 
		o.tax,
		coalesce(s.boardid, CAST('','Nullable(String)')) AS boardid, 
		coalesce(s.board_title, CAST('','Nullable(String)')) AS board_title, 
		coalesce(s.sectype, CAST('','Nullable(String)')) AS sectype, 
		coalesce(s.sectype_name, CAST('','Nullable(String)')) AS sectype_name, 
		coalesce(s.sectype_group, CAST('','Nullable(String)')) AS sectype_group
	FROM operations_date o
		LEFT JOIN securities s ON o.secid=s.secid
)
SELECT * FROM dataset ORDER BY operation_date