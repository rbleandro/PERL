truncate table tttl_us;
LOAD into table tttl_us 
(
    shipper_num      '|:|',
    service_type     '|:|',
    reference_num    '|:|',
    bc_shipper_num   '|:|',
    conv_time_date   '|:|',
    inserted_on_cons '|:|',
    updated_on_cons  '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_us_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
