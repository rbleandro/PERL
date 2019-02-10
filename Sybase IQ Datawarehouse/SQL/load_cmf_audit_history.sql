truncate table cmf_audit_history;
LOAD into table cmf_audit_history 
( 
  customer                   '|:|',
    change_user                '|:|',
    change_date_time           '|:|',
    file_iD                    '|:|',
    field_iD                   '|:|',
    old_data_value             '|:|',
    new_data_value             '\n'
)
from '/opt/sybase/bcp_data/cmf_data/cmf_audit_history_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
