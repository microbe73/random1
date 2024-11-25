( Editor Variables )
variable fh
variable curr-line ( struct pointer, @ needed to get struct  )
variable num-lines
variable fmem
variable fhead
256 Constant max-line
create line-buffer max-line 2 + allot
create buffer2 max-line 2 + allot
begin-structure linelist ( -- u )
        field: linelist-next ( intlist -- addr1 ) ( struct pointer )
        field: linelist-line  ( intlist -- addr2 )
end-structure


: bfill   256 0 u+do line-buffer i + 0 swap ! loop ;
: b2fill  256 0 u+do buffer2 i + 0 swap ! loop ;
bfill

0 num-lines !

( addr u -- [Opens the file] )
: open    r/w open-file throw fh ! ;
: close   fh @ close-file throw ;
: clean   0 0 fh @ reposition-file throw ;

: lcount  0 num-lines ! begin line-buffer 256 fh @ read-line throw num-lines @ 1 +
          num-lines ! nip 0= until ;

: l-load  align here line-buffer align here 256 allot 256 cmove curr-line @ linelist-line !
          linelist allocate throw curr-line @ linelist-next !
          curr-line @ linelist-next @ curr-line !
          0 curr-line @ linelist-next ! 0 curr-line @ linelist-line ! ;
( lets goooo )
: f-load  bfill num-lines @ 1 u+do line-buffer max-line fh @ read-line throw
          drop drop l-load bfill loop ( so now line of file is in line-buffer and l-load needs to read it ) ;
( set curr-line back to start )
: rcurr   fhead @ curr-line ! ;
( allocate an instance of linelist for each line )
: init    open lcount linelist allocate throw fhead ! rcurr clean f-load ;


( : l-load  here line-buffer here 256 allot 256 cmove swap cells fmem @ + ! ; 

: f-load  bfill num-lines @  0 u+do line-buffer max-line fh @
          read-line throw nip i l-load drop bfill loop ; 
: init    open lcount num-lines @ cells allocate throw fmem ! clean f-load ; )

: deinit  fmem @ free throw close ;
( line-num -- linelist-line )
( gonna assume i didn't save otherwise why does this not work lol )
: addify  rcurr 1 u+do curr-line @ linelist-next @ curr-line ! loop curr-line @ linelist-line ;
( print entire file to stdout )
: ,p      num-lines @ 1 u+do i addify @ 256 type 10 emit loop  ;

( c-addr u line-num -- ) ( replace line with other text )
: in      bfill addify -rot line-buffer swap cmove
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

( I edited this line using this new sr feature it felt so cool im literally this 1950s IBM superhacker )
( c-addr1 u1 c-addr2 u2 line-num -- [replace string 2 with string 1 on line-num] )
: sr    b2fill { c1 u1 c2 u2 line-num }
        0 0 begin line-num addify @ over + u2 c2 u2 compare
        if 2dup line-num addify @ + c@ swap buffer2 + c! 1 + swap 1 + swap
        else over buffer2 + c1 swap u1 cmove u2 + swap u1 + swap endif
        2dup 255 > swap 255 > or until drop drop ; ( this is criminal forth style here but it works so wtv )
( this is the multiple lol )
( testing multiple inserts at once )
( made in make more stack sense, testing if i broke )
( I don't think it broke )
( c-addr1 u1 c-addr2 u2 start-line end-line -- [replace string 2 with string 1 on all lines in a range] )
: srmul  { c1 u1 c2 u2 l1 l2 } l2 1 + l1 u+do c1 u1 c2 u2 i sr buffer2 255 i in loop ;
: sc { c1 u1 line-num } 0 begin line-num addify @ over + u1 c1 u1 compare
0= if line-num . dup . 59 emit endif 1 + dup 255 >= until drop ;
( lul lol lol )
( c1 u1 line-start line-end )
: scmul swap 1 + u+do 2dup i sc loop drop drop ;
( also inserted the newlines after reloading this code and using nline which I wrote in this editor yeaaaaaaaaa )
: gl 1 num-lines @ ;












