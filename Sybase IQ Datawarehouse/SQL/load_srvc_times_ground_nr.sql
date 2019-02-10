truncate table srvc_times_ground_nr;
load into table srvc_times_ground_nr
(
terminal  '|:|',
fsa       '|:|',
days      '|:|',
select_NG '|:|',
comments  '\n'
)
from '/opt/sybase/bcp_data/cmf_data/srvc_times_ground_nr.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
