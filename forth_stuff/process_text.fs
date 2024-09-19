( https://www.youtube.com/watch?v=mvrE2ZGe-rs )



( essentially create a programming language )
empty

: srcfile   s" c.txt" ;

( buffer for reading )
variable 'src
variable #src
variable fh

: open      srcfile r/o open-file throw fh ! ;
: close     fh @ close-file throw ;
( read 1024 bytes of the file at a time, throw any exceptions, read until the end )
: read      begin here 1024 fh @ read-file throw dup allot 0= until ;
( for measuring length of the file )
: start     here 'src ! ;
: finish    here 'src @ - #src ! ;
( reading the file properly )
: gulp      open read close ;
: slurp     start gulp finish ;



( command dispatcher )
variable offset
variable 'token
variable #token
: addr      offset @ 'src @ + ;
: chr       addr c@ ;
: -ws       32 u> ;
: -,        44 <> ;
: advance   1 offset +! ;
: seek      begin chr -ws while advance repeat ;
: cseek     begin chr -, while advance repeat ;
: ctoken    addr cseek addr over - advance ;
: token     addr seek addr over - advance 2dup #token ! 'token ! ;
: .token    'token @ #token @ type ;
: error     cr cr .token -1 abort" Command was not found" ;
: command   token sfind if execute else error then ;
: 10^       1 swap 0 u+do 10 * loop ;

( convert string to integer: takes addr len -- num)
: ctoi      c@ 48 - ;

: atoi      dup 1 - 10^ swap 0 swap 0 u+do >r swap dup ctoi rot 2dup *
            -rot nip 10 / swap r> + rot 1 + -rot loop nip nip ;

( fill up the newly created array with the correct elements )
: fill      dup @ 0 u+do dup 1 i + cells + ctoken atoi swap ! loop ;
: array     token atoi dup 1 + cells allocate throw dup -rot ! fill ;
: iw        ." <i>" token type ." </i>" ;
: bw        ." <b>" token type ." </b>" ;

( process input buffer )
: entity    [char] & emit type [char] ; emit ;
: rdrop     postpone r> postpone drop ; immediate
: call      >r ;
: ===>      over = if drop r> call entity rdrop exit then rdrop ;
: eitherA   dup [char] A = if drop array rdrop exit then  ;
: or<       [char] < ===> s" lt" ;
: or>       [char] > ===> s" gt" ;
: orEsc     dup [char] ~ = if drop command rdrop exit then ;
: interpret chr advance eitherA orEsc ( else ) emit ;
: -end      offset @ #src @ u< ;
: process   0 offset ! begin -end while interpret repeat ;

slurp


slurp


end while interpret repeat ;

slurp


slurp

