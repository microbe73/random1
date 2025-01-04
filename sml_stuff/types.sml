structure Types = struct
  datatype typ
  = Nat
  | Real
  | Char
  | Bool
  | List of typ
  | Func of typ * typ
end
