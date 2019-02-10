truncate table revhstd1;
LOAD into table revhstd1
(   shipper_num      '|:|',
    inv_discount_amt '|:|',
    ytd_discount_amt '|:|',
    invoice_date     '|:|',
    invoice_num      '|:|',
    discount_pct     '\n'
)
from '/opt/sybase/bcp_data/rev_hist/revhstd1_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
