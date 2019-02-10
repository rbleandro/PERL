LOAD into table cmforv01 
(
    customer_num      '|:|',
    fuel_surcharge_1  '|:|',
    fuel_surcharge_2  '|:|',
    fuel_surcharge_3  '|:|',
    fuel_surcharge_4  '|:|',
    fuel_surcharge_5  '|:|',
    fuel_surcharge_6  '|:|',
    fuel_surcharge_7  '|:|',
    fuel_surcharge_8  '|:|',
    fuel_surcharge_9  '|:|',
    fuel_surcharge_10 '|:|',
    fuel_surcharge_11 '|:|',
    fuel_surcharge_12 '|:|',
    fuel_surcharge_13 '\n'
)

from '/opt/sybase/bcp_data/cmf_data/cmforv01_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
