truncate table LaborParts;
LOAD into table LaborParts
(        
    GroupCode                   '|:|',
    PONumber                    '|:|',
    InvoiceNumber               '|:|',
    POType                      '|:|',
    POStat                      '|:|',
    PODateClosed                '|:|',
    POTotal                     '|:|',
    RONumber                    '|:|',
    FleetCode                   '|:|',
    UnitCode                    '|:|',
    EqType                      '|:|',
    ReasonForRepairCode         '|:|',
    RODate                      '|:|',
    ROLine                      '|:|',
    CompanyCode                 '|:|',
    ROStat                      '|:|',
    ROType                      '|:|',
    ROSys                       '|:|',
    RegularHours                '|:|',
    OverTimeHours               '|:|',
    RegularRate                 '|:|',
    OverTimeRate                '|:|',
    EqMake                      '|:|',
    EqModel                     '|:|',
    EqYear                      '|:|',
    MeterReading                '|:|',
    MeterType                   '|:|',
    ROGroupCode                 '|:|',
    POHdrShippingExpensed       '|:|',
    POHdrTaxesExpensed          '|:|',
    POHdrMiscExpensed           '|:|',
    POHdrShippingApportioned    '|:|',
    POHdrTaxesApportioned       '|:|',
    POHdrMiscApportioned        '|:|',
    ROLaborAssy                 '|:|',
    ROLaborWorkCompletedCode    '|:|',
    ROLaborWorkAccomplishedCode '|:|',
    PorL                        '|:|',
    PartTotalCost               '|:|',
    PartReimbursed              '|:|',
    PartPONumber                '|:|',
    PartRONumber                '|:|',
    ROPartAssy                  '|:|',
    ROPartPart                  '|:|',
    ROPartFailureCode 		'\n'
)

from '/opt/sybase/bcp_data/cmf_data/LaborParts_ins.dat'
QUOTES OFF
ESCAPES OFF
BYTE ORDER LOW
FORMAT ascii
NOTIFY 100000
IGNORE CONSTRAINT UNIQUE 0;

