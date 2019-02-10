truncate table phone_statistics;
LOAD into table phone_statistics 
(   ID          '|:|',
    Trunk       '|:|',
    Extention   '|:|',
    ID2         '|:|',
    Date_Time   '|:|',
    Duration    '|:|',
    Dialed      '|:|',
    TimeOnPhone '\n'
)
from '/opt/sybase/bcp_data/cmf_data/phone_statistics_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0
