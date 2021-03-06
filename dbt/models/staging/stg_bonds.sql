WITH staging as (
	SELECT
		secid, 
		boardid, 
		shortname, 
		secname, 
		latname, 
		yieldatprevwaprice,
		couponvalue, 
		accruedint,
		toDateOrZero(nextcoupon) as nextcoupon_dt, 
		prevprice,
	    lotsize,
		facevalue, 
		toDateOrZero(matdate) as matdate_dt, 
		decimals, 
		couponperiod, 
		issuesize, 
		prevlegalcloseprice, 
		prevadmittedquote, 
		toDateOrZero(prevdate) as prevdate_dt, 
		if(faceunit='SUR', 'RUR', faceunit) as faceunit_cur, 
		buybackprice, 
		toDateOrZero(buybackdate) as buybackdate_dt, 
		if(currencyid='SUR', 'RUR', currencyid) as currencyid_cur, 
		issuesizeplaced, 
		sectype, 
		couponpercent, 
		toDateOrZero(offerdate) as offerdate_dt, 
		toDateOrZero(settledate) as settledate_dt, 
		lotvalue
	FROM {{ source('moex_data', 'src_bonds') }}
)

SELECT
	secid, 
	boardid, 
	shortname, 
	secname, 
	latname, 
	yieldatprevwaprice,
	couponvalue, 
	accruedint,
	nextcoupon_dt as nextcoupon, 
	prevprice,
    lotsize,
	facevalue, 
	matdate_dt as matdate, 
	decimals, 
	couponperiod, 
	issuesize, 
	prevlegalcloseprice, 
	prevadmittedquote, 
	prevdate_dt as prevdate, 
	faceunit_cur as faceunit, 
	buybackprice, 
	buybackdate_dt as buybackdate,
	currencyid_cur as currencyid, 
	issuesizeplaced, 
	sectype, 
	couponpercent, 
	offerdate_dt as offerdate, 
	settledate_dt as settledate, 
	lotvalue
FROM staging
