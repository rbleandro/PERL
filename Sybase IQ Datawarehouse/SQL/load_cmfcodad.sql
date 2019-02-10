LOAD into table cmfcodad 
(
    customer_num   '|:|',
    cod_name       '|:|',
    cod_address_1  '|:|',
    cod_address_2  '|:|',
    cod_city       '|:|',
    cod_province   '|:|',
    cod_postal_zip '\n'
)

from '/opt/sybase/bcp_data/cmf_data/cmfcodad_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
