truncate table ara_cause;
LOAD into table ara_cause
(
cause_id            '|:|',
cause_description_E '|:|',
cause_description_F '|:|',
flag		    '\n'
)

from '/opt/sybase/bcp_data/cmf_data/ara_cause_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

