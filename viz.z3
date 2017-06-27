(declare-datatypes () ((Marktype 
BarMark PointMark
)))

(declare-datatypes () ((Channel 
XAxis YAxis Color
)))

(declare-const mark Marktype)

; get output
(check-sat)
(get-model)

; print mark
(get-value (mark))
