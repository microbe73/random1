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
      and nextTerm1 (op_w_toks : (A.term -> A.term) * T.token list) :
        A.term * T.token list =
        let
          val oper = #1(op_w_toks)
          val toks = #2(op_w_toks)
        in
          (case nextTerm toks
             of NONE => raise Fail "Parse error (unbound monad)"
              | SOME (t1, T.RPar :: toks1) => (oper t1, toks1)
              | _ => raise Fail "Parse error (monad closing parentheses)"
          )
        end
      and nextTerm3 (op_w_toks : (A.term * A.term * A.term -> A.term) * T.token
        list) : A.term * T.token list =
        let
          val oper = #1(op_w_toks)
          val toks = #2(op_w_toks)
        in
          (case nextTerm toks
             of NONE => raise Fail "Parse error (unbound triad)"
              | SOME (t1, T.Comma :: toks1) =>
                  (case nextTerm toks1
                     of NONE => raise Fail "Parse error (triad second term) "
                      | SOME (t2, T.Comma :: toks2) =>
                           (case nextTerm toks2
                              of NONE => raise Fail
                              "Parse error (triad third term)"
                               | SOME (t3, T.RPar :: toks3) =>
                                    (oper(t1, t2, t3), toks3)
                               | _ => raise Fail
                               "Par error (closing parentheses)"
                            )
                      | _ => raise Fail "Pars error (closing parentheses)"
                  )
              | _ => raise Fail "Parse error (triad second term)"
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
                  SOME (nextTerm2 (A.Or, toks))
            | (T.Pair :: T.LPar :: toks) => 
                  SOME (nextTerm2 (A.Pair, toks))
            | (T.Fst :: T.LPar :: toks) =>
                  SOME (nextTerm1 (A.Fst, toks))
            | (T.Snd :: T.LPar :: toks) =>
                  SOME (nextTerm1 (A.Snd, toks))
            | (T.If :: T.LPar :: toks) =>
                  SOME (nextTerm3 (A.If, toks))
            | (T.Let :: T.LPar :: toks) =>
                  SOME (nextTerm3 (A.Let, toks))
            | (T.Mul :: T.LPar :: toks) =>
                  SOME (nextTerm2 (A.Mul, toks))
            | (T.Div :: T.LPar :: toks) =>
                  SOME (nextTerm2 (A.Div, toks))
            | (T.Concat :: T.LPar :: toks) =>
                  SOME (nextTerm2 (A.Concat, toks))
            | (T.Comp :: T.LPar :: toks) =>
                  SOME (nextTerm2 (A.Comp, toks))
            | (T.Lt :: T.LPar :: toks) =>
                  SOME (nextTerm2 (A.Lt, toks))
            | (T.Gt :: T.LPar :: toks) =>
                  SOME (nextTerm2 (A.Gt, toks))
            | (T.Add :: T.LPar :: toks) =>
                  SOME (nextTerm2 (A.Add, toks))
            | (T.And :: T.LPar :: toks) =>
                  SOME (nextTerm2 (A.And, toks))
            | (T.Head :: T.LPar :: toks) =>
                  SOME (nextTerm1 (A.Head, toks))
            | (T.FRead :: T.LPar :: toks) =>
                  SOME (nextTerm1 (A.FRead, toks))
            | (T.LBrac :: toks) => parseList (A.List [], toks)
            | (T.Var c :: toks) => SOME (A.Var c, toks)
            | (T.App :: T.LPar :: toks) =>
                  SOME (nextTerm2 (A.App, toks))
            | (T.Binor :: T.LPar :: toks) => 
                  SOME (nextTerm2 (A.Binor, toks))
            | (T.Binand :: T.LPar :: toks) => 
                  SOME (nextTerm2 (A.Binand, toks))
            | (T.Map :: T.LPar :: toks) =>
                  SOME (nextTerm2 (A.Map, toks))
            | (T.Filter :: T.LPar :: toks) =>
                  SOME (nextTerm2 (A.Filter, toks))
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
