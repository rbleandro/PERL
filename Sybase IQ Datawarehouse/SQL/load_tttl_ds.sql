LOAD into table tttl_drop_shipper
(
    shipper_num     '|:|',
    added_date_time '|:|',
    added_by        '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ds_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
