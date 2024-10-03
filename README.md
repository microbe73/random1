# random1
If anyone is here it is likely because I have sold out another one of my non-monetary related interests to try and get an internship or something, I personally enjoy most the kind of programming I do in this repository.

The most interesting project here in my opinion is the forth_stuff folder. There are the process_text.fs and forth_arrays.fs files which combined create something resembling an array language: you can call the words in forth_arrays.fs in order to do some basic 1D array operations. The c.txt file is an example of this, calling process in the process_text.fs file will
compute the addition result and put it into the third array. There is also the ed.fs file, which is legally a text editor. It stores text primitively just as a 2D array so lines have to be less than 256 characters long, but it works in a similar manner to the ed text editor. You can call gforth ed.fs, then load a file into memory in the editor and print lines from it,
write new lines, and even use search and replace. You can then save the file and load another.

The coq_stuff folder has some basic experiments in the coq language, mostly just messing around with natural number theorems

The advent2023 and Euler folders are written in J and were basically me exploring array languages.
