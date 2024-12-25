# Experimental!
R     ← &fras "day22.txt"
W     ← ⍚(⋕)⊜□ ≠@\n. R
Prune ← ◿ 16777216
Mix   ← °⋯◿ 2+°⊟⬚0⊟ ∩⋯°⊟⇌⍆ ⊟
Next  ← Prune Mix⊸× 2048Prune Mix⊸(⌊ ÷ 32) Prune Mix⊸× 64
/+ ⍚(⍥(Next) 2000) W
