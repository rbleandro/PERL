LOAD into table occ_otc_detail 
( 
FILLER(1),
AccountNumber '","',
BilledTelcoNumber '","',
BillingNumber '","', 
NumberBilled '","',
BilledDate '","',
BilledTypeNumber '","',
CustomerReferenceNumber '","',
FromDate '","',
ToDate '","',
Circuit '","',
ChargeType '","',
USOCShortDes '","',
ProductCode '","',
ProductCodeDes '","',
SubProductCode '","',
SubProductCodeDes '","',
Reference_ '","',
Quantity '","',
UnitCost '","',
MonthlyRate '","',
Amount '","',
ServiceCharge '","',
OCCDescription '\n' 
)
from '/opt/sybase/tmp/occ_otc.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
