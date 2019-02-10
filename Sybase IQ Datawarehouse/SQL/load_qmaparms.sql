truncate table qmaparms;
LOAD into table qmaparms
(
    shipper          '|:|',
    file_type        '|:|',
    check_store      '|:|',
    process_cust_ref '|:|',
    process_as       '|:|',
    pr_handle        '|:|',
    pr_program       '|:|',
    print_manifest   '|:|',
    check_seq         '\n'
)

from '/opt/sybase/bcp_data/cmf_data/qmaparms_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

