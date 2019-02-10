truncate table householder_elite;
LOAD into table householder_elite
(   
SO_PC			ASCII(6),
SO_Del_Inst_Area	ASCII(30),
SO_Del_Inst_Type	ASCII(5),
SO_Del_Inst_Qual	ASCII(15),
SO_Abbr_Name		ASCII(15),
SO_Inst_Status		ASCII(1),
DM_Type			ASCII(2),
DM_ID			ASCII(4),
PoC_Apartments		ASCII(5),
PoC_Businesses		ASCII(5),
PoC_Houses		ASCII(5),
PoC_Farms		ASCII(5),
CC_Apartments		ASCII(5),
CC_Businesses		ASCII(5),
CC_Houses		ASCII(5),
CC_Farms		ASCII(5),
Postal_Code		ASCII(6),
LDU_Type		ASCII(2),
RO_PC			ASCII(6),
RO_Post_Del_Area	ASCII(30),
RO_Del_Inst_Area	ASCII(30),
RO_Del_Inst_Type	ASCII(5),
RO_Del_Inst_Qual	ASCII(15),
RO_Inst_St_Add_Num	ASCII(6),
RO_Inst_St_Add_Suf	ASCII(1),
RO_Inst_Suite_Num	ASCII(6),
RO_Street_Name		ASCII(30),
RO_Street_Type		ASCII(6),
RO_Street_Dir		ASCII(2),
RO_Prov_Code		ASCII(2),
RO_Inst_Status_Code	ASCII(1),
FSA			ASCII(3)
)
from '/opt/sybase/tmp/HouseElite.txt'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
SKIP 1
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0
ROW DELIMITED BY '\n'
