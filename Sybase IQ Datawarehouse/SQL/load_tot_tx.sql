LOAD into table tot_tx
(   province            '|:|',
    intra_provincial_yn '|:|',
    inter_prepaid_yn    '|:|',
    inter_collect_yn    '|:|',
    us_yn               '|:|',
    inter_prepaid_limit '|:|',
    inter_collect_limit '|:|',
    us_prepaid_limit    '|:|',
    tax_rate_pc         '\n'
)
from '/opt/sybase/bcp_data/cmf_data/tot_tx.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
