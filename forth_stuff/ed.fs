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

( todo: Add insertion between lines [ib, ia] by using the linked-list aspect of things )
( todo: avoid buffer overflows if possible [for functions make sure the line number given is not too large] )

: bfill   max-line 0 u+do line-buffer i + 0 swap ! loop ;
: b2fill  max-line 0 u+do buffer2 i + 0 swap ! loop ;
bfill

0 num-lines !

( addr u -- [Opens the file] )
: open    r/w open-file throw fh ! ;
: close   fh @ close-file throw ;
: clean   0 0 fh @ reposition-file throw ;

: lcount  0 num-lines ! begin line-buffer max-line fh @ read-line throw num-lines @ 1 +
          num-lines ! nip 0= until ;

: l-load  align here line-buffer align here max-line allot max-line cmove curr-line @ linelist-line !
          linelist allocate throw curr-line @ linelist-next !
          curr-line @ linelist-next @ curr-line !
          0 curr-line @ linelist-next ! 0 curr-line @ linelist-line ! ;

: f-load  bfill num-lines @ 1 u+do line-buffer max-line fh @ read-line throw
          drop drop l-load bfill loop ;
( set curr-line back to start )
: rcurr   fhead @ curr-line ! ;
( c-addr u -- [load a file into memory] )
: init    open lcount linelist allocate throw fhead ! rcurr clean f-load ;

( should fix this )
: deinit  rcurr begin curr-line @ dup linelist-next @ swap free throw dup curr-line ! until ;

( sets curr-line to the next line )
: n-line  curr-line @ linelist-next @ curr-line ! ;

( line-num -- [sets curr-line to the addressed line] )
: addify  rcurr 1 u+do n-line loop ;
( []  -- linelist-line [ gets pointer to current line's text ] )
: gcline  curr-line @ linelist-line ;
( print entire file to stdout )
: ,p      10 emit rcurr num-lines @ 1 u+do gcline @ max-line type 10 emit n-line loop  ;

( c-addr u line-num -- ) ( replace line with other text )
: in      bfill addify gcline -rot line-buffer swap cmove
          here line-buffer here max-line allot max-line cmove swap ! ;

( c-addr u line-num -- ) ( insert text between line-num and line-num + 1, or at the end if it is the last line )
: ia      bfill -rot line-buffer swap cmove addify curr-line @ linelist-next @ ( so now we have the current next line at the bottom of the stack, our new allocation needs to point to this )
          linelist allocate throw dup curr-line @ linelist-next ! swap over linelist-next !
          line-buffer align here max-line allot tuck max-line cmove swap linelist-line !
          num-lines @ 1 + num-lines ! ;
( start-line end-line )
( note: May want to add line numbers )
: p       10 emit over addify 1 + swap u+do gcline @ max-line type 10 emit n-line loop ;

( line-addr )
: s-line  dup c@ if begin dup 1 fh @ write-file throw 1 + dup c@ 0= until endif ;

create newl 1 allot
10 newl !
( save changes ) ( maybe just refactor to use while loop instead of for loop to avoid off by 1 errors )
: w       rcurr clean num-lines @ 1 u+do gcline @ s-line drop newl 1 fh @
          write-file throw n-line loop deinit close ;

( line-num -- c-addr max-line ) ( copy a line )
: c       addify gcline @ max-line ;
( num -- c-addr num ) ( creates a string of n newline characters )
: nline   here over allot over 0 u+do 10 over i + c! loop swap ;

( I edited this line using this new sr feature it felt so cool im literally this 1950s IBM superhacker )
( c-addr1 u1 c-addr2 u2 line-num -- [replace string 2 with string 1 on line-num] )
: sr    b2fill { c1 u1 c2 u2 line-num }
        0 0 begin line-num addify gcline @ over + u2 c2 u2 compare
        if 2dup line-num addify gcline @ + c@ swap buffer2 + c! 1 + swap 1 + swap
        else over buffer2 + c1 swap u1 cmove u2 + swap u1 + swap endif
        2dup max-line 1 - > swap max-line 1 - > or until drop drop ; ( this is criminal forth style here but it works so wtv )
( this is the multiple lol )
( testing multiple inserts at once )
( made in make more stack sense, testing if i broke )
( I don't think it broke )
( c-addr1 u1 c-addr2 u2 start-line end-line -- [replace string 2 with string 1 on all lines in a range] )
: srmul  { c1 u1 c2 u2 l1 l2 } l2 1 + l1 u+do c1 u1 c2 u2 i sr buffer2 max-line 1 - i in loop ;
: sc { c1 u1 line-num } 0 begin line-num addify gcline @ over + u1 c1 u1 compare
0= if line-num . dup . 59 emit endif 1 + dup max-line 1 - >= until drop ;
( lul lol lol )
( c1 u1 line-start line-end )
: scmul swap 1 + u+do 2dup i sc loop drop drop ;
( also inserted the newlines after reloading this code and using nline which I wrote in this editor yeaaaaaaaaa )
: gl 1 num-lines @ ;












