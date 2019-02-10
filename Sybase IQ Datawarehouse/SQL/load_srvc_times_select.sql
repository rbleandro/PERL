truncate table srvc_times_select;
load into table srvc_times_select
(
    from_fsa_low  '|:|',
    from_fsa_high '|:|',
    to_fsa_low    '|:|',
    to_fsa_high   '|:|',
    deliver_days  '\n'
)
from '/opt/sybase/bcp_data/cmf_data/srvc_times_select_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
