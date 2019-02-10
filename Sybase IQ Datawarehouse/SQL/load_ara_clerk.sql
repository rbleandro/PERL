truncate table ara_clerk;
LOAD into table ara_clerk
(
clerk_id       '|:|',
clerk_name     '|:|',
security_level '\n'
)

from '/opt/sybase/bcp_data/cmf_data/ara_clerk_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

