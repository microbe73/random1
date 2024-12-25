# Experimental!
# .,:∘◌¬±¯⌵√∿⌊⌈⁅=≠<>≤≥+-×÷◿ⁿₙ↧↥∠ℂ⧻△⇡⊢⊣⇌♭¤⋯⍉⍆⍏⍖⊚⊛◴◰□⋕≍←↚~|#|^
# ⊟⊂⊏⊡↯↙↘↻⤸▽⌕⦷∊⊗/∧\∵≡⍚⊞⧅⧈⍥⊕⊜◇⋅⊙⟜⊸⤙⤚◡∩⌅°⌝⍜⊃⊓⍢⬚⨬⍣⍩⍤⚂ηπτ∞?_¯@$!
# So i cheated a little bit but when opening my puzzle input I highlighted
# the part with the rules and the part with the actual rows and just made them
# two separate files for convenience. However, it's again crazy to me how
# short the solution is even 5 days in, when typically stuff gets more complex
# . For the days where they work well array languages work incredibly (strings
# and other stuff like graphs or trees are much harder to represent).
# The first part of my solution involved taking the tuples of the array which
# were pairs of elements with every element after them i.e. 75,47,61,53
# becomes [[75 47] [75 61] [75 53] [47 61] [47 53] [61 53]] (literally 3
# characters to do this btw). I then went through all of the elements of this
# new tuple array to check if each one is in the rule array and reduced with
# multiplication so I have either 1 or 0 for every single one, since if every
# tuple is in the rule array then every element will be 1, otherwise not.
# By the way the rules are parsed as a 2D array of tuples by matching for
# numbers and just splitting and the input is converted again to a box of
# arrays since the arrays have different lengths.
# After getting a new box which has a 1 wherever the input satisfies all of
# the rules and a 0 everywhere it doesn't, I multiplied the original input by
# this result (since array languages just let you do 1 * [1 2 3 4] cuz they
# are cool like that), and then found the middle element of each array with
# dividing 1 - the length by 2. This works since any arrays which violate the
# rules will just end up with 0 as their middle elements since we multiply by
# 0, and since we have to just return the sum of all of the legal ones the
# illegal ones are zeroed out so a simple sum reduce solves day 5!
R     ← &fras "day5_1.txt"
I     ← &fras "day5_2.txt"
Rules ← ↯ ∞_2⊜⋕⊸∊+@0⇡ 10 R
Inp   ← ⊜(□⊜⋕≠@,.)≠@\n. I
°□/+⍚(⊡÷ 2 - 1 ⧻.)⍚×Inp⍚(/×∊ Rules)⍚(⧅< 2) Inp
