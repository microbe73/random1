data =. cutopen 1!:1 < 'advent/advent2.txt'
temp =. > 0 { data
chrs1 =: (';';'';',';'')
chrs2 =: (' ')
m =: monad : 'chrs2 chopstring chrs1 stringreplace y'
curr =. m &.> data
len =. # &.> curr
fun =: monad : '2 * 1 + i. ((y % 2) - 1)'
inds =. fun &.> len
inds
curr
nums =: dyad :  '". > (x) { y'
inds nums &.> curr

