: empty     s" ---marker--- marker ---marker---" evaluate ;
: edit      s" nvim process_text.fs" system ;
: run       s" process_text.fs" included ;
: ecr       edit run ;

marker ---marker---
