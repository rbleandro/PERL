truncate table disp_recno;
LOAD into table disp_recno
(
    rec_no             '\n'
)

from '/opt/sybase/bcp_data/cmf_data/disp_recno_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

