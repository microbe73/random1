structure LexicalToken = struct
  datatype token
  = True
  | False
  | Nat of int
  | Char of char
  | Real of real
  | RPar
  | LPar
  | RBrac
  | LBrac
  | And
  | Add
  | Comma
  | Head
end
