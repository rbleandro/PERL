LOAD into table trm 
(
terminal ',',
number ',',
city ',',
province  '\n'
)
from '/opt/sybase/tmp/trm.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
