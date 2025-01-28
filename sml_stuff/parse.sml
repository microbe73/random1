structure Parse : sig
   val oneTermParse : LexicalToken.token list -> (AST.term * LexicalToken.token list) option
   val parse : LexicalToken.token list -> AST.term

end = struct

  structure T = LexicalToken
  structure A = AST
  structure Typ = Types

 fun oneTermParse tList =
      let fun parseList (tList : (AST.term * LexicalToken.token list)) : (AST.term * LexicalToken.token list) option =
         let
            val toks = #2(tList)
            val curr_list = #1(tList)
         in
            (case toks
               of (T.RBrac :: rest) => SOME (curr_list, rest)
                | _ => (case nextTerm toks
                          of NONE => raise Fail "Parse error (unbound list)"
                           | SOME (t1, T.Comma :: toks1) =>
                                (case curr_list
                                   of A.List l1 => parseList (A.List (l1 @ [t1]),
                                   toks1)
                                    | _ => raise Fail "Impossible..."
                                 )
                           | SOME (t1, T.RBrac :: toks1) =>
                                (case curr_list
                                   of A.List l1 =>
                                    SOME (A.List (l1 @ [t1]), toks1)
                                    | _ => raise Fail "Implausible..."
                                 )
                           | _ => raise Fail "Parse error: check list commas"
                        )
            )
         end
      and nextType tList =
        (case tList
           of [] => raise Fail "unable to parse Lambda type"
            | (T.Nt :: toks) => SOME (Types.Nat, toks)
            | (T.Rl :: toks) => SOME (Types.Real, toks)
            | (T.Ch :: toks) => SOME (Types.Char, toks)
            | (T.Bl :: toks) => SOME (Types.Bool, toks)
            | (T.Lst :: T.LPar :: toks) =>
                (case nextType toks
                     of NONE => raise Fail "Parse error (unbound List type)"
                      | SOME (t1, T.RPar :: toks1) => SOME (Types.List(t1), toks1)
                      | _ => raise Fail "closing parentheses for list type missing"
                )
            | (T.Fn :: T.LPar :: toks) =>
                (case nextType toks
                     of NONE => raise Fail "Parse error (unbound function type)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextType toks1
                             of NONE => raise Fail "Parse error (fn type second term)"
                              | SOME (t2, T.RPar :: toks2) => SOME (Types.Func(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (fn second term)"
                  )
            | _ => raise Fail "Unable to parse Lambda type"
          )
      and nextTerm2 (op_w_toks : (A.term * A.term -> A.term) * T.token list) :
        A.term * T.token list  =
        let
          val oper = #1(op_w_toks)
          val toks = #2(op_w_toks)
        in
          (case nextTerm toks
             of NONE => raise Fail "Parse error (unbound dyad)"
              | SOME (t1, T.Comma :: toks1) =>
                  (case nextTerm toks1
                     of NONE => raise Fail "Parse error (dyad second term)"
                      | SOME (t2, T.RPar :: toks2) => (oper (t1, t2), toks2)
                      | _ => raise Fail "Pars error (closing parentheses)"
                  )
              | _ => raise Fail "Parse error (dyad second term)"
          )
        end
      and nextTerm tList =
        (case tList
           of [] => NONE
            | (T.True :: toks) => SOME (A.True, toks)
            | (T.False :: toks) => SOME (A.False, toks)
            | (T.Nat n :: toks) => SOME (A.Nat n, toks)
            | (T.Char c :: toks) => SOME (A.Char c, toks)
            | (T.Real r :: toks) => SOME (A.Real r, toks)
            | (T.Sub :: T.LPar :: toks) =>
                SOME (nextTerm2 (A.Sub, toks))
            | (T.Or :: T.LPar :: toks) => 
                  (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound Or)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (Or second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.Or(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (Or second term)"
                    )
            | (T.Pair :: T.LPar :: toks) => 
                  (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound Pair)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (Pair second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.Pair(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (Pair second term)"
                    )
            | (T.If :: T.LPar :: toks) =>
               (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound If)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (If second term) "
                              | SOME (t2, T.Comma :: toks2) => 
                                   (case nextTerm toks2
                                      of NONE => raise Fail
                                      "Parse error (If third term)"
                                       | SOME (t3, T.RPar :: toks3) =>
                                            SOME (A.If(t1, t2, t3), toks3)
                                       | _ => raise Fail 
                                       "Par error (closing parentheses)"
                                    )
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (If second term)"
                  )
            (*
             * Get this for free with pairs!
            | (T.Let :: T.LPar :: T.LBrac :: toks) =>
                (case (parseList (A.List [], toks))
                  of NONE => raise Fail "Parse error (unbound Let)"
                    | SOME (t1, T.Comma :: toks1) =>
                        (case nextTerm toks1
                           of NONE => raise Fail "Parse error (Let third term)"
                            | SOME (t2, T.Comma :: toks2) =>
                                (case nextTerm toks2
                                   of NONE => raise Fail
                                   "Parse error (Let third term)"
                                    | SOME (t3, T.RPar :: toks3) =>
                                        SOME (A.Let (t1, t2, t3), toks3)
                                    | _ => raise Fail
                                    "Par error (closing parentheses)"
                                  )
                            | _ => raise Fail "Pars error (closing parentheses)"
                        )
                    | _ => raise Fail "Parse error (closing parentheses)"
                )
            *)
            | (T.Let :: T.LPar :: toks) => 
               (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound let)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (Let second term) "
                              | SOME (t2, T.Comma :: toks2) => 
                                   (case nextTerm toks2
                                      of NONE => raise Fail 
                                      "Parse error (Let third term)"
                                       | SOME (t3, T.RPar :: toks3) =>
                                            SOME (A.Let(t1, t2, t3), toks3)
                                       | _ => raise Fail 
                                       "Par error (closing parentheses)"
                                    )
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (Let second term)"
                  )
            | (T.Mul :: T.LPar :: toks) =>
                   (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound Mul)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (Mul second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.Mul(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (Mul second term)"
                    )
            | (T.Div :: T.LPar :: toks) =>
                   (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound Div)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (Div second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.Div(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (Div second term)"
                    )
            | (T.Concat :: T.LPar :: toks) =>
                   (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound Concat)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (Concat second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.Concat(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (Concat second term)"
                    )
            | (T.Comp :: T.LPar :: toks) =>
                   (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound Comp)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (Comp second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.Comp(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (Comp second term)"
                    )
            | (T.Lt :: T.LPar :: toks) =>
                   (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound Lt)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (Lt second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.Lt(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (Lt second term)"
                    )
            | (T.Gt :: T.LPar :: toks) =>
                   (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound Gt)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (Gt second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.Gt(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (Gt second term)"
                    )
            | (T.Add :: T.LPar :: toks) =>
                  (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound add)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (add second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.Add(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (add second term)"
                    )

            | (T.And :: T.LPar :: toks) =>
                  (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound and)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (and second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.And(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (and second term)"
                    )
            | (T.Head :: T.LPar :: toks) =>
                  (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound Head)"
                      | SOME (t1, T.RPar :: toks1) => SOME (A.Head(t1), toks1)
                      | _ => raise Fail "closing parentheses for head missing"
                    )
            | (T.FRead :: T.LPar :: toks) =>
                  (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound FRead)"
                      | SOME (t1, T.RPar :: toks1) => SOME (A.FRead(t1), toks1)
                      | _ => raise Fail "closing parentheses for FRead missing"
                    )
            | (T.LBrac :: toks) => parseList (A.List [], toks)
            | (T.Var c :: toks) => SOME (A.Var c, toks)
            | (T.Lam :: T.LPar :: toks) =>
                  (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound lambda)"
                      | SOME (A.Var x, T.Comma :: toks1) =>
                          (case nextType toks1
                             of NONE => raise Fail "Parse error (lam second term) "
                              | SOME (t2, T.Comma :: toks2) => 
                                  (case nextTerm toks2
                                     of NONE => raise Fail
                                     "Parse error (lam third term)"
                                      | SOME (t3, T.RPar :: toks3) =>
                                          SOME (A.Lam(x, t2, t3), toks3)
                                      | _ => raise Fail "Parse error closing par"
                                  )
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (lam first term)"
                    )
            | (T.App :: T.LPar :: toks) =>
                  (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound app)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (app second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.App(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (app second term)"
                    )
            | (T.Binor :: T.LPar :: toks) => 
                  (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound Binor)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (Binor second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.Binor(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (Binor second term)"
                    )
            | (T.Binand :: T.LPar :: toks) => 
                  (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound Binand)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (Binand second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.Binand(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (Binand second term)"
                    )
            | (T.Map :: T.LPar :: toks) =>
                  (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound Map)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (Map second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.Map(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (Map second term)"
                    )
            | (T.Filter :: T.LPar :: toks) =>
                  (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound filter)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (filter second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.Filter(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (filter second term)"
                    )
            | _ => raise Fail "unable to parse tokens "
         )
      in
         nextTerm tList
      end
   fun parse tList =
      let 
          val res : (AST.term * LexicalToken.token list) option = oneTermParse tList
        in
          (case res
             of NONE => raise Fail "Parse error"
              | SOME (astTerm, tList) =>
                   (case tList
                      of [] => astTerm
                       | _ => raise Fail "parse")
          )
        end

      end
