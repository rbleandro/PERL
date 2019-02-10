--truncate table tttl_batchdown;
load into table tttl_batchdown
(
service_type     '|:|',
reference_num    '|:|',
shipper_num      '|:|',
smart_barcode    '|:|',
type             '|:|',
file_datetime    '|:|',
terminal         '|:|',
inserted_on_cons '|:|',
sid		 '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_batchdown_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
