LOAD into table tot_tm
(   
    terminal              '|:|',
    terminal_name         '|:|',
    sales_region          '|:|',
    operating_region      '|:|',
    time_zone_adjustment  '|:|',
    terminal_type         '|:|',
    terminal_function     '|:|',
    address_1             '|:|',
    address_2             '|:|',
    address_3             '|:|',
    city                  '|:|',
    postal_code           '|:|',
    province              '|:|',
    phone_number          '|:|',
    fax_number            '|:|',
    daytime_contact       '|:|',
    evening_contact       '|:|',
    manager               '|:|',
    alternate_terminal    '|:|',
    terminal_abbreviation '|:|',
    interline_allow_pu '\n'

)
from '/opt/sybase/bcp_data/cmf_data/tot_tm.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
