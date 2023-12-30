arrnums =: monad : '(9,y) $ y # (1 + i. 9)'
data =. cutopen 1!:1 < 'advent/advent1.txt'
nums =: 'one';'two';'three';'four';'five';'six';'seven';'eight';'nine'
nums2 =: '1';'2';'3';'4';'5';'6';'7';'8';'9'
first =. nums E.&.> (1 { data)
second =. nums2 E.&.> (1 { data)
len =. # > 1 { data
arr =. (> first) +. > second
arr2 =. arr * arrnums len
c =. I. (+/arr2) > 0
g =. c { (+/arr2)
res =: monad : '(10 * 0 { ((I. (+/(((> (nums E.&.> (y))) +. > (nums2 E.&.> (y))) * arrnums (# > (y)))) > 0) { (+/(((> (nums E.&.> (y))) +. > (nums2 E.&.> (y))) * arrnums # > (y))))) + (_1 { ((I. (+/(((> (nums E.&.> (y))) +. > (nums2 E.&.> (y))) * arrnums # > (y))) > 0) { (+/(((> (nums E.&.> (y))) +. > (nums2 E.&.> (y))) * arrnums # > (y)))))'
data =. <&.> data
answer =. res &.> data
+/ > answer