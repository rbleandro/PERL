LOAD into TABLE cmfaudit 
(
    customer_num     '|:|',
    change_user      '|:|',
    change_date_time '|:|',
    file_id          '|:|',
    field_id         '|:|',
    old_data_value   '|:|',
    new_data_value   '\n'
)

from '/opt/sybase/bcp_data/cmf_data/cmfaudit_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
