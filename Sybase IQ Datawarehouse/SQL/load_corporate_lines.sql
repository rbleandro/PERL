truncate table corporate_lines;
LOAD into table corporate_lines
(
    corpline         '|:|',
    corp_description '|:|',
    corp_variable    '|:|',
    fixed            '|:|',
    corporate        '\n'
)

from '/opt/sybase/bcp_data/cmf_data/corporate_lines_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

