LOAD into table svp_messages
(
    reference_num    '|:|',
    service_type     '|:|',
    shipper_num      '|:|',
    first_scan_date  '|:|',
    eput_flag        '|:|',
    message_code     '|:|',
    terminal_num     '|:|',
    inserted_on_cons '|:|',
    updated_on_cons  '\n'   
)
from '/opt/sybase/bcp_data/cmf_data/svp_messages_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
