truncate table costing_control;
LOAD into table costing_control
(
    special_pcs    '|:|',
    special_weight '|:|',
    corp_pieces    '|:|',
    corp_costs     '\n'
)

from '/opt/sybase/bcp_data/cmf_data/costing_control_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

