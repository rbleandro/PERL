truncate table disp_users;
LOAD into table disp_users
(
    userid    '|:|',
    region    '|:|',
    msgs      '|:|',
    run_sheet '|:|',
    edit_runs '|:|',
    routes    '|:|',
    reports   '\n'
)

from '/opt/sybase/bcp_data/cmf_data/disp_users_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

