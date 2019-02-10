LOAD into table cc_approved
(
customer    '|:|',
name        '|:|',
agency      '|:|',
notice      '|:|',
cc_status   '|:|',
cc_date     '|:|',
approved    '|:|',
appdate     '|:|',
appby       '|:|',
collector   '|:|',
comments    '|:|',
pickup_type '|:|',
reason      '|:|',
condreinst  '|:|',
condition   '|:|',
met_cond    '|:|',
other_cond  '||\n'
)

from '/opt/sybase/bcp_data/cmf_data/cc_approved_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
