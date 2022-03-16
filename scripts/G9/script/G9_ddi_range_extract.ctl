options  ( skip=0 )
load data
truncate
into table G9_DMS_DUMP
fields terminated by '|' trailing nullcols
(
SWITCH,
CLLI,
CIRCUIT_REF,
BILLING_NUMBER,
SIGNALLING,
x2 FILLER,
x3 FILLER,
x4 FILLER,
START_NUMBER,
END_NUMBER
)
