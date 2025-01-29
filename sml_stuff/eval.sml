structure Eval : sig
  val eval_gen : AST.term -> AST.term
  val unlet : AST.term -> AST.term
  val unmultilet : AST.term -> AST.term
end = struct
  structure A = AST
  structure S = Subst
  (* TODO: Unmultilet, should take a let statement and turn the multiple lets
   * into nested let expressions 
   * When testing, unmultilet, then type check, then unlet (kinda scuffed tbh
   * but like idk)
   * *)
   (* Also TODO: Refactor parsing so it goes from looking extremely ugly
    * to just slightly repetitive, it's literally the same thing 15 times
    * *)
  fun unmultilet term =
    (case term
       of A.Let (xs, t1, t2) =>
            (case (xs, t1)
               of (AST.List vrnms, AST.List vls) =>
                    (case (vrnms, vls)
                       of ([], []) => t2
                        | (name :: rest1, []) =>
                            raise Fail "More names given than assigned"
                        | ([], vlu :: rest2) =>
                            raise Fail "More variables set without name"
                        | (name :: restnms, vlu :: restvals) =>
                            (A.Let(name, vlu,
                            unmultilet (A.Let(A.List restnms, A.List restvals,
                            t2))))
                    )
                | _ => raise Fail "Variable assignment invalid"
            )
        | _ => term
    )
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
  fun binor l1 l2 =
    (case (l1, l2)
       of (a1 :: rest1, a2 :: rest2) =>
            (case (a1, a2)
               of (A.Nat n1, A.Nat n2) =>
                    if (n1 mod 2) = 1 orelse (n2 mod 2) = 1 then
                      (A.Nat 1 :: binor rest1 rest2)
                    else
                      (A.Nat 0 :: binor rest1 rest2)
                | _ => raise Fail "Invalid list"
            )
        | _ => []
    )
  fun binand l1 l2 =
    (case (l1, l2)
       of (a1 :: rest1, a2 :: rest2) =>
            (case (a1, a2)
               of (A.Nat n1, A.Nat n2) =>
                    if (n1 mod 2) = 1 andalso (n2 mod 2) = 1 then
                      (A.Nat 1 :: binand rest1 rest2)
                    else
                      (A.Nat 0 :: binand rest1 rest2)
                | _ => raise Fail "Invalid list"
            )
        | _ => []
    )
  fun binmk lsts =
    (case lsts
       of (l1, l2) =>
            let
              val len1 = length l1
              val len2 = length l2
              fun mod2 x = x mod 2
            in
              if len1 < len2 then
                binmk ((A.Nat 0 :: l1), l2)
              else if len1 > len2 then
                binmk (l1, (A.Nat 0 :: l2))
              else
                (l1, l2)
            end
    )
  fun eval_map ( fn_w_lst : AST.term * AST.term ) : AST.term list =
    let
      val func = #1(fn_w_lst)
      val lst = #2(fn_w_lst)
    in
      (case lst
         of A.List l1 =>
              (case l1
                 of [] => []
                  | (t :: rest) =>
                      (A.App (func, t) :: eval_map (func, A.List rest))
              )
         | _ => raise Fail "mapping on non-list"
      )
    end
  fun eval_gen term =
    let fun eval term =
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
          | A.List lst => A.List (eval_list lst)
          | A.Exn e => term
          | A.Char c => term
          | A.Pair (l1, r2) =>
              let
                val v1 = eval l1
                val v2 = eval r2
              in
                AST.Pair(v1, v2)
              end
          | A.Fst (p1) =>
              let
                val v1 = eval p1
              in
                (case v1
                   of AST.Pair (v1, v2) => v1
                    | _ => raise Fail "Fst of non-pair"
                )
              end
          | A.Snd (p1) =>
              let
                val v1 = eval p1
              in
                (case v1
                   of AST.Pair (v1, v2) => v2
                    | _ => raise Fail "Snd of non-pair"
                )
              end
          | A.Lam (x, typ, t1) => term
          | A.Var s => term
          | A.Binor (l1, l2) => 
              (case (l1, l2)
                 of (AST.List lst1, AST.List lst2) =>
                      let
                        val new_lists = binmk (lst1, lst2)
                        val list1 = #1(new_lists)
                        val list2 = #2(new_lists)
                      in
                        AST.List (binor list1 list2)
                      end
                  | _ => raise Fail "invalid Binor terms given"
              )
          | A.Binand (l1, l2) =>
              (case (l1, l2)
                 of (AST.List lst1, AST.List lst2) =>
                      let
                        val new_lists = binmk (lst1, lst2)
                        val list1 = #1(new_lists)
                        val list2 = #2(new_lists)
                      in
                        AST.List (binand list1 list2)
                      end
                  | _ => raise Fail "invalid Binand terms given"
              )
          | A.Map (t1, t2) =>
              let
                val res_list = eval_map (t1, t2)
              in
                eval (AST.List res_list)
              end
          | A.Filter (t1, t2) =>
              (case t2
                 of A.List tlist =>
                      let
                        val filtered_list = eval_filter (t1, tlist)
                      in
                        eval (A.List filtered_list)
                      end
                | _ => raise Fail "filtering non-list"
              )
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
    and eval_list term_list =
      (case term_list
         of [] => []
          | (t :: rest) => (eval t :: eval_list rest)
      )
    and eval_filter (term_list : (A.term * A.term list)) : A.term list =
      let
        val func = #1(term_list)
        val tlist = #2(term_list)
      in
        (case tlist
           of [] => []
            | (trm :: rest) =>
                let
                  val res = eval (A.App (func, trm))
                in
                  (case res
                     of A.True => (trm :: eval_filter (func, rest))
                      | A.False => eval_filter (func, rest)
                      | _ => raise Fail "Non-boolean function for filter"
                  )
                end
        )
      end
    in
      eval term
    end
end

