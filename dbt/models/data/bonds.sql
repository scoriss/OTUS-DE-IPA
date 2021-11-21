{{
    config (
      enabled=True,
      tags=["moex"],
      engine='MergeTree()',
      order_by=['load_date','secid'],
      partition_by='toYYYYMM(load_date)'
    )
}}

WITH bonds AS (
	SELECT * FROM {{ ref('stg_bonds') }}
),
sectype AS (
	SELECT * FROM {{ ref('sectype') }}
),
boards AS (
	SELECT * FROM {{ ref('boards') }}
),
marketdata AS (
	SELECT * FROM {{ ref('stg_bonds_marketdata') }}
)
SELECT 
  toDate(now()) AS load_date,
  s.secid AS secid, 
  s.boardid AS boardid, 
  s.shortname AS shortname, 
  s.secname AS secname, 
  s.latname AS latname, 
  s.yieldatprevwaprice AS yieldatprevwaprice, 
  s.couponvalue AS couponvalue, 
  s.accruedint AS accruedint, 
  s.nextcoupon AS nextcoupon, 
  s.prevprice AS prevprice, 
  s.lotsize AS lotsize, 
  s.facevalue AS facevalue,
 	s.currencyid as currencyid, 
  s.matdate AS matdate, 
  s.decimals AS decimals, 
  s.couponperiod AS couponperiod, 
  s.issuesize AS issuesize, 
  s.prevlegalcloseprice AS prevlegalcloseprice, 
  s.prevadmittedquote AS prevadmittedquote, 
  s.prevdate AS prevdate,
  s.faceunit AS faceunit, 
  s.buybackprice AS buybackprice, 
  s.buybackdate AS buybackdate, 
  s.issuesizeplaced AS issuesizeplaced, 
  s.sectype AS sectype, 
  s.couponpercent AS couponpercent, 
  s.offerdate AS offerdate, 
  s.settledate AS settledate, 
  s.lotvalue AS lotvalue,
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
  m.yield AS yield, 
  m.yieldatwaprice AS yieldatwaprice, 
  m.yieldtoprevyield AS yieldtoprevyield, 
  m.lasttoprevprice AS lasttoprevprice, 
  m.numtrades AS numtrades, 
  m.voltoday AS voltoday,
  m.valtoday AS valtoday, 
  m.valtoday_usd AS valtoday_usd, 
  m.valtoday_rur AS valtoday_rur, 
  toDateTime(m.updatetime, 'UTC') AS updatetime, 
  m.duration AS duration, 
  m.change AS change, 
  toDateTime(m.systime, 'UTC') AS systime, 
  m.yieldlastcoupon AS yieldlastcoupon
FROM bonds s
  INNER JOIN sectype t ON s.sectype=t.sectype
  INNER JOIN boards b ON s.boardid=b.boardid
  INNER JOIN marketdata m ON s.secid=m.secid
