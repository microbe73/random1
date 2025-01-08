structure Eval : sig
  val eval : AST.term -> AST.term
  val unlet : AST.term -> AST.term
end = struct
  structure A = AST
  structure S = Subst
  fun unlet term =
    (case term
       of A.Let(x, t1, t2) =>
            let
              val t2prime = unlet t2
              val t1prime = unlet t1
              val typ = TypeCheck.check_term t1prime
            in
              (case x
                 of A.Var s => A.App (A.Lam (s, typ, t2prime), t1prime)
                  | _ => raise Fail "Non-variable assigned to let expression"
              )
            end
        | _ => term (* means that let expressions are not allowed unless they
        are the top level expressions which I suppose is fine *)
    )
  fun trm_to_clist trm =
    (case trm
       of A.List l1 =>
            (case l1
               of (c :: rest) =>
                    (case c
                       of A.Char c1 => ([c1] @ (trm_to_clist (A.List rest)))
                        | _ => raise Fail "non-name given"
                    )
                | [] => []
            )
        | _ => raise Fail "non-name given"
    )
  fun readin filestream = explode (TextIO.inputAll filestream)
  fun clist_to_trm clist =
    (case clist
       of [] => []
        | (c :: rest) => [AST.Char c] @ clist_to_trm rest
    )


    
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
                 of A.Lam (x, typ, term) => eval (S.sub (x, t2prime, term))
                  | _ => raise Fail "Applying to non-function"
              )
            end
        | A.Let (x, t1, t2) =>
            let
              val t1prime = eval t1
            in
              (case x
                 of A.Var s => eval (S.sub (s, t1prime, t2))
                  | _ => raise Fail "Let expression assigned to non-variable"
              )
            end
        | A.True => term
        | A.Nat n => term
        | A.False => term
        | A.Real r => term
        | A.List lst => term
        | A.Exn e => term
        | A.Char c => term
        | A.Lam (x, typ, t1) => term
        | A.Var s => term
        | A.FRead fnam =>
            let
              val fname = eval fnam
              val filename = implode (trm_to_clist fname)
              val filestream = TextIO.openIn(filename)
              val fileout = readin filestream
            in
              AST.List (clist_to_trm fileout)
            end handle IO.Io info => AST.Exn "Error opening file (check the name)"

    )

end

