structure Eval : sig
  val eval : AST.term -> AST.term
end = struct
  structure A = AST
  fun eval term =
    (case term
       of A.Add (t1, t2) =>
            let
              val t1prime = eval t1
              val t2prime = eval t2
            in
              (case t1prime
                 of A.Nat n1 => (case t2prime
                                  of A.Nat n2 => A.Nat (n1 + n2)
                                    | _ => raise Fail "Adding non-numbers"
                                )
                  | _ => raise Fail "Adding non-number"
              )
            end
        | A.And (t1, t2) =>
            let
              val t1prime = eval t1
              val t2prime = eval t2
            in
              (case t1prime
                 of A.True => t2
                  | A.False => A.False
                  | _ => raise Fail "Anding non-bool"
              )
            end
        | A.Head t1 =>
            let
              val t1prime = eval t1
            in
              (case t1prime
                 of A.List (h :: l1) => h
                  | _ => raise Fail "Head of non-list"
              )
            end
        | _ => term
    )


end
