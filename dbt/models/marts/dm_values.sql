{{
    config (
      tags=["moex"],
      materialized='table',
	  engine='MergeTree()',
      order_by=['id']
    )
}}

WITH prev_rest AS (
	SELECT sum(value) AS val_ FROM (
		SELECT 
			operation,
			(SUM(total)*multiIf((operation='coupon' OR operation='dividend' OR operation='pay_in'), toInt8(1), toInt8(-1))) 
				+ (SUM(commission+nkd+tax)*-1) as value
		FROM {{ ref('operations') }}
		WHERE toDate(operation_date) <= (SELECT MAX(prevdate) FROM {{ ref('dm_portfolio') }})
		GROUP BY operation )
), 
current_cost AS (
	SELECT SUM(full_cost) AS val_ FROM {{ ref('dm_portfolio') }}
),
previous_cost AS (
	SELECT SUM(full_previous_cost) AS val_ FROM {{ ref('dm_portfolio') }}
),
current_rest AS (
	SELECT sum(total * if(is_income=0, -1, 1)) AS val_ FROM {{ ref('dm_operations_total') }}
),
current_full AS (
	SELECT r.val_+ c.val_ as val_ FROM current_rest r CROSS JOIN current_cost c
),
previous_full AS (
	SELECT r.val_+ c.val_ as val_ FROM prev_rest r CROSS JOIN previous_cost c
),
change_to_prev AS (
	SELECT f.val_- p.val_ as val_ FROM current_full f CROSS JOIN previous_full p
),
change_to_prev_prc AS (
	SELECT (toFloat64(p.val_)/toFloat64(f.val_))*100 as val_ FROM previous_full f CROSS JOIN change_to_prev p
),
pay_in AS (
	SELECT SUM(total) as val_ FROM {{ ref('operations') }} WHERE operation='pay_in'
),
growth AS (
	SELECT f.val_- p.val_ as val_ FROM current_full f CROSS JOIN pay_in p
),
growth_prc AS (
	SELECT (toFloat64(c.val_-p.val_)/toFloat64(p.val_))*100 as val_ FROM current_full c CROSS JOIN pay_in p
)
SELECT toUInt8(1) AS id, 'Остаток' AS type, ROUND(val_,2) AS val FROM prev_rest
UNION ALL
SELECT toUInt8(2) AS id, 'Тек. стоимость бумаг' AS type, ROUND(val_,2) AS val FROM current_cost
UNION ALL
SELECT toUInt8(3) AS id, 'Остаток пред. дня' AS type, ROUND(val_,2) AS val FROM current_rest
UNION ALL
SELECT toUInt8(4) AS id, 'Пред. стоимость бумаг' AS type, ROUND(val_,2) AS val FROM previous_cost
UNION ALL
SELECT toUInt8(5) AS id, 'Тек. стоимость портфеля' AS type, ROUND(val_,2) AS val FROM current_full
UNION ALL
SELECT toUInt8(6) AS id, 'Пред. стоимость портфеля' AS type, ROUND(val_,2) AS val FROM previous_full
UNION ALL
SELECT toUInt8(7) AS id, 'Прибыль' AS type, ROUND(val_,2) AS val FROM growth
UNION ALL
SELECT toUInt8(8) AS id, 'Изм. за день' AS type, ROUND(val_,2) AS val FROM change_to_prev
UNION ALL
SELECT toUInt8(9) AS id, 'Прибыль, %' AS type, toDecimal32(ROUND(val_,2),2) AS val FROM growth_prc
UNION ALL
SELECT toUInt8(10) AS id, 'Изм. за день, %' AS type, toDecimal32(ROUND(val_,2),2) AS val FROM change_to_prev_prc
