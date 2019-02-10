truncate table cost_term_fix_oh;
LOAD into table cost_term_fix_oh
(
    terminal  '|:|',
    region    '|:|',
    groupcode '|:|',
    corpline  '|:|',
    amount    '\n'
)

from '/opt/sybase/bcp_data/cmf_data/cost_term_fix_oh_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

