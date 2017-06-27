(declare-datatypes () ((Marktype 
BarMark PointMark
)))

(declare-datatypes () ((AggFunc 
None MeanAgg MaxAgg
)))

(declare-datatypes () ((EncodingType 
Quantitative Ordinal Nominal
)))

(declare-datatypes () ((RawType 
StringType FloatType IntegerType BooleanType
)))

(declare-datatypes () ((DataColumn 
(mk-col (columnId Int) (type RawType) (cardinality Int))
)))

(declare-datatypes () ((Encoding
(mk-enc (column DataColumn) (type EncodingType) (binned Bool) (agg AggFunc))
)))

; constant declarations

(declare-const mark Marktype)

(declare-const xEncoding Encoding)
(declare-const yEncoding Encoding)
(declare-const colorEncoding Encoding)

; hard constraints
(assert )

; get output
(check-sat)
(get-model)

; print spec
(echo "Spec:")
(get-value (mark))
(get-value (xEncoding))
(get-value (yEncoding))
(get-value (colorEncoding))
