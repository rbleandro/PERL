truncate table tariff_xref_ratecode;
LOAD into table tariff_xref_ratecode
(
    ratecode '|:|',
    tariff   '\n'
)

from '/opt/sybase/bcp_data/cmf_data/tariff_xref_ratecode_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

