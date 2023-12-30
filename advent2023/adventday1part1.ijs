strToInt =: monad : '0 ".&>y'
ind =: monad : 'I. (strToInt y)>0'
parse =: monad : '((((0 { ind y) { strToInt y)) * 10) + (_1 { ind y) { strToInt y'
res =: monad : '+/ > parse &.> y'
readfile =: 1!:1
fn =. < 'advent/advent1.txt'
data =. cutopen readfile fn
res data