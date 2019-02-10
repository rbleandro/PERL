truncate table winnipeg_cods;
LOAD into table winnipeg_cods 
(
    Waybill   ',',
    Release_date     ',',
    Amount          '\n'
)
from '/opt/sybase/tmp/winnipeg_cods.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
