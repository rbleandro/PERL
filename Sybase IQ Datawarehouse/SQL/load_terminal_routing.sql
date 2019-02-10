truncate table terminal_routing;
LOAD into table terminal_routing
(
    orig_term  '|:|',
    dest_term  '|:|',
    thru_term1 '|:|',
    thru_term2 '|:|',
    thru_term3 '|:|',
    thru_term4 '|:|',
    thru_term5 '\n'
)

from '/opt/sybase/bcp_data/cmf_data/terminal_routing_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

