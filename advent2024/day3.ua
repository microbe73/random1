R       ← &fras "day3.txt"
Valid   ← regex "mul\\(\\d\\d*,\\d\\d*\\)" R
Extract ← ⍚((⍚°□°□°□ Valid))
Nums    ← ⍚((⍚(regex "\\d\\d*"))) Extract
Parser  ← ⍚(⋕ Nums)
# Part 1
/+ ⍚(/× /×) Parser
