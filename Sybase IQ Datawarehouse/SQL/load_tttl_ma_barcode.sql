--truncate table tttl_ma_barcode;
load into table tttl_ma_barcode
(
service_type  '|:|',
reference_num '|:|',
shipper_num   '|:|',
manlink       '|:|',
shipment_id   '|:|',
pieceno       '|:|',
weight        '|:|',
"cube"        '|:|',
cube_length   '|:|',
cube_width    '|:|',
cube_height   '|:|',
COD_amount    '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ma_barcode_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
