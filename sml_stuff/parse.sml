structure Parse : sig
   val oneTermParse : LexicalToken.token list -> (AST.term * LexicalToken.token list) option
   val parse : LexicalToken.token list -> AST.term

end = struct

  structure T = LexicalToken
  structure A = AST

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
      and nextTerm tList =
        (case tList
           of [] => NONE
            | (T.True :: toks) => SOME (A.True, toks)
            | (T.False :: toks) => SOME (A.False, toks)
            | (T.Nat n :: toks) => SOME (A.Nat n, toks)
            | (T.Char c :: toks) => SOME (A.Char c, toks)
            | (T.Real r :: toks) => SOME (A.Real r, toks)
            | (T.Sub :: T.LPar :: toks) => 
                 (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound sub)"
                      | SOME (t1, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (sub second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.Sub(t1,t2), toks2)
                              | _ => raise Fail "Pars error (closing parentheses)"
                          )
                      | _ => raise Fail "Parse error (sub second term)"
                    )
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
            | (T.LBrac :: toks) => parseList (A.List [], toks)
            | (T.Var c :: toks) => SOME (A.Var c, toks)
            | (T.Lam :: T.LPar :: toks) =>
                  (case nextTerm toks
                     of NONE => raise Fail "Parse error (unbound lambda)"
                      | SOME (A.Var x, T.Comma :: toks1) =>
                          (case nextTerm toks1
                             of NONE => raise Fail "Parse error (lam second term) "
                              | SOME (t2, T.RPar :: toks2) => SOME (A.Lam(x,t2), toks2)
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
