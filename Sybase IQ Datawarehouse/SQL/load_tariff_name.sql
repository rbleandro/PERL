truncate table tariff_name;
LOAD into table tariff_name
(
    tariff      '|:|',
    description '\n'
)

from '/opt/sybase/bcp_data/cmf_data/tariff_name_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

