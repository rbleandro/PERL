truncate table interline_costs;
LOAD into table interline_costs
(
    interline       '|:|',
    pucostperpc     '|:|',
    delcostperpc    '|:|',
    codpucostperpc  '|:|',
    coddelcostperpc '|:|',
    pucostperstop   '|:|',
    addpucostperpc  '|:|',
    delcostperstop  '|:|',
    adddelcostperpc '\n'
)

from '/opt/sybase/bcp_data/cmf_data/interline_costs_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

