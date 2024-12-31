structure Eval : sig
  val eval : AST.term -> AST.term
end = struct
  structure A = AST
  structure S = Subst
  fun eval term =
    (case term
       of A.Add (t1, t2) =>
            let
              val t1prime = eval t1
              val t2prime = eval t2
              val tprime = (t1prime, t2prime)
            in
              (case tprime
                 of (A.Nat n1, A.Nat n2) => A.Nat (n1 + n2)
                  | (A.Real r1, A.Real r2) => A.Real (r1 + r2)
                  | (A.Exn s, _) => A.Exn s
                  | (_, A.Exn s) => A.Exn s
                  | _ => raise Fail "Adding invalid terms"
              )
            end
        | A.Mul (t1, t2) =>
            let
              val t1prime = eval t1
              val t2prime = eval t2
              val tprime = (t1prime, t2prime)
            in
              (case tprime
                 of (A.Nat n1, A.Nat n2) => A.Nat (n1 * n2)
                  | (A.Real r1, A.Real r2) => A.Real (r1 * r2)
                  | (A.Exn s, _) => A.Exn s
                  | (_, A.Exn s) => A.Exn s
                  | _ => raise Fail "Multiplying invalid terms"
              )
            end
        | A.Sub (t1, t2) =>
            let
              val t1prime = eval t1
              val t2prime = eval t2
              val tprime = (t1prime, t2prime)
            in
              (case tprime
                 of (A.Nat n1, A.Nat n2) => if n1 - n2 >= 0 then A.Nat (n1 - n2)
                                            else A.Exn "Negative result"
                  | (A.Real r1, A.Real r2) => A.Real (r1 - r2)
                  | (A.Exn s, _) => A.Exn s
                  | (_, A.Exn s) => A.Exn s
                  | _ => raise Fail "Subtracting invalid terms"
              )
            end
        | A.Div (t1, t2) =>
            let
              val t1prime = eval t1
              val t2prime = eval t2
              val tprime = (t1prime, t2prime)
            in
              (case tprime
                 of (A.Nat n1, A.Nat n2) => if n2 = 0 then A.Exn "Div by 0" else A.Nat (n1 div n2)
                  | (A.Real r1, A.Real r2) => if  Real.== (r2, 0.0) then A.Exn "Div by 0.0"
                  else A.Real (r1 / r2)
                  | (A.Exn s, _) => A.Exn s
                  | (_, A.Exn s) => A.Exn s
                  | _ => raise Fail "Dividing invalid terms"
              )
            end
        | A.And (t1, t2) =>
            let
              val t1prime = eval t1
              val t2prime = eval t2
            in
              (case t1prime
                 of A.True => t2prime
                  | A.False => A.False
                  | A.Exn s => A.Exn s
                  | _ => raise Fail "Anding non-bool"
              )
            end
        | A.Or (t1, t2) =>
            let
              val t1prime = eval t1
              val t2prime = eval t2
            in
              (case t1prime
                 of A.True => A.True
                  | A.False => t2prime
                  | A.Exn s => A.Exn s
                  | _ => raise Fail "Oring non-bool"
              )
            end
        | A.Head t1 =>
            let
              val t1prime = eval t1
            in
              (case t1prime
                 of A.List (h :: l1) => eval h
                  | A.List [] => A.Exn "List out of bounds"
                  | A.Exn s => A.Exn s
                  | _ => raise Fail "Head of non-list"
              )
            end
        | A.If (t1, t2, t3) =>
            let
              val t1prime = eval t1
              val t2prime = eval t2
              val t3prime = eval t3
            in
              (case t1prime
                 of A.True => t2prime
                  | A.False => t3prime
                  | A.Exn s => A.Exn s
                  | _ => raise Fail "Non-bool in if conditional"
              )
            end
        | A.Lt (t1, t2) =>
            let
              val t1prime = eval t1
              val t2prime = eval t2
              val tprime = (t1prime, t2prime)
            in
              (case tprime
                 of (A.Nat n1, A.Nat n2) => if n1 < n2 then A.True else A.False
                  | (A.Real r1, A.Real r2) => if r1 < r2 then A.True else
                    A.False
                  | (A.Exn s, _) => A.Exn s
                  | (_, A.Exn s) => A.Exn s
                  | _ => raise Fail "Lting invalid terms"
              )
            end
        | A.Gt (t1, t2) =>
            let
              val t1prime = eval t1
              val t2prime = eval t2
              val tprime = (t1prime, t2prime)
            in
              (case tprime
                 of (A.Nat n1, A.Nat n2) => if n1 > n2 then A.True else A.False
                  | (A.Real r1, A.Real r2) => if r1 > r2 then A.True else
                    A.False
                  | (A.Exn s, _) => A.Exn s
                  | (_, A.Exn s) => A.Exn s
                  | _ => raise Fail "Gting invalid terms"
              )
            end
        | A.Concat (t1, t2) =>
            let
              val t1prime = eval t1
              val t2prime = eval t2
              val tprime = (t1prime, t2prime)
            in
              (case tprime
                 of (A.List l1, A.List l2) => A.List (l1 @ l2)
                  | (A.Exn s, _) => A.Exn s
                  | (_, A.Exn s) => A.Exn s
                  | _ => raise Fail "Concatenating non-lists"
              )
            end
        | A.Comp (t1, t2) =>
            let
              val t1prime = eval t1
              val t2prime = eval t2
            in
              (case t2prime
                 of A.List l2 => 
                      (case t1prime
                         of A.Exn s => A.Exn s
                          | _ => A.List (t1prime :: l2)
                      )
                  | A.Exn s => A.Exn s
                  | _ => raise Fail "Comprehending on non-list"
              )
            end
        | A.App (t1, t2) =>
            let
              val t1prime = eval t1
              val t2prime = eval t2
            in
              (case t1prime
                 of A.Lam (x, term) => eval (S.sub (x, t2prime, term))
                  | _ => raise Fail "Applying to non-function"
              )
            end
        | _ => term
    )

end

