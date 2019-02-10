truncate table ara_number;
LOAD into table ara_number
(
ara_number	'\n'
)

from '/opt/sybase/bcp_data/cmf_data/ara_number_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

