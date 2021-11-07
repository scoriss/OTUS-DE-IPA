import requests
import apimoex
import logging

import pandas as pd

from typing import Optional


logger = logging.getLogger("moex_logger")
logger.setLevel(logging.DEBUG)

class MoexIss:

    MOEX_ISS_URL = 'https://iss.moex.com/iss'
    MOEX_OPERATIONS_PARAM = {
        'shares': {'iss.only': 'securities', 'table': 'securities',
            'operation_url': '/engines/stock/markets/shares/boardgroups/57/',
            'table_columns': ('SECID','BOARDID','SHORTNAME','PREVPRICE','LOTSIZE','DECIMALS','SECNAME','FACEUNIT',
                'PREVDATE','ISSUESIZE','ISIN','LATNAME','PREVLEGALCLOSEPRICE','PREVADMITTEDQUOTE','CURRENCYID',
                'SECTYPE','SETTLEDATE')
            },

        'shares_marketdata': {'iss.only': 'marketdata', 'table': 'marketdata',
            'operation_url': '/engines/stock/markets/shares/boardgroups/57/',
            'table_columns': ('SECID', 'BOARDID', 'BID', 'OFFER', 'SPREAD', 'BIDDEPTHT', 'OFFERDEPTHT', 'OPEN', 'LOW',  
                'HIGH', 'LAST', 'LASTCHANGE', 'LASTCHANGEPRCNT', 'QTY', 'VALUE', 'VALUE_USD', 'NUMTRADES', 'VOLTODAY',  
                'VALTODAY', 'VALTODAY_USD', 'ETFSETTLEPRICE', 'UPDATETIME', 'LCLOSEPRICE', 'LCURRENTPRICE', 'SYSTIME', 
                'ISSUECAPITALIZATION', 'ISSUECAPITALIZATION_UPDATETIME', 'VALTODAY_RUR')
            },

        'bonds': {'iss.only': 'securities', 'table': 'securities',
            'operation_url': '/engines/stock/markets/bonds/boardgroups/58/',
            'table_columns': ('SECID', 'SHORTNAME', 'YIELDATPREVWAPRICE', 'COUPONVALUE', 'NEXTCOUPON', 'ACCRUEDINT', 'PREVPRICE', 'LOTSIZE', 
                'FACEVALUE', 'BOARDID', 'MATDATE', 'DECIMALS', 'COUPONPERIOD', 'ISSUESIZE', 'PREVLEGALCLOSEPRICE', 'PREVADMITTEDQUOTE', 
                'PREVDATE', 'SECNAME', 'FACEUNIT', 'BUYBACKPRICE', 'BUYBACKDATE', 'LATNAME', 'ISSUESIZEPLACED', 'SECTYPE', 'COUPONPERCENT', 
                'OFFERDATE', 'SETTLEDATE', 'LOTVALUE')
            },

        'bonds_marketdata': {'iss.only': 'marketdata', 'table': 'marketdata',
            'operation_url': '/engines/stock/markets/bonds/boardgroups/58/',
            'table_columns': ('SECID', 'BID', 'OFFER', 'SPREAD', 'BIDDEPTHT', 'OFFERDEPTHT', 'OPEN', 'LOW', 'HIGH', 'LAST', 
                'LASTCHANGE', 'LASTCHANGEPRCNT', 'QTY', 'VALUE', 'YIELD', 'VALUE_USD', 'YIELDATWAPRICE', 'YIELDTOPREVYIELD', 
                'LASTTOPREVPRICE', 'NUMTRADES', 'VOLTODAY', 'VALTODAY', 'VALTODAY_USD', 'BOARDID', 'UPDATETIME', 
                'DURATION', 'CHANGE', 'SYSTIME', 'VALTODAY_RUR', 'YIELDLASTCOUPON')
            },

        'shares_history': {'iss.only': 'securities,history.cursor', 'table': 'history',
            'operation_url': '/history/engines/stock/markets/shares/securities/',
            'table_columns': ('BOARDID', 'TRADEDATE', 'SHORTNAME', 'SECID', 'OPEN', 'LOW', 'HIGH', 'CLOSE', 
                'VOLUME', 'VALUE', 'NUMTRADES')
            },

        'bonds_history': {'iss.only': 'securities,history.cursor', 'table': 'history',
            'operation_url': '/history/engines/stock/markets/bonds/securities/',
            'table_columns': ('BOARDID', 'TRADEDATE', 'SHORTNAME', 'SECID', 'MATDATE', 'FACEVALUE', 'VOLUME', 'VALUE', 
                'NUMTRADES', 'OPEN', 'LOW', 'HIGH', 'CLOSE', 'YIELDATWAP', 'ACCINT', 'DURATION', 'COUPONPERCENT', 
                'COUPONVALUE', 'FACEUNIT')
            }

    }

    def __init__(self):
        self.__session = requests.Session()
        self.headers = {'Content-Type': 'application/json; charset=utf-8'}
        self.request_url = None
        self.arguments = None
        self.type_operation = None

    def set_request_parameters(self, type_operation: str, secid: Optional[str] = None) -> None:
        self.type_operation = type_operation
        if secid:
            self.request_url = (MoexIss.MOEX_ISS_URL + MoexIss.MOEX_OPERATIONS_PARAM[type_operation]['operation_url'] + secid.upper() + '.json')
        else:
            self.request_url = (MoexIss.MOEX_ISS_URL + MoexIss.MOEX_OPERATIONS_PARAM[type_operation]['operation_url'] + 'securities.json')

        self.arguments = {'iss.only': MoexIss.MOEX_OPERATIONS_PARAM[type_operation]['iss.only']}
        if len(MoexIss.MOEX_OPERATIONS_PARAM[type_operation]['table_columns']) > 0:
            self.arguments[MoexIss.MOEX_OPERATIONS_PARAM[type_operation]['table'] + '.columns'] = ",".join(MoexIss.MOEX_OPERATIONS_PARAM[type_operation]['table_columns'])
        
        logging.debug('request_url: ' + str(self.request_url)) 
        logging.debug('arguments: ' + str(self.arguments)) 

    def get_request(self) -> pd.DataFrame:
        data = {}
        with self.__session as session:
            try:
                iss = apimoex.ISSClient(session, self.request_url, self.arguments)
                data = iss.get()
            except apimoex.client.ISSMoexError as error:
                logging.warning(error)  
            finally:
                if MoexIss.MOEX_OPERATIONS_PARAM[self.type_operation]['table'] in data:
                    df_moex = pd.DataFrame(data[MoexIss.MOEX_OPERATIONS_PARAM[self.type_operation]['table']])
                else:
                    df_moex = pd.DataFrame(columns = MoexIss.MOEX_OPERATIONS_PARAM[self.type_operation]['table_columns'])

            df_moex.columns = df_moex.columns.str.lower()

            for col in df_moex.columns:
                if (pd.api.types.is_string_dtype(df_moex[col])):
                    df_moex[col] = df_moex[col].fillna("")
                    df_moex[col] = df_moex[col].replace({'\"': ""}, regex=True)
                elif (pd.api.types.is_numeric_dtype(df_moex[col])):
                    df_moex[col] = df_moex[col].fillna(0)

        return df_moex


    def get_shares(self) -> pd.DataFrame:
        self.set_request_parameters('shares')
        return self.get_request()

    def get_shares_marketdata(self) -> pd.DataFrame:
        self.set_request_parameters('shares_marketdata')
        return self.get_request()

    def get_bonds(self) -> pd.DataFrame:
        self.set_request_parameters('bonds')
        return self.get_request()

    def get_bonds_marketdata(self) -> pd.DataFrame:
        self.set_request_parameters('bonds_marketdata')
        return self.get_request()

