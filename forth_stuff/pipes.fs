
: itoa     48 + emit ;
: get-dig  0 swap begin 10 / swap 1 + swap dup 0= until drop ;
: get-plc  get-dig 1 tuck u+do 10 * loop ;
( num -- [prints out the number to stdout] )
: itos     dup get-dig 0 u+do dup get-plc 2dup / itoa mod loop drop ;
: line-num 1 + dup itos 58 emit 32 emit ;
create line-buffer 255 allot
: bfill   255 0 u+do line-buffer i + 0 swap ! loop ;

: foo  0 >r begin line-buffer dup 255 stdin read-line throw dup while type r> line-num >r repeat ;
foo bye
