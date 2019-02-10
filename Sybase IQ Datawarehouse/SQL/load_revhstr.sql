truncate table revhstr;
LOAD into table revhstr
(   linkage     '|:|',
    shipment_id '|:|',
    DV_charges  '|:|',
    DV_amt      '|:|',
    COD_charges '|:|',
    COD_amt     '|:|',
    PUT_charges '|:|',
    XC_charges  '|:|',
    EA_charges  '|:|',
    EA_level    '\n'
)
from '/opt/sybase/bcp_data/rev_hist/revhstr_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0
