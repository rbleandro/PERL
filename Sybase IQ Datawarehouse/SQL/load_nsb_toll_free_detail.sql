LOAD into table nsb_toll_free_detail 
( 
FILLER(1),
AccountNumber '","',
BilledTelcoNumber '","',
BillingNumber '","', 
NumberBilled '","',
BilledDate '","',
BTNServiceType '","',
OriginAreaCode '","',
OriginPrefix '","',
OriginCity '","',
OriginProvince '","',
ProductCodeDes '","',
SubProductCodeDes '","',
IncompleteCalls '","',
CompletedCalls '","',
CompletedMinutes '","',
AmountBilled '","',
CustomerReferenceNumber '\n' 
)
from '/opt/sybase/tmp/nsb_detail.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
