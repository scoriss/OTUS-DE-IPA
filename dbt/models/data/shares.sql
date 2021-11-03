{{
    config (
      enabled=True,
      engine='MergeTree()',
      order_by=['load_date','secid'],
      partition_by='toYYYYMM(load_date)'
    )
}}

WITH shares AS (
	SELECT * FROM {{ ref('stg_shares') }}
),
sectype AS (
	SELECT * FROM {{ ref('sectype') }}
),
boards AS (
	SELECT * FROM {{ ref('boards') }}
),
marketdata AS (
	SELECT * FROM {{ ref('stg_shares_marketdata') }}
)
SELECT 
  toDate(now()) AS load_date,
  s.secid AS secid, 
  s.boardid AS boardid, 
  s.shortname AS shortname, 
  s.secname AS secname, 
  s.latname AS latname, 
  s.lotsize AS lotsize, 
  s.decimals AS decimals, 
  s.faceunit AS faceunit, 
  s.issuesize AS issuesize, 
  s.isin AS isin, 
  s.currencyid AS currencyid, 
  s.sectype AS sectype, 
  s.prevprice AS prevprice, 
  s.prevdate AS prevdate,
  t.sectype_name AS sectype_name, 
  t.sectype_group AS sectype_group,
  b.board_title AS board_title, 
  b.market_id AS market_id,
  m.open AS open, 
  m.low AS low, 
  m.high AS high, 
  m.last AS last, 
  m.bid AS bid, 
  m.offer AS offer, 
  m.spread AS spread, 
  m.biddeptht AS biddeptht, 
  m.offerdeptht AS offerdeptht, 
  m.lastchange AS lastchange, 
  m.lastchangeprcnt AS lastchangeprcnt, 
  m.qty AS qty, 
  m.value AS value, 
  m.value_usd AS value_usd, 
  m.numtrades AS numtrades, 
  m.voltoday AS voltoday, 
  m.valtoday AS valtoday, 
  m.valtoday_usd AS valtoday_usd, 
  m.valtoday_rur AS valtoday_rur, 
  m.updatetime AS updatetime, 
  m.lcloseprice AS lcloseprice, 
  m.lcurrentprice AS lcurrentprice, 
  m.systime AS systime, 
  m.issuecapitalization AS issuecapitalization, 
  m.issuecapitalization_updatetime AS issuecapitalization_updatetime
FROM shares s
  INNER JOIN sectype t ON s.sectype=t.sectype
  INNER JOIN boards b ON s.boardid=b.boardid
  INNER JOIN marketdata m ON s.secid=m.secid
