structure AST = struct
  structure T = Types
  datatype term
  = Nat of int
  | True
  | False
  | Add of term * term
  | And of term * term
  | List of term list
  | Head of term
  | Char of char
  | Real of real
  | Sub of term * term
  | Or of term * term
  | If of term * term * term
  | Mul of term * term
  | Div of term * term
  | Concat of term * term
  | Comp of term * term
  | Lt of term * term
  | Gt of term * term
  | Exn of string
  | Var of string
  | Lam of string * T.typ * term
  | App of term * term
  | Let of term * term * term
end

