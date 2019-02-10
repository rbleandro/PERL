truncate table disp_route;
LOAD into table disp_route
(
    route      '|:|',
    route_desc '|:|',
    region     '|:|',
    terminal   '|:|',
    alt_route  '|:|',
    stops      '|:|',
    pieces     '\n'
)

from '/opt/sybase/bcp_data/cmf_data/disp_route_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

