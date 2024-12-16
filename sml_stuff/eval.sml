structure Eval : sig
  val isV : AST.term -> bool
  val step : AST.term -> AST.term option
  val eval : AST.term -> AST.term list
end = struct
  structure A = AST
  fun isV term =
    (case term
       of A.Nat n => true
        | A.True => true
        | A.False => true
        | A.List lst => true
        | _ => false
    )
  fun step term = raise Fail "todo: Step one evaluating step"
  fun eval term = raise Fail "todo: Evaluation"


end
