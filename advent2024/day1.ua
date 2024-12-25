# Experimental!
# Todo: 22 p1, 2p2, 3p1, 4
R ← &fras "day1.txt"
# So the first question has essentially two lists but in column format
# W takes the lists, splits on spaces and newlines to get a rank 2 list, and
# then calling transpose makes it essentially two lists like this:
# [[3 4 2 1 3 3] [4 3 5 2 9 9]].
# Part 1 is quite simple, just sorting the lists, subtracting and taking the
# absolute value to find the distances is all we need.
# For part 2, to find the similarity score we split into the two arrays, and 
# then for each element in the first array (the three dots), we use find to
# get a mask of where it appears in the array and then a sum reduce gives us
# the total number of times that it appears in the array. We then multiply
# the resulting array we get, a count of the frequency of elements of the
# first array in the second, by the first array and sum reduce for the solution
W ← ⍉⊜(⊜⋕≠@ .)≠@\n. R
# Part 1
/+⌵-°⊟≡(⍆)W
# Part 2 (finding the similarity score)
Arrfir ← ⊙◌°⊟W
Arrsnd ← ◌∵□°⊟W
∵(/+⌕ : Arrsnd) Arrfir
/+ × Arrfir
