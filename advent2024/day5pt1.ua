# Experimental!
R     ← &fras "day5_1.txt"
I     ← &fras "day5_2.txt"
Rules ← ↯ ∞_2⊜⋕⊸∈+@0⇡ 10 R
Inp   ← ⊜(□⊜⋕≠@,.)≠@\n. I
# Rules ← [[1 5] [7 1] [5 3] [1 0] [3 8] [1 3] [1 8] [5 8] [5 0] [3 0] [8 0]]
In ← {[1 5 3 8 0] [1 7 0]}
°□/+⍚(⊡÷ 2 - 1 ⧻.)⍚×Inp⍚(/×∈ Rules)⍚(⧅< 2) Inp
