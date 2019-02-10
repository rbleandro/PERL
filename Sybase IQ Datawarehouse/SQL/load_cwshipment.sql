truncate table cwshipment;
LOAD into table cwshipment
(
    linkage       '|:|',
    shipment_id   '|:|',
    service_code  '|:|',
    cw_pieces     '|:|',
    rh_pieces     '|:|',
    rh_weight     '|:|',
    rebill_weight '|:|',
    rebill_type   '|:|',
    dw_flag       '|:|',
    xc_pieces     '|:|',
    billed_date   '|:|',
    RBF           '|:|',
    create_date   '|:|',
    actual_weight '|:|',
    dim_weight    '|:|',
    weight_type   '|:|',
    doc_rev       '|:|',
    act_rev       '|:|',
    dim_rev	  '\n'
)

from '/opt/sybase/bcp_data/rev_hist/cwshipment_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 1000000
IGNORE CONSTRAINT UNIQUE 0;

