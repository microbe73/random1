structure Parse : sig

   val nextTerm : LexicalToken.token list -> (AST.term * LexicalToken.token list) option
   val parse    : LexicalToken.token list -> AST.term

end = struct

  structure T = LexicalToken
  structure A = AST
(*todo: Add list parsing, test it*)
   fun nextTerm tList =
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
         | _ => raise Fail "unable to parse tokens (no list parsing yet)"
      )
   fun parse tList =
      let 
          val res : (AST.term * LexicalToken.token list) option = nextTerm tList
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
