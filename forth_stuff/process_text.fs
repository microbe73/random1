( Approximately following https://www.youtube.com/watch?v=mvrE2ZGe-rs )
( the vision is that I combine this stuff with the array words in order to )
( essentially create a programming language )
empty

: srcfile   s" a.txt" ;

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
: advance   1 offset +! ;
: seek      begin chr -ws while advance repeat ;
: token     addr seek addr over - advance 2dup #token ! 'token ! ;
: .token    'token @ #token @ type ;
: error     cr cr .token -1 abort" Command was not found" ;
: command   token sfind if execute else error then ;
( convert string to integer )
: atoi      c@ 48 - .token ;
( fill up the newly created array with the correct elements )
: fill      .token drop drop ;
: array     token drop atoi dup cells allocate throw dup -rot ! token fill ;
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
