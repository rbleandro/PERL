truncate table ara_source;
LOAD into table ara_source
(
source_id          '|:|',
source_description '|:|',
flag		   '\n'
)

from '/opt/sybase/bcp_data/cmf_data/ara_source_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

