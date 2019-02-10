truncate table tttl_ma_other;
load into table tttl_ma_other
(
service_type  '|:|',
reference_num '|:|',
shipper_num   '|:|',
manlink       '|:|',
shipment_id   '|:|',
pieceno       '|:|',
type          '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ma_other_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
