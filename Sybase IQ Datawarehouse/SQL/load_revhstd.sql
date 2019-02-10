truncate table revhstd;
LOAD into table revhstd
(   shipper_num  '|:|',
    discount_amt '|:|',
    invoice_date '|:|',
    invoice_num  '|:|',
    discount_pct '\n'
)
from '/opt/sybase/bcp_data/rev_hist/revhstd_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
