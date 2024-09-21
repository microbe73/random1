( Editor Variables )
variable fh
variable curr-line
variable num-lines
variable fmem
256 Constant max-line
create line-buffer max-line 2 + allot

: bfill   256 0 u+do line-buffer i + 0 swap ! loop ;
bfill

0 num-lines !

( addr u -- [Opens the file] )
: open    r/w open-file throw fh ! ;
: close   fh @ close-file throw ;
: clean   0 0 fh @ reposition-file throw ;

: lcount  0 num-lines ! begin line-buffer 256 fh @ read-line throw num-lines @ 1 + 
          num-lines ! nip 0= until ;

: l-load  here line-buffer here 256 allot 256 cmove swap cells fmem @ + ! ;

: f-load  bfill num-lines @  0 u+do line-buffer max-line fh @
          read-line throw nip i l-load drop bfill loop ;

: init    open lcount num-lines @ cells allocate throw fmem ! clean f-load ;
: deinit  fmem @ free throw close ;
( print entire file to stdout )
: ,p      num-lines @ 0 u+do fmem @ i cells + @ 255 type 10 emit loop  ;

( line_num c-addr u -- ) ( replace line with other text )
: in      bfill rot 1 - cells fmem @ + -rot line-buffer swap cmove
          here line-buffer here 256 allot 256 cmove swap ! ;


( start-line end-line )
: p       swap 1 - u+do fmem @ i cells + @ 255 type 10 emit loop ;

( line-addr )
: s-line  dup c@ if begin dup 1 fh @ write-file throw 1 + dup c@ 0= until endif ;

create newl 1 cells allot
10 newl !
( save changes )
: w       clean num-lines @ 0 u+do fmem @ i cells + @ s-line drop newl 1 fh @
          write-file throw loop deinit ;

( line-num -- c-addr 255 ) ( copy a line )
: c       1 - cells fmem @ + @ 255 ;
( num -- c-addr num ) ( creates a string of n newline characters )
: nline   here over allot over 0 u+do 10 over i + c! loop swap ;
( I wrote this code using the editor it felt so cool im literally 1950s IBM superhacker )














( also inserted the newlines after reloading this code and using it yeaaaaaaaaa )









