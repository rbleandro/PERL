truncate table tttl_hv_high_value;
LOAD into table tttl_hv_high_value 
(
    reference_num    '|:|',
    service_type     '|:|',
    shipper_num      '|:|',
    conv_time_date   '|:|',
    employee_num     '|:|',
    inserted_on_cons '|:|',
    updated_on_cons  '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_hv_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
