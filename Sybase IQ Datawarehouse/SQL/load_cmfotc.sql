truncate table cmfotc;
LOAD into table cmfotc 
(
    customer_num '|:|',
    city         '|:|',
    postal_zip   '|:|',
    notes        '||\n'
)

from '/opt/sybase/bcp_data/cmf_data/cmfotc_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
