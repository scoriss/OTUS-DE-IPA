WITH datas AS (
	SELECT secid, shortname, sectype_name, sectype_group, full_cost  FROM {{ ref('dm_portfolio') }}
	UNION ALL
	SELECT 'Валюта' AS secid, 'Валюта' AS shortname, 'Валюта' AS sectype_name, 'Валюта' AS sectype_group, val as full_cost FROM {{ ref('dm_values') }} WHERE id=1
)
SELECT * FROM datas