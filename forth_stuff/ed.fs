( Editor Variables )
variable fh
variable curr-line ( struct pointer, @ needed to get struct  )
variable num-lines
variable fhead
variable initial-mem
256 Constant max-line
create line-buffer max-line allot
create buffer2 max-line allot
begin-structure linelist ( -- u )
        field: linelist-next ( intlist -- addr1 ) ( struct pointer )
        field: linelist-line  ( intlist -- addr2 ) ( string pointer [char*[]] )
        field: linelist-len ( intlist -- addr3 ) ( int pointer )
end-structure
( I think i'm pretty happy with the state of the editor for right now, it has pretty much all the basic features I would want with inserting, deleting,
copying, search and replace etc. and I'm actually confident that it all works. I may implement the bounds checking but it's not too serious and most of the
time GForth will just throw an out of bounds error anyway )
( Todo: try to refactor so I don't need the line buffers anymore, that way arbitrary line length 100% will work, also refactor to look like nicer Forth code )
( on second thought I did not consider that ok maybe I do just use the line buffers, maybe a bit less though and also still can refactor to look nicer/not iterate twice )
: bfill   max-line 0 u+do line-buffer i + 0 swap ! loop ;
: b2fill  max-line 0 u+do buffer2 i + 0 swap ! loop ;
bfill

0 num-lines !

( []  -- linelist-line [ gets pointer to current line's text ] )
: gcline  curr-line @ linelist-line ;
: gclen   curr-line @ linelist-len ;
: gcnext  curr-line @ linelist-next ;

( set curr-line back to start )
: rcurr   fhead @ curr-line ! ;
( -- [sets curr-line's fields to 0] )
: nullify 0 gcline ! 0 gclen ! 0 gcnext ! ;
( sets curr-line to the next line )
: n-line  curr-line @ linelist-next @ curr-line ! ;
( line-num -- [sets curr-line to the addressed line] )
: addify  rcurr 1 u+do n-line loop ;

( addr u -- [Opens the file] )
: open    r/w open-file throw fh ! ;
: close   fh @ close-file throw ;
: clean   0 0 fh @ reposition-file throw ;

: l-load  { len } align here line-buffer align here len allot len cmove gcline ! len gclen ! ( set values for this line )
          linelist allocate throw gcnext ! gcnext @ curr-line !  nullify ( move pointer to next line, set to 0s to avoid weird bugs ) ;

( ptr -- [increase the value pointed to by 1] )
: ++      dup @ 1 + swap ! ;

: f-load  begin bfill line-buffer max-line fh @ read-line throw num-lines ++ while 1 + l-load repeat bfill ;
( c-addr u -- [load a file into memory] )
: init    open linelist allocate throw fhead ! rcurr clean f-load ;

: deinit  rcurr begin curr-line @ dup linelist-next @ swap free throw dup curr-line ! until ;

: gl 1 num-lines @ 1 - ;

: itoa     48 + emit ;
: get-dig  0 swap begin 10 / swap 1 + swap dup 0= until drop ;
: get-plc  get-dig 1 tuck u+do 10 * loop ;
( num -- [prints out the number to stdout] )
: itos     dup get-dig 0 u+do dup get-plc 2dup / itoa mod loop drop ;

( start-line end-line )
: p        10 emit over addify 1 + swap u+do gcline @ i itos 58 emit 32 emit gclen @ type 10 emit n-line loop ;
( print entire file to stdout )
: ,p       gl p ;

( : in      bfill addify gcline -rot line-buffer swap dup 1 + { len } cmove
          here line-buffer here len allot len cmove swap !
          len gclen ! ; )
( c-addr u line-num -- ) ( replace line with other text )
: in     addify { len } here len allot tuck len cmove 0 c, gcline ! len 1 + gclen ! ;

( c-addr u line-num -- ) ( insert text between line-num and line-num + 1, or at the end if it is the last line )
: ia      bfill -rot line-buffer swap dup 1 + { len } cmove addify curr-line @ linelist-next @
          linelist allocate throw dup curr-line @ linelist-next ! swap over linelist-next ! ( sets the current line's next line to the new one and the new line's next line to the one after )
          line-buffer here len allot tuck len cmove swap linelist-line ! ( sets the new line's string pointer to the text )
          n-line len gclen ! ( sets the new line's int pointer to the length of the new line )
          num-lines @ 1 + num-lines ! ;
( c-addr u ) ( insert text before the first line )
: i0      bfill line-buffer swap dup 1 + { len } cmove fhead @
          linelist allocate throw dup fhead ! linelist-next !
          line-buffer here max-line allot tuck max-line cmove fhead @ linelist-line !
          len fhead @ linelist-len ! ( sets the first line's int pointer to the length of the first line )
          num-lines @ 1 + num-lines ! ;
( c-addr u line-num c-num -- ) ( insert text at a specific character in a line )
: ic      bfill { len line-num c-num } len line-num addify gclen @ c-num < if -1 abort" Illegal insertion (beyond end of line)" endif
          gcline @ line-buffer c-num cmove line-buffer c-num + swap cmove gcline @ c-num + line-buffer len c-num + + gclen @ c-num - cmove ( move everything into the line buffer )
          here line-buffer here len gclen @ + allot len gclen @ + cmove gcline !
          len gclen @ + gclen ! ;



( line-num ) ( delete given line )
: del     1 - addify curr-line @ linelist-next @ curr-line @ linelist-next @ linelist-next @ curr-line @ linelist-next !
          free throw num-lines @ 1 - num-lines ! ;
( delete the first line )
: d0      fhead @ fhead @ linelist-next @ fhead ! free throw num-lines @ 1 - num-lines ! ;

create newl 1 allot
10 newl !
: clearall initial-mem @ here - allot ;
( save changes ) ( maybe just refactor to use while loop instead of for loop to avoid off by 1 errors )
: w       rcurr clean 0 num-lines @ 1 u+do gcline @ gclen @ tuck 1 - fh @
          write-line throw n-line + loop 0 fh @ resize-file close deinit clearall ;

( line-num -- c-addr len ) ( copy a line )
: c       addify gcline @ gclen @ ;

( I edited this line using this new sr feature it felt so cool im literally this 1950s IBM superhacker )
( c-addr1 u1 c-addr2 u2 line-num -- [replace string 2 with string 1 on line-num] )
: sr    b2fill dup addify gclen @ { c1 u1 c2 u2 line-num length }
        0 0 begin gcline @ over + u2 c2 u2 compare
        if 2dup gcline @ + c@ swap buffer2 + c! 1 + swap 1 + swap ( not a match )
        else over buffer2 + c1 swap u1 cmove u2 + swap u1 + swap gclen @ u1 u2 - + gclen ! endif ( match between the strings )
        dup length 1 - > until drop drop ; ( this is criminal forth style here but it works so wtv )

( c-addr1 u1 c-addr2 u2 start-line end-line -- [replace string 2 with string 1 on all lines in a range] )
: srmul  { c1 u1 c2 u2 l1 l2 } l2 1 + l1 u+do c1 u1 c2 u2 i sr buffer2 gclen @ 1 - i in loop ;
: sc { c1 u1 line-num } 0 line-num addify begin gcline @ over + u1 c1 u1 compare
0= if line-num . dup . 59 emit endif 1 + dup gclen @ 1 - >= until drop ;

( c1 u1 line-start line-end )
: scmul swap 1 + u+do 2dup i sc loop drop drop ;
( also inserted the newlines after reloading this code and using nline which I wrote in this editor yeaaaaaaaaa )
: yay s" yay!" type ;
create qmark 1 allot 34 qmark !
( line-num -- replace [quote] with a quotation mark on line-num )
: qrep { num } qmark 1 s" quote" num num srmul ;

( this needs to be at the end of the file, keeps track of the starting point for allocations so that saving frees everything done since )
here initial-mem !
