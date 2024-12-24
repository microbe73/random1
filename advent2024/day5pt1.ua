# Experimental!
R     ← &fras "day5_1.txt"
I     ← &fras "day5_2.txt"
Rules ← ↯ ∞_2⊜⋕⊸∈+@0⇡ 10 R
Inp   ← ⊜(□⊜⋕≠@,.)≠@\n. I
°□/+⍚(⊡÷ 2 - 1 ⧻.)⍚×Inp⍚(/×∈ Rules)⍚(⧅< 2) Inp
