truncate table ara_action;
LOAD into table ara_action
(
action_id          '|:|',
action_description '|:|',
flag		   '\n'
)

from '/opt/sybase/bcp_data/cmf_data/ara_action_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

