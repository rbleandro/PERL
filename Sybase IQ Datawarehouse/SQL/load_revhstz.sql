LOAD into table revhstz
(   linkage          '|:|',
    shipment_id      '|:|',
    zone_16912	     '|:|',
    rate_16912       '\n'
)
from '/opt/sybase/bcp_data/rev_hist/revhstz_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
