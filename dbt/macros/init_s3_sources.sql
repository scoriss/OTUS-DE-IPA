{% macro init_s3_sources() -%}
    -- execution initial commands in sequence in target.schema
    -- Table src_sectype
    {% set sql %}
        DROP TABLE IF EXISTS {{ target.schema }}.src_sectype    
    {% endset %}
    {% set table = run_query(sql) %}

    {% set sql %}
        CREATE TABLE {{ target.schema }}.src_sectype (
            sectype         LowCardinality(String),
            sectype_name    String
        )
        ENGINE = S3('https://storage.yandexcloud.net/{{ env_var('S3_BUCKET') }}/data/sectype.tsv', 'TabSeparatedWithNames')
    {% endset %}
    {% set table = run_query(sql) %}

    -- Table src_boards
    {% set sql %}
        DROP TABLE IF EXISTS {{ target.schema }}.src_boards    
    {% endset %}
    {% set table = run_query(sql) %}

    {% set sql %}
        CREATE TABLE {{ target.schema }}.src_boards (
            id           			UInt16,
            boardid              	LowCardinality(String),
            board_title             String,
            board_group_id          UInt8,
            market_id            	UInt8,
            is_traded        		UInt8
    	)
        ENGINE = S3('https://storage.yandexcloud.net/{{ env_var('S3_BUCKET') }}/data/boards.tsv', 'TabSeparatedWithNames')
    {% endset %}
    {% set table = run_query(sql) %}


    -- Table src_ipa_dataset
    {% set sql %}
        DROP TABLE IF EXISTS {{ target.schema }}.src_ipa_dataset    
    {% endset %}
    {% set table = run_query(sql) %}

    {% set sql %}
        CREATE TABLE {{ target.schema }}.src_ipa_dataset (
            dt_datetime     DateTime,
            operation       LowCardinality(String),        
            secid           LowCardinality(String),        
            sec_name        String,        
            amount          UInt32,       
            price           Decimal(18,6),
            total           Decimal(18,6),       
            currency   		FixedString(3),       
            commission      Decimal(18,2),       
            nkd         	Decimal(18,2),       
            tax         	Decimal(18,2)           
        )
        ENGINE = S3('https://storage.yandexcloud.net/{{ env_var('S3_BUCKET') }}/data/ipa_dataset.tsv', 'TabSeparatedWithNames')
    {% endset %}
    {% set table = run_query(sql) %}

    -- MOEX Data - Tables -----------------------------------------------------------------------------------

    -- Table src_shares
    {% set sql %}
        DROP TABLE IF EXISTS {{ target.schema }}.src_shares    
    {% endset %}
    {% set table = run_query(sql) %}

    {% set sql %}
        CREATE TABLE {{ target.schema }}.src_shares (
            secid     			String,
            boardid       		LowCardinality(String),        
            shortname           String,        
            prevprice        	Decimal(18,6),        
            lotsize        		UInt16,        
            decimals 			UInt16,
            secname   			String,       
            faceunit        	LowCardinality(String),        
            prevdate 			String,
            issuesize			UInt32,       
            isin   				String,       
            latname   			String,       
            prevlegalcloseprice Decimal(18,6),       
            prevadmittedquote   Decimal(18,6),
            currencyid   		LowCardinality(String),       
            sectype        		LowCardinality(String),
            settledate        	String
        )
        ENGINE = S3('https://storage.yandexcloud.net/{{ env_var('S3_BUCKET') }}/moex-data/current/shares/shares.tsv', 'TSVWithNames')
    {% endset %}
    {% set table = run_query(sql) %}


    -- Table src_shares_marketdata
    {% set sql %}
        DROP TABLE IF EXISTS {{ target.schema }}.src_shares_marketdata    
    {% endset %}
    {% set table = run_query(sql) %}

    {% set sql %}
        CREATE TABLE {{ target.schema }}.src_shares_marketdata (
            secid     						String,
            boardid     					LowCardinality(String),
            bid     						Decimal(18,6),
            offer     						Decimal(18,6),
            spread     						Decimal(18,6),
            biddeptht     					UInt32,
            offerdeptht     				UInt32,
            open     						Decimal(18,6),
            low     						Decimal(18,6),
            high     						Decimal(18,6),
            last     						Decimal(18,6),
            lastchange     					Decimal(18,6),
            lastchangeprcnt     			Decimal(18,6),
            qty     						UInt32,
            value     						Decimal(18,6),
            value_usd     					Decimal(18,6),
            numtrades     					UInt32,
            voltoday     					UInt64,
            valtoday     					UInt64,
            valtoday_usd     				UInt64,
            etfsettleprice     				Decimal(18,6),
            updatetime     					String,
            lcloseprice     				Decimal(18,6),
            lcurrentprice     				Decimal(18,6),
            systime     					String,
            issuecapitalization     		Float64,
            issuecapitalization_updatetime  String,
            valtoday_rur     				UInt64
        )
        ENGINE = S3('https://storage.yandexcloud.net/{{ env_var('S3_BUCKET') }}/moex-data/current/shares/shares_marketdata.tsv', 'TabSeparatedWithNames')
    {% endset %}
    {% set table = run_query(sql) %}

    -- Table src_bonds
    {% set sql %}
        DROP TABLE IF EXISTS {{ target.schema }}.src_bonds    
    {% endset %}
    {% set table = run_query(sql) %}

    {% set sql %}
        CREATE TABLE {{ target.schema }}.src_bonds (
            secid     				String,
            shortname     			String,
            yieldatprevwaprice      Decimal(9,2),
            couponvalue     		Decimal(9,2),
            nextcoupon     			String,
            accruedint     			Decimal(9,2),
            prevprice               Decimal(18,6),
            lotsize                 UInt16,
            facevalue     			Decimal(18,2),
            boardid     			LowCardinality(String),
            matdate     			String,
            decimals     			UInt16,
            couponperiod     		UInt16,
            issuesize     			UInt64,
            prevlegalcloseprice     Decimal(18,6),
            prevadmittedquote     	Decimal(18,6),
            prevdate     			String,
            secname     			String,
            faceunit     			LowCardinality(String),
            buybackprice     		Decimal(9,2),
            buybackdate     		String,
            latname     			String,
            currencyid              LowCardinality(String),
            issuesizeplaced     	Float64,
            sectype     			LowCardinality(String),
            couponpercent     		Decimal(9,2),
            offerdate     			String,
            settledate     			String,
	        lotvalue     			Decimal(18,2)
        )
        ENGINE = S3('https://storage.yandexcloud.net/{{ env_var('S3_BUCKET') }}/moex-data/current/bonds/bonds.tsv', 'TabSeparatedWithNames')
    {% endset %}
    {% set table = run_query(sql) %}

    -- Table src_bonds_marketdata
    {% set sql %}
        DROP TABLE IF EXISTS {{ target.schema }}.src_bonds_marketdata    
    {% endset %}
    {% set table = run_query(sql) %}

    {% set sql %}
        CREATE TABLE {{ target.schema }}.src_bonds_marketdata (
            secid     				String,
            bid     				Decimal(18,6),
            offer     				Decimal(18,6),
            spread     				Decimal(18,6),
            biddeptht     			UInt32,
            offerdeptht     		UInt32,
            open     				Decimal(18,6),
            low     				Decimal(18,6),
            high     				Decimal(18,6),
            last     				Decimal(18,6),
            lastchange     			Decimal(18,6),
            lastchangeprcnt     	Decimal(18,6),
            qty     				UInt32,
            value     				Decimal(18,6),
            yield                   Decimal(9,2),
            value_usd     			Decimal(18,6),
            yieldatwaprice     		Decimal(9,2),
            yieldtoprevyield     	Decimal(9,2),
            lasttoprevprice     	Decimal(18,6),
            numtrades     			UInt32,
            voltoday     			UInt64,
            valtoday     			UInt64,
            valtoday_usd     		UInt64,
            boardid     			LowCardinality(String),
            updatetime     			String,
            duration     			UInt32,
            change     				Decimal(9,2),
            systime     			String,
            valtoday_rur     		UInt32,
            yieldlastcoupon     	Decimal(9,2)
        )
        ENGINE = S3('https://storage.yandexcloud.net/{{ env_var('S3_BUCKET') }}/moex-data/current/bonds/bonds_marketdata.tsv', 'TabSeparatedWithNames')
    {% endset %}
    {% set table = run_query(sql) %}

{%- endmacro %}