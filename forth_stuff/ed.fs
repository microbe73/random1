( Editor Variables )
variable fh ( file handler )
variable curr-line ( struct pointer, @ needed to get struct  )
variable num-lines ( int pointer )
variable fhead ( struct pointer )
variable initial-mem
variable last-edit ( struct pointer )
256 Constant max-line
create line-buffer max-line allot

begin-structure linelist ( -- u )
    field: linelist-next ( intlist -- addr1 ) ( struct pointer )
    field: linelist-line  ( intlist -- addr2 ) ( string pointer [char*[]] )
    field: linelist-len ( intlist -- addr3 ) ( int pointer )
end-structure
( The next step: undo feature. The way the editor works right now this is actually "free" in a memory sense, since we are re-assigning memory a bunch already
 also it is somewhat clear to me how to do it )

( I think by induction these structures only need to assume they were the most recent edit so line number stuff shouldnt be an issue )
begin-structure undonode
    field: undonode-edittype ( int* )
    field: undonode-prevedit ( undonode* )
    field: undonode-linenum ( undoin -- num ) ( int* )
    field: undonode-textptr ( char** )
    field: undonode-len ( int* )
end-structure



: bfill   max-line 0 u+do line-buffer i + 0 swap ! loop ;
bfill
0 num-lines !

( QOL WORDS )
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

( ptr -- [increase/decrease the value pointed to by 1] )
: ++      dup @ 1 + swap ! ;
: --      dup @ 1 - swap ! ;
: gl 1 num-lines @ 1 - ;

: itoa     48 + emit ;
: get-dig  0 swap begin 10 / swap 1 + swap dup 0= until drop ;
: get-plc  get-dig 1 tuck u+do 10 * loop ;
( num -- [prints out the number to stdout] )
: itos     dup get-dig 0 u+do dup get-plc 2dup / itoa mod loop drop ;



( FILE I/O OPERATIONS )
( addr u -- [Opens the file] )
: open    r/w open-file throw fh ! ;

: close   fh @ close-file throw ;

: clean   0 0 fh @ reposition-file throw ;

: lat     linelist allocate throw ;

: l-load  { len } align here line-buffer align here len allot len cmove gcline ! len gclen ! ( set values for this line )
          lat gcnext ! gcnext @ curr-line !  nullify ( move pointer to next line, set to 0s to avoid weird bugs ) ;

: f-load  begin bfill line-buffer max-line fh @ read-line throw num-lines ++ while 1 + l-load repeat bfill ;

( c-addr u -- [load a file into memory] )
: init    open lat fhead ! rcurr clean f-load ;

: deinit  rcurr begin curr-line @ dup linelist-next @ swap free throw dup curr-line ! until ;



( start-line end-line )
: p        10 emit over addify 1 + swap u+do gcline @ i itos 58 emit 32 emit gclen @ type 10 emit n-line loop ;
( print entire file to stdout )
: ,p       gl p ;

( INSERTION WORDS SETUP )
( c-num -- c-num{!} [checks if c-num is more than the length of the current line, aborts if it is] )
: bound     gclen @ over < if -1 abort" Illegal insertion beyond end of line" endif ;
( c-num -- c-num [moves the first c characters of the current line into the line buffer] )
: prein     gcline @ over line-buffer swap cmove ;
( c-addr u c-num -- u c-num [moves the u characters offset by c places into the line buffer] )
: newin     dup >r line-buffer + swap dup >r cmove r> r> ;
( u c-num -- new-len [inserts the last part into the line buffer] )
: postin    { u c-num } gcline @ c-num + line-buffer c-num u + + 
            gclen @ c-num - cmove gclen @ u + ;
( c-addr u -- new-addr [move an input string into a new address, null-terminate it] )
: mhere     { len } here len allot tuck len cmove 0 c, ;
: unat      undonode allocate throw ;
( lnum n -- [creates a new undonode, adds it to list] )
: usetup    unat tuck undonode-edittype ! gcline @ over undonode-textptr ! gclen @ over undonode-len !
            over over undonode-linenum ! nip last-edit @ over undonode-prevedit ! last-edit ! ;
( INSERTION WORDS )
( c-addr u line-num -- ) ( replace line with other text )
: in        dup addify 3 usetup { len } len mhere gcline ! len 1 + gclen ! ;

