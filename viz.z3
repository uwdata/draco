(declare-datatypes () ((Marktype 
BarMark PointMark
)))

(declare-const mark Marktype)

; get output
(check-sat)
(get-model)

; print mark
(get-value (mark))
