structure AST = struct
  datatype term
  = Nat of int
  | True
  | False
  | Add of term * term
  | And of term * term
  | List of term list
  | Head of term

end

