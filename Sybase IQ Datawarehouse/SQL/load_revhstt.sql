truncate table revhstt;
LOAD into table revhstt
(  shipper_num  '|:|',
    tax_type '|:|',
    amount '|:|',
    invoice_num '|:|',
    invoice_date '|:|',
    store_number '\n'   
)
from '/opt/sybase/bcp_data/rev_hist/revhstt_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
