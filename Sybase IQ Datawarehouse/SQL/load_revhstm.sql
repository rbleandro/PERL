truncate table revhstm;
LOAD into table revhstm
(   shipper_num  '|:|',
    rev_reference    '|:|',
    rev_type         '|:|',
    entry_date   '|:|',
    amount       '|:|',
    invoice_date '|:|',
    invoice      '|:|',
    doc_date     '|:|',
    fuel_surch_pct '\n'
)
from '/opt/sybase/bcp_data/rev_hist/revhstm_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
