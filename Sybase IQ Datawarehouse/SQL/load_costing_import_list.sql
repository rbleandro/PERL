truncate table costing_import_list;
LOAD into table costing_import_list
(
    customer '\n'
)

from '/opt/sybase/bcp_data/cmf_data/costing_import_list_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

