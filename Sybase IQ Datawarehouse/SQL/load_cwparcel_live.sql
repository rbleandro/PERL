truncate table cwparcel_live;
LOAD into table cwparcel_live
(
    service_type        '|:|',
    reference_num       '|:|',
    shipper_num         '|:|',
    dimension_unit      '|:|',
    length              '|:|',
    width               '|:|',
    height              '|:|',
    weight_unit         '|:|',
    cw_weight           '|:|',
    equipment_id        '|:|',
    pickup_shipper_num  '|:|',
    billing_weight_unit '|:|',
    dim_weight_factor   '|:|',
    actual_weight       '|:|',
    dim_weight          '|:|',
    ground_xc           '|:|',
    usa_xc              '|:|',
    linkage             '|:|',
    shipment_id         '|:|',
    cw_date             '|:|',
    loaded_date  	'|:|',
    cwused              '\n'
)

from '/opt/sybase/bcp_data/rev_hist/cwparcel_live_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

