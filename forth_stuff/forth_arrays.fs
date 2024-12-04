( so the plan is to define words for arrays stored in the following way:
len, [0, 1, 2, ...]. I think this is the best way to do like map or filter
or reduce. the ' [word] operator gives the address of a word and then
execute executes it )
: square dup * ;

: map ( op arr -- )
  dup @ 0 u+do
  1 cells + dup @ rot tuck execute rot dup -rot !
  loop drop drop ;

: reduce ( op arr -- op arr num )
  dup @ swap 1 cells + dup @ rot 1 u+do
  swap 1 cells + dup @ 2swap -rot 2tuck execute 2swap nip -rot
  loop ;

: positive
  0 > ;

: ccount ( op arr -- op arr num [counts the number of elements in an array that meet a condition] )
{ op arr }
0 arr @ 0 u+do
arr i 1 + cells + @ op execute
if 1 + endif loop op swap arr swap ;





: filter ( op arr1 -- op arr1 arr2 [arr1 is filtered into arr2] )
ccount here over 1 + cells allot
{ op arr1 num arr2 }
1 arr1 @ 0 u+do arr1 i 1 + cells + @ op execute
if arr1 i 1 + cells + @ over cells arr2 + !
1 + endif
loop drop op arr1 num arr2 ! arr2 ; 




: a_op ( op arr1 arr2 -- arr1 arr2 arr3 [element wise operation on a1 and a2 like + so that a3[i] = a1[i] + a2[i] )
dup @ here over 1 + cells allot { op arr1 arr2 len arr3 } len arr3 !
arr1 arr2 arr3
len 1 + 1 u+do arr1 i cells + @ arr2 i cells + @ op execute arr3 i cells + ! loop ;
: c-b ( arr ind -- arr ind [checks if the bounds are allowed] ) { arr ind } arr @ ind < if s" out of bounds" exception throw endif arr ;
: m_row ( matrix1 i -- arr1 [returns row i of the matrix, 1-indexed, so for example a 2 by 2 matrix has rows 1 and 2] ) cells + @ ;
: m_el ( matrix1 i j -- n [element m_{ij}] ) -rot m_row swap c-b swap cells + @ ;
: m_cre ( i j -- matrix1 ) here { rows cols addr } rows 1 + cells allot rows addr ! rows 1 + 1 u+do here cols 1 + cells allot cols over ! addr i cells + ! loop addr ;
( So for multi dimensional arrays we have an array of pointers. But to tell apart the pointer 40459045 from the number 40459045, arrays of pointers will have negative length numbers )
( On second thought this is a user-side issue only use matrix functions on matrices and array functions on arrays that's why there are different ones, this is probably better )

: m_op ( op matrix1 matrix2 -- matrix1 matrix2 matrix3 [operation can be something like addition or subtraction or any element-wise operation] )
here swap dup @ { op m1 m3 m2 rows } rows 1 + cells allot rows m3 ! rows 1 + 1 u+do
op m1 i m_row m2 i m_row .s a_op m3 i cells + ! drop drop
loop m1 m2 m3
;
( create m1 3 cells allot create m2 3 cells allot create m1r1 3 cells allot create m1r2 3 cells allot create m2r1 3 cells allot create m2r2 3 cells allot 2 m1 ! 2 m2 ! )
( : set2 )
  ( 2 m1r1 ! 2 m1r2 ! 2 m2r1 ! 2 m2r2 ! 5 m1r1 1 cells + ! 3 m1r1 2 cells + ! 8 m1r2 1 cells + ! 4 m1r2 2 cells + ! 9 m2r1 1 cells + ! 11 m2r1 2 cells + ! 0 m2r2 1 cells + ! 7 m2r2 2 cells + ! )
( test )
