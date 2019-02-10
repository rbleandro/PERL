truncate table dsshipment_trail;
LOAD into table dsshipment_trail
(  
    acting_user       '|:|' ,
    action_date       '|:|' ,
    action            '|:|' ,
    ins_documentID        '|:|',
    ins_shipper_num       '|:|',
    ins_service_code      '|:|',
    ins_pieces            '|:|',
    ins_weight            '|:|',
    ins_postal_code       '|:|',
    ins_document_date     '|:|',
    ins_COD_amount        '|:|',
    ins_DV_amount         '|:|',
    ins_XC_pieces         '|:|',
    ins_barcode_count     '|:|',
    ins_value_in_COD_flag '|:|',
    ins_value_in_DV_flag  '|:|',
    ins_value_in_XC_flag  '|:|',
    ins_PUT_flag          '|:|',
    ins_error_flag        '|:|',
    ins_scanner_time_date '|:|',
    ins_scannerID         '|:|',
    ins_extracted_to_sortation         '|:|',
    ins_billed_flag       '|:|',
    ins_store             '|:|',
    ins_weight_type       '|:|',
    del_documentID        '|:|',
    del_shipper_num       '|:|',
    del_service_code      '|:|',
    del_pieces            '|:|',
    del_weight            '|:|',
    del_postal_code       '|:|',
    del_document_date     '|:|',
    del_COD_amount        '|:|',
    del_DV_amount         '|:|',
    del_XC_pieces         '|:|',
    del_barcode_count     '|:|',
    del_value_in_COD_flag '|:|',
    del_value_in_DV_flag  '|:|',
    del_value_in_XC_flag  '|:|',
    del_PUT_flag          '|:|',
    del_error_flag        '|:|',
    del_scanner_time_date '|:|',
    del_scannerID         '|:|',
    del_extracted_to_sortation         '|:|',
    del_billed_flag       '|:|',
    del_store             '|:|',
    del_weight_type       '\n'
)
from '/opt/sybase/bcp_data/rev_hist/dsshipment_trail_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

