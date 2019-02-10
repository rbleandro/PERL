LOAD into table cmfcurrp 
(
    customer_num                '|:|',
    ground_shipments            '|:|',
    select_shipments            '|:|',
    us_shipments                '|:|',
    ground_pieces               '|:|',
    select_parcels              '|:|',
    select_letters              '|:|',
    select_paks                 '|:|',
    us_pieces                   '|:|',
    ground_cod_pieces           '|:|',
    select_cod_parcels          '|:|',
    select_cod_letters          '|:|',
    select_cod_paks             '|:|',
    us_cod_pieces               '|:|',
    ground_weight               '|:|',
    select_weight               '|:|',
    us_weight                   '|:|',
    ground_revenue              '|:|',
    select_revenue              '|:|',
    us_revenue                  '|:|',
    ground_cod_charges          '|:|',
    select_cod_charges          '|:|',
    us_cod_charges              '|:|',
    service_charges             '|:|',
    pickup_tag_pieces           '|:|',
    pickup_tag_charges          '|:|',
    ground_dv_charges           '|:|',
    select_dv_charges           '|:|',
    us_dv_charges               '|:|',
    other_charges               '|:|',
    total_revenue               '|:|',
    total_pieces                '|:|',
    claims_damaged              '|:|',
    claims_damaged_dollars      '|:|',
    claims_dam_declined         '|:|',
    claims_dam_declined_dollars '|:|',
    claims_shortages            '|:|',
    claims_shortages_dollars    '|:|',
    claims_sht_declined         '|:|',
    claims_sht_declined_dollars '|:|',
    claims_cod                  '|:|',
    claims_cod_dollars          '|:|',
    claims_cod_declined         '|:|',
    claims_cod_declined_dollars '|:|',
    traces                      '|:|',
    ara                         '|:|',
    ara_amount                  '|:|',
    pods_billed                 '\n'
)

from '/opt/sybase/bcp_data/cmf_data/cmfcurrp_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
