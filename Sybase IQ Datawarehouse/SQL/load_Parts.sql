truncate table Parts;
LOAD into table Parts
(
    EqTypeGroupCode          '|:|',
    POHdrPONumber            '|:|',
    POHdrInvoiceNumber       '|:|',
    POHdrType                '|:|',
    POHdrStat                '|:|',
    POHdrDateClosed          '|:|',
    POHdrTotal               '|:|',
    ROPartRONumber           '|:|',
    ROPartStat               '|:|',
    ROPartType               '|:|',
    ROPartSys                '|:|',
    ROPartTotalCost          '|:|',
    ROPartReimbursed         '|:|',
    ROPartPONumber           '|:|',
    RODetRONumber            '|:|',
    RODetFleetCode           '|:|',
    RODetUnitCode            '|:|',
    RODetEqType              '|:|',
    RODetReasonForRepairCode '|:|',
    RODetRODate              '|:|',
    RODetROLine              '|:|',
    RODetCompanyCode         '|:|',
    EqMake                   '|:|',
    EqModel                  '|:|',
    EqYear                   '|:|',
    MeterReading             '|:|',
    MeterType                '|:|',
    ROGroupCode              '|:|',
    POHdrShippingExpensed    '|:|',
    POHdrTaxesExpensed       '|:|',
    POHdrMiscExpensed        '|:|',
    POHdrShippingApportioned '|:|',
    POHdrTaxesApportioned    '|:|',
    POHdrMiscApportioned     '\n'
)

from '/opt/sybase/bcp_data/cmf_data/Parts_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

