( editor variables )
variable fh
variable start
variable curr-line
256 Constant max-line
Create line-buffer max-line 2 + allot


: f       s" process_text.fs" ;


: open    f r/w open-file throw fh ! fh @ start ! ;
: close   fh @ close-file throw ;
: clean   close open ; ( Reset file handler to beginning )
( print entire file to stdout )
: ,p      begin line-buffer max-line fh @ read-line throw line-buffer rot
          stdout write-line throw 0= until .s clean ;
( line_num c-addr u -- )
: a       rot 0 u+do line-buffer max-line fh @ read-line throw drop drop loop
          fh @ write-file clean ;
: t       line-buffer 256 fh @ read-line throw drop clean ;
: q       fh @ write-line clean ;
 
