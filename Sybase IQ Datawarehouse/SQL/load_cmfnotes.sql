LOAD into table cmfnotes 
(
    customer_num   '|:|',
    note_group     '|:|',
    note_user      '|:|',
    note_date_time '|:|',
    notes          '\n'
)

from '/opt/sybase/bcp_data/cmf_data/cmfnotes_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
