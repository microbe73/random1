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



variable offset
( For any special characters, replace the character [i.e c] with &c;, )
( this can be modified easily, useful for escaping special characters in the conversion )
: entity    [char] & emit type [char] ; emit ;
: rdrop     postpone r> postpone drop ; immediate
: call      >r ;
: ===>      over = if drop r> call entity rdrop exit then rdrop ;
: either&   [char] & ===> s" amp" ;
: or<       [char] < ===> s" lt" ;
: or>       [char] > ===> s" gt" ;
: interpret either& or< or> ( else ) emit ;

: process   0 offset ! begin offset @ #src @ u< while
            'src @ offset @ + c@ interpret 1 offset +! repeat ;

slurp
