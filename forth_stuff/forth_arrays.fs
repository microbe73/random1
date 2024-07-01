( so the plan is to define words for arrays stored in the following way:
len, [0, 1, 2, ...]. I think this is the best way to do like map or filter
or reduce. the ' [word] operator gives the address of a word and then
execute executes it )
: square dup * ;

: map ( op arr -- arr )
  dup @ 0 u+do
  1 cells + dup @ rot tuck execute rot dup -rot !
  loop ;

: reduce ( op arr -- arr )
  dup @ swap 1 cells + dup @ rot 1 u+do
  swap 1 cells + dup @ 2swap -rot 2tuck execute 2swap nip -rot
  loop ;
