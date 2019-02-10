truncate table am_points1;
LOAD into table am_points1
(
Terminal        '|:|',
Interline       '|:|',
City            '|:|',
Delay           '|:|',
Service         '|:|',
Week1           '|:|',
Week2           '|:|',
PCode_From      '|:|',
PCode_To        '|:|',
Additional_Days '|:|',
Sort_Terminal   '|:|',
Point_Served	'\n'
)

from '/opt/sybase/bcp_data/cmf_data/po_aa'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

