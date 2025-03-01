( editor Variables )
variable fh ( file handler )
variable curr-line ( struct pointer, @ needed to get struct  )
variable num-lines ( int pointer )
variable fhead ( struct pointer )
variable initial-mem
variable last-edit ( struct pointer )
variable clear-undo ( when performing an edit after an undo, the entire undo list needs to be cleared )
variable clear-redo ( if a redo is performed, set this so we don't clear the undo list. )
variable next-redo ( struct pointer )
256 Constant max-line
create line-buffer max-line allot

begin-structure linelist ( -- u )
    field: linelist-next ( intlist -- addr1 ) ( struct pointer )
    field: linelist-line  ( intlist -- addr2 ) ( string pointer [char*[]] )
    field: linelist-len ( intlist -- addr3 ) ( int pointer )
end-structure



begin-structure editnode
    field: editnode-edittype ( int* )
    field: editnode-prevedit ( editnode* )
    field: editnode-linenum ( undoin -- num ) ( int* )
    field: editnode-textptr ( char** )
    field: editnode-len ( int* )
end-structure


( clear the undo list [ -- ] )
: unclear   clear-undo @ if begin
            last-edit @ dup dup while editnode-prevedit @ last-edit ! free throw repeat
            0 clear-undo ! 0 next-redo ! 2drop then ;
: bfill     max-line 0 u+do line-buffer i + 0 swap ! loop ;
bfill
0 num-lines !
0 last-edit !
0 next-redo !
0 clear-undo !
( QOL WORDS )
( []  -- linelist-line [ gets pointer to current line's text ] )
: gcline    curr-line @ linelist-line ;
: gclen     curr-line @ linelist-len ;
: gcnext    curr-line @ linelist-next ;

( set curr-line back to start )
: rcurr     fhead @ curr-line ! ;
( -- [sets curr-line's fields to 0] )
: nullify   0 gcline ! 0 gclen ! 0 gcnext ! ;
( sets curr-line to the next line )
: n-line    curr-line @ linelist-next @ curr-line ! ;

( line-num -- [sets curr-line to the addressed line] )
: addify    rcurr 1 u+do n-line loop ;

( ptr -- [increase/decrease the value pointed to by 1] )
: ++        dup @ 1 + swap ! ;
: --        dup @ 1 - swap ! ;
: gl        1 num-lines @ 1 - ;

: itoa      48 + emit ;
: get-dig   0 swap begin 10 / swap 1 + swap dup 0= until drop ;
: get-plc   get-dig 1 tuck u+do 10 * loop ;
( num -- [prints out the number to stdout] )
: itos      dup get-dig 0 u+do dup get-plc 2dup / itoa mod loop drop ;



( FILE I/O OPERATIONS )
( addr u -- [Opens the file] )
: open      r/w open-file throw fh ! ;

: close     fh @ close-file throw ;

: clean     0 0 fh @ reposition-file throw ;

: lat       linelist allocate throw ;

: l-load    { len } align here line-buffer align here len allot len cmove gcline ! len gclen ! ( set values for this line )
            lat gcnext ! gcnext @ curr-line !  nullify ( move pointer to next line, set to 0s to avoid weird bugs ) ;

: f-load    begin bfill line-buffer max-line fh @ read-line throw num-lines ++ while 1 + l-load repeat bfill ;

( c-addr u -- [load a file into memory] )
: init      open lat fhead ! rcurr clean f-load drop ;

: deinit    rcurr begin curr-line @ dup linelist-next @ swap free throw dup curr-line ! until ;



( start-line end-line )
: p         10 emit over addify 1 + swap u+do gcline @ i itos 58 emit 32 emit gclen @ type 10 emit n-line loop ;
( print entire file to stdout )
: ,p        gl p ;

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
: enat      editnode allocate throw ;
( lnum n -- [creates a new editnode, adds it to list] )
: usetup    unclear enat tuck editnode-edittype ! gcline @ over editnode-textptr ! gclen @ over editnode-len !
            over over editnode-linenum ! nip last-edit @ over editnode-prevedit ! last-edit ! ;

( the edit nodes for non-destructive text insertions need to be made differently )
: uisetup   unclear enat tuck editnode-edittype ! tuck editnode-linenum ! over swap tuck
            editnode-len ! rot tuck over editnode-textptr ! last-edit @ over editnode-prevedit !
            last-edit ! swap ;
( INSERTION WORDS )
( c-addr u line-num -- ) ( replace line with other text )
: in        dup addify 3 usetup { len } len mhere gcline ! len 1 + gclen ! ;

: ia        dup addify 4 uisetup { len } len mhere lat gcnext @ over gcnext ! over linelist-next ! len 1 + over
            linelist-len ! linelist-line ! num-lines ++ ;

( c-addr u ) ( insert text before the first line )
: i0        rcurr 1 1 uisetup { len } len mhere lat tuck linelist-line ! fhead @ over linelist-next !
            len 1 + over linelist-len ! fhead ! num-lines ++ ;

( c-addr u line-num c-num -- ) ( insert text at a specific character in a line )
: ic        bfill swap dup >r addify bound prein newin postin line-buffer swap 1 - r> in ;

( DELETION WORDS )
( line-num -- )
: del       dup dup addify 5 usetup 1 - addify gcnext @ gcnext @ linelist-next @ gcnext ! free throw num-lines -- ;
( delete the first line )
: d0        rcurr 1 2 usetup fhead @ fhead @ linelist-next @ fhead ! free throw num-lines -- ;

( UNDO/REDO WORDS )
: set-redo  next-redo @ over editnode-prevedit ! next-redo ! ;
: redid     next-redo @ dup editnode-prevedit @ next-redo ! free throw 1 clear-undo ! ;
: undid     last-edit @ dup editnode-prevedit @ last-edit ! set-redo 1 clear-undo ! ;
( editnode -- )
: uni0      drop fhead @ fhead @ linelist-next @ fhead ! free throw num-lines -- ;
: und0      lat over editnode-textptr @ over linelist-line ! over editnode-len @ over linelist-len ! \ same as dl just with fhead instead
            fhead @ over linelist-next ! fhead ! drop num-lines ++ ; \ set the new line to be in fhead, set its next line to be current fhead
: unin      dup editnode-linenum @ addify dup editnode-textptr @ over gcline @ swap editnode-textptr !
            gcline ! dup editnode-len @ over gclen @ 1 - swap editnode-len ! gclen ! drop ;
: unia      editnode-linenum @ addify gcnext @ gcnext @ linelist-next @ gcnext ! free throw num-lines -- ;
: undl      dup editnode-linenum @ 1 - addify lat over editnode-textptr @ over linelist-line ! \ allocate new linelist, set text to be stored, also addify prev line
            over editnode-len @ over linelist-len ! gcnext @ over linelist-next ! gcnext ! drop num-lines ++ ;

: rei0      dup editnode-textptr @ swap editnode-len @ i0 ;
: rein      dup editnode-textptr @ swap dup editnode-len @ swap editnode-linenum @ in ;
: reia      dup editnode-textptr @ swap dup editnode-len @ swap editnode-linenum @ ia ;
: redl      editnode-linenum @ del ;

: undo      last-edit @ dup editnode-edittype @
            case
                1 of uni0 endof
                2 of und0 endof
                3 of unin endof
                4 of unia endof
                5 of undl endof
                drop s" didn't undo anything might be error but the experienced programmer will know what's wrong" type
            endcase undid ;

: redo      0 clear-undo ! next-redo @ dup editnode-edittype @
            case
                1 of rei0 endof
                2 of d0   endof
                3 of rein endof
                4 of reia endof
                5 of redl endof
                drop s" Did not redo the experienced programmer will know what's wrong" type
            endcase redid ;
create newl 1 allot
10 newl !
: clearall  0 clear-undo ! unclear initial-mem @ here - allot ;
( save changes )
: w         rcurr clean 0 num-lines @ 1 u+do gcline @ gclen @ tuck 1 - fh @
            write-line throw n-line + loop 0 fh @ resize-file close deinit clearall 0 num-lines ! 0 fhead !  ;

( line-num -- c-addr len ) ( copy a line )
: c         addify gcline @ gclen @ ;

( SEARCHING AND REPLACING )
: no-mat    2dup gcline @ + c@ swap line-buffer + c! 1 + swap 1 + swap ;

( c-addr1 u1 c-addr2 u2 line-num -- [replace string 2 with string 1 on line-num, cannot be called standalone] )
: sr        bfill dup addify gclen @ { c1 u1 c2 u2 line-num length }
            0 0 0 begin gcline @ over + u2 c2 u2 compare if no-mat
            else rot 1 + -rot over line-buffer + c1 swap u1 cmove u2 + swap u1 + swap gclen @ u1 u2 - + gclen ! endif
            dup length 1 - > until drop drop ;

( num-changes u1 u2 )
: newlen    - * gclen @ + gclen ! ;
( c-addr1 u1 c-addr2 u2 start-line end-line -- [replace string 2 with string 1 on all lines in a range] )
: srmul     { c1 u1 c2 u2 l1 l2 } l2 1 + l1 u+do c1 u1 c2 u2 i sr dup if \ If there was a replacement, actually change it
            >r line-buffer gclen @ 1 - r> u2 u1 newlen i in else drop endif loop ;

( c1 u1 line-num )
: sc        { c1 u1 line-num } 0 line-num addify begin gcline @ over + u1 c1 u1 compare
            0= if line-num . dup . 59 emit endif 1 + dup gclen @ 1 - >= until drop ;

( c1 u1 line-start line-end )
: scmul     1 + swap u+do 2dup i sc loop drop drop ;

: yay       s" yay!" type ;
create qmark 1 allot 34 qmark !
( line-num -- replace [quote] with a quotation mark on line-num )
: qrep      { num } qmark 1 s" quote" num num srmul ;

( this needs to be at the end of the file, keeps track of the starting point for allocations so that saving frees everything done since )
here initial-mem !
