LOAD into table rateschd 
(
    rate_code               '|:|',
    association_code        '|:|',
    effective_date          '|:|',
    base_rate_code          '|:|',
    base_rate_alpha         '|:|',
    association_discount    '|:|',
    select_rate_code        '|:|',
    select_rate_alpha       '|:|',
    usa_rate_code           '|:|',
    usa_rate_alpha          '|:|',
    zone_weight_name        '|:|',
    zone_weight_alpha       '|:|',
    declared_value_base     '|:|',
    declared_value_mode     '|:|',
    declared_value_rate     '|:|',
    cod_declared_value_base '|:|',
    cod_declared_value_mode '|:|',
    cod_declared_value_rate '|:|',
    select_discount         '|:|',
    usa_discount            '|:|',
    date_done               '\n'
)

from '/opt/sybase/bcp_data/cmf_data/rateschd_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
