truncate table cost_master;
LOAD into table cost_master 
(
"sample" '|:|',
"comments" '|:|\n'
)

from '/opt/sybase/bcp_data/cmf_data/cost_master.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
