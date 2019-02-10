truncate table dimweight;
LOAD into table dimweight
(   service_type    '|:|',
    reference_num   '|:|',
    length          '|:|',
    width           '|:|',
    height          '|:|',
    unitlwh         '|:|',
    weight          '|:|',
    unitw           '|:|',
    volume          '|:|',
    unitv           '|:|',
    dim_weight      '|:|',
    factor          '|:|',
    siteid          '|:|',
    rectime         '|:|',
    recdate         '|:|',
    customer_num    '|:|',
    recorded_weight '\n'
)
from '/opt/sybase/bcp_data/rev_hist/dimweight_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
