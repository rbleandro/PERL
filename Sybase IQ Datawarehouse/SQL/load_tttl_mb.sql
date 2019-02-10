truncate table tttl_mb_multiple_barcodes;
LOAD into table tttl_mb_multiple_barcodes 
(
    secondary_reference_num '|:|',
    secondary_service_type  '|:|',
    secondary_shipper_num   '|:|',
    primary_reference_num   '|:|',
    primary_service_type    '|:|',
    primary_shipper_num     '|:|',
    manual_entry_flag       '|:|',
    inserted_on_cons        '|:|',
    updated_on_cons         '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_mb_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
