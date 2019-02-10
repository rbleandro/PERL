LOAD into table svp_parcel
(
    reference_num         '|:|',
    service_type          '|:|',
    shipper_num           '|:|',
    first_scan_date       '|:|',
    pickup_shipper_num    '|:|',
    document_id           '|:|',
    document_date         '|:|',
    linkage               '|:|',
    shipment_id           '|:|',
    term_from_scan        '|:|',
    interline_from_scan   '|:|',
    term_from_postal      '|:|',
    interline_from_postal '|:|',
    province_from         '|:|',
    term_to_scan          '|:|',
    interline_to_scan     '|:|',
    province_to           '|:|',
    sort_terminal         '|:|',
    origin_postal         '|:|',
    destin_postal_scan    '|:|',
    first_scan_time       '|:|',
    first_scan_status     '|:|',
    first_scan_flag       '|:|',
    del_scan_time         '|:|',
    del_scan_status       '|:|',
    del_scan_flag         '|:|',
    actual_days           '|:|',
    std_days              '|:|',
    made_service          '|:|',
    evaluation_date_sp    '|:|',
    correctly_manifested  '|:|',
    split_at_delivery     '|:|',
    evaluation_date_rh    '|:|',
    destin_postal_man     '|:|',
    inserted_on_cons      '|:|',
    updated_on_cons       '|:|',
    del_attempt_time	  '|:|',
    del_attempt_status    '|:|',   
    INO_terminal          '|:|',
    INO_date              '|:|',
    INO_standard_days     '|:|',
    INO_actual_days       '\n'
)
from '/opt/sybase/bcp_data/cmf_data/svp_parcel_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
