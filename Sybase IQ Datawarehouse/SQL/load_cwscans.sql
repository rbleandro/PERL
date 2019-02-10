truncate table cwscans_live;
LOAD into table cwscans_live
(
    service_type   '|:|',
    reference_num  '|:|',
    shipper_num    '|:|',
    dimension_unit '|:|',
    length         '|:|',
    width          '|:|',
    height         '|:|',
    weight_unit    '|:|',
    cw_weight      '|:|',
    equipment_id   '|:|',
    cw_date        '|:|',
    loaded_date    '|:|',
    induct         '|:|',
    sid		   '\n'
)

from '/opt/sybase/bcp_data/rev_hist/cwscans_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

