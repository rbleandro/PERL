LOAD into table tttl_rt_return_to_shipper 
(
    rts_reference_num '|:|',
    rts_service_type  '|:|',
    FSA               '|:|',
    reference_num     '|:|',
    service_type      '|:|',
    shipper_num       '|:|',
    inserted_on_cons  '|:|',
    updated_on_cons   '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_rt_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
