truncate table flash_master;
LOAD into table flash_master 
(
   fterm   '|:|',
    fterm3  '|:|',
    fregion '|:|',
    fmd     '|:|',
    fmm     '|:|',
    fmdy    '|:|',
    fdd     '|:|',
    fyy     '|:|',
    fpupcs  '|:|',
    fdepcs  '|:|',
    fstppi  '|:|',
    fstpde  '|:|',
    fmpups  '|:|',
    fna     '|:|',
    fsa     '|:|',
    fmsort  '|:|',
    fpdhrg  '|:|',
    fpdhot  '|:|',
    fhubhrs '|:|',
    fprehrs '|:|',
    fofchrs '|:|',
    flnhrs  '|:|',
    fslshrs '|:|',
    favgrev '|:|',
    fpdwgr  '|:|',
    fpdwgo  '|:|',
    flhwg   '|:|',
    fprewg  '|:|',
    fhubwg  '|:|',
    fofwg   '|:|',
    fslswg  '|:|',
    fpdmile '|:|',
    flhmile '|:|',
    fldhr   '|:|',
    fldwg   '|:|',
    fcar    '|:|',
    fint    '|:|',
    fccar   '|:|',
    fcint   '\n'
)
from '/opt/sybase/bcp_data/cmf_data/flash_master_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;
