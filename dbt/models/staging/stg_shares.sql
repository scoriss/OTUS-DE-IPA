WITH staging as (
	SELECT
		secid, 
		boardid, 
		shortname,
		secname,
		latname,
		lotsize, 
		decimals, 
		faceunit, 
		if(faceunit='SUR', 'RUR', faceunit) as faceunit_cur, 
		issuesize, 
		isin,
		currencyid, 
		if(currencyid='SUR', 'RUR', currencyid) as currencyid_cur, 
		sectype,
		prevprice,
		prevdate,
		toDateOrNull(prevdate) as prevdate_dt 

	FROM {{ source('moex_data', 'src_shares') }}
)

SELECT
	secid, 
	boardid, 
	shortname,
	secname,
	latname,
	lotsize, 
	decimals, 
	faceunit_cur as faceunit, 
	issuesize, 
	isin,
	currencyid_cur as currencyid,
	sectype,
	prevprice, 
	prevdate_dt as prevdate
FROM staging
