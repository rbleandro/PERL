LOAD into TABLE pts_served 
(
    terminal       '|:|',
    interline      '|:|',
    city           '|:|',
    delay          '|:|',
    service        '|:|',
    week1          '|:|',
    week2          '|:|',
    postal_code    '|:|',
    additional_day '|:|',
    sent_terminal  '\n'
)

from '/opt/sybase/bcp_data/cmf_data/pts_served_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
