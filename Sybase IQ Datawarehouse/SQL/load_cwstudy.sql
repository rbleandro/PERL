truncate table cwstudy;
LOAD into table cwstudy
(
    linkage     '|:|',
    shipment_id '|:|',
    doc_weight  '|:|',
    act_weight  '|:|',
    dim_weight  '|:|',
    ship_type   '|:|',
    doc_rev     '|:|',
    act_rev     '|:|',
    dim_rev     '|:|',
    billed_date '\n'
)

from '/opt/sybase/bcp_data/rev_hist/cwstudy_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
