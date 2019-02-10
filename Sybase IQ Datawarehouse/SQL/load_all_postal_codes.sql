truncate table all_postal_codes;
LOAD into table all_postal_codes
(  postal_code   '|:|', 
    major_city   '|:|',   
    minor_city     '|:|',
    province_code   '|:|',
    valid           '|:|',
    served          '|:|',
    terminal        '|:|',
    interline       '|:|',
    delay           '|:|',
    service         '|:|',
    week1           '|:|',
    week2           '|:|',
    additional_days '|:|',
    sort_terminal   '\n'  
  )
from '/opt/sybase/bcp_data/canada_post/all_postal_codes.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
