truncate table srvc_times_ground;
load into table srvc_times_ground
(
terminal  '|:|',
to_fsa1   '|:|',
to_fsa2   '|:|',
days      '|:|',
select_NG '|:|',
comments  '\n'
)
from '/opt/sybase/bcp_data/cmf_data/srvc_times_ground_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
