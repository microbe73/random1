structure Parse : sig
   val oneTermParse : LexicalToken.token list -> (AST.term * LexicalToken.token list) option
   val parse : LexicalToken.token list -> AST.term

end = struct

  structure T = LexicalToken
  structure A = AST
(*todo: test it, but it compiles and its SML so like it probably works *)
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
            | _ => raise Fail "unable to parse tokens (no list parsing yet)"
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
