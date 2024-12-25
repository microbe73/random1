# Experimental!
R ← &fras "day2.txt"
W ← ⊜(□⊜⋕≠@ .)≠@\n.R
# Part 1
# I spent like an hour going in circles on part 2 lol, I like kinda need to do
# a non-tacit thing but don't know how to do it with combinators oops
# Anyway, this code starts by converting the input text into a box of arrays
# (since the rows can have different sizes), and then in very poor Uiua style
# (I think this was a good bit more characters and stack juggling than it
# needed to be [also idk why that bug happens I set the thing to dark mode in
# the plugin wtvr]), but it takes the initial array, computes the difference
# between each element pairwise with the window function giving the pairs and
# then transposing to get two arrays, one with the first elements of each pair
# and the other with the second, and then subtracting. Afterwards I put that
# array through the constraints: has to be all positive or all negative
# steps and every step has to have absolute value between 1 and 3. Each of
# these phases leaves a 1 or 0 on the stack if it is true or false, so simple
# multiplication means we get 1 only for rows which satisfy the constraints
# and 0 otherwise, so a sum reduce gives the answer. (BTW it's kinda crazy
# that 20 lines of english text is literally a one liner in Uiua under 50 chars
# like wow)
Safe ← ××∩/×≥1:≤3.⌵:⊸(×∩(=1⧻◴)>0:<0.) -°⊟⍉⧈∘ 2 # (check if an array is safe)
# Part 1
/+⍚(Safe) W
# Part 2
Cnew ← ≡⍜(↻|↘ 1) ⇡ ⊃⧻ ¤
/+ ∨ ⍚(Safe) W ⍚(≥1 /+≡(Safe) Cnew) W
