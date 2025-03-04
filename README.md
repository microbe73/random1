
# random1

<!--toc:start-->
- [random1](#random1)
  - [Forth Stuff](#forth-stuff)
    - [Ed.fs](#edfs)
    - [Arrays](#arrays)
    - [Other things](#other-things)
  - [SML Stuff](#sml-stuff)
    - [The LISP-style Interpreter](#the-lisp-style-interpreter)
  - [Coq Stuff](#coq-stuff)
    - [Math](#math)
  - [Advent of Code](#advent-of-code)
    - [Array Langauge solutions](#array-langauge-solutions)
  - [Script Stuff](#script-stuff)
  - [Everything Else](#everything-else)
  - [Have a nice day, and good luck in your future programming adventures](#have-a-nice-day-and-good-luck-in-your-future-programming-adventures)
<!--toc:end-->

If anyone is here it is likely because I have sold out another one of my non-monetary related interests to try and get an internship or something, I personally enjoy most the
kind of programming I do in this repository.
## Forth Stuff
### Ed.fs
The most interesting project in the forth_stuff folder is ed.fs. Ed.fs is legally a Forth text editor, thanks to how Forth is a free REPL language you can interact with text 
files in a manner similar to the ed text editor, load a file into memory and then you push a string onto the stack along with a line to insert it on, at or after (or line and
character to insert it between) and can then edit the text in a REPL fashion. It also has features like search and replace and undo/redo. Under the hood it doesn't use the
best text storage data structure ever (it is a linked list of line arrays which store the length), but it isn't too space inefficient and it is quite easy to work with when 
coding it. Also it's technically infinitely extensible because you are just in the Forth REPL sooo.
### Arrays
There is also the process_text.fs and forth_arrays.fs files, in tandem they allow you to parse a simple text file like c.txt and basically pre-load some arrays into memory,
in a syntax that is slightly less bad than Forth's idea of just manually moving a pointer and assigning values each time. The process_text.fs file comes largely from this 10
year old (maybe even longer) Youtube video, I followed it as a tutorial to learn Forth
### Other things
The forth_stuff folder also has a few (somewhat unsuccessful) Forth experiments trying to work with things like scripting and the C interface \
Forth is really cool though!
## SML Stuff
### The LISP-style Interpreter
The project in the SML stuff folder is a simple interpreter for a lisp-style recursive descent parsed language. It has features like let bindings, typechecking, lists, and
lambda expressions, and basic arithmetic/boolean/string stuff, I think the best aspect of it is the modularity of the design (which SML helps with a lot), its really easy to
keep track of exactly what does what, where to put functions, and adding a new simple builtin like a square root for example is basically a trivial exercise at this point,
just add it into the AST and let the LSP errors tell you how to fill in the rest. Functional programming is also really cool!
## Coq Stuff
### Math
I proved some stuff in Coq, mostly just messing around with natural number theorems and then also I followed along with a Coq book tutorial for a bit and made the other file
## Advent of Code
### Array Langauge solutions
The Advent2023 and 2024 folders were me solving a couple of Advent of Code problems in the J and Uiua langauges, respectively. J was the first "unusual" language I tried to
program in back in 2023, I found it enjoyable but I struggled to solve even the first couple of days, and I could tell I stylistically did not understand the language, my J
code certainly does not look the best even if it gets the job done, and in APL descendants the visual purity of the code is a very good marker for the quality and honestly
the runtime. In 2024 I used Uiua, which was a language I really enjoyed. The combination of the stack and array paradigms was really interesting, I was a bit biased as I
already knew Forth but I found the stack a much easier way to pass around the various strange arrays and matrices that get created when solving problems in array languages.
I think Uiua has a lot of potential, its core principles are just nice and the code is aesthetic when it is well-written.
## Script Stuff
A few bash and C scripts for automating some simple tasks.
## Everything Else
I saw this thing about the Math behind Diplomacy and actually the adjudication algorithm it showed a part of was really not bad at all, but I might need to be in a non-school
headspace for me to really think through how to make that idea work and implement a geniune Diplomacy interface. I also tried learning Rust, I know C and enjoy functional
programming but somehow so far Rust hasn't quite clicked yet, a lot of stuff I like such as Uiua and Millet is written in Rust so I do want to know it I just haven't quite
"gotten" it yet, but I'll keep trying.
## Have a nice day, and good luck in your future programming adventures
the heading says it all