: ia        dup addify 4 usetup { len } len mhere lat gcnext @ over gcnext ! over linelist-next ! len 1 + over
            linelist-len ! linelist-line ! num-lines ++ ;

( c-addr u ) ( insert text before the first line )
: i0        rcurr 1 1 usetup { len } len mhere lat tuck linelist-line ! fhead @ over linelist-next !
            len 1 + over linelist-len ! fhead ! num-lines ++ ;

( c-addr u line-num c-num -- ) ( insert text at a specific character in a line )
: ic        bfill swap dup >r addify bound prein newin postin line-buffer swap 1 - r> .s in ;

( DELETION WORDS )
( line-num -- )
: del       dup dup addify 5 usetup 1 - addify gcnext @ gcnext @ linelist-next @ gcnext ! free throw num-lines -- ;
( delete the first line )
: d0        rcurr 1 2 usetup fhead @ fhead @ linelist-next @ fhead ! free throw num-lines -- ;

( UNDO WORDS )

: undid     last-edit @ undonode-prevedit last-edit ! ;
( undonode -- )
: uni0      d0 ;
: und0      lat over undonode-textptr @ over linelist-line ! over undonode-len @ over linelist-len ! \ same as dl just with fhead instead
            dup linelist-next fhead @ ! fhead ! drop num-lines ++ ; \ set the new line to be in fhead, set its next line to be current fhead
: unin      dup undonode-linenum @ addify dup undonode-textptr @ gcline ! undonode-len gclen ! ;
: unia      undonode-linenum @ 1 + del ;
: undl      dup undonode-linenum @ 1 - addify lat over undonode-textptr @ over linelist-line ! \ allocate new linelist, set text to be stored, also addify prev line
            over undonode-len @ over linelist-len ! gcnext @ over linelist-next ! gcnext ! drop num-lines ++ ;
( : unsr    unin )
( : unic    unin )
( undonode -- )
: undo      dup dup undonode-edittype @
            case
                1 of uni0 undid endof
                2 of und0 undid endof
                3 of unin undid endof
                4 of unia undid endof
                5 of undl undid endof
                drop s" didn't undo anything might be error but the experienced programmer will know what's wrong" type
            endcase ;

create newl 1 allot
10 newl !
: clearall initial-mem @ here - allot ;
( save changes )
: w       rcurr clean 0 num-lines @ 1 u+do gcline @ gclen @ tuck 1 - fh @
          write-line throw n-line + loop 0 fh @ resize-file close deinit clearall 0 num-lines ! 0 fhead !  ;

( line-num -- c-addr len ) ( copy a line )
: c       addify gcline @ gclen @ ;

( SEARCHING AND REPLACING )
: no-mat  2dup gcline @ + c@ swap line-buffer + c! 1 + swap 1 + swap ;

( c-addr1 u1 c-addr2 u2 line-num -- [replace string 2 with string 1 on line-num] )
: sr     bfill dup addify gclen @ { c1 u1 c2 u2 line-num length }
          0 0 begin gcline @ over + u2 c2 u2 compare if no-mat
          else over line-buffer + c1 swap u1 cmove u2 + swap u1 + swap gclen @ u1 u2 - + gclen ! endif
          dup length 1 - > until drop drop ;

         
( c-addr1 u1 c-addr2 u2 start-line end-line -- [replace string 2 with string 1 on all lines in a range] )
: srmul   { c1 u1 c2 u2 l1 l2 } l2 1 + l1 u+do c1 u1 c2 u2 i sr line-buffer gclen @ 1 - i in loop ;
: sc      { c1 u1 line-num } 0 line-num addify begin gcline @ over + u1 c1 u1 compare
          0= if line-num . dup . 59 emit endif 1 + dup gclen @ 1 - >= until drop ;

( c1 u1 line-start line-end )
: scmul 1 + swap u+do 2dup i sc loop drop drop ;
( also inserted the newlines after reloading this code and using nline which I wrote in this editor yeaaaaaaaaa )
: yay s" yay!" type ;
create qmark 1 allot 34 qmark !
( line-num -- replace [quote] with a quotation mark on line-num )
: qrep { num } qmark 1 s" quote" num num srmul ;

( this needs to be at the end of the file, keeps track of the starting point for allocations so that saving frees everything done since )
here initial-mem !
