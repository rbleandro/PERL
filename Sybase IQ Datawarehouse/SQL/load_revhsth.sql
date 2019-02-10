--truncate table revhsth;
LOAD into table revhsth
(   shipper_num     '|:|',
    pickup_rec_num  '|:|',
    pickup_rec_date '|:|',
    data_entry_date '|:|',
    billto_type     '|:|',
    bt422           '|:|',
    units           '|:|',
    assoc_code      '|:|',
    origin_pc       '|:|',
    ZW_discount     '|:|',
    ZW_alpha        '|:|',
    RBF_paper       '|:|',
    RBF_file        '|:|',
    filenum         '|:|',
    release_as      '|:|',
    invoice         '|:|',
    invoice_date    '|:|',
    linkage         '|:|',
    com_disc_date   '|:|',
    user_id         '\n'
)
from '/opt/sybase/bcp_data/rev_hist/revhsth_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
