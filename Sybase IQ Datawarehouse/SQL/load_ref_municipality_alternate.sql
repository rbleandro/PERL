truncate table ref_municipality_alternate;
LOAD into table ref_municipality_alternate
(
    record_type    '|:|',
    province_code  '|:|',
    alternate_name '|:|',
    real_name      '|:|',
    type           '|:|',
    allowed        '|:|',
    fsa            '|:|',
    real_province  '|:|',
    spare          '\n'
)
from '/opt/sybase/bcp_data/canada_post/ref_municipality_alternate.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
