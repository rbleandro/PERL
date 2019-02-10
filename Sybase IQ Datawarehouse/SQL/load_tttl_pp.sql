LOAD into table tttl_pp 
(
    pod_request_num '|:|',
    reference_num   '|:|',
    service_type    '|:|',
    shipper_num     '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_pp_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
