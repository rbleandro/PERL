truncate table dsshipment_orig;
LOAD into table dsshipment_orig
(
    documentID        '|:|',
    shipper_num       '|:|',
    service_code      '|:|',
    pieces            '|:|',
    weight            '|:|',
    postal_code       '|:|',
    document_date     '|:|',
    COD_amount        '|:|',
    DV_amount         '|:|',
    XC_pieces         '|:|',
    barcode_count     '|:|',
    value_in_COD_flag '|:|',
    value_in_DV_flag  '|:|',
    value_in_XC_flag  '|:|',
    PUT_flag          '|:|',
    error_flag        '|:|',
    scanner_time_date '|:|',
    scannerID         '|:|',
    extracted_to_sortation         '|:|',
    billed_flag       '|:|',
    store             '|:|',
    weight_type       '\n'
)
from '/opt/sybase/bcp_data/rev_hist/dsshipment_orig_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

