truncate table disp_cust;
LOAD into table disp_cust
(
    customer        '|:|',
    pu_route        '|:|',
    pu_time         '|:|',
    cl_time         '|:|',
    pu_loc          '|:|',
    pu_pcs          '|:|',
    trailer_route   '|:|',
    trailer_pu_time '|:|',
    trailer_cl_time '|:|',
    trailer_pu_loc  '|:|',
    trailer_pu_pcs '\n'
)

from '/opt/sybase/bcp_data/cmf_data/disp_cust_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

