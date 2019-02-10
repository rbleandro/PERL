LOAD into table cmfbilto 
(
    customer_num      '|:|',
    billto_name       '|:|',
    billto_address_1  '|:|',
    billto_address_2  '|:|',
    billto_city       '|:|',
    billto_province   '|:|',
    billto_postal_zip '\n'
)

from '/opt/sybase/bcp_data/cmf_data/cmfbilto_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
