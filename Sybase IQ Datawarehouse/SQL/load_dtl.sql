LOAD into table dtl 
( 
 AcctNbr ',',
 InvcDate ',',
 MobileNbr ',',
 CallSeq ',',
 _Date ',',
 _Time ',',
  C ',',
  D ',',
  OrigPlace ',',
  PR ',',
  CalledNumber ',',
  CalledLoc ',',
  PR2 ',',
  duration ',',
  Rate  ',',
  UsageAmt ',',
  LDChg  ',',
  CallCost ',',
  ACB ',',
  ACBGST ',',
  ACBHST ',',
  ACBPST ',',
  PC ',',
  M ',',
  PktDvol ',',
  R ',',
  Descripton ',',
  EventType ',',
  BilledBy ',',
  Period '\n' 
)
from '/opt/sybase/tmp/dtl.csv'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
