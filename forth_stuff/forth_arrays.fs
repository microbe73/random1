( so the plan is to define words for arrays stored in the following way:
len, [0, 1, 2, ...]. I think this is the best way to do like map or filter
or reduce. the ' [word] operator gives the address of a word and then
execute executes it )
: square dup * ;

: map ( op arr -- )
  dup @ 0 u+do
  1 cells + dup @ rot tuck execute rot dup -rot !
  loop drop drop ;

: reduce ( op arr -- num )
  dup @ swap 1 cells + dup @ rot 1 u+do
  swap 1 cells + dup @ 2swap -rot 2tuck execute 2swap nip -rot
  loop nip ;

: positive
  0 > ;

: ccount ( op arr -- op arr num [counts the number of elements in an array that meet a condition] )
  0 swap dup @ 0 u+do
  1 cells + dup @ -rot 2swap swap tuck execute 
  if
    rot 1 + rot
  else
    -rot
  endif
  loop swap ;

: filter ( op arr2 arr1 -- op arr2 arr1 [arr1 is filtered into arr2, run ccount first to find the correct size for arr2] )
  dup @ 0 u+do
  1 cells + swap -rot dup @ rot tuck execute 
  if
    -rot dup @ rot 1 cells + tuck ! swap
  else
    -rot
  endif
  loop
;
