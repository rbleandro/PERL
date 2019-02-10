LOAD into table signatures 
(
    sigs	      '\n'
)

from '/opt/sybase/bcp_data/cpscan/sigs.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
