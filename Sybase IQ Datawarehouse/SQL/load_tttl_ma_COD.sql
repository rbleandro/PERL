truncate table tttl_ma_COD;
load into table tttl_ma_COD
(
manlink         '|:|',
shipment_id     '|:|',
COD_charges     '|:|',
COD_amount      '|:|',
COD_type        '|:|',
COD_cheque_date '\n'
)
from '/opt/sybase/bcp_data/cpscan/tttl_ma_COD_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
