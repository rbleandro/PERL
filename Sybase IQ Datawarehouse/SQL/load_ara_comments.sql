truncate table ara_comments;
LOAD into table ara_comments
(
ara_number '|:|',
comments1  '|:|',
comments2  '|:|',
comments3  '|:|',
comments4  '|:|',
comments5  '\n'
)

from '/opt/sybase/bcp_data/cmf_data/ara_comments_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

