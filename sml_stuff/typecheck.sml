structure TypeCheck : sig
  val check : AST.term -> Types.typ
end = struct
  fun check term = raise Fail "todo: Type Checker implementation"
end
