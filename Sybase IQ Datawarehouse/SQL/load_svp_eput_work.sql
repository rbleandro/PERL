LOAD into table svp_eput_work 
(
    reference_num	'|:|',
    service_type	'|:|',
    shipper_num		'|:|',
    first_scan_date	'|:|',
    pickup_shipper_num	'|:|',
    document_id		'|:|',
    document_date	'|:|',
    linkage		'|:|',
    shipment_id		'|:|',
    eput_type		'|:|',
    term_from		'|:|',
    interline_from	'|:|',
    province_from	'|:|',
    term_to		'|:|',
    interline_to	'|:|',
    province_to		'|:|',
    origin_postal	'|:|',
    destin_postal	'|:|',
    first_scan_time	'|:|',
    first_scan_status	'|:|',
    first_scan_flag	'|:|',
    del_scan_time	'|:|',
    del_scan_status	'|:|',
    del_scan_flag	'|:|',
    actual_days		'|:|',
    std_days		'|:|',
    made_service	'|:|',
    evaluation_date	'|:|',
    inserted_on_cons	'|:|',
    updated_on_cons	'|:|',
    INO_terminal        '|:|',
    INO_date            '|:|',
    INO_standard_days   '|:|',
    INO_actual_days     '\n'
)
from '/opt/sybase/bcp_data/cmf_data/svp_eput_work_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
