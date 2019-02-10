LOAD into table account_summary_detail 
( 
FILLER(1),
AccountNumber '","',
BilledDate '","',
ChargeTypeDesc '","',
Charge '","',
GST '","',
HST '","',
OST '","',
QST '","',
TaxOtherProv '","',
TotalAmount '","',
CustomerRefNum '\n' 
)
from '/opt/sybase/tmp/acct_sum_det.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
