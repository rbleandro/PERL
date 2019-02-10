LOAD into table svp_message_code
(
    code                 '|:|',
    description_e        '|:|',
    description_f        '|:|',
    prevents_evaluation  '|:|',
    explanation          '\n'   
)
from '/opt/sybase/bcp_data/cmf_data/svp_message_code_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
