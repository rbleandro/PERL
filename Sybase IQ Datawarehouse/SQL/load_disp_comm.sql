set option LOAD_MEMORY_MB = 300;
truncate table disp_comm;
LOAD into table disp_comm
(
    rec_no   '|:|',
    comments '||\n'
)

from '/opt/sybase/bcp_data/cmf_data/disp_comm_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

