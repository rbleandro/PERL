truncate table srvc_times_ground_pc;
load into table srvc_times_ground_pc
(
terminal  	'|:|',
postal_code     '|:|',
days      	'\n'
)
from '/opt/sybase/bcp_data/cmf_data/srvc_times_ground_pc.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
