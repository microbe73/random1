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
: clean 0 0 fh @ reposition-file throw ;
clean

: l-load  here line-buffer here 256 allot 256 cmove swap cells fmem + ! ;

: f-load  bfill num-lines @ 0 u+do line-buffer max-line fh @ read-line throw nip i 
          l-load drop bfill loop ;
f-load
close

( print entire file to stdout )
: ,p      num-lines @ 0 u+do fmem i cells + @ 255 type 10 emit loop  ;

( line_num c-addr u -- ) ( replace line with other text )
: in      bfill rot 1 - cells fmem + -rot line-buffer swap cmove
          here line-buffer here 256 allot 256 cmove swap ! ;


( start-line end-line )
: p       swap 1 - u+do fmem i cells + @ 255 type 10 emit loop ;

( line-addr )
: s-line  dup c@ if begin dup 1 fh @ write-file throw 1 + dup c@ 0= until endif ;

create newl 1 cells allot
10 newl !
open
: w       clean num-lines @ 0 u+do fmem i cells + @ s-line drop newl 1 fh @ write-file
          throw loop ;
