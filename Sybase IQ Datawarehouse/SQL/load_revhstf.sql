truncate table revhstf;
LOAD into table revhstf
(   linkage          '|:|',
    shipment_id      '|:|',
    rate_code        '|:|',
    service_code     '|:|',
    destin_pc        '|:|',
    zone             '|:|',
    shipments        '|:|',
    weight           '|:|',
    pieces           '|:|',
    customer_ref1    '|:|',
    customer_ref2    '|:|',
    discount_flag    '|:|',
    discount_percent '|:|',
    base_freight     '|:|',
    discount_amt     '|:|',
    net_freight      '\n'
)
from '/opt/sybase/bcp_data/rev_hist/revhstf_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0
