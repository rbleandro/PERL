truncate table ara_purs;
LOAD into table ara_purs
(
customer      '|:|',
ara_number    '|:|',
pur_number    '|:|',
pur_date      '|:|',
pur_amount    '|:|',
rebill_number '\n'
)

from '/opt/sybase/bcp_data/cmf_data/ara_purs_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

