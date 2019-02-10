LOAD into table revhstf1_ae
(   linkage        '|:|',
    shipment_id    '|:|',
    rate_code      '|:|',
    rate_alpha     '|:|',
    service_code   '|:|',
    destin_pc      '|:|',
    zone           '|:|',
    shipments      '|:|',
    weight         '|:|',
    pieces         '|:|',
    customer_ref1  '|:|',
    customer_ref2  '|:|',
    base_freight   '|:|',
    discount_flag1 '|:|',
    discount_pct1  '|:|',
    discount_amt1  '|:|',
    net1           '|:|',
    discount_flag2 '|:|',
    discount_pct2  '|:|',
    discount_amt2  '|:|',
    net2           '|:|',
    discount_flag3 '|:|',
    discount_pct3  '|:|',
    discount_amt3  '|:|',
    net_freight    '|:|',
    cwflag         '\n'
)
from '/opt/sybase/bcp_data/rev_hist/revhstf1_ae'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
