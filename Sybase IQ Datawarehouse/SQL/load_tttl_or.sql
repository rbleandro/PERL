truncate table tttl_or;
LOAD into table tttl_or 
(
    order_num      '|:|',
    order_shipper  '|:|',
    service_type   '|:|',
    reference_num  '|:|',
    shipper_num    '|:|',
    conv_time_date '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_or_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
