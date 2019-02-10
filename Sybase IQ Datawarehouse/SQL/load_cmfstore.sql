LOAD into table cmfstore 
(
    bill_to_number   '|:|',
    customer_num     '|:|',
    store_number     '|:|',
    store_name       '|:|',
    store_postal_zip '\n'
)

from '/opt/sybase/bcp_data/cmf_data/cmfstore_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
