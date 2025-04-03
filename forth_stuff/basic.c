#include "basic.h"
#include <gforth.h>
int add(int a, int b){
  return a + b;
}
Cell gforth_main(int argc, char **argv, char **env)
  Cell retvalue=gforth_start(argc, argv);

  if(retvalue == -56) { /* throw-code for quit */
    retvalue = gforth_bootmessage();     // show boot message
    if(retvalue == -56)
      retvalue = gforth_quit(); // run quit loop
  }
  gforth_cleanup();
  gforth_printmetrics();
  // gforth_free_dict(); // if you want to restart, do this

  return retvalue;
}
int main(){
// just a chill comment
  return 0;
}
