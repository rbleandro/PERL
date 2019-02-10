truncate table F_PUProc_Rec;
LOAD into table F_PUProc_Rec
(
ulId        '|:|',
szName      '|:|',
unClass     '|:|',
ulFlags     '|:|',
ulSite      '|:|',
ulStation   '|:|',
ulSecurity  '|:|',
ulGroup     '|:|',
ulOwner     '|:|',
szDateTime  '|:|',
ulKey       '|:|',
szKey1      '|:|',
szKey2      '|:|',
szKey3      '|:|',
szKey4      '|:|',
szKey5      '|:|',
szKey6      '|:|',
szKey7      '|:|',
szKey8      '|:|',
szKey9      '|:|',
szKey10     '|:|',
szKey11     '|:|',
szKey12     '|:|',
szKey13     '|:|',
szKey14     '|:|',
szKey15     '|:|',
szKey16     '|:|',
dwVersion   '|:|',
szGlobalID  '|:|',
dwSize      '|:|',
dwLocation  '|:|',
dwAppLink   '|:|',
ulR1        '|:|',
ulR2        '|:|',
ulR3        '|:|',
ulR4        '|:|',
ulR5        '\n'
)

from '/opt/sybase/bcp_data/cmf_data/F_PU_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

