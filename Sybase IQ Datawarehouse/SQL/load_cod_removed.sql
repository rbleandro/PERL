truncate table cod_removed;
LOAD into table cod_removed
(
    cid            ',',
    service_type  ',',
    shipper_num   ',',
    reference_num       ',',
    full_barcode       ',',
    cod_amount     ',',
    removal_reason        ',',
    alt_settlement_barcode         ',',
    removal_datetime '\n'
)

from '/opt/sybase/bcp_data/cod_removed.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
HEADER SKIP 1
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

