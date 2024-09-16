( editor variables )
variable fh
variable curr-line
variable num-lines
256 Constant max-line
Create line-buffer max-line 2 + allot

: bfill   256 0 u+do line-buffer i + 0 swap ! loop ;
bfill

: f       s" process_text.fs" ;
0 num-lines !


: open    f r/w open-file throw fh ! ;
: close   fh @ close-file throw ;

: lcount  begin line-buffer 256 fh @ read-line throw num-lines @ 1 + num-lines ! nip
          0= until ;
open
lcount
create fmem num-lines @ cells allot
0 0 fh @ reposition-file throw

: l-load  here line-buffer here 256 allot 256 cmove swap cells fmem + ! ;
: f-load  num-lines @ 0 u+do line-buffer max-line fh @ read-line throw nip i l-load
          drop bfill loop ;
f-load


: clean   0 0 fh @ reposition-file throw fill ; ( Reset file handler to beginning )
( print entire file to stdout )
: ,p      num-lines @ 0 u+do fmem i cells + @ 255 type 10 emit loop  ;
( line_num c-addr u -- )
: a       rot 0 u+do line-buffer max-line fh @ read-line throw  loop
          fh @ write-file clean ;
 
