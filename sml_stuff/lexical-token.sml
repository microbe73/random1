structure LexicalToken = struct
  datatype token
  = True
  | False
  | Nat of int
  | RPar
  | LPar
  | RBrac
  | LBrac
  | And
  | Add
  | Comma
  | Head
end
